const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://www.cairographics.org/samples/text/
fn text(cr: *cairo.Context) void {
    cr.selectFontFace("Sans", cairo.FontSlant.Normal, cairo.FontWeight.Bold);
    cr.setFontSize(90.0);

    cr.moveTo(10.0, 135.0);
    cr.setSourceRgb(0.0, 0.0, 0.0); // black
    cr.showText("Hello");

    cr.moveTo(70.0, 165.0);
    cr.textPath("void");
    cr.setSourceRgb(0.5, 0.5, 1); // bluish-violet
    cr.fillPreserve();
    cr.setSourceRgb(0.0, 0.0, 0.0); // black
    cr.setLineWidth(2.56);
    cr.stroke();

    // draw helping lines
    cr.setSourceRgba(1, 0.2, 0.2, 0.6);
    cr.arc(10.0, 135.0, 5.12, 0, 2 * pi);
    cr.closePath();
    cr.arc(70.0, 165.0, 5.12, 0, 2 * pi);
    cr.fill();
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    std.debug.print("text example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.fromSurface(&surface);
    defer cr.destroy();

    setBackground(&cr);
    text(&cr);
    _ = surface.writeToPng("examples/generated/text.png");
}
