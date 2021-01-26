const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://www.cairographics.org/samples/set_line_join/
fn setLineJoin(cr: *cairo.Context) void {
    cr.setSourceRgb(0.0, 0.0, 0.0); // black

    cr.setLineWidth(40.96);

    cr.moveTo(76.8, 84.48);
    cr.relLineTo(51.2, -51.2);
    cr.relLineTo(51.2, 51.2);
    cr.setLineJoin(cairo.LineJoin.miter); // default
    cr.stroke();

    cr.moveTo(76.8, 161.28);
    cr.relLineTo(51.2, -51.2);
    cr.relLineTo(51.2, 51.2);
    cr.setLineJoin(cairo.LineJoin.bevel);
    cr.stroke();

    cr.moveTo(76.8, 238.08);
    cr.relLineTo(51.2, -51.2);
    cr.relLineTo(51.2, 51.2);
    cr.setLineJoin(cairo.LineJoin.round);
    cr.stroke();
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    // std.debug.print("set_line_join example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    setLineJoin(&cr);
    _ = surface.writeToPng("examples/generated/set_line_join.png");
}
