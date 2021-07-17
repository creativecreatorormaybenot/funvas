// The implementation in this file is based on KdotJPG's implementation here: https://github.com/KdotJPG/OpenSimplex2/blob/a186b9bb644747c936d7cba748d11f28b1cee66e/java/OpenSimplex2F.java.

import 'dart:typed_data';

import 'package:open_simplex_2/src/fast_floor.dart';
import 'package:open_simplex_2/src/grad.dart';

const _kN2 = 0.01001634121365712;
const _kN3 = 0.030485933181293584;
const _kN4 = 0.009202377986303158;
const _kSize = 2048;
const _kMask = 2047;

/// K.jpg's OpenSimplex 2, faster variant.
///
/// - 2D is standard simplex implemented using a lookup table.
/// - 3D is "Re-oriented 4-point BCC noise" which constructs a
///   congruent BCC lattice in a much different way than usual.
/// - 4D constructs the lattice as a union of five copies of its
///   reciprocal. It successively finds the closest point on each.
///
/// Multiple versions of each function are provided. See the documentation for
/// each for more info.
class OpenSimplex2F {
  /// Creates a seeded [OpenSimplex2F] that can be used to evaluate noise.
  OpenSimplex2F(int seed) {
    if (!_staticInitialized) {
      _statInit();
      _staticInitialized = true;
    }

    final source = Int16List(_kSize);
    for (int i = 0; i < _kSize; i++) {
      source[i] = i;
    }
    for (int i = _kSize - 1; i >= 0; i--) {
      // KdotJPG's implementation uses Java's long here. int in Dart has the
      // same size, however, JavaScript (when running on web) does not allow for
      // int literals this big, which is why we need to use int.parse.
      seed = seed * int.parse('6364136223846793005') +
          int.parse('1442695040888963407');
      var r = (seed + 31) % (i + 1);
      if (r < 0) r += i + 1;
      _perm[i] = source[r];
      _permGrad2[i] = _gradients2d[_perm[i]];
      _permGrad3[i] = _gradients3d[_perm[i]];
      _permGrad4[i] = _gradients4d[_perm[i]];
      source[r] = source[i];
    }
  }

  final _perm = Int16List(_kSize);
  final _permGrad2 = List.filled(_kSize, const Grad2(0, 0));
  final _permGrad3 = List.filled(_kSize, const Grad3(0, 0, 0));
  final _permGrad4 = List.filled(_kSize, const Grad4(0, 0, 0, 0));

  // Noise evaluators

  /// 2D Simplex noise, standard lattice orientation.
  double noise2(double x, double y) {
    // Get points for A2* lattice
    final s = 0.366025403784439 * (x + y);
    final xs = x + s, ys = y + s;

    return _noise2Base(xs, ys);
  }

  /// 2D Simplex noise, with Y pointing down the main diagonal.
  ///
  /// Might be better for a 2D sandbox style game, where Y is vertical.
  /// Probably slightly less optimal for heightmaps or continent maps.
  double noise2XBeforeY(double x, double y) {
    // Skew transform and rotation baked into one.
    final xx = x * 0.7071067811865476;
    final yy = y * 1.224744871380249;

    return _noise2Base(yy + xx, yy - xx);
  }

  /// 2D Simplex noise base.
  ///
  /// Lookup table implementation inspired by DigitalShadow.
  double _noise2Base(double xs, double ys) {
    double value = 0;

    // Get base points and offsets
    int xsb = fastFloor(xs), ysb = fastFloor(ys);
    double xsi = xs - xsb, ysi = ys - ysb;

    // Index to point list
    final index = ((ysi - xsi) / 2 + 1).toInt();

    double ssi = (xsi + ysi) * -0.211324865405187;
    double xi = xsi + ssi, yi = ysi + ssi;

    // Point contributions
    for (int i = 0; i < 3; i++) {
      _LatticePoint2D c = _lookup2d[index + i];

      double dx = xi + c.dx, dy = yi + c.dy;
      double attn = 0.5 - dx * dx - dy * dy;
      if (attn <= 0) continue;

      int pxm = (xsb + c.xsv) & _kMask, pym = (ysb + c.ysv) & _kMask;
      Grad2 grad = _permGrad2[_perm[pxm] ^ pym];
      double extrapolation = grad.dx * dx + grad.dy * dy;

      attn *= attn;
      value += attn * attn * extrapolation;
    }

    return value;
  }

  /// 3D Re-oriented 4-point BCC noise, classic orientation.
  ///
  /// Proper substitute for 3D Simplex in light of Forbidden Formulae.
  /// Use noise3XYBeforeZ or noise3XZBeforeY instead, wherever appropriate.
  double noise3Classic(double x, double y, double z) {
    // Re-orient the cubic lattices via rotation, to produce the expected look on cardinal planar slices.
    // If texturing objects that don't tend to have cardinal plane faces, you could even remove this.
    // Orthonormal rotation. Not a skew transform.
    double r = (2.0 / 3.0) * (x + y + z);
    double xr = r - x, yr = r - y, zr = r - z;

    // Evaluate both lattices to form a BCC lattice.
    return _noise3BCC(xr, yr, zr);
  }

  /// 3D Re-oriented 4-point BCC noise, with better visual isotropy in (X, Y).
  ///
  /// Recommended for 3D terrain and time-varied animations.
  /// The Z coordinate should always be the "different" coordinate in your use case.
  /// If Y is vertical in world coordinates, call noise3XYBeforeZ(x, z, Y) or use noise3XZBeforeY.
  /// If Z is vertical in world coordinates, call noise3XYBeforeZ(x, y, Z).
  /// For a time varied animation, call noise3XYBeforeZ(x, y, T).
  double noise3XYBeforeZ(double x, double y, double z) {
    // Re-orient the cubic lattices without skewing, to make X and Y triangular like 2D.
    // Orthonormal rotation. Not a skew transform.
    double xy = x + y;
    double s2 = xy * -0.211324865405187;
    double zz = z * 0.577350269189626;
    double xr = x + s2 - zz, yr = y + s2 - zz;
    double zr = xy * 0.577350269189626 + zz;

    // Evaluate both lattices to form a BCC lattice.
    return _noise3BCC(xr, yr, zr);
  }

