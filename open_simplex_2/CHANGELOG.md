## 0.2.1

* Switched from `fastFloor` to `num.floor` as https://github.com/dart-lang/sdk/commit/16e8dc257e51d48669ce8d5d91ac094325faa5b5
  has landed on stable.

## 0.2.0+1

* Fixed seeding constant on web.

## 0.2.0

* Fixed web incompatibility (due to Dart's JavaScript 64-bit signed two’s complement limitation) by
  making use of `fixnum` and its `Int64` type.

## 0.1.0+1

* Improved references in README.

## 0.1.0

* Released initial stable version.
* Updated README to indicate stable status.

## 0.0.2

* Implemented `OpenSimplex2F`.
* Introduced common `OpenSimplex2` interface.

## 0.0.1+1

* Improved public API.
* Validated `fastFloor` performance.

## 0.0.1

* Implemented `OpenSimplex2F`.
* Added example app.
