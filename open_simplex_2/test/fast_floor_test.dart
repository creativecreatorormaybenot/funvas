import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:test/test.dart';

void main() {
  test('fast floor beats floor', () {
    late final double fastFloorRuntime, floorRuntime;
    final fastFloorEmitter = _TestEmitter((value) => fastFloorRuntime = value);
    final fastFloorBenchmark = _FastFloorBenchmark(fastFloorEmitter);
    final floorEmitter = _TestEmitter((value) => floorRuntime = value);
    final floorBenchmark = _FloorBenchmark(floorEmitter);
    // Tested both running fast floor first versus running floor first and
    // fast floor consistently beats floor.
    floorBenchmark.report();
    fastFloorBenchmark.report();

    expect(fastFloorRuntime, greaterThan(floorRuntime));
  });
}

/// Floors the given [double] towards negative infinity faster than [floor]
/// does.
///
/// There is a test case validating that this is indeed (if only slightly)
/// faster than [floor], always.
///
/// Note that this is **not** part of the main package anymore since the testing
/// in this package lead to [num.floor] being improved to be faster than this
/// function. See https://github.com/dart-lang/sdk/issues/46650.
int _fastFloor(double x) {
  // We cannot simply return x.toInt() because casting to an integer floors
  // towards zero (truncates) and we want to floor towards negative infinity.
  final xi = x.toInt();
  return x < xi ? xi - 1 : xi;
}

class _TestEmitter extends ScoreEmitter {
  _TestEmitter(this.onResult);

  final void Function(double value) onResult;

  @override
  void emit(String testName, double value) {
    onResult(value);
  }
}

class _FastFloorBenchmark extends BenchmarkBase {
  _FastFloorBenchmark(_TestEmitter emitter)
      : super('Fast floor', emitter: emitter);

  @override
  void run() {
    for (var n = pi; n < 1e7; n *= e) {
      _fastFloor(n);
    }
    for (var n = -pi; n > -1e7; n *= e) {
      _fastFloor(n);
    }
  }
}

class _FloorBenchmark extends BenchmarkBase {
  _FloorBenchmark(_TestEmitter emitter) : super('Floor', emitter: emitter);

  @override
  void run() {
    for (var n = pi; n < 1e7; n *= e) {
      n.floor();
    }
    for (var n = -pi; n > -1e7; n *= e) {
      n.floor();
    }
  }
}