  /// 3D Re-oriented 4-point BCC noise, with better visual isotropy in (X, Z).
  ///
  /// Recommended for 3D terrain and time-varied animations.
  /// The Y coordinate should always be the "different" coordinate in your use case.
  /// If Y is vertical in world coordinates, call noise3XZBeforeY(x, Y, z).
  /// If Z is vertical in world coordinates, call noise3XZBeforeY(x, Z, y) or use noise3XYBeforeZ.
  /// For a time varied animation, call noise3XZBeforeY(x, T, y) or use noise3XYBeforeZ.
  double noise3XZBeforeY(double x, double y, double z) {
    // Re-orient the cubic lattices without skewing, to make X and Z triangular like 2D.
    // Orthonormal rotation. Not a skew transform.
    double xz = x + z;
    double s2 = xz * -0.211324865405187;
    double yy = y * 0.577350269189626;
    double xr = x + s2 - yy;
    double zr = z + s2 - yy;
    double yr = xz * 0.577350269189626 + yy;

    // Evaluate both lattices to form a BCC lattice.
    return _noise3BCC(xr, yr, zr);
  }

  /// Generate overlapping cubic lattices for 3D Re-oriented BCC noise.
  ///
  /// Lookup table implementation inspired by DigitalShadow.
  /// It was actually faster to narrow down the points in the loop itself,
  /// than to build up the index with enough info to isolate 4 points.
  double _noise3BCC(double xr, double yr, double zr) {
    // Get base and offsets inside cube of first lattice.
    int xrb = fastFloor(xr), yrb = fastFloor(yr), zrb = fastFloor(zr);
    double xri = xr - xrb, yri = yr - yrb, zri = zr - zrb;

    // Identify which octant of the cube we're in. This determines which cell
    // in the other cubic lattice we're in, and also narrows down one point on each.
    int xht = (xri + 0.5).toInt(),
        yht = (yri + 0.5).toInt(),
        zht = (zri + 0.5).toInt();
    int index = (xht << 0) | (yht << 1) | (zht << 2);

    // Point contributions
    double value = 0;
    _LatticePoint3D? c = _lookup3d[index];
    while (c != null) {
      double dxr = xri + c.dxr, dyr = yri + c.dyr, dzr = zri + c.dzr;
      double attn = 0.5 - dxr * dxr - dyr * dyr - dzr * dzr;
      if (attn < 0) {
        c = c.nextOnFailure;
      } else {
        int pxm = (xrb + c.xrv) & _kMask,
            pym = (yrb + c.yrv) & _kMask,
            pzm = (zrb + c.zrv) & _kMask;
        Grad3 grad = _permGrad3[_perm[_perm[pxm] ^ pym] ^ pzm];
        double extrapolation = grad.dx * dxr + grad.dy * dyr + grad.dz * dzr;

        attn *= attn;
        value += attn * attn * extrapolation;
        c = c.nextOnSuccess;
      }
    }
    return value;
  }

  /// 4D OpenSimplex2F noise, classic lattice orientation.
  double noise4Classic(double x, double y, double z, double w) {
    // Get points for A4 lattice
    double s = -0.138196601125011 * (x + y + z + w);
    double xs = x + s, ys = y + s, zs = z + s, ws = w + s;

    return _noise4Base(xs, ys, zs, ws);
  }

  /// 4D OpenSimplex2F noise, with XY and ZW forming orthogonal triangular-based
  /// planes.
  ///
  /// Recommended for 3D terrain, where X and Y (or Z and W) are horizontal.
  /// Recommended for noise(x, y, sin(time), cos(time)) trick.
  double noise4XYBeforeZW(double x, double y, double z, double w) {
    double s2 =
        (x + y) * -0.178275657951399372 + (z + w) * 0.215623393288842828;
    double t2 =
        (z + w) * -0.403949762580207112 + (x + y) * -0.375199083010075342;
    double xs = x + s2, ys = y + s2, zs = z + t2, ws = w + t2;

    return _noise4Base(xs, ys, zs, ws);
  }

  /// 4D OpenSimplex2F noise, with XZ and YW forming orthogonal triangular-based
  /// planes.
  ///
  /// Recommended for 3D terrain, where X and Z (or Y and W) are horizontal.
  double noise4XZBeforeYW(double x, double y, double z, double w) {
    double s2 =
        (x + z) * -0.178275657951399372 + (y + w) * 0.215623393288842828;
    double t2 =
        (y + w) * -0.403949762580207112 + (x + z) * -0.375199083010075342;
    double xs = x + s2, ys = y + t2, zs = z + s2, ws = w + t2;

    return _noise4Base(xs, ys, zs, ws);
  }

  /// 4D OpenSimplex2F noise, with XYZ oriented like noise3Classic,
  /// and W for an extra degree of freedom. W repeats eventually.
  ///
  /// Recommended for time-varied animations which texture a 3D object (W=time)
  double noise4XYZBeforeW(double x, double y, double z, double w) {
    double xyz = x + y + z;
    double ww = w * 0.2236067977499788;
    double s2 = xyz * -0.16666666666666666 + ww;
    double xs = x + s2, ys = y + s2, zs = z + s2, ws = -0.5 * xyz + ww;

    return _noise4Base(xs, ys, zs, ws);
  }

