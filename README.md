# zig-cairo

Thin wrapper for the [Cairo](https://github.com/freedesktop/cairo) 2D graphics library.

🚧 Very much a work in progress... 🚧

Run `zig build --help` to see all the compilation targets.

For example, the `rounded_rectangle` binary generates a PNG that you can view in your viewer of choice (I use [feh](https://feh.finalrewind.org/)):

```sh
zig build rounded_rectangle && feh examples/generated/rounded_rectangle.png
```
