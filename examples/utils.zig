const cairo = @import("cairo");

/// Set a cairo Context with the same gray background used on the cairo website.
/// https://www.cairographics.org/samples/
pub fn setBackground(cr: *cairo.Context) void {
    cr.setSourceRgb(0.93, 0.93, 0.93); // gray
    cr.paintWithAlpha(1.0);
}
