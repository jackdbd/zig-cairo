const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://www.cairographics.org/samples/text_extents/
fn textExtents(cr: *cairo.Context) !void {
    cr.selectFontFace("Sans", cairo.FontSlant.normal, cairo.FontWeight.normal);
    cr.setFontSize(100.0);
    const some_text = "cairo"; // TODO: check that text is UTF8-encoded

    var te = cr.textExtents(some_text);
    const x = 25.0;
    const y = 150.0;
    cr.moveTo(x, y);
    cr.setSourceRgb(0.0, 0.0, 0.0); // black
    cr.showText(some_text);

    // draw helping lines
    cr.setSourceRgba(1, 0.2, 0.2, 0.6);
    cr.setLineWidth(6.0);
    cr.arc(x, y, 10.0, 0, 2 * pi);
    cr.fill();
    cr.moveTo(x, y);
    try cr.relLineTo(0, -te.height);
    try cr.relLineTo(te.width, 0);
    try cr.relLineTo(te.x_bearing, -te.y_bearing);
    cr.stroke();
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    try textExtents(&cr);
    _ = surface.writeToPng("examples/generated/text_extents.png");
}
