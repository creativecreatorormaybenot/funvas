/// Floors the given [double] towards negative infinity faster than [floor]
/// does.
///
/// There is a test case validating that this is indeed (if only slightly)
/// faster than [floor], always.
int fastFloor(double x) {
  // We cannot simply return x.toInt() because casting to an integer floors
  // towards zero (truncates) and we want to floor towards negative infinity.
  final xi = x.toInt();
  return x < xi ? xi - 1 : xi;
}
