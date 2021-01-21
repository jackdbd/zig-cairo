const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

// TODO: this example does nothing at the moment
// https://github.com/ziglang/zig/issues/4738
// https://github.com/ziglang/zig/pull/4973

/// https://github.com/pygobject/pycairo/blob/master/examples/pycairo_examples.ipynb
fn glyphsExample(cr: *cairo.Context) !void {
    cr.selectFontFace("Sans", cairo.FontSlant.Normal, cairo.FontWeight.Normal);
    cr.setFontSize(18.0);

    var glyph = try cairo.Glyph.allocate(3);
    std.debug.print("glyph {}\n", .{glyph});
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    std.debug.print("glyphs example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.fromSurface(&surface);
    defer cr.destroy();

    setBackground(&cr);
    try glyphsExample(&cr);
    _ = surface.writeToPng("examples/generated/glyphs.png");
}
