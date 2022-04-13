// The implementation in this file is based on KdotJPG's implementation here: https://github.com/KdotJPG/OpenSimplex2/blob/a186b9bb644747c936d7cba748d11f28b1cee66e/java/OpenSimplex2S.java.

import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:open_simplex_2/src/grad.dart';
import 'package:open_simplex_2/src/open_simplex_2.dart';

const _kN2 = 0.05481866495625118;
const _kN3 = 0.2781926117527186;
const _kN4 = 0.11127401889945551;
const _kSize = 2048;
const _kMask = 2047;

/// K.jpg's OpenSimplex 2, smooth variant ("SuperSimplex").
///
/// - 2D is standard simplex, modified to support larger kernels.
///   Implemented using a lookup table.
/// - 3D is "Re-oriented 8-point BCC noise" which constructs a
///   congruent BCC lattice in a much different way than usual.
/// - 4D uses a naïve pregenerated lookup table, and averages out
///   to the expected performance.
///
/// Multiple versions of each function are provided. See the
/// documentation above each, for more info.
class OpenSimplex2S implements OpenSimplex2 {
  /// Creates a seeded [OpenSimplex2S] that can be used to evaluate noise.
  OpenSimplex2S(int seed) {
    if (!_staticInitialized) {
      _staticInit();
      _staticInitialized = true;
    }

    final source = Int16List(_kSize);
    for (var i = 0; i < _kSize; i++) {
      source[i] = i;
    }
    // KdotJPG's implementation uses Java's long here. Long in Java is a
    // 64-bit two's complement integer. int in Dart is also a 64-bit two's
    // complement integer, however, *only on native* (see https://dart.dev/guides/language/numbers).
    // However, we want to support web, i.e. JavaScript, as well with this
    // package and therefore we have to use the fixnum Int64 type. See
    // https://github.com/dart-lang/sdk/issues/46852#issuecomment-894888740.
    var seed64 = Int64(seed);
    for (int i = _kSize - 1; i >= 0; i--) {
      // KdotJPG's implementation uses long literals here. We can use int
      // literals of this size as well in Dart, however, these are too big for
      // JavaScript and therefore we have to use int.parse instead.
      seed64 = seed64 * Int64.parseInt('6364136223846793005') +
          Int64.parseInt('1442695040888963407');
      // We know r cannot be bigger than 2047, so we can convert it back to an
      // int.
      var r = ((seed64 + 31) % (i + 1)).toInt();
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

  /// 2D SuperSimplex noise, standard lattice orientation.
  @override
  double noise2(double x, double y) {
    // Get points for A2* lattice
    double s = 0.366025403784439 * (x + y);
    double xs = x + s, ys = y + s;

    return _noise2Base(xs, ys);
  }

  /// 2D SuperSimplex noise, with Y pointing down the main diagonal.
  ///
  /// Might be better for a 2D sandbox style game, where Y is vertical.
  /// Probably slightly less optimal for heightmaps or continent maps.
  @override
  double noise2XBeforeY(double x, double y) {
    // Skew transform and rotation baked into one.
    double xx = x * 0.7071067811865476;
    double yy = y * 1.224744871380249;

    return _noise2Base(yy + xx, yy - xx);
  }

  /// 2D SuperSimplex noise base.
  ///
  /// Lookup table implementation inspired by DigitalShadow.
  double _noise2Base(double xs, double ys) {
    double value = 0;

    // Get base points and offsets
    int xsb = xs.floor(), ysb = ys.floor();
    double xsi = xs - xsb, ysi = ys - ysb;

    // Index to point list
    final a = (xsi + ysi).toInt();
    int index = (a << 2) |
        (xsi - ysi / 2 + 1 - a / 2.0).toInt() << 3 |
        (ysi - xsi / 2 + 1 - a / 2.0).toInt() << 4;

    double ssi = (xsi + ysi) * -0.211324865405187;
    double xi = xsi + ssi, yi = ysi + ssi;

    // Point contributions
    for (int i = 0; i < 4; i++) {
      _LatticePoint2D c = _lookup2d[index + i];

      double dx = xi + c.dx, dy = yi + c.dy;
      double attn = 2.0 / 3.0 - dx * dx - dy * dy;
      if (attn <= 0) continue;

      int pxm = (xsb + c.xsv) & _kMask, pym = (ysb + c.ysv) & _kMask;
      Grad2 grad = _permGrad2[_perm[pxm] ^ pym];
      double extrapolation = grad.dx * dx + grad.dy * dy;

      attn *= attn;
      value += attn * attn * extrapolation;
    }

    return value;
  }

  /// 3D Re-oriented 8-point BCC noise, classic orientation.
  ///
  /// Proper substitute for what 3D SuperSimplex would be,
  /// in light of Forbidden Formulae.
  /// Use noise3XYBeforeZ or noise3XZBeforeY instead, wherever appropriate.
  @override
  double noise3Classic(double x, double y, double z) {
    // Re-orient the cubic lattices via rotation, to produce the expected look on cardinal planar slices.
    // If texturing objects that don't tend to have cardinal plane faces, you could even remove this.
    // Orthonormal rotation. Not a skew transform.
    double r = (2.0 / 3.0) * (x + y + z);
    double xr = r - x, yr = r - y, zr = r - z;

    // Evaluate both lattices to form a BCC lattice.
    return _noise3BCC(xr, yr, zr);
  }

  /// 3D Re-oriented 8-point BCC noise, with better visual isotropy in (X, Y).
  ///
  /// Recommended for 3D terrain and time-varied animations.
  /// The Z coordinate should always be the "different" coordinate in your use case.
  /// If Y is vertical in world coordinates, call noise3XYBeforeZ(x, z, Y) or use noise3XZBeforeY.
  /// If Z is vertical in world coordinates, call noise3XYBeforeZ(x, y, Z).
  /// For a time varied animation, call noise3XYBeforeZ(x, y, T).
  @override
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

  /// 3D Re-oriented 8-point BCC noise, with better visual isotropy in (X, Z).
  ///
  /// Recommended for 3D terrain and time-varied animations.
  /// The Y coordinate should always be the "different" coordinate in your use case.
  /// If Y is vertical in world coordinates, call noise3XZBeforeY(x, Y, z).
  /// If Z is vertical in world coordinates, call noise3XZBeforeY(x, Z, y) or use noise3XYBeforeZ.
  /// For a time varied animation, call noise3XZBeforeY(x, T, y) or use noise3XYBeforeZ.
  @override
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
  /// than to build up the index with enough info to isolate 8 points.
  double _noise3BCC(double xr, double yr, double zr) {
    // Get base and offsets inside cube of first lattice.
    int xrb = xr.floor(), yrb = yr.floor(), zrb = zr.floor();
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
      double attn = 0.75 - dxr * dxr - dyr * dyr - dzr * dzr;
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

  /// 4D SuperSimplex noise, classic lattice orientation.
  @override
  double noise4Classic(double x, double y, double z, double w) {
    // Get points for A4 lattice
    double s = 0.309016994374947 * (x + y + z + w);
    double xs = x + s, ys = y + s, zs = z + s, ws = w + s;

    return _noise4Base(xs, ys, zs, ws);
  }

  /// 4D SuperSimplex noise, with XY and ZW forming orthogonal triangular-based planes.
  ///
  /// Recommended for 3D terrain, where X and Y (or Z and W) are horizontal.
  /// Recommended for noise(x, y, sin(time), cos(time)) trick.
  @override
  double noise4XYBeforeZW(double x, double y, double z, double w) {
    double s2 =
        (x + y) * -0.28522513987434876941 + (z + w) * 0.83897065470611435718;
    double t2 =
        (z + w) * 0.21939749883706435719 + (x + y) * -0.48214856493302476942;
    double xs = x + s2, ys = y + s2, zs = z + t2, ws = w + t2;

    return _noise4Base(xs, ys, zs, ws);
  }

  /// 4D SuperSimplex noise, with XZ and YW forming orthogonal triangular-based planes.
  ///
  /// Recommended for 3D terrain, where X and Z (or Y and W) are horizontal.
  @override
  double noise4XZBeforeYW(double x, double y, double z, double w) {
    double s2 =
        (x + z) * -0.28522513987434876941 + (y + w) * 0.83897065470611435718;
    double t2 =
        (y + w) * 0.21939749883706435719 + (x + z) * -0.48214856493302476942;
    double xs = x + s2, ys = y + t2, zs = z + s2, ws = w + t2;

    return _noise4Base(xs, ys, zs, ws);
  }

  /// 4D SuperSimplex noise, with XYZ oriented like noise3Classic,
  /// and W for an extra degree of freedom.
  ///
  /// Recommended for time-varied animations which texture a 3D object (W=time)
  @override
  double noise4XYZBeforeW(double x, double y, double z, double w) {
    double xyz = x + y + z;
    double ww = w * 1.118033988749894;
    double s2 = xyz * -0.16666666666666666 + ww;
    double xs = x + s2, ys = y + s2, zs = z + s2, ws = -0.5 * xyz + ww;

    return _noise4Base(xs, ys, zs, ws);
  }

  /// 4D SuperSimplex noise base.
  /// Using ultra-simple 4x4x4x4 lookup partitioning.
  ///
  /// This isn't as elegant or SIMD/GPU/etc. portable as other approaches,
  /// but it does compete performance-wise with optimized OpenSimplex1.
  double _noise4Base(double xs, double ys, double zs, double ws) {
    double value = 0;

    // Get base points and offsets
    int xsb = xs.floor(), ysb = ys.floor(), zsb = zs.floor(), wsb = ws.floor();
    double xsi = xs - xsb, ysi = ys - ysb, zsi = zs - zsb, wsi = ws - wsb;

    // Unskewed offsets
    double ssi = (xsi + ysi + zsi + wsi) * -0.138196601125011;
    double xi = xsi + ssi, yi = ysi + ssi, zi = zsi + ssi, wi = wsi + ssi;

    int index = (((xs * 4).floor() & 3) << 0) |
        (((ys * 4).floor() & 3) << 2) |
        (((zs * 4).floor() & 3) << 4) |
        (((ws * 4).floor() & 3) << 6);

    // Point contributions
    for (final c in _lookup4d[index]) {
      double dx = xi + c.dx, dy = yi + c.dy, dz = zi + c.dz, dw = wi + c.dw;
      double attn = 0.8 - dx * dx - dy * dy - dz * dz - dw * dw;
      if (attn > 0) {
        attn *= attn;

        int pxm = (xsb + c.xsv) & _kMask, pym = (ysb + c.ysv) & _kMask;
        int pzm = (zsb + c.zsv) & _kMask, pwm = (wsb + c.wsv) & _kMask;
        Grad4 grad = _permGrad4[_perm[_perm[_perm[pxm] ^ pym] ^ pzm] ^ pwm];
        double extrapolation =
            grad.dx * dx + grad.dy * dy + grad.dz * dz + grad.dw * dw;

        value += attn * attn * extrapolation;
      }
    }
    return value;
  }

  // Definitions

  static final _lookup2d = <_LatticePoint2D>[];
  static final _lookup3d = <_LatticePoint3D>[];
  static final _lookup4d = <List<_LatticePoint4D>>[];
  static final _gradients2d = <Grad2>[];
  static final _gradients3d = <Grad3>[];
  static final _gradients4d = <Grad4>[];

  static var _staticInitialized = false;

  /// Performs the initialization of all static lookup members.
  ///
  /// This function as well as [_staticInitialized] exist because there is
  /// no comparable concept to static blocks (from Java) in Dart.
  static void _staticInit() {
    for (int i = 0; i < 8; i++) {
      int i1, j1, i2, j2;
      if ((i & 1) == 0) {
        if ((i & 2) == 0) {
          i1 = -1;
          j1 = 0;
        } else {
          i1 = 1;
          j1 = 0;
        }
        if ((i & 4) == 0) {
          i2 = 0;
          j2 = -1;
        } else {
          i2 = 0;
          j2 = 1;
        }
      } else {
        if ((i & 2) != 0) {
          i1 = 2;
          j1 = 1;
        } else {
          i1 = 0;
          j1 = 1;
        }
        if ((i & 4) != 0) {
          i2 = 1;
          j2 = 2;
        } else {
          i2 = 1;
          j2 = 0;
        }
      }
      _lookup2d.addAll([
        const _LatticePoint2D(0, 0),
        const _LatticePoint2D(1, 1),
        _LatticePoint2D(i1, j1),
        _LatticePoint2D(i2, j2),
      ]);
    }

    for (int i = 0; i < 8; i++) {
      int i1, j1, k1, i2, j2, k2;
      i1 = (i >> 0) & 1;
      j1 = (i >> 1) & 1;
      k1 = (i >> 2) & 1;
      i2 = i1 ^ 1;
      j2 = j1 ^ 1;
      k2 = k1 ^ 1;

      // The two points within this octant, one from each of the two cubic half-lattices.
      _LatticePoint3D c0 = _LatticePoint3D(i1, j1, k1, 0);
      _LatticePoint3D c1 = _LatticePoint3D(i1 + i2, j1 + j2, k1 + k2, 1);

      // (1, 0, 0) vs (0, 1, 1) away from octant.
      _LatticePoint3D c2 = _LatticePoint3D(i1 ^ 1, j1, k1, 0);
      _LatticePoint3D c3 = _LatticePoint3D(i1, j1 ^ 1, k1 ^ 1, 0);

      // (1, 0, 0) vs (0, 1, 1) away from octant, on second half-lattice.
      _LatticePoint3D c4 = _LatticePoint3D(i1 + (i2 ^ 1), j1 + j2, k1 + k2, 1);
      _LatticePoint3D c5 =
          _LatticePoint3D(i1 + i2, j1 + (j2 ^ 1), k1 + (k2 ^ 1), 1);

      // (0, 1, 0) vs (1, 0, 1) away from octant.
      _LatticePoint3D c6 = _LatticePoint3D(i1, j1 ^ 1, k1, 0);
      _LatticePoint3D c7 = _LatticePoint3D(i1 ^ 1, j1, k1 ^ 1, 0);

      // (0, 1, 0) vs (1, 0, 1) away from octant, on second half-lattice.
      _LatticePoint3D c8 = _LatticePoint3D(i1 + i2, j1 + (j2 ^ 1), k1 + k2, 1);
      _LatticePoint3D c9 =
          _LatticePoint3D(i1 + (i2 ^ 1), j1 + j2, k1 + (k2 ^ 1), 1);

      // (0, 0, 1) vs (1, 1, 0) away from octant.
      _LatticePoint3D cA = _LatticePoint3D(i1, j1, k1 ^ 1, 0);
      _LatticePoint3D cB = _LatticePoint3D(i1 ^ 1, j1 ^ 1, k1, 0);

      // (0, 0, 1) vs (1, 1, 0) away from octant, on second half-lattice.
      _LatticePoint3D cC = _LatticePoint3D(i1 + i2, j1 + j2, k1 + (k2 ^ 1), 1);
      _LatticePoint3D cD =
          _LatticePoint3D(i1 + (i2 ^ 1), j1 + (j2 ^ 1), k1 + k2, 1);

      // First two points are guaranteed.
      c0.nextOnFailure = c0.nextOnSuccess = c1;
      c1.nextOnFailure = c1.nextOnSuccess = c2;

      // If c2 is in range, then we know c3 and c4 are not.
      c2.nextOnFailure = c3;
      c2.nextOnSuccess = c5;
      c3.nextOnFailure = c4;
      c3.nextOnSuccess = c4;

      // If c4 is in range, then we know c5 is not.
      c4.nextOnFailure = c5;
      c4.nextOnSuccess = c6;
      c5.nextOnFailure = c5.nextOnSuccess = c6;

      // If c6 is in range, then we know c7 and c8 are not.
      c6.nextOnFailure = c7;
      c6.nextOnSuccess = c9;
      c7.nextOnFailure = c8;
      c7.nextOnSuccess = c8;

      // If c8 is in range, then we know c9 is not.
      c8.nextOnFailure = c9;
      c8.nextOnSuccess = cA;
      c9.nextOnFailure = c9.nextOnSuccess = cA;

      // If cA is in range, then we know cB and cC are not.
      cA.nextOnFailure = cB;
      cA.nextOnSuccess = cD;
      cB.nextOnFailure = cC;
      cB.nextOnSuccess = cC;

      // If cC is in range, then we know cD is not.
      cC.nextOnFailure = cD;
      cC.nextOnSuccess = null;
      cD.nextOnFailure = cD.nextOnSuccess = null;

      _lookup3d.add(c0);
    }

    const lookup4DPregen = <List<int>>[
      [
        0x15,
        0x45,
        0x51,
        0x54,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA
      ],
      [
        0x15,
        0x45,
        0x51,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x6A,
        0x95,
        0x96,
        0x9A,
        0xA6,
        0xAA
      ],
      [
        0x01,
        0x05,
        0x11,
        0x15,
        0x41,
        0x45,
        0x51,
        0x55,
        0x56,
        0x5A,
        0x66,
        0x6A,
        0x96,
        0x9A,
        0xA6,
        0xAA
      ],
      [
        0x01,
        0x15,
        0x16,
        0x45,
        0x46,
        0x51,
        0x52,
        0x55,
        0x56,
        0x5A,
        0x66,
        0x6A,
        0x96,
        0x9A,
        0xA6,
        0xAA,
        0xAB
      ],
      [
        0x15,
        0x45,
        0x54,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x69,
        0x6A,
        0x95,
        0x99,
        0x9A,
        0xA9,
        0xAA
      ],
      [
        0x05,
        0x15,
        0x45,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xAA
      ],
      [0x05, 0x15, 0x45, 0x55, 0x56, 0x59, 0x5A, 0x66, 0x6A, 0x96, 0x9A, 0xAA],
      [
        0x05,
        0x15,
        0x16,
        0x45,
        0x46,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x66,
        0x6A,
        0x96,
        0x9A,
        0xAA,
        0xAB
      ],
      [
        0x04,
        0x05,
        0x14,
        0x15,
        0x44,
        0x45,
        0x54,
        0x55,
        0x59,
        0x5A,
        0x69,
        0x6A,
        0x99,
        0x9A,
        0xA9,
        0xAA
      ],
      [0x05, 0x15, 0x45, 0x55, 0x56, 0x59, 0x5A, 0x69, 0x6A, 0x99, 0x9A, 0xAA],
      [0x05, 0x15, 0x45, 0x55, 0x56, 0x59, 0x5A, 0x6A, 0x9A, 0xAA],
      [
        0x05,
        0x15,
        0x16,
        0x45,
        0x46,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x5B,
        0x6A,
        0x9A,
        0xAA,
        0xAB
      ],
      [
        0x04,
        0x15,
        0x19,
        0x45,
        0x49,
        0x54,
        0x55,
        0x58,
        0x59,
        0x5A,
        0x69,
        0x6A,
        0x99,
        0x9A,
        0xA9,
        0xAA,
        0xAE
      ],
      [
        0x05,
        0x15,
        0x19,
        0x45,
        0x49,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x69,
        0x6A,
        0x99,
        0x9A,
        0xAA,
        0xAE
      ],
      [
        0x05,
        0x15,
        0x19,
        0x45,
        0x49,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x5E,
        0x6A,
        0x9A,
        0xAA,
        0xAE
      ],
      [
        0x05,
        0x15,
        0x1A,
        0x45,
        0x4A,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x5B,
        0x5E,
        0x6A,
        0x9A,
        0xAA,
        0xAB,
        0xAE,
        0xAF
      ],
      [
        0x15,
        0x51,
        0x54,
        0x55,
        0x56,
        0x59,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0xA5,
        0xA6,
        0xA9,
        0xAA
      ],
      [
        0x11,
        0x15,
        0x51,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x96,
        0xA5,
        0xA6,
        0xAA
      ],
      [0x11, 0x15, 0x51, 0x55, 0x56, 0x5A, 0x65, 0x66, 0x6A, 0x96, 0xA6, 0xAA],
      [
        0x11,
        0x15,
        0x16,
        0x51,
        0x52,
        0x55,
        0x56,
        0x5A,
        0x65,
        0x66,
        0x6A,
        0x96,
        0xA6,
        0xAA,
        0xAB
      ],
      [
        0x14,
        0x15,
        0x54,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x99,
        0xA5,
        0xA9,
        0xAA
      ],
      [
        0x15,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x9A,
        0xA6,
        0xA9,
        0xAA
      ],
      [
        0x15,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x96,
        0x9A,
        0xA6,
        0xAA,
        0xAB
      ],
      [
        0x15,
        0x16,
        0x55,
        0x56,
        0x5A,
        0x66,
        0x6A,
        0x6B,
        0x96,
        0x9A,
        0xA6,
        0xAA,
        0xAB
      ],
      [0x14, 0x15, 0x54, 0x55, 0x59, 0x5A, 0x65, 0x69, 0x6A, 0x99, 0xA9, 0xAA],
      [
        0x15,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x99,
        0x9A,
        0xA9,
        0xAA,
        0xAE
      ],
      [0x15, 0x55, 0x56, 0x59, 0x5A, 0x65, 0x66, 0x69, 0x6A, 0x9A, 0xAA],
      [0x15, 0x16, 0x55, 0x56, 0x59, 0x5A, 0x66, 0x6A, 0x6B, 0x9A, 0xAA, 0xAB],
      [
        0x14,
        0x15,
        0x19,
        0x54,
        0x55,
        0x58,
        0x59,
        0x5A,
        0x65,
        0x69,
        0x6A,
        0x99,
        0xA9,
        0xAA,
        0xAE
      ],
      [
        0x15,
        0x19,
        0x55,
        0x59,
        0x5A,
        0x69,
        0x6A,
        0x6E,
        0x99,
        0x9A,
        0xA9,
        0xAA,
        0xAE
      ],
      [0x15, 0x19, 0x55, 0x56, 0x59, 0x5A, 0x69, 0x6A, 0x6E, 0x9A, 0xAA, 0xAE],
      [
        0x15,
        0x1A,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x6A,
        0x6B,
        0x6E,
        0x9A,
        0xAA,
        0xAB,
        0xAE,
        0xAF
      ],
      [
        0x10,
        0x11,
        0x14,
        0x15,
        0x50,
        0x51,
        0x54,
        0x55,
        0x65,
        0x66,
        0x69,
        0x6A,
        0xA5,
        0xA6,
        0xA9,
        0xAA
      ],
      [0x11, 0x15, 0x51, 0x55, 0x56, 0x65, 0x66, 0x69, 0x6A, 0xA5, 0xA6, 0xAA],
      [0x11, 0x15, 0x51, 0x55, 0x56, 0x65, 0x66, 0x6A, 0xA6, 0xAA],
      [
        0x11,
        0x15,
        0x16,
        0x51,
        0x52,
        0x55,
        0x56,
        0x65,
        0x66,
        0x67,
        0x6A,
        0xA6,
        0xAA,
        0xAB
      ],
      [0x14, 0x15, 0x54, 0x55, 0x59, 0x65, 0x66, 0x69, 0x6A, 0xA5, 0xA9, 0xAA],
      [
        0x15,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xBA
      ],
      [0x15, 0x55, 0x56, 0x59, 0x5A, 0x65, 0x66, 0x69, 0x6A, 0xA6, 0xAA],
      [0x15, 0x16, 0x55, 0x56, 0x5A, 0x65, 0x66, 0x6A, 0x6B, 0xA6, 0xAA, 0xAB],
      [0x14, 0x15, 0x54, 0x55, 0x59, 0x65, 0x69, 0x6A, 0xA9, 0xAA],
      [0x15, 0x55, 0x56, 0x59, 0x5A, 0x65, 0x66, 0x69, 0x6A, 0xA9, 0xAA],
      [0x15, 0x55, 0x56, 0x59, 0x5A, 0x65, 0x66, 0x69, 0x6A, 0xAA],
      [
        0x15,
        0x16,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x6B,
        0xAA,
        0xAB
      ],
      [
        0x14,
        0x15,
        0x19,
        0x54,
        0x55,
        0x58,
        0x59,
        0x65,
        0x69,
        0x6A,
        0x6D,
        0xA9,
        0xAA,
        0xAE
      ],
      [0x15, 0x19, 0x55, 0x59, 0x5A, 0x65, 0x69, 0x6A, 0x6E, 0xA9, 0xAA, 0xAE],
      [
        0x15,
        0x19,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x6E,
        0xAA,
        0xAE
      ],
      [
        0x15,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x66,
        0x69,
        0x6A,
        0x6B,
        0x6E,
        0x9A,
        0xAA,
        0xAB,
        0xAE,
        0xAF
      ],
      [
        0x10,
        0x15,
        0x25,
        0x51,
        0x54,
        0x55,
        0x61,
        0x64,
        0x65,
        0x66,
        0x69,
        0x6A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xBA
      ],
      [
        0x11,
        0x15,
        0x25,
        0x51,
        0x55,
        0x56,
        0x61,
        0x65,
        0x66,
        0x69,
        0x6A,
        0xA5,
        0xA6,
        0xAA,
        0xBA
      ],
      [
        0x11,
        0x15,
        0x25,
        0x51,
        0x55,
        0x56,
        0x61,
        0x65,
        0x66,
        0x6A,
        0x76,
        0xA6,
        0xAA,
        0xBA
      ],
      [
        0x11,
        0x15,
        0x26,
        0x51,
        0x55,
        0x56,
        0x62,
        0x65,
        0x66,
        0x67,
        0x6A,
        0x76,
        0xA6,
        0xAA,
        0xAB,
        0xBA,
        0xBB
      ],
      [
        0x14,
        0x15,
        0x25,
        0x54,
        0x55,
        0x59,
        0x64,
        0x65,
        0x66,
        0x69,
        0x6A,
        0xA5,
        0xA9,
        0xAA,
        0xBA
      ],
      [
        0x15,
        0x25,
        0x55,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x7A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xBA
      ],
      [0x15, 0x25, 0x55, 0x56, 0x65, 0x66, 0x69, 0x6A, 0x7A, 0xA6, 0xAA, 0xBA],
      [
        0x15,
        0x26,
        0x55,
        0x56,
        0x65,
        0x66,
        0x6A,
        0x6B,
        0x7A,
        0xA6,
        0xAA,
        0xAB,
        0xBA,
        0xBB
      ],
      [
        0x14,
        0x15,
        0x25,
        0x54,
        0x55,
        0x59,
        0x64,
        0x65,
        0x69,
        0x6A,
        0x79,
        0xA9,
        0xAA,
        0xBA
      ],
      [0x15, 0x25, 0x55, 0x59, 0x65, 0x66, 0x69, 0x6A, 0x7A, 0xA9, 0xAA, 0xBA],
      [
        0x15,
        0x25,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x7A,
        0xAA,
        0xBA
      ],
      [
        0x15,
        0x55,
        0x56,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x6B,
        0x7A,
        0xA6,
        0xAA,
        0xAB,
        0xBA,
        0xBB
      ],
      [
        0x14,
        0x15,
        0x29,
        0x54,
        0x55,
        0x59,
        0x65,
        0x68,
        0x69,
        0x6A,
        0x6D,
        0x79,
        0xA9,
        0xAA,
        0xAE,
        0xBA,
        0xBE
      ],
      [
        0x15,
        0x29,
        0x55,
        0x59,
        0x65,
        0x69,
        0x6A,
        0x6E,
        0x7A,
        0xA9,
        0xAA,
        0xAE,
        0xBA,
        0xBE
      ],
      [
        0x15,
        0x55,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x6E,
        0x7A,
        0xA9,
        0xAA,
        0xAE,
        0xBA,
        0xBE
      ],
      [
        0x15,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x6B,
        0x6E,
        0x7A,
        0xAA,
        0xAB,
        0xAE,
        0xBA,
        0xBF
      ],
      [
        0x45,
        0x51,
        0x54,
        0x55,
        0x56,
        0x59,
        0x65,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA
      ],
      [
        0x41,
        0x45,
        0x51,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xAA
      ],
      [0x41, 0x45, 0x51, 0x55, 0x56, 0x5A, 0x66, 0x95, 0x96, 0x9A, 0xA6, 0xAA],
      [
        0x41,
        0x45,
        0x46,
        0x51,
        0x52,
        0x55,
        0x56,
        0x5A,
        0x66,
        0x95,
        0x96,
        0x9A,
        0xA6,
        0xAA,
        0xAB
      ],
      [
        0x44,
        0x45,
        0x54,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x69,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA9,
        0xAA
      ],
      [
        0x45,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA6,
        0xA9,
        0xAA
      ],
      [
        0x45,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x66,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA6,
        0xAA,
        0xAB
      ],
      [
        0x45,
        0x46,
        0x55,
        0x56,
        0x5A,
        0x66,
        0x6A,
        0x96,
        0x9A,
        0x9B,
        0xA6,
        0xAA,
        0xAB
      ],
      [0x44, 0x45, 0x54, 0x55, 0x59, 0x5A, 0x69, 0x95, 0x99, 0x9A, 0xA9, 0xAA],
      [
        0x45,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x69,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA9,
        0xAA,
        0xAE
      ],
      [0x45, 0x55, 0x56, 0x59, 0x5A, 0x6A, 0x95, 0x96, 0x99, 0x9A, 0xAA],
      [0x45, 0x46, 0x55, 0x56, 0x59, 0x5A, 0x6A, 0x96, 0x9A, 0x9B, 0xAA, 0xAB],
      [
        0x44,
        0x45,
        0x49,
        0x54,
        0x55,
        0x58,
        0x59,
        0x5A,
        0x69,
        0x95,
        0x99,
        0x9A,
        0xA9,
        0xAA,
        0xAE
      ],
      [
        0x45,
        0x49,
        0x55,
        0x59,
        0x5A,
        0x69,
        0x6A,
        0x99,
        0x9A,
        0x9E,
        0xA9,
        0xAA,
        0xAE
      ],
      [0x45, 0x49, 0x55, 0x56, 0x59, 0x5A, 0x6A, 0x99, 0x9A, 0x9E, 0xAA, 0xAE],
      [
        0x45,
        0x4A,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x6A,
        0x9A,
        0x9B,
        0x9E,
        0xAA,
        0xAB,
        0xAE,
        0xAF
      ],
      [
        0x50,
        0x51,
        0x54,
        0x55,
        0x56,
        0x59,
        0x65,
        0x66,
        0x69,
        0x95,
        0x96,
        0x99,
        0xA5,
        0xA6,
        0xA9,
        0xAA
      ],
      [
        0x51,
        0x55,
        0x56,
        0x59,
        0x65,
        0x66,
        0x6A,
        0x95,
        0x96,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA
      ],
      [
        0x51,
        0x55,
        0x56,
        0x5A,
        0x65,
        0x66,
        0x6A,
        0x95,
        0x96,
        0x9A,
        0xA5,
        0xA6,
        0xAA,
        0xAB
      ],
      [
        0x51,
        0x52,
        0x55,
        0x56,
        0x5A,
        0x66,
        0x6A,
        0x96,
        0x9A,
        0xA6,
        0xA7,
        0xAA,
        0xAB
      ],
      [
        0x54,
        0x55,
        0x56,
        0x59,
        0x65,
        0x69,
        0x6A,
        0x95,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA
      ],
      [
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA
      ],
      [
        0x15,
        0x45,
        0x51,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x6A,
        0x95,
        0x96,
        0x9A,
        0xA6,
        0xAA,
        0xAB
      ],
      [0x55, 0x56, 0x5A, 0x66, 0x6A, 0x96, 0x9A, 0xA6, 0xAA, 0xAB],
      [
        0x54,
        0x55,
        0x59,
        0x5A,
        0x65,
        0x69,
        0x6A,
        0x95,
        0x99,
        0x9A,
        0xA5,
        0xA9,
        0xAA,
        0xAE
      ],
      [
        0x15,
        0x45,
        0x54,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x69,
        0x6A,
        0x95,
        0x99,
        0x9A,
        0xA9,
        0xAA,
        0xAE
      ],
      [
        0x15,
        0x45,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA6,
        0xA9,
        0xAA,
        0xAB,
        0xAE
      ],
      [0x55, 0x56, 0x59, 0x5A, 0x66, 0x6A, 0x96, 0x9A, 0xA6, 0xAA, 0xAB],
      [
        0x54,
        0x55,
        0x58,
        0x59,
        0x5A,
        0x69,
        0x6A,
        0x99,
        0x9A,
        0xA9,
        0xAA,
        0xAD,
        0xAE
      ],
      [0x55, 0x59, 0x5A, 0x69, 0x6A, 0x99, 0x9A, 0xA9, 0xAA, 0xAE],
      [0x55, 0x56, 0x59, 0x5A, 0x69, 0x6A, 0x99, 0x9A, 0xA9, 0xAA, 0xAE],
      [0x55, 0x56, 0x59, 0x5A, 0x6A, 0x9A, 0xAA, 0xAB, 0xAE, 0xAF],
      [0x50, 0x51, 0x54, 0x55, 0x65, 0x66, 0x69, 0x95, 0xA5, 0xA6, 0xA9, 0xAA],
      [
        0x51,
        0x55,
        0x56,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x96,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xBA
      ],
      [0x51, 0x55, 0x56, 0x65, 0x66, 0x6A, 0x95, 0x96, 0xA5, 0xA6, 0xAA],
      [0x51, 0x52, 0x55, 0x56, 0x65, 0x66, 0x6A, 0x96, 0xA6, 0xA7, 0xAA, 0xAB],
      [
        0x54,
        0x55,
        0x59,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x99,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xBA
      ],
      [
        0x15,
        0x51,
        0x54,
        0x55,
        0x56,
        0x59,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xBA
      ],
      [
        0x15,
        0x51,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x96,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xAB,
        0xBA
      ],
      [0x55, 0x56, 0x5A, 0x65, 0x66, 0x6A, 0x96, 0x9A, 0xA6, 0xAA, 0xAB],
      [0x54, 0x55, 0x59, 0x65, 0x69, 0x6A, 0x95, 0x99, 0xA5, 0xA9, 0xAA],
      [
        0x15,
        0x54,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xAE,
        0xBA
      ],
      [
        0x15,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x9A,
        0xA6,
        0xA9,
        0xAA
      ],
      [
        0x15,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x96,
        0x9A,
        0xA6,
        0xAA,
        0xAB
      ],
      [0x54, 0x55, 0x58, 0x59, 0x65, 0x69, 0x6A, 0x99, 0xA9, 0xAA, 0xAD, 0xAE],
      [0x55, 0x59, 0x5A, 0x65, 0x69, 0x6A, 0x99, 0x9A, 0xA9, 0xAA, 0xAE],
      [
        0x15,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x99,
        0x9A,
        0xA9,
        0xAA,
        0xAE
      ],
      [
        0x15,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x66,
        0x69,
        0x6A,
        0x9A,
        0xAA,
        0xAB,
        0xAE,
        0xAF
      ],
      [
        0x50,
        0x51,
        0x54,
        0x55,
        0x61,
        0x64,
        0x65,
        0x66,
        0x69,
        0x95,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xBA
      ],
      [
        0x51,
        0x55,
        0x61,
        0x65,
        0x66,
        0x69,
        0x6A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xB6,
        0xBA
      ],
      [0x51, 0x55, 0x56, 0x61, 0x65, 0x66, 0x6A, 0xA5, 0xA6, 0xAA, 0xB6, 0xBA],
      [
        0x51,
        0x55,
        0x56,
        0x62,
        0x65,
        0x66,
        0x6A,
        0xA6,
        0xA7,
        0xAA,
        0xAB,
        0xB6,
        0xBA,
        0xBB
      ],
      [
        0x54,
        0x55,
        0x64,
        0x65,
        0x66,
        0x69,
        0x6A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xB9,
        0xBA
      ],
      [0x55, 0x65, 0x66, 0x69, 0x6A, 0xA5, 0xA6, 0xA9, 0xAA, 0xBA],
      [0x55, 0x56, 0x65, 0x66, 0x69, 0x6A, 0xA5, 0xA6, 0xA9, 0xAA, 0xBA],
      [0x55, 0x56, 0x65, 0x66, 0x6A, 0xA6, 0xAA, 0xAB, 0xBA, 0xBB],
      [0x54, 0x55, 0x59, 0x64, 0x65, 0x69, 0x6A, 0xA5, 0xA9, 0xAA, 0xB9, 0xBA],
      [0x55, 0x59, 0x65, 0x66, 0x69, 0x6A, 0xA5, 0xA6, 0xA9, 0xAA, 0xBA],
      [
        0x15,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xBA
      ],
      [
        0x15,
        0x55,
        0x56,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0xA6,
        0xAA,
        0xAB,
        0xBA,
        0xBB
      ],
      [
        0x54,
        0x55,
        0x59,
        0x65,
        0x68,
        0x69,
        0x6A,
        0xA9,
        0xAA,
        0xAD,
        0xAE,
        0xB9,
        0xBA,
        0xBE
      ],
      [0x55, 0x59, 0x65, 0x69, 0x6A, 0xA9, 0xAA, 0xAE, 0xBA, 0xBE],
      [
        0x15,
        0x55,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0xA9,
        0xAA,
        0xAE,
        0xBA,
        0xBE
      ],
      [
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0xAA,
        0xAB,
        0xAE,
        0xBA,
        0xBF
      ],
      [
        0x40,
        0x41,
        0x44,
        0x45,
        0x50,
        0x51,
        0x54,
        0x55,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA
      ],
      [0x41, 0x45, 0x51, 0x55, 0x56, 0x95, 0x96, 0x99, 0x9A, 0xA5, 0xA6, 0xAA],
      [0x41, 0x45, 0x51, 0x55, 0x56, 0x95, 0x96, 0x9A, 0xA6, 0xAA],
      [
        0x41,
        0x45,
        0x46,
        0x51,
        0x52,
        0x55,
        0x56,
        0x95,
        0x96,
        0x97,
        0x9A,
        0xA6,
        0xAA,
        0xAB
      ],
      [0x44, 0x45, 0x54, 0x55, 0x59, 0x95, 0x96, 0x99, 0x9A, 0xA5, 0xA9, 0xAA],
      [
        0x45,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xEA
      ],
      [0x45, 0x55, 0x56, 0x59, 0x5A, 0x95, 0x96, 0x99, 0x9A, 0xA6, 0xAA],
      [0x45, 0x46, 0x55, 0x56, 0x5A, 0x95, 0x96, 0x9A, 0x9B, 0xA6, 0xAA, 0xAB],
      [0x44, 0x45, 0x54, 0x55, 0x59, 0x95, 0x99, 0x9A, 0xA9, 0xAA],
      [0x45, 0x55, 0x56, 0x59, 0x5A, 0x95, 0x96, 0x99, 0x9A, 0xA9, 0xAA],
      [0x45, 0x55, 0x56, 0x59, 0x5A, 0x95, 0x96, 0x99, 0x9A, 0xAA],
      [
        0x45,
        0x46,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0x9B,
        0xAA,
        0xAB
      ],
      [
        0x44,
        0x45,
        0x49,
        0x54,
        0x55,
        0x58,
        0x59,
        0x95,
        0x99,
        0x9A,
        0x9D,
        0xA9,
        0xAA,
        0xAE
      ],
      [0x45, 0x49, 0x55, 0x59, 0x5A, 0x95, 0x99, 0x9A, 0x9E, 0xA9, 0xAA, 0xAE],
      [
        0x45,
        0x49,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0x9E,
        0xAA,
        0xAE
      ],
      [
        0x45,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x6A,
        0x96,
        0x99,
        0x9A,
        0x9B,
        0x9E,
        0xAA,
        0xAB,
        0xAE,
        0xAF
      ],
      [0x50, 0x51, 0x54, 0x55, 0x65, 0x95, 0x96, 0x99, 0xA5, 0xA6, 0xA9, 0xAA],
      [
        0x51,
        0x55,
        0x56,
        0x65,
        0x66,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xEA
      ],
      [0x51, 0x55, 0x56, 0x65, 0x66, 0x95, 0x96, 0x9A, 0xA5, 0xA6, 0xAA],
      [0x51, 0x52, 0x55, 0x56, 0x66, 0x95, 0x96, 0x9A, 0xA6, 0xA7, 0xAA, 0xAB],
      [
        0x54,
        0x55,
        0x59,
        0x65,
        0x69,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xEA
      ],
      [
        0x45,
        0x51,
        0x54,
        0x55,
        0x56,
        0x59,
        0x65,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xEA
      ],
      [
        0x45,
        0x51,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xAB,
        0xEA
      ],
      [0x55, 0x56, 0x5A, 0x66, 0x6A, 0x95, 0x96, 0x9A, 0xA6, 0xAA, 0xAB],
      [0x54, 0x55, 0x59, 0x65, 0x69, 0x95, 0x99, 0x9A, 0xA5, 0xA9, 0xAA],
      [
        0x45,
        0x54,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x69,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xAE,
        0xEA
      ],
      [
        0x45,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA6,
        0xA9,
        0xAA
      ],
      [
        0x45,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x66,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA6,
        0xAA,
        0xAB
      ],
      [0x54, 0x55, 0x58, 0x59, 0x69, 0x95, 0x99, 0x9A, 0xA9, 0xAA, 0xAD, 0xAE],
      [0x55, 0x59, 0x5A, 0x69, 0x6A, 0x95, 0x99, 0x9A, 0xA9, 0xAA, 0xAE],
      [
        0x45,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x69,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA9,
        0xAA,
        0xAE
      ],
      [
        0x45,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x6A,
        0x96,
        0x99,
        0x9A,
        0xAA,
        0xAB,
        0xAE,
        0xAF
      ],
      [0x50, 0x51, 0x54, 0x55, 0x65, 0x95, 0xA5, 0xA6, 0xA9, 0xAA],
      [0x51, 0x55, 0x56, 0x65, 0x66, 0x95, 0x96, 0xA5, 0xA6, 0xA9, 0xAA],
      [0x51, 0x55, 0x56, 0x65, 0x66, 0x95, 0x96, 0xA5, 0xA6, 0xAA],
      [
        0x51,
        0x52,
        0x55,
        0x56,
        0x65,
        0x66,
        0x95,
        0x96,
        0xA5,
        0xA6,
        0xA7,
        0xAA,
        0xAB
      ],
      [0x54, 0x55, 0x59, 0x65, 0x69, 0x95, 0x99, 0xA5, 0xA6, 0xA9, 0xAA],
      [
        0x51,
        0x54,
        0x55,
        0x56,
        0x59,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xBA,
        0xEA
      ],
      [
        0x51,
        0x55,
        0x56,
        0x65,
        0x66,
        0x6A,
        0x95,
        0x96,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA
      ],
      [
        0x51,
        0x55,
        0x56,
        0x5A,
        0x65,
        0x66,
        0x6A,
        0x95,
        0x96,
        0x9A,
        0xA5,
        0xA6,
        0xAA,
        0xAB
      ],
      [0x54, 0x55, 0x59, 0x65, 0x69, 0x95, 0x99, 0xA5, 0xA9, 0xAA],
      [
        0x54,
        0x55,
        0x59,
        0x65,
        0x69,
        0x6A,
        0x95,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA
      ],
      [
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA
      ],
      [
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x6A,
        0x95,
        0x96,
        0x9A,
        0xA6,
        0xA9,
        0xAA,
        0xAB
      ],
      [
        0x54,
        0x55,
        0x58,
        0x59,
        0x65,
        0x69,
        0x95,
        0x99,
        0xA5,
        0xA9,
        0xAA,
        0xAD,
        0xAE
      ],
      [
        0x54,
        0x55,
        0x59,
        0x5A,
        0x65,
        0x69,
        0x6A,
        0x95,
        0x99,
        0x9A,
        0xA5,
        0xA9,
        0xAA,
        0xAE
      ],
      [
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x69,
        0x6A,
        0x95,
        0x99,
        0x9A,
        0xA6,
        0xA9,
        0xAA,
        0xAE
      ],
      [
        0x55,
        0x56,
        0x59,
        0x5A,
        0x66,
        0x69,
        0x6A,
        0x96,
        0x99,
        0x9A,
        0xA6,
        0xA9,
        0xAA,
        0xAB,
        0xAE,
        0xAF
      ],
      [
        0x50,
        0x51,
        0x54,
        0x55,
        0x61,
        0x64,
        0x65,
        0x95,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xB5,
        0xBA
      ],
      [0x51, 0x55, 0x61, 0x65, 0x66, 0x95, 0xA5, 0xA6, 0xA9, 0xAA, 0xB6, 0xBA],
      [
        0x51,
        0x55,
        0x56,
        0x61,
        0x65,
        0x66,
        0x95,
        0x96,
        0xA5,
        0xA6,
        0xAA,
        0xB6,
        0xBA
      ],
      [
        0x51,
        0x55,
        0x56,
        0x65,
        0x66,
        0x6A,
        0x96,
        0xA5,
        0xA6,
        0xA7,
        0xAA,
        0xAB,
        0xB6,
        0xBA,
        0xBB
      ],
      [0x54, 0x55, 0x64, 0x65, 0x69, 0x95, 0xA5, 0xA6, 0xA9, 0xAA, 0xB9, 0xBA],
      [0x55, 0x65, 0x66, 0x69, 0x6A, 0x95, 0xA5, 0xA6, 0xA9, 0xAA, 0xBA],
      [
        0x51,
        0x55,
        0x56,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x96,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xBA
      ],
      [
        0x51,
        0x55,
        0x56,
        0x65,
        0x66,
        0x6A,
        0x96,
        0xA5,
        0xA6,
        0xAA,
        0xAB,
        0xBA,
        0xBB
      ],
      [
        0x54,
        0x55,
        0x59,
        0x64,
        0x65,
        0x69,
        0x95,
        0x99,
        0xA5,
        0xA9,
        0xAA,
        0xB9,
        0xBA
      ],
      [
        0x54,
        0x55,
        0x59,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x99,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xBA
      ],
      [
        0x55,
        0x56,
        0x59,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xBA
      ],
      [
        0x55,
        0x56,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x96,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xAB,
        0xBA,
        0xBB
      ],
      [
        0x54,
        0x55,
        0x59,
        0x65,
        0x69,
        0x6A,
        0x99,
        0xA5,
        0xA9,
        0xAA,
        0xAD,
        0xAE,
        0xB9,
        0xBA,
        0xBE
      ],
      [
        0x54,
        0x55,
        0x59,
        0x65,
        0x69,
        0x6A,
        0x99,
        0xA5,
        0xA9,
        0xAA,
        0xAE,
        0xBA,
        0xBE
      ],
      [
        0x55,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xAE,
        0xBA,
        0xBE
      ],
      [
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x9A,
        0xA6,
        0xA9,
        0xAA,
        0xAB,
        0xAE,
        0xBA
      ],
      [
        0x40,
        0x45,
        0x51,
        0x54,
        0x55,
        0x85,
        0x91,
        0x94,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xEA
      ],
      [
        0x41,
        0x45,
        0x51,
        0x55,
        0x56,
        0x85,
        0x91,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xAA,
        0xEA
      ],
      [
        0x41,
        0x45,
        0x51,
        0x55,
        0x56,
        0x85,
        0x91,
        0x95,
        0x96,
        0x9A,
        0xA6,
        0xAA,
        0xD6,
        0xEA
      ],
      [
        0x41,
        0x45,
        0x51,
        0x55,
        0x56,
        0x86,
        0x92,
        0x95,
        0x96,
        0x97,
        0x9A,
        0xA6,
        0xAA,
        0xAB,
        0xD6,
        0xEA,
        0xEB
      ],
      [
        0x44,
        0x45,
        0x54,
        0x55,
        0x59,
        0x85,
        0x94,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA9,
        0xAA,
        0xEA
      ],
      [
        0x45,
        0x55,
        0x85,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xDA,
        0xEA
      ],
      [0x45, 0x55, 0x56, 0x85, 0x95, 0x96, 0x99, 0x9A, 0xA6, 0xAA, 0xDA, 0xEA],
      [
        0x45,
        0x55,
        0x56,
        0x86,
        0x95,
        0x96,
        0x9A,
        0x9B,
        0xA6,
        0xAA,
        0xAB,
        0xDA,
        0xEA,
        0xEB
      ],
      [
        0x44,
        0x45,
        0x54,
        0x55,
        0x59,
        0x85,
        0x94,
        0x95,
        0x99,
        0x9A,
        0xA9,
        0xAA,
        0xD9,
        0xEA
      ],
      [0x45, 0x55, 0x59, 0x85, 0x95, 0x96, 0x99, 0x9A, 0xA9, 0xAA, 0xDA, 0xEA],
      [
        0x45,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x85,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xAA,
        0xDA,
        0xEA
      ],
      [
        0x45,
        0x55,
        0x56,
        0x5A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0x9B,
        0xA6,
        0xAA,
        0xAB,
        0xDA,
        0xEA,
        0xEB
      ],
      [
        0x44,
        0x45,
        0x54,
        0x55,
        0x59,
        0x89,
        0x95,
        0x98,
        0x99,
        0x9A,
        0x9D,
        0xA9,
        0xAA,
        0xAE,
        0xD9,
        0xEA,
        0xEE
      ],
      [
        0x45,
        0x55,
        0x59,
        0x89,
        0x95,
        0x99,
        0x9A,
        0x9E,
        0xA9,
        0xAA,
        0xAE,
        0xDA,
        0xEA,
        0xEE
      ],
      [
        0x45,
        0x55,
        0x59,
        0x5A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0x9E,
        0xA9,
        0xAA,
        0xAE,
        0xDA,
        0xEA,
        0xEE
      ],
      [
        0x45,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0x9B,
        0x9E,
        0xAA,
        0xAB,
        0xAE,
        0xDA,
        0xEA,
        0xEF
      ],
      [
        0x50,
        0x51,
        0x54,
        0x55,
        0x65,
        0x91,
        0x94,
        0x95,
        0x96,
        0x99,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xEA
      ],
      [
        0x51,
        0x55,
        0x91,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xE6,
        0xEA
      ],
      [0x51, 0x55, 0x56, 0x91, 0x95, 0x96, 0x9A, 0xA5, 0xA6, 0xAA, 0xE6, 0xEA],
      [
        0x51,
        0x55,
        0x56,
        0x92,
        0x95,
        0x96,
        0x9A,
        0xA6,
        0xA7,
        0xAA,
        0xAB,
        0xE6,
        0xEA,
        0xEB
      ],
      [
        0x54,
        0x55,
        0x94,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xE9,
        0xEA
      ],
      [0x55, 0x95, 0x96, 0x99, 0x9A, 0xA5, 0xA6, 0xA9, 0xAA, 0xEA],
      [0x55, 0x56, 0x95, 0x96, 0x99, 0x9A, 0xA5, 0xA6, 0xA9, 0xAA, 0xEA],
      [0x55, 0x56, 0x95, 0x96, 0x9A, 0xA6, 0xAA, 0xAB, 0xEA, 0xEB],
      [0x54, 0x55, 0x59, 0x94, 0x95, 0x99, 0x9A, 0xA5, 0xA9, 0xAA, 0xE9, 0xEA],
      [0x55, 0x59, 0x95, 0x96, 0x99, 0x9A, 0xA5, 0xA6, 0xA9, 0xAA, 0xEA],
      [
        0x45,
        0x55,
        0x56,
        0x59,
        0x5A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xEA
      ],
      [
        0x45,
        0x55,
        0x56,
        0x5A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA6,
        0xAA,
        0xAB,
        0xEA,
        0xEB
      ],
      [
        0x54,
        0x55,
        0x59,
        0x95,
        0x98,
        0x99,
        0x9A,
        0xA9,
        0xAA,
        0xAD,
        0xAE,
        0xE9,
        0xEA,
        0xEE
      ],
      [0x55, 0x59, 0x95, 0x99, 0x9A, 0xA9, 0xAA, 0xAE, 0xEA, 0xEE],
      [
        0x45,
        0x55,
        0x59,
        0x5A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA9,
        0xAA,
        0xAE,
        0xEA,
        0xEE
      ],
      [
        0x55,
        0x56,
        0x59,
        0x5A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xAA,
        0xAB,
        0xAE,
        0xEA,
        0xEF
      ],
      [
        0x50,
        0x51,
        0x54,
        0x55,
        0x65,
        0x91,
        0x94,
        0x95,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xE5,
        0xEA
      ],
      [0x51, 0x55, 0x65, 0x91, 0x95, 0x96, 0xA5, 0xA6, 0xA9, 0xAA, 0xE6, 0xEA],
      [
        0x51,
        0x55,
        0x56,
        0x65,
        0x66,
        0x91,
        0x95,
        0x96,
        0xA5,
        0xA6,
        0xAA,
        0xE6,
        0xEA
      ],
      [
        0x51,
        0x55,
        0x56,
        0x66,
        0x95,
        0x96,
        0x9A,
        0xA5,
        0xA6,
        0xA7,
        0xAA,
        0xAB,
        0xE6,
        0xEA,
        0xEB
      ],
      [0x54, 0x55, 0x65, 0x94, 0x95, 0x99, 0xA5, 0xA6, 0xA9, 0xAA, 0xE9, 0xEA],
      [0x55, 0x65, 0x95, 0x96, 0x99, 0x9A, 0xA5, 0xA6, 0xA9, 0xAA, 0xEA],
      [
        0x51,
        0x55,
        0x56,
        0x65,
        0x66,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xEA
      ],
      [
        0x51,
        0x55,
        0x56,
        0x66,
        0x95,
        0x96,
        0x9A,
        0xA5,
        0xA6,
        0xAA,
        0xAB,
        0xEA,
        0xEB
      ],
      [
        0x54,
        0x55,
        0x59,
        0x65,
        0x69,
        0x94,
        0x95,
        0x99,
        0xA5,
        0xA9,
        0xAA,
        0xE9,
        0xEA
      ],
      [
        0x54,
        0x55,
        0x59,
        0x65,
        0x69,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xEA
      ],
      [
        0x55,
        0x56,
        0x59,
        0x65,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xEA
      ],
      [
        0x55,
        0x56,
        0x5A,
        0x66,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xAB,
        0xEA,
        0xEB
      ],
      [
        0x54,
        0x55,
        0x59,
        0x69,
        0x95,
        0x99,
        0x9A,
        0xA5,
        0xA9,
        0xAA,
        0xAD,
        0xAE,
        0xE9,
        0xEA,
        0xEE
      ],
      [
        0x54,
        0x55,
        0x59,
        0x69,
        0x95,
        0x99,
        0x9A,
        0xA5,
        0xA9,
        0xAA,
        0xAE,
        0xEA,
        0xEE
      ],
      [
        0x55,
        0x59,
        0x5A,
        0x69,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xAE,
        0xEA,
        0xEE
      ],
      [
        0x55,
        0x56,
        0x59,
        0x5A,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA6,
        0xA9,
        0xAA,
        0xAB,
        0xAE,
        0xEA
      ],
      [
        0x50,
        0x51,
        0x54,
        0x55,
        0x65,
        0x95,
        0xA1,
        0xA4,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xB5,
        0xBA,
        0xE5,
        0xEA,
        0xFA
      ],
      [
        0x51,
        0x55,
        0x65,
        0x95,
        0xA1,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xB6,
        0xBA,
        0xE6,
        0xEA,
        0xFA
      ],
      [
        0x51,
        0x55,
        0x65,
        0x66,
        0x95,
        0x96,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xB6,
        0xBA,
        0xE6,
        0xEA,
        0xFA
      ],
      [
        0x51,
        0x55,
        0x56,
        0x65,
        0x66,
        0x95,
        0x96,
        0xA5,
        0xA6,
        0xA7,
        0xAA,
        0xAB,
        0xB6,
        0xBA,
        0xE6,
        0xEA,
        0xFB
      ],
      [
        0x54,
        0x55,
        0x65,
        0x95,
        0xA4,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xB9,
        0xBA,
        0xE9,
        0xEA,
        0xFA
      ],
      [0x55, 0x65, 0x95, 0xA5, 0xA6, 0xA9, 0xAA, 0xBA, 0xEA, 0xFA],
      [
        0x51,
        0x55,
        0x65,
        0x66,
        0x95,
        0x96,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xBA,
        0xEA,
        0xFA
      ],
      [
        0x55,
        0x56,
        0x65,
        0x66,
        0x95,
        0x96,
        0xA5,
        0xA6,
        0xAA,
        0xAB,
        0xBA,
        0xEA,
        0xFB
      ],
      [
        0x54,
        0x55,
        0x65,
        0x69,
        0x95,
        0x99,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xB9,
        0xBA,
        0xE9,
        0xEA,
        0xFA
      ],
      [
        0x54,
        0x55,
        0x65,
        0x69,
        0x95,
        0x99,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xBA,
        0xEA,
        0xFA
      ],
      [
        0x55,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xBA,
        0xEA,
        0xFA
      ],
      [
        0x55,
        0x56,
        0x65,
        0x66,
        0x6A,
        0x95,
        0x96,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xAB,
        0xBA,
        0xEA
      ],
      [
        0x54,
        0x55,
        0x59,
        0x65,
        0x69,
        0x95,
        0x99,
        0xA5,
        0xA9,
        0xAA,
        0xAD,
        0xAE,
        0xB9,
        0xBA,
        0xE9,
        0xEA,
        0xFE
      ],
      [
        0x55,
        0x59,
        0x65,
        0x69,
        0x95,
        0x99,
        0xA5,
        0xA9,
        0xAA,
        0xAE,
        0xBA,
        0xEA,
        0xFE
      ],
      [
        0x55,
        0x59,
        0x65,
        0x69,
        0x6A,
        0x95,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xAE,
        0xBA,
        0xEA
      ],
      [
        0x55,
        0x56,
        0x59,
        0x5A,
        0x65,
        0x66,
        0x69,
        0x6A,
        0x95,
        0x96,
        0x99,
        0x9A,
        0xA5,
        0xA6,
        0xA9,
        0xAA,
        0xAB,
        0xAE,
        0xBA,
        0xEA
      ],
    ];
    final latticePoints = <_LatticePoint4D>[];
    for (int i = 0; i < 256; i++) {
      int cx = ((i >> 0) & 3) - 1;
      int cy = ((i >> 2) & 3) - 1;
      int cz = ((i >> 4) & 3) - 1;
      int cw = ((i >> 6) & 3) - 1;
      latticePoints.add(_LatticePoint4D(cx, cy, cz, cw));
    }
    for (int i = 0; i < 256; i++) {
      _lookup4d.add(<_LatticePoint4D>[]);
      for (int j = 0; j < lookup4DPregen[i].length; j++) {
        _lookup4d[i].add(latticePoints[lookup4DPregen[i][j]]);
      }
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
        Grad3(grad.dx / _kN3, grad.dy / _kN3, grad.dz / _kN3),
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
        Grad4(grad.dx / _kN4, grad.dy / _kN4, grad.dz / _kN4, grad.dw / _kN4),
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
  _LatticePoint4D(this.xsv, this.ysv, this.zsv, this.wsv) {
    double ssv = (xsv + ysv + zsv + wsv) * -0.138196601125011;
    dx = -xsv - ssv;
    dy = -ysv - ssv;
    dz = -zsv - ssv;
    dw = -wsv - ssv;
  }

  final int xsv, ysv, zsv, wsv;
  late final double dx, dy, dz, dw;
}
