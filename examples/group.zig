const std = @import("std");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// https://github.com/pygobject/pycairo/blob/master/examples/pycairo_examples.ipynb
fn groupExample(cr: *cairo.Context) !void {
    cr.setSourceRgb(0.8, 0.8, 0.8); // gray
    cr.rectangle(25.6, 25.6, 153.6, 153.6);
    cr.fill();

    var red_pattern = try cairo.Pattern.createRgb(1, 0, 0);
    defer red_pattern.destroy();

    var black_pattern = try cairo.Pattern.createRgb(0, 0, 0);
    defer black_pattern.destroy();

    cr.pushGroup();
    // define a red rectangle
    cr.setSource(&red_pattern);
    cr.rectangle(76.8, 76.8, 153.6, 153.6);
    // fill the path we have just defined (i.e. the rectangle) and preserve it
    cr.fillPreserve();
    // define a black rectangular frame
    cr.setLineWidth(8.0);
    cr.setSource(&black_pattern);
    cr.stroke();
    cr.popGroupToSource();
    // paint the entire group with a semi-transparent alpha channel
    cr.paintWithAlpha(0.5);
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    // std.debug.print("group example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    try groupExample(&cr);
    _ = surface.writeToPng("examples/generated/group.png");
}
