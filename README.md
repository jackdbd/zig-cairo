# zig-cairo

Thin wrapper for the [Cairo](https://github.com/freedesktop/cairo) 2D graphics library.

🚧 Very much a work in progress... 🚧

Run `zig build --help` to see all the compilation targets.

## Examples

For example, the `rounded_rectangle` binary generates a PNG that you can view in your viewer of choice (I use [feh](https://feh.finalrewind.org/)):

```sh
zig build rounded_rectangle && feh examples/generated/rounded_rectangle.png
```

Some examples don't generate any image file. For example, the following one opens a window and renders cairo graphics inside of it (using a Cairo [XCB](https://xcb.freedesktop.org/) surface):

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
- 0.7.1
- 0.8.0-dev.1032+8098b3f84
