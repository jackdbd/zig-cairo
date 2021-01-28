const std = @import("std");
const cairo = @import("cairo");
const render = @import("render.zig");

pub fn main() !void {
    const width_pt: f64 = 640;
    const height_pt: f64 = 480;
    var surface = try cairo.Surface.pdf("examples/generated/report.pdf", width_pt, height_pt);
    defer surface.destroy();

    try surface.setMetadata(cairo.PdfMetadata.title, "Some Title");
    try surface.setMetadata(cairo.PdfMetadata.author, "Some author");
    try surface.setMetadata(cairo.PdfMetadata.create_date, "2021-01-28T19:49+02:00");
    try surface.setMetadata(cairo.PdfMetadata.keywords, "foo,bar");

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    cr.tagBegin("H1", null);
    cr.moveTo(20, 30);
    cr.showText("Heading 1");
    cr.tagEnd("H1");

    cr.tagBegin(cairo.Link, "uri='https://cairographics.org'");
    cr.moveTo(100, 200);
    cr.showText("This is a hyperlink to the Cairo website.");
    cr.tagEnd(cairo.Link);
}
