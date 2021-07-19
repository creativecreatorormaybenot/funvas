import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:open_simplex_2/src/fast_floor.dart';
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

    expect(fastFloorRuntime, lessThan(floorRuntime));
  });
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
      fastFloor(n);
    }
    for (var n = -pi; n > -1e7; n *= e) {
      fastFloor(n);
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
