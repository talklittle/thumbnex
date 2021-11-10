# Thumbnex

[![Build Status](https://github.com/talklittle/thumbnex/actions/workflows/ci.yml/badge.svg)](https://github.com/talklittle/thumbnex/actions?query=workflow%3ACI)
[![Module Version](https://img.shields.io/hexpm/v/thumbnex.svg)](https://hex.pm/packages/thumbnex)

Elixir library to generate thumbnails from images and videos.

Documentation: https://hexdocs.pm/thumbnex/

## Installation

Add `:thumbnex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:thumbnex, "~> 0.3.6"}
  ]
end
```

## Prerequisites

* [ImageMagick](https://imagemagick.org)
* [FFmpeg](https://ffmpeg.org)

## Release notes

See the [changelog](./CHANGELOG.md) for changes between versions.

## Examples

Create a regular thumbnail:

```elixir
Thumbnex.create_thumbnail(
  "/path/to/input.mp4",
  "/path/to/output.jpg",
  max_width: 200,
  max_height: 200
)
```

Create a lightweight animated GIF preview:

```elixir
Thumbnex.animated_gif_thumbnail(
  "/path/to/input.mp4",
  "/path/to/output.gif",
  frame_count: 4,
  fps: 1
)
```

## Copyright and License

Copyright (c) 2016 Andrew Shu

Thumbnex source code is licensed under the [MIT License](./LICENSE.md).
