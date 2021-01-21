const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://www.cairographics.org/samples/set_line_cap/
fn setLineCap(cr: *cairo.Context) void {
    cr.setSourceRgb(0.0, 0.0, 0.0); // black

    cr.setLineWidth(30.0);

    cr.setLineCap(cairo.LineCap.Butt); // default
    cr.moveTo(64.0, 50.0);
    cr.lineTo(64.0, 200.0);
    cr.stroke();

    cr.setLineCap(cairo.LineCap.Round);
    cr.moveTo(128.0, 50.0);
    cr.lineTo(128.0, 200.0);
    cr.stroke();

    cr.setLineCap(cairo.LineCap.Square);
    cr.moveTo(192.0, 50.0);
    cr.lineTo(192.0, 200.0);
    cr.stroke();

    // draw helping lines
    cr.setSourceRgb(1, 0.2, 0.2);
    cr.setLineWidth(2.56);
    cr.moveTo(64.0, 50.0);
    cr.lineTo(64.0, 200.0);
    cr.moveTo(128.0, 50.0);
    cr.lineTo(128.0, 200.0);
    cr.moveTo(192.0, 50.0);
    cr.lineTo(192.0, 200.0);
    cr.stroke();
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    std.debug.print("set_line_cap example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    setLineCap(&cr);
    _ = surface.writeToPng("examples/generated/set_line_cap.png");
}
