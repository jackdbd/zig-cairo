const std = @import("std");
const builtin = @import("builtin");
const pi = std.math.pi;
const cairo = @import("cairo");
const setBackground = @import("utils.zig").setBackground;

/// Zig porting of this example from the Perl Cairo tutorial.
/// https://www.lemoda.net/cairo/cairo-tutorial/grid.html
fn drawGrid(cr: *cairo.Context, size: u16, divisions: usize) void {
    cr.setSourceRgb(0.4, 0.4, 1.0); // blue

    var i: usize = 0;
    while (i < divisions) : (i += 1) {
        const s = @intToFloat(f64, size);
        const k = s * @intToFloat(f64, i) / @intToFloat(f64, divisions);
        cr.moveTo(k, 0);
        cr.lineTo(k, s);
        cr.moveTo(0, k);
        cr.lineTo(s, k);
    }
    cr.stroke();
}

pub fn main() !void {
    const size: u16 = 400;
    var surface = try cairo.Surface.image(size, size);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    const divisions: usize = 10;
    drawGrid(&cr, size, divisions);
    _ = surface.writeToPng("examples/generated/grid.png");
}
