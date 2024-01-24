# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.5.0 (2024-01-24)

* Breaking changes
  * `Thumbnex.create_thumbnail/3` can now return `{:error, error_output}` instead of crashing. Still returns `:ok` on success. ([#15](https://github.com/talklittle/thumbnex/pull/15))
  * `Thumbnex.animated_gif_thumbnail/3` can return `{:error, {cmd_output, error_status}}` instead of crashing. Still returns `:ok` on success. ([#15](https://github.com/talklittle/thumbnex/pull/15))
  * `Thumbnex.Animations.duration/1` now returns `{:ok, duration}` or `{:ok, :no_duration}` or `{:error, reason}`. ([#15](https://github.com/talklittle/thumbnex/pull/15))
  * `Thumbnex.ExtractFrame.single_frame/3` now returns `{:ok, path}` or `{:error, {cmd_output, error_status}}`. ([#15](https://github.com/talklittle/thumbnex/pull/15))
  * `Thumbnex.ExtractFrame.multiple_frames/4` now returns `{:ok, path}` or `{:error, {cmd_output, error_status}}`. ([#15](https://github.com/talklittle/thumbnex/pull/15))
  * Require Elixir 1.12.

* Enhancements
  * Bump dependency versions. ([#16](https://github.com/talklittle/thumbnex/pull/16))

* Bugfixes
  * Fixed warnings on Elixir 1.16. ([#17](https://github.com/talklittle/thumbnex/pull/17))

## 0.4.0 (2021-11-16)

* Bump ffmpex dependency to 0.9.0.
* Require Elixir 1.9.

### 0.3.6 (2021-11-10)

* Bump ffmpex dependency to 0.8.0.

### 0.3.5 (2021-07-03)

* Bump mogrify dependency to 0.9.0.

### 0.3.4 (2021-05-05)

* Bump dependency versions.

### 0.3.3 (2020-07-09)

* Bump dependency versions.

### 0.3.2 (2019-11-26)

* Fix `Thumbnex.Animations.duration/1` regression.

### 0.3.1 (2019-09-05)

* Bump ffmpex dependency to 0.7.0.
* Bump mogrify dependency to 0.7.3.

## 0.3.0 (2018-03-26)

* Bump ffmpex dependency to 0.5.0.
* Require Elixir 1.4.

### 0.2.4 (2017-07-27)

* Fix Elixir 1.5, Erlang 19 warnings.

### 0.2.3 (2017-01-07)

* Fix Elixir 1.4 warnings.
* Bump mogrify dependency to 0.5.3.

### 0.2.2 (2016-12-03)

* Bump ffmpex dependency to 0.4.0.

### 0.2.1 (2016-09-10)

* Bump ffmpex dependency to 0.3.0.

## 0.2.0 (2016-08-24)

* Added `Thumbnex.animated_gif_thumbnail/3`.

## 0.1.0 (2016-08-17)

* First Thumbnex release.
* Create thumbnail from image or video.
* Specify dimensions, image format, and timestamp.
