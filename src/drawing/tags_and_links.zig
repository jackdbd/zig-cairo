//! Hyperlinks and document structure.
const std = @import("std");
const c = @import("../c.zig");

/// https://www.cairographics.org/manual/cairo-Tags-and-Links.html#cairo-tag-begin
pub fn tagBegin(c_ptr: *c.struct__cairo, tag_name: []const u8, attributes: ?[]const u8) void {
    if (attributes == null) {
        c.cairo_tag_begin(c_ptr, tag_name.ptr, null);
    } else {
        c.cairo_tag_begin(c_ptr, tag_name.ptr, attributes.?.ptr);
    }
}

/// https://www.cairographics.org/manual/cairo-Tags-and-Links.html#cairo-tag-end
pub fn tagEnd(c_ptr: *c.struct__cairo, tag_name: []const u8) void {
    c.cairo_tag_end(c_ptr, tag_name.ptr);
}
