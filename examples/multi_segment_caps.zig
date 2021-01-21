const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://www.cairographics.org/samples/multi_segment_caps/
fn multiSegmentCaps(cr: *cairo.Context) void {
    cr.setSourceRgb(0.0, 0.0, 0.0); // black

    cr.moveTo(50.0, 75.0);
    cr.lineTo(200.0, 75.0);

    cr.moveTo(50.0, 125.0);
    cr.lineTo(200.0, 125.0);

    cr.moveTo(50.0, 175.0);
    cr.lineTo(200.0, 175.0);

    cr.setLineWidth(30.0);
    cr.setLineCap(cairo.LineCap.Round);
    cr.stroke();
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    std.debug.print("multi_segment_caps example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    multiSegmentCaps(&cr);
    _ = surface.writeToPng("examples/generated/multi_segment_caps.png");
}