  /// 4D OpenSimplex2F noise base.
  ///
  /// Current implementation not fully optimized by lookup tables.
  /// But still comes out slightly ahead of Gustavson's Simplex in tests.
  double _noise4Base(double xs, double ys, double zs, double ws) {
    double value = 0;

    // Get base points and offsets
    int xsb = fastFloor(xs),
        ysb = fastFloor(ys),
        zsb = fastFloor(zs),
        wsb = fastFloor(ws);
    double xsi = xs - xsb, ysi = ys - ysb, zsi = zs - zsb, wsi = ws - wsb;

    // If we're in the lower half, flip so we can repeat the code for the upper half. We'll flip back later.
    double siSum = xsi + ysi + zsi + wsi;
    double ssi = siSum * 0.309016994374947; // Prep for vertex contributions.
    final inLowerHalf = (siSum < 2);
    if (inLowerHalf) {
      xsi = 1 - xsi;
      ysi = 1 - ysi;
      zsi = 1 - zsi;
      wsi = 1 - wsi;
      siSum = 4 - siSum;
    }

    // Consider opposing vertex pairs of the octahedron formed by the central cross-section of the stretched tesseract
    double aabb = xsi + ysi - zsi - wsi,
        abab = xsi - ysi + zsi - wsi,
        abba = xsi - ysi - zsi + wsi;
    double aabbScore = aabb.abs(),
        ababScore = abab.abs(),
        abbaScore = abba.abs();

    // Find the closest point on the stretched tesseract as if it were the upper half
    int vertexIndex, via, vib;
    double asi, bsi;
    if (aabbScore > ababScore && aabbScore > abbaScore) {
      if (aabb > 0) {
        asi = zsi;
        bsi = wsi;
        vertexIndex = int.parse('0011', radix: 2);
        via = int.parse('0111', radix: 2);
        vib = int.parse('1011', radix: 2);
      } else {
        asi = xsi;
        bsi = ysi;
        vertexIndex = int.parse('1100', radix: 2);
        via = int.parse('1101', radix: 2);
        vib = int.parse('1110', radix: 2);
      }
    } else if (ababScore > abbaScore) {
      if (abab > 0) {
        asi = ysi;
        bsi = wsi;
        vertexIndex = int.parse('0101', radix: 2);
        via = int.parse('0111', radix: 2);
        vib = int.parse('1101', radix: 2);
      } else {
        asi = xsi;
        bsi = zsi;
        vertexIndex = int.parse('1010', radix: 2);
        via = int.parse('1011', radix: 2);
        vib = int.parse('1110', radix: 2);
      }
    } else {
      if (abba > 0) {
        asi = ysi;
        bsi = zsi;
        vertexIndex = int.parse('1001', radix: 2);
        via = int.parse('1011', radix: 2);
        vib = int.parse('1101', radix: 2);
      } else {
        asi = xsi;
        bsi = wsi;
        vertexIndex = int.parse('0110', radix: 2);
        via = int.parse('0111', radix: 2);
        vib = int.parse('1110', radix: 2);
      }
    }
    if (bsi > asi) {
      via = vib;
      double temp = bsi;
      bsi = asi;
      asi = temp;
    }
    if (siSum + asi > 3) {
      vertexIndex = via;
      if (siSum + bsi > 4) {
        vertexIndex = int.parse('1111', radix: 2);
      }
    }

    // Now flip back if we're actually in the lower half.
    if (inLowerHalf) {
      xsi = 1 - xsi;
      ysi = 1 - ysi;
      zsi = 1 - zsi;
      wsi = 1 - wsi;
      vertexIndex ^= int.parse('1111', radix: 2);
    }

    // Five points to add, total, from five copies of the A4 lattice.
    for (int i = 0; i < 5; i++) {
      // Update xsb/etc. and add the lattice point's contribution.
      _LatticePoint4D c = _vertices4d[vertexIndex];
      xsb += c.xsv;
      ysb += c.ysv;
      zsb += c.zsv;
      wsb += c.wsv;
      double xi = xsi + ssi, yi = ysi + ssi, zi = zsi + ssi, wi = wsi + ssi;
      double dx = xi + c.dx, dy = yi + c.dy, dz = zi + c.dz, dw = wi + c.dw;
      double attn = 0.5 - dx * dx - dy * dy - dz * dz - dw * dw;
      if (attn > 0) {
        int pxm = xsb & _kMask,
            pym = ysb & _kMask,
            pzm = zsb & _kMask,
            pwm = wsb & _kMask;
        Grad4 grad = _permGrad4[_perm[_perm[_perm[pxm] ^ pym] ^ pzm] ^ pwm];
        double ramped =
            grad.dx * dx + grad.dy * dy + grad.dz * dz + grad.dw * dw;

        attn *= attn;
        value += attn * attn * ramped;
      }

      // Maybe this helps the compiler/JVM/LLVM/etc. know we can end the loop here. Maybe not.
      if (i == 4) break;

      // Update the relative skewed coordinates to reference the vertex we just added.
      // Rather, reference its counterpart on the lattice copy that is shifted down by
      // the vector <-0.2, -0.2, -0.2, -0.2>
      xsi += c.xsi;
      ysi += c.ysi;
      zsi += c.zsi;
      wsi += c.wsi;
      ssi += c.ssiDelta;

      // Next point is the closest vertex on the 4-simplex whose base vertex is the aforementioned vertex.
      double score0 = 1.0 +
          ssi *
              (-1.0 /
                  0.309016994374947); // Seems slightly faster than 1.0-xsi-ysi-zsi-wsi
      vertexIndex = int.parse('0000', radix: 2);
      if (xsi >= ysi && xsi >= zsi && xsi >= wsi && xsi >= score0) {
        vertexIndex = int.parse('0001', radix: 2);
      } else if (ysi > xsi && ysi >= zsi && ysi >= wsi && ysi >= score0) {
        vertexIndex = int.parse('0010', radix: 2);
      } else if (zsi > xsi && zsi > ysi && zsi >= wsi && zsi >= score0) {
        vertexIndex = int.parse('0100', radix: 2);
      } else if (wsi > xsi && wsi > ysi && wsi > zsi && wsi >= score0) {
        vertexIndex = int.parse('1000', radix: 2);
      }
    }

    return value;
  }

  // Definitions

