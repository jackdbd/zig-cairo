# zig-cairo

[![Build Status](https://travis-ci.com/jackdbd/zig-cairo.svg?branch=main)](https://travis-ci.com/jackdbd/zig-cairo)

Thin wrapper for the [Cairo](https://github.com/freedesktop/cairo) 2D graphics library.

🚧 Very much a work in progress... 🚧

Run `zig build --help` to see all the compilation targets.

## Examples

Most examples generate a PNG. Here I use [feh](https://feh.finalrewind.org/) to view the generated file:

```sh
zig build rounded_rectangle && feh examples/generated/rounded_rectangle.png
zig build spirograph && feh examples/generated/spirograph.png
zig build text_extents && feh examples/generated/text_extents.png
```

A few examples generate a SVG.

```sh
zig build surface_svg && inkscape examples/generated/test-image.svg
```

Some other examples don't generate any image file. This one opens a window and renders cairo graphics inside of it (using a Cairo [XCB](https://xcb.freedesktop.org/) surface):

```sh
zig build surface_xcb
```

## Tests

```sh
# run all tests, in all modes (debug, release-fast, release-safe, release-small)
zig build test

# run all tests, only in debug mode
zig build test-debug
```

Tested on these zig compiler versions using [zigup](https://github.com/marler8997/zigup):

- 0.6.0
- 0.7.0 (not working, see [#2](https://github.com/jackdbd/zig-cairo/issues/2))
- 0.7.1 (not working, see [#2](https://github.com/jackdbd/zig-cairo/issues/2))
- 0.8.0-dev.1032+8098b3f84
