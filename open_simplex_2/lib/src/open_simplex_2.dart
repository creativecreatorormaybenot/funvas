import 'package:open_simplex_2/src/open_simplex_2f.dart';
import 'package:open_simplex_2/src/open_simplex_2s.dart';

/// Abstract base class for OpenSimplex2 noise that is the super type for the
/// public API of both [OpenSimplex2F] and [OpenSimplex2S].
///
/// Additional documentation for the methods lives in the implementing classes
/// because behavior will differ based on implementation.
abstract class OpenSimplex2 {
  /// 2D noise, standard lattice orientation.
  double noise2(double x, double y);

  /// 2D noise, with Y pointing down the main diagonal.
  double noise2XBeforeY(double x, double y);

  /// 3D Re-oriented 8-point BCC noise, classic orientation.
  double noise3Classic(double x, double y, double z);

  /// 3D Re-oriented 8-point BCC noise, with better visual isotropy in (X, Y).
  double noise3XYBeforeZ(double x, double y, double z);

  /// 3D Re-oriented 8-point BCC noise, with better visual isotropy in (X, Z).
  double noise3XZBeforeY(double x, double y, double z);

  /// 4D noise, classic lattice orientation.
  double noise4Classic(double x, double y, double z, double w);

  /// 4D noise, with XY and ZW forming orthogonal triangular-based planes.
  double noise4XYBeforeZW(double x, double y, double z, double w);

  /// 4D noise, with XZ and YW forming orthogonal triangular-based planes.
  double noise4XZBeforeYW(double x, double y, double z, double w);

  /// 4D noise, with XYZ oriented like [noise3Classic], and W for an extra degree
  /// of freedom.
  double noise4XYZBeforeW(double x, double y, double z, double w);
}