  static final _lookup2d = const <_LatticePoint2D>[
    _LatticePoint2D(1, 0),
    _LatticePoint2D(0, 0),
    _LatticePoint2D(1, 1),
    _LatticePoint2D(0, 1),
  ];
  static final _lookup3d = List.filled(8, _LatticePoint3D(0, 0, 0, 0));
  static final _vertices4d = List.filled(16, _LatticePoint4D(0, 0, 0, 0));

  static final _gradients2d = <Grad2>[];
  static final _gradients3d = <Grad3>[];
  static final _gradients4d = <Grad4>[];

  static var _staticInitialized = false;

  /// Performs the initilization of all static lookup members.
  ///
  /// This function as well as [_staticInitialized] exist because there is
  /// no comparable concept to static blocks (from Java) in Dart.
  static void _statInit() {
    for (int i = 0; i < 8; i++) {
      int i1, j1, k1, i2, j2, k2;
      i1 = (i >> 0) & 1;
      j1 = (i >> 1) & 1;
      k1 = (i >> 2) & 1;
      i2 = i1 ^ 1;
      j2 = j1 ^ 1;
      k2 = k1 ^ 1;

      // The two points within this octant, one from each of the two cubic half-lattices.
      final c0 = _LatticePoint3D(i1, j1, k1, 0);
      final c1 = _LatticePoint3D(i1 + i2, j1 + j2, k1 + k2, 1);

      // Each single step away on the first half-lattice.
      final c2 = _LatticePoint3D(i1 ^ 1, j1, k1, 0);
      final c3 = _LatticePoint3D(i1, j1 ^ 1, k1, 0);
      final c4 = _LatticePoint3D(i1, j1, k1 ^ 1, 0);

      // Each single step away on the second half-lattice.
      final c5 = _LatticePoint3D(i1 + (i2 ^ 1), j1 + j2, k1 + k2, 1);
      final c6 = _LatticePoint3D(i1 + i2, j1 + (j2 ^ 1), k1 + k2, 1);
      final c7 = _LatticePoint3D(i1 + i2, j1 + j2, k1 + (k2 ^ 1), 1);

      // First two are guaranteed.
      c0.nextOnFailure = c0.nextOnSuccess = c1;
      c1.nextOnFailure = c1.nextOnSuccess = c2;

      // Once we find one on the first half-lattice, the rest are out.
      // In addition, knowing c2 rules out c5.
      c2.nextOnFailure = c3;
      c2.nextOnSuccess = c6;
      c3.nextOnFailure = c4;
      c3.nextOnSuccess = c5;
      c4.nextOnFailure = c4.nextOnSuccess = c5;

      // Once we find one on the second half-lattice, the rest are out.
      c5.nextOnFailure = c6;
      c5.nextOnSuccess = null;
      c6.nextOnFailure = c7;
      c6.nextOnSuccess = null;
      c7.nextOnFailure = c7.nextOnSuccess = null;

      _lookup3d[i] = c0;
    }

    for (int i = 0; i < 16; i++) {
      _vertices4d[i] = _LatticePoint4D(
          (i >> 0) & 1, (i >> 1) & 1, (i >> 2) & 1, (i >> 3) & 1);
    }

    const grad2 = [
      Grad2(0.130526192220052, 0.99144486137381),
      Grad2(0.38268343236509, 0.923879532511287),
      Grad2(0.608761429008721, 0.793353340291235),
      Grad2(0.793353340291235, 0.608761429008721),
      Grad2(0.923879532511287, 0.38268343236509),
      Grad2(0.99144486137381, 0.130526192220051),
      Grad2(0.99144486137381, -0.130526192220051),
      Grad2(0.923879532511287, -0.38268343236509),
      Grad2(0.793353340291235, -0.60876142900872),
      Grad2(0.608761429008721, -0.793353340291235),
      Grad2(0.38268343236509, -0.923879532511287),
      Grad2(0.130526192220052, -0.99144486137381),
      Grad2(-0.130526192220052, -0.99144486137381),
      Grad2(-0.38268343236509, -0.923879532511287),
      Grad2(-0.608761429008721, -0.793353340291235),
      Grad2(-0.793353340291235, -0.608761429008721),
      Grad2(-0.923879532511287, -0.38268343236509),
      Grad2(-0.99144486137381, -0.130526192220052),
      Grad2(-0.99144486137381, 0.130526192220051),
      Grad2(-0.923879532511287, 0.38268343236509),
      Grad2(-0.793353340291235, 0.608761429008721),
      Grad2(-0.608761429008721, 0.793353340291235),
      Grad2(-0.38268343236509, 0.923879532511287),
      Grad2(-0.130526192220052, 0.99144486137381)
    ];
    final grad2Adjusted = [
      for (final grad in grad2) Grad2(grad.dx / _kN2, grad.dy / _kN2),
    ];
    for (int i = 0; i < _kSize; i++) {
      _gradients2d.add(grad2Adjusted[i % grad2.length]);
    }

    const grad3 = [
      Grad3(-2.22474487139, -2.22474487139, -1.0),
      Grad3(-2.22474487139, -2.22474487139, 1.0),
      Grad3(-3.0862664687972017, -1.1721513422464978, 0.0),
      Grad3(-1.1721513422464978, -3.0862664687972017, 0.0),
      Grad3(-2.22474487139, -1.0, -2.22474487139),
      Grad3(-2.22474487139, 1.0, -2.22474487139),
      Grad3(-1.1721513422464978, 0.0, -3.0862664687972017),
      Grad3(-3.0862664687972017, 0.0, -1.1721513422464978),
      Grad3(-2.22474487139, -1.0, 2.22474487139),
      Grad3(-2.22474487139, 1.0, 2.22474487139),
      Grad3(-3.0862664687972017, 0.0, 1.1721513422464978),
      Grad3(-1.1721513422464978, 0.0, 3.0862664687972017),
      Grad3(-2.22474487139, 2.22474487139, -1.0),
      Grad3(-2.22474487139, 2.22474487139, 1.0),
      Grad3(-1.1721513422464978, 3.0862664687972017, 0.0),
      Grad3(-3.0862664687972017, 1.1721513422464978, 0.0),
      Grad3(-1.0, -2.22474487139, -2.22474487139),
      Grad3(1.0, -2.22474487139, -2.22474487139),
      Grad3(0.0, -3.0862664687972017, -1.1721513422464978),
      Grad3(0.0, -1.1721513422464978, -3.0862664687972017),
      Grad3(-1.0, -2.22474487139, 2.22474487139),
      Grad3(1.0, -2.22474487139, 2.22474487139),
      Grad3(0.0, -1.1721513422464978, 3.0862664687972017),
      Grad3(0.0, -3.0862664687972017, 1.1721513422464978),
      Grad3(-1.0, 2.22474487139, -2.22474487139),
      Grad3(1.0, 2.22474487139, -2.22474487139),
      Grad3(0.0, 1.1721513422464978, -3.0862664687972017),
      Grad3(0.0, 3.0862664687972017, -1.1721513422464978),
      Grad3(-1.0, 2.22474487139, 2.22474487139),
      Grad3(1.0, 2.22474487139, 2.22474487139),
      Grad3(0.0, 3.0862664687972017, 1.1721513422464978),
      Grad3(0.0, 1.1721513422464978, 3.0862664687972017),
      Grad3(2.22474487139, -2.22474487139, -1.0),
      Grad3(2.22474487139, -2.22474487139, 1.0),
      Grad3(1.1721513422464978, -3.0862664687972017, 0.0),
      Grad3(3.0862664687972017, -1.1721513422464978, 0.0),
      Grad3(2.22474487139, -1.0, -2.22474487139),
      Grad3(2.22474487139, 1.0, -2.22474487139),
      Grad3(3.0862664687972017, 0.0, -1.1721513422464978),
      Grad3(1.1721513422464978, 0.0, -3.0862664687972017),
      Grad3(2.22474487139, -1.0, 2.22474487139),
      Grad3(2.22474487139, 1.0, 2.22474487139),
      Grad3(1.1721513422464978, 0.0, 3.0862664687972017),
      Grad3(3.0862664687972017, 0.0, 1.1721513422464978),
      Grad3(2.22474487139, 2.22474487139, -1.0),
      Grad3(2.22474487139, 2.22474487139, 1.0),
      Grad3(3.0862664687972017, 1.1721513422464978, 0.0),
      Grad3(1.1721513422464978, 3.0862664687972017, 0.0)
    ];
    final grad3Adjusted = [
      for (final grad in grad3)
        Grad3(
          grad.dx / _kN3,
          grad.dy / _kN3,
          grad.dz / _kN3,
        ),
    ];
    for (int i = 0; i < _kSize; i++) {
      _gradients3d.add(grad3Adjusted[i % grad3.length]);
    }

    const grad4 = [
      Grad4(-0.753341017856078, -0.37968289875261624, -0.37968289875261624,
          -0.37968289875261624),
      Grad4(-0.7821684431180708, -0.4321472685365301, -0.4321472685365301,
          0.12128480194602098),
      Grad4(-0.7821684431180708, -0.4321472685365301, 0.12128480194602098,
          -0.4321472685365301),
      Grad4(-0.7821684431180708, 0.12128480194602098, -0.4321472685365301,
          -0.4321472685365301),
      Grad4(-0.8586508742123365, -0.508629699630796, 0.044802370851755174,
          0.044802370851755174),
      Grad4(-0.8586508742123365, 0.044802370851755174, -0.508629699630796,
          0.044802370851755174),
      Grad4(-0.8586508742123365, 0.044802370851755174, 0.044802370851755174,
          -0.508629699630796),
      Grad4(-0.9982828964265062, -0.03381941603233842, -0.03381941603233842,
          -0.03381941603233842),
      Grad4(-0.37968289875261624, -0.753341017856078, -0.37968289875261624,
          -0.37968289875261624),
      Grad4(-0.4321472685365301, -0.7821684431180708, -0.4321472685365301,
          0.12128480194602098),
      Grad4(-0.4321472685365301, -0.7821684431180708, 0.12128480194602098,
          -0.4321472685365301),
      Grad4(0.12128480194602098, -0.7821684431180708, -0.4321472685365301,
          -0.4321472685365301),
      Grad4(-0.508629699630796, -0.8586508742123365, 0.044802370851755174,
          0.044802370851755174),
      Grad4(0.044802370851755174, -0.8586508742123365, -0.508629699630796,
          0.044802370851755174),
      Grad4(0.044802370851755174, -0.8586508742123365, 0.044802370851755174,
          -0.508629699630796),
      Grad4(-0.03381941603233842, -0.9982828964265062, -0.03381941603233842,
          -0.03381941603233842),
      Grad4(-0.37968289875261624, -0.37968289875261624, -0.753341017856078,
          -0.37968289875261624),
      Grad4(-0.4321472685365301, -0.4321472685365301, -0.7821684431180708,
          0.12128480194602098),
      Grad4(-0.4321472685365301, 0.12128480194602098, -0.7821684431180708,
          -0.4321472685365301),
      Grad4(0.12128480194602098, -0.4321472685365301, -0.7821684431180708,
          -0.4321472685365301),
      Grad4(-0.508629699630796, 0.044802370851755174, -0.8586508742123365,
          0.044802370851755174),
      Grad4(0.044802370851755174, -0.508629699630796, -0.8586508742123365,
          0.044802370851755174),
      Grad4(0.044802370851755174, 0.044802370851755174, -0.8586508742123365,
          -0.508629699630796),
      Grad4(-0.03381941603233842, -0.03381941603233842, -0.9982828964265062,
          -0.03381941603233842),
      Grad4(-0.37968289875261624, -0.37968289875261624, -0.37968289875261624,
          -0.753341017856078),
      Grad4(-0.4321472685365301, -0.4321472685365301, 0.12128480194602098,
          -0.7821684431180708),
      Grad4(-0.4321472685365301, 0.12128480194602098, -0.4321472685365301,
          -0.7821684431180708),
      Grad4(0.12128480194602098, -0.4321472685365301, -0.4321472685365301,
          -0.7821684431180708),
      Grad4(-0.508629699630796, 0.044802370851755174, 0.044802370851755174,
          -0.8586508742123365),
      Grad4(0.044802370851755174, -0.508629699630796, 0.044802370851755174,
          -0.8586508742123365),
      Grad4(0.044802370851755174, 0.044802370851755174, -0.508629699630796,
          -0.8586508742123365),
      Grad4(-0.03381941603233842, -0.03381941603233842, -0.03381941603233842,
          -0.9982828964265062),
      Grad4(-0.6740059517812944, -0.3239847771997537, -0.3239847771997537,
          0.5794684678643381),
      Grad4(-0.7504883828755602, -0.4004672082940195, 0.15296486218853164,
          0.5029860367700724),
      Grad4(-0.7504883828755602, 0.15296486218853164, -0.4004672082940195,
          0.5029860367700724),
      Grad4(-0.8828161875373585, 0.08164729285680945, 0.08164729285680945,
          0.4553054119602712),
      Grad4(-0.4553054119602712, -0.08164729285680945, -0.08164729285680945,
          0.8828161875373585),
      Grad4(-0.5029860367700724, -0.15296486218853164, 0.4004672082940195,
          0.7504883828755602),
      Grad4(-0.5029860367700724, 0.4004672082940195, -0.15296486218853164,
          0.7504883828755602),
      Grad4(-0.5794684678643381, 0.3239847771997537, 0.3239847771997537,
          0.6740059517812944),
      Grad4(-0.3239847771997537, -0.6740059517812944, -0.3239847771997537,
          0.5794684678643381),
      Grad4(-0.4004672082940195, -0.7504883828755602, 0.15296486218853164,
          0.5029860367700724),
      Grad4(0.15296486218853164, -0.7504883828755602, -0.4004672082940195,
          0.5029860367700724),
      Grad4(0.08164729285680945, -0.8828161875373585, 0.08164729285680945,
          0.4553054119602712),
      Grad4(-0.08164729285680945, -0.4553054119602712, -0.08164729285680945,
          0.8828161875373585),
      Grad4(-0.15296486218853164, -0.5029860367700724, 0.4004672082940195,
          0.7504883828755602),
      Grad4(0.4004672082940195, -0.5029860367700724, -0.15296486218853164,
          0.7504883828755602),
      Grad4(0.3239847771997537, -0.5794684678643381, 0.3239847771997537,
          0.6740059517812944),
      Grad4(-0.3239847771997537, -0.3239847771997537, -0.6740059517812944,
          0.5794684678643381),
      Grad4(-0.4004672082940195, 0.15296486218853164, -0.7504883828755602,
          0.5029860367700724),
      Grad4(0.15296486218853164, -0.4004672082940195, -0.7504883828755602,
          0.5029860367700724),
      Grad4(0.08164729285680945, 0.08164729285680945, -0.8828161875373585,
          0.4553054119602712),
      Grad4(-0.08164729285680945, -0.08164729285680945, -0.4553054119602712,
          0.8828161875373585),
      Grad4(-0.15296486218853164, 0.4004672082940195, -0.5029860367700724,
          0.7504883828755602),
      Grad4(0.4004672082940195, -0.15296486218853164, -0.5029860367700724,
          0.7504883828755602),
      Grad4(0.3239847771997537, 0.3239847771997537, -0.5794684678643381,
          0.6740059517812944),
      Grad4(-0.6740059517812944, -0.3239847771997537, 0.5794684678643381,
          -0.3239847771997537),
      Grad4(-0.7504883828755602, -0.4004672082940195, 0.5029860367700724,
          0.15296486218853164),
      Grad4(-0.7504883828755602, 0.15296486218853164, 0.5029860367700724,
          -0.4004672082940195),
      Grad4(-0.8828161875373585, 0.08164729285680945, 0.4553054119602712,
          0.08164729285680945),
      Grad4(-0.4553054119602712, -0.08164729285680945, 0.8828161875373585,
          -0.08164729285680945),
      Grad4(-0.5029860367700724, -0.15296486218853164, 0.7504883828755602,
          0.4004672082940195),
      Grad4(-0.5029860367700724, 0.4004672082940195, 0.7504883828755602,
          -0.15296486218853164),
      Grad4(-0.5794684678643381, 0.3239847771997537, 0.6740059517812944,
          0.3239847771997537),
      Grad4(-0.3239847771997537, -0.6740059517812944, 0.5794684678643381,
          -0.3239847771997537),
      Grad4(-0.4004672082940195, -0.7504883828755602, 0.5029860367700724,
          0.15296486218853164),
      Grad4(0.15296486218853164, -0.7504883828755602, 0.5029860367700724,
          -0.4004672082940195),
      Grad4(0.08164729285680945, -0.8828161875373585, 0.4553054119602712,
          0.08164729285680945),
      Grad4(-0.08164729285680945, -0.4553054119602712, 0.8828161875373585,
          -0.08164729285680945),
      Grad4(-0.15296486218853164, -0.5029860367700724, 0.7504883828755602,
          0.4004672082940195),
      Grad4(0.4004672082940195, -0.5029860367700724, 0.7504883828755602,
          -0.15296486218853164),
      Grad4(0.3239847771997537, -0.5794684678643381, 0.6740059517812944,
          0.3239847771997537),
      Grad4(-0.3239847771997537, -0.3239847771997537, 0.5794684678643381,
          -0.6740059517812944),
      Grad4(-0.4004672082940195, 0.15296486218853164, 0.5029860367700724,
          -0.7504883828755602),
      Grad4(0.15296486218853164, -0.4004672082940195, 0.5029860367700724,
          -0.7504883828755602),
      Grad4(0.08164729285680945, 0.08164729285680945, 0.4553054119602712,
          -0.8828161875373585),
      Grad4(-0.08164729285680945, -0.08164729285680945, 0.8828161875373585,
          -0.4553054119602712),
      Grad4(-0.15296486218853164, 0.4004672082940195, 0.7504883828755602,
          -0.5029860367700724),
      Grad4(0.4004672082940195, -0.15296486218853164, 0.7504883828755602,
          -0.5029860367700724),
      Grad4(0.3239847771997537, 0.3239847771997537, 0.6740059517812944,
          -0.5794684678643381),
      Grad4(-0.6740059517812944, 0.5794684678643381, -0.3239847771997537,
          -0.3239847771997537),
      Grad4(-0.7504883828755602, 0.5029860367700724, -0.4004672082940195,
          0.15296486218853164),
      Grad4(-0.7504883828755602, 0.5029860367700724, 0.15296486218853164,
          -0.4004672082940195),
      Grad4(-0.8828161875373585, 0.4553054119602712, 0.08164729285680945,
          0.08164729285680945),
      Grad4(-0.4553054119602712, 0.8828161875373585, -0.08164729285680945,
          -0.08164729285680945),
      Grad4(-0.5029860367700724, 0.7504883828755602, -0.15296486218853164,
          0.4004672082940195),
      Grad4(-0.5029860367700724, 0.7504883828755602, 0.4004672082940195,
          -0.15296486218853164),
      Grad4(-0.5794684678643381, 0.6740059517812944, 0.3239847771997537,
          0.3239847771997537),
      Grad4(-0.3239847771997537, 0.5794684678643381, -0.6740059517812944,
          -0.3239847771997537),
      Grad4(-0.4004672082940195, 0.5029860367700724, -0.7504883828755602,
          0.15296486218853164),
      Grad4(0.15296486218853164, 0.5029860367700724, -0.7504883828755602,
          -0.4004672082940195),
      Grad4(0.08164729285680945, 0.4553054119602712, -0.8828161875373585,
          0.08164729285680945),
      Grad4(-0.08164729285680945, 0.8828161875373585, -0.4553054119602712,
          -0.08164729285680945),
      Grad4(-0.15296486218853164, 0.7504883828755602, -0.5029860367700724,
          0.4004672082940195),
      Grad4(0.4004672082940195, 0.7504883828755602, -0.5029860367700724,
          -0.15296486218853164),
      Grad4(0.3239847771997537, 0.6740059517812944, -0.5794684678643381,
          0.3239847771997537),
      Grad4(-0.3239847771997537, 0.5794684678643381, -0.3239847771997537,
          -0.6740059517812944),
      Grad4(-0.4004672082940195, 0.5029860367700724, 0.15296486218853164,
          -0.7504883828755602),
      Grad4(0.15296486218853164, 0.5029860367700724, -0.4004672082940195,
          -0.7504883828755602),
      Grad4(0.08164729285680945, 0.4553054119602712, 0.08164729285680945,
          -0.8828161875373585),
      Grad4(-0.08164729285680945, 0.8828161875373585, -0.08164729285680945,
          -0.4553054119602712),
      Grad4(-0.15296486218853164, 0.7504883828755602, 0.4004672082940195,
          -0.5029860367700724),
      Grad4(0.4004672082940195, 0.7504883828755602, -0.15296486218853164,
          -0.5029860367700724),
      Grad4(0.3239847771997537, 0.6740059517812944, 0.3239847771997537,
          -0.5794684678643381),
      Grad4(0.5794684678643381, -0.6740059517812944, -0.3239847771997537,
          -0.3239847771997537),
      Grad4(0.5029860367700724, -0.7504883828755602, -0.4004672082940195,
          0.15296486218853164),
      Grad4(0.5029860367700724, -0.7504883828755602, 0.15296486218853164,
          -0.4004672082940195),
      Grad4(0.4553054119602712, -0.8828161875373585, 0.08164729285680945,
          0.08164729285680945),
      Grad4(0.8828161875373585, -0.4553054119602712, -0.08164729285680945,
          -0.08164729285680945),
      Grad4(0.7504883828755602, -0.5029860367700724, -0.15296486218853164,
          0.4004672082940195),
      Grad4(0.7504883828755602, -0.5029860367700724, 0.4004672082940195,
          -0.15296486218853164),
      Grad4(0.6740059517812944, -0.5794684678643381, 0.3239847771997537,
          0.3239847771997537),
      Grad4(0.5794684678643381, -0.3239847771997537, -0.6740059517812944,
          -0.3239847771997537),
      Grad4(0.5029860367700724, -0.4004672082940195, -0.7504883828755602,
          0.15296486218853164),
      Grad4(0.5029860367700724, 0.15296486218853164, -0.7504883828755602,
          -0.4004672082940195),
      Grad4(0.4553054119602712, 0.08164729285680945, -0.8828161875373585,
          0.08164729285680945),
      Grad4(0.8828161875373585, -0.08164729285680945, -0.4553054119602712,
          -0.08164729285680945),
      Grad4(0.7504883828755602, -0.15296486218853164, -0.5029860367700724,
          0.4004672082940195),
      Grad4(0.7504883828755602, 0.4004672082940195, -0.5029860367700724,
          -0.15296486218853164),
      Grad4(0.6740059517812944, 0.3239847771997537, -0.5794684678643381,
          0.3239847771997537),
      Grad4(0.5794684678643381, -0.3239847771997537, -0.3239847771997537,
          -0.6740059517812944),
      Grad4(0.5029860367700724, -0.4004672082940195, 0.15296486218853164,
          -0.7504883828755602),
      Grad4(0.5029860367700724, 0.15296486218853164, -0.4004672082940195,
          -0.7504883828755602),
      Grad4(0.4553054119602712, 0.08164729285680945, 0.08164729285680945,
          -0.8828161875373585),
      Grad4(0.8828161875373585, -0.08164729285680945, -0.08164729285680945,
          -0.4553054119602712),
      Grad4(0.7504883828755602, -0.15296486218853164, 0.4004672082940195,
          -0.5029860367700724),
      Grad4(0.7504883828755602, 0.4004672082940195, -0.15296486218853164,
          -0.5029860367700724),
      Grad4(0.6740059517812944, 0.3239847771997537, 0.3239847771997537,
          -0.5794684678643381),
      Grad4(0.03381941603233842, 0.03381941603233842, 0.03381941603233842,
          0.9982828964265062),
      Grad4(-0.044802370851755174, -0.044802370851755174, 0.508629699630796,
          0.8586508742123365),
      Grad4(-0.044802370851755174, 0.508629699630796, -0.044802370851755174,
          0.8586508742123365),
      Grad4(-0.12128480194602098, 0.4321472685365301, 0.4321472685365301,
          0.7821684431180708),
      Grad4(0.508629699630796, -0.044802370851755174, -0.044802370851755174,
          0.8586508742123365),
      Grad4(0.4321472685365301, -0.12128480194602098, 0.4321472685365301,
          0.7821684431180708),
      Grad4(0.4321472685365301, 0.4321472685365301, -0.12128480194602098,
          0.7821684431180708),
      Grad4(0.37968289875261624, 0.37968289875261624, 0.37968289875261624,
          0.753341017856078),
      Grad4(0.03381941603233842, 0.03381941603233842, 0.9982828964265062,
          0.03381941603233842),
      Grad4(-0.044802370851755174, 0.044802370851755174, 0.8586508742123365,
          0.508629699630796),
      Grad4(-0.044802370851755174, 0.508629699630796, 0.8586508742123365,
          -0.044802370851755174),
      Grad4(-0.12128480194602098, 0.4321472685365301, 0.7821684431180708,
          0.4321472685365301),
      Grad4(0.508629699630796, -0.044802370851755174, 0.8586508742123365,
          -0.044802370851755174),
      Grad4(0.4321472685365301, -0.12128480194602098, 0.7821684431180708,
          0.4321472685365301),
      Grad4(0.4321472685365301, 0.4321472685365301, 0.7821684431180708,
          -0.12128480194602098),
      Grad4(0.37968289875261624, 0.37968289875261624, 0.753341017856078,
          0.37968289875261624),
      Grad4(0.03381941603233842, 0.9982828964265062, 0.03381941603233842,
          0.03381941603233842),
      Grad4(-0.044802370851755174, 0.8586508742123365, -0.044802370851755174,
          0.508629699630796),
      Grad4(-0.044802370851755174, 0.8586508742123365, 0.508629699630796,
          -0.044802370851755174),
      Grad4(-0.12128480194602098, 0.7821684431180708, 0.4321472685365301,
          0.4321472685365301),
      Grad4(0.508629699630796, 0.8586508742123365, -0.044802370851755174,
          -0.044802370851755174),
      Grad4(0.4321472685365301, 0.7821684431180708, -0.12128480194602098,
          0.4321472685365301),
      Grad4(0.4321472685365301, 0.7821684431180708, 0.4321472685365301,
          -0.12128480194602098),
      Grad4(0.37968289875261624, 0.753341017856078, 0.37968289875261624,
          0.37968289875261624),
      Grad4(0.9982828964265062, 0.03381941603233842, 0.03381941603233842,
          0.03381941603233842),
      Grad4(0.8586508742123365, -0.044802370851755174, -0.044802370851755174,
          0.508629699630796),
      Grad4(0.8586508742123365, -0.044802370851755174, 0.508629699630796,
          -0.044802370851755174),
      Grad4(0.7821684431180708, -0.12128480194602098, 0.4321472685365301,
          0.4321472685365301),
      Grad4(0.8586508742123365, 0.508629699630796, -0.044802370851755174,
          -0.044802370851755174),
      Grad4(0.7821684431180708, 0.4321472685365301, -0.12128480194602098,
          0.4321472685365301),
      Grad4(0.7821684431180708, 0.4321472685365301, 0.4321472685365301,
          -0.12128480194602098),
      Grad4(0.753341017856078, 0.37968289875261624, 0.37968289875261624,
          0.37968289875261624)
    ];
    final grad4Adjusted = [
      for (final grad in grad4)
        Grad4(
          grad.dx / _kN4,
          grad.dy / _kN4,
          grad.dz / _kN4,
          grad.dw / _kN4,
        ),
    ];
    for (int i = 0; i < _kSize; i++) {
      _gradients4d.add(grad4Adjusted[i % grad4.length]);
    }
  }
}

