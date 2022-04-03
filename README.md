# zig-cairo

[![Build Status](https://travis-ci.com/jackdbd/zig-cairo.svg?branch=main)](https://travis-ci.com/jackdbd/zig-cairo)

Thin wrapper for the [cairo](https://github.com/freedesktop/cairo) 2D graphics library.

🚧 Very much a work in progress... 🚧

## Naming convention

As suggested in the [cairo Appendix](https://www.cairographics.org/manual/language-bindings.html), the type names and method names of the original C library were changed to follow the [Zig Style Guide](https://ziglang.org/documentation/0.7.1/#Names). For example, a method like `cairo_set_source(cr, source)` in cairo becomes `cr.setSource(source)` in zig-cairo.

## Examples

Run `zig build --help` to see all the compilation targets.

Most examples generate a PNG. Here I use [feh](https://feh.finalrewind.org/) to view the generated file:

```sh
zig build rounded_rectangle && feh examples/generated/rounded_rectangle.png
zig build spirograph && feh examples/generated/spirograph.png
zig build text_extents && feh examples/generated/text_extents.png
```

A few examples generate a SVG:

```sh
zig build surface_svg && inkscape examples/generated/test-image.svg
```

Some other examples don't generate any image file. This one opens a window and renders cairo graphics inside of it (using a cairo [XCB](https://xcb.freedesktop.org/) surface):

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

Tested against these zig compiler versions on [Travis CI](https://travis-ci.com/github/jackdbd/zig-cairo) and using [zigup](https://github.com/marler8997/zigup) on my machine:

- 0.7.0 (not working, see [#2](https://github.com/jackdbd/zig-cairo/issues/2))
- 0.7.1 (not working, see [#2](https://github.com/jackdbd/zig-cairo/issues/2))
- 0.8.0-dev.1032+8098b3f84

## stuff...

You can also [download cairo source files](https://www.cairographics.org/download/).

```sh
git clone git://anongit.freedesktop.org/git/cairo
```

```sh
zig translate-c ~/repos/cairo/util/cairo-gobject/cairo-gobject-enums.c -lcairo

zig translate-c ~/repos/cairo/src/cairo-features.h ~/repos/cairo/src/cairo.h
cairo_helloworld.c -lcairo > cairo_helloworld.zig
```