class _LatticePoint2D {
  const _LatticePoint2D(this.xsv, this.ysv)
      : dx = -xsv - ((xsv + ysv) * -0.211324865405187),
        dy = -ysv - ((xsv + ysv) * -0.211324865405187);

  final int xsv, ysv;
  final double dx, dy;
}

class _LatticePoint3D {
  _LatticePoint3D(int xrv, int yrv, int zrv, int lattice)
      : dxr = -xrv + lattice * 0.5,
        dyr = -yrv + lattice * 0.5,
        dzr = -zrv + lattice * 0.5,
        xrv = xrv + lattice * 1024,
        yrv = yrv + lattice * 1024,
        zrv = zrv + lattice * 1024;

  final double dxr, dyr, dzr;
  final int xrv, yrv, zrv;

  _LatticePoint3D? nextOnFailure, nextOnSuccess;
}

class _LatticePoint4D {
  _LatticePoint4D(int xsv, int ysv, int zsv, int wsv)
      : xsv = xsv + 409,
        ysv = ysv + 409,
        zsv = zsv + 409,
        wsv = wsv + 409,
        xsi = 0.2 - xsv,
        ysi = 0.2 - ysv,
        zsi = 0.2 - zsv,
        wsi = 0.2 - wsv {
    final ssv = (xsv + ysv + zsv + wsv) * 0.309016994374947;
    dx = -xsv - ssv;
    dy = -ysv - ssv;
    dz = -zsv - ssv;
    dw = -wsv - ssv;
    ssiDelta = (0.8 - xsv - ysv - zsv - wsv) * 0.309016994374947;
  }

  final int xsv, ysv, zsv, wsv;
  late final double dx, dy, dz, dw;
  final double xsi, ysi, zsi, wsi;
  late final double ssiDelta;
}
