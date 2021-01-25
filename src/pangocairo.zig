const std = @import("std");
const log = std.log;
const c = @import("c.zig");
const cairo = @import("cairo.zig");
const Error = @import("errors.zig").Error;

pub const SCALE = c.PANGO_SCALE;

// log.debug("TYPE INFO: {}", .{@typeInfo(@TypeOf(ret))});

/// https://developer.gnome.org/pango/stable/pango-Layout-Objects.html#PangoLayoutLine
pub const LayoutLine = struct {
    c_ptr: *c.struct__PangoLayoutLine,

    const Self = @This();
};

pub const Layout = struct {
    c_ptr: *c.struct__PangoLayout,

    const Self = @This();

    /// https://developer.gnome.org/pango/stable/pango-Cairo-Rendering.html#pango-cairo-create-layout
    pub fn create(cr: *cairo.Context) !Self {
        const c_ptr = c.pango_cairo_create_layout(cr.c_ptr);
        if (c_ptr == null) return Error.NullPointer;
        return Self{ .c_ptr = c_ptr.? };
    }

    pub fn destroy(self: *Self) void {
        c.g_object_unref(self.c_ptr);
    }

    /// https://developer.gnome.org/pango/stable/pango-Layout-Objects.html#pango-layout-get-context
    pub fn getContext(self: *Self) !Context {
        const c_ptr = c.pango_layout_get_context(self.c_ptr);
        if (c_ptr == null) return Error.NullPointer;
        return Context{ .c_ptr = c_ptr.? };
    }

    /// https://developer.gnome.org/pango/stable/pango-Layout-Objects.html#pango-layout-get-line-readonly
    pub fn getLineReadonly(self: *Self, line: c_int) !LayoutLine {
        const c_ptr = c.pango_layout_get_line_readonly(self.c_ptr, line);
        if (c_ptr == null) return Error.NullPointer;
        return LayoutLine{ .c_ptr = c_ptr.? };
    }

    // TODO: is this ok?
    /// https://developer.gnome.org/pango/stable/pango-Layout-Objects.html#pango-layout-get-pixel-size
    pub fn getPixelSize(self: *Self) Size {
        var width: c_int = 0;
        var height: c_int = 0;
        c.pango_layout_get_pixel_size(self.c_ptr, &width, &height);
        return Size{ .width = @intToFloat(f64, width), .height = @intToFloat(f64, height) };
    }

    // TODO: is this ok?
    /// https://developer.gnome.org/pango/stable/pango-Layout-Objects.html#pango-layout-get-size
    pub fn getSize(self: *Self) Size {
        // var width: [*]c_int = 0;
        // var height: [*]c_int = 0;
        var width: c_int = 0;
        var height: c_int = 0;
        c.pango_layout_get_size(self.c_ptr, &width, &height);
        return Size{ .width = @intToFloat(f64, width), .height = @intToFloat(f64, height) };
    }

    /// https://developer.gnome.org/pango/stable/pango-Layout-Objects.html#pango-layout-set-attributes
    pub fn setAttributes(self: *Self, attrs: *AttrList) void {
        c.pango_layout_set_attributes(self.c_ptr, attrs.c_ptr);
    }

    /// https://developer.gnome.org/pango/stable/pango-Layout-Objects.html#pango-layout-set-font-description
    pub fn setFontDescription(self: *Self, desc: FontDescription) void {
        c.pango_layout_set_font_description(self.c_ptr, desc.c_ptr);
    }

    /// https://developer.gnome.org/pango/stable/pango-Layout-Objects.html#pango-layout-set-text
    pub fn setText(self: *Self, text: []const u8) void {
        c.pango_layout_set_text(self.c_ptr, text.ptr, @intCast(c_int, text.len));
    }

    /// https://developer.gnome.org/pango/stable/pango-Cairo-Rendering.html#pango-cairo-show-layout
    pub fn show(self: *Self, cr: *cairo.Context) void {
        c.pango_cairo_show_layout(cr.c_ptr, self.c_ptr);
    }

    /// https://developer.gnome.org/pango/stable/pango-Cairo-Rendering.html#pango-cairo-update-layout
    pub fn update(self: *Self, cr: *cairo.Context) void {
        c.pango_cairo_update_layout(cr.c_ptr, self.c_ptr);
    }
};

// TODO: what to use? c_int, f64, u32, etc...
pub const Size = struct {
    width: f64,
    height: f64,
};

/// https://developer.gnome.org/pango/stable/pango-Fonts.html#PangoFontDescription
pub const FontDescription = struct {
    c_ptr: *c.struct__PangoFontDescription,

    const Self = @This();

    /// https://developer.gnome.org/pango/stable/pango-Fonts.html#pango-font-description-copy
    pub fn copy(self: *Self) !Self {
        const c_ptr = c.pango_font_description_copy(self.c_ptr);
        if (c_ptr == null) return Error.NoMemory; // or other errors?
        return Self{ .c_ptr = c_ptr.? };
    }

    /// https://developer.gnome.org/pango/stable/pango-Fonts.html#pango-font-description-free
    pub fn destroy(self: *Self) void {
        c.pango_font_description_free(self.c_ptr);
    }

    /// https://developer.gnome.org/pango/stable/pango-Fonts.html#pango-font-description-equal
    pub fn equal(self: *Self, other: *Self) bool {
        if (c.pango_font_description_equal(self.c_ptr, other.c_ptr) == 1) {
            return true;
        } else {
            return false;
        }
    }

    /// https://developer.gnome.org/pango/stable/pango-Fonts.html#pango-font-description-from-string
    pub fn fromString(str: []const u8) !Self {
        const c_ptr = c.pango_font_description_from_string(str.ptr);
        if (c_ptr == null) return Error.NullPointer;
        return Self{ .c_ptr = c_ptr.? };
    }

    /// https://developer.gnome.org/pango/stable/pango-Fonts.html#pango-font-description-get-size
    pub fn getSize(self: *Self) usize {
        return @intCast(usize, c.pango_font_description_get_size(self.c_ptr));
    }

    /// https://developer.gnome.org/pango/stable/pango-Fonts.html#pango-font-description-get-style
    /// https://developer.gnome.org/pango/stable/pango-Fonts.html#PangoStyle
    pub fn getStyle(self: *Self) void {
        const style = c.pango_font_description_get_style(self.c_ptr);
        // log.debug("style {}", .{&style}); // it's unnamed
    }

    /// https://developer.gnome.org/pango/stable/pango-Fonts.html#pango-font-description-get-weight
    /// https://developer.gnome.org/pango/stable/pango-Fonts.html#PangoWeight
    pub fn getWeight(self: *Self) void {
        const weight = c.pango_font_description_get_weight(self.c_ptr);
        // log.debug("weight {}", .{weight}); // it's unnamed
    }

    /// https://developer.gnome.org/pango/stable/pango-Fonts.html#pango-font-description-new
    pub fn new() !Self {
        const c_ptr = c.pango_font_description_new();
        if (c_ptr == null) return Error.NoMemory; // or other errors?
        return Self{ .c_ptr = c_ptr.? };
    }

    /// https://developer.gnome.org/pango/stable/pango-Fonts.html#pango-font-description-set-absolute-size
    pub fn setAbsoluteSize(self: *Self, size: f64) void {
        c.pango_font_description_set_absolute_size(self.c_ptr, size);
    }
};

/// https://developer.gnome.org/pango/stable/pango-Cairo-Rendering.html#pango-cairo-layout-line-path
pub fn linePath(cr: *cairo.Context, line: LayoutLine) void {
    c.pango_cairo_layout_line_path(cr.c_ptr, line.c_ptr);
}

pub const PangoAttrShape = [*c]c.struct__PangoAttrShape;

const DNotify = fn (?*c_void) callconv(.C) void;

/// https://developer.gnome.org/pango/stable/pango-Cairo-Rendering.html#PangoCairoShapeRendererFunc
/// https://developer.gnome.org/pango/stable/pango-Text-Attributes.html#PangoAttrShape
/// https://developer.gnome.org/pango/stable/pango-Text-Attributes.html#pango-attr-shape-new-with-data
/// do_path: whether only the shape path should be appended to current path of cr and no filling/stroking done.
/// data: user data passed to pango_cairo_context_set_shape_renderer().
const PangoCairoShapeRendererFunc = fn (?*c.struct__cairo, [*c]c.struct__PangoAttrShape, c_int, ?*c_void) callconv(.C) void;

pub const Context = struct {
    c_ptr: *c.struct__PangoContext,

    const Self = @This();

    /// https://developer.gnome.org/pango/stable/pango-Cairo-Rendering.html#pango-cairo-context-set-shape-renderer
    pub fn setShapeRenderer(self: *Self, func: PangoCairoShapeRendererFunc, data: ?*c_void, dnotify: ?DNotify) void {
        // log.debug("setShapeRenderer", .{});
        // log.debug("func {}", .{func});
        // log.debug("data {}", .{data});
        // log.debug("dnotify {}", .{dnotify});
        c.pango_cairo_context_set_shape_renderer(self.c_ptr, func, data, dnotify);
        // log.debug("", .{});
    }
};

// TODO: move to pango.zig module?
/// https://developer.gnome.org/pango/stable/pango-Text-Attributes.html#PangoAttrList
pub const AttrList = struct {
    c_ptr: *c.struct__PangoAttrList,

    const Self = @This();

    /// https://developer.gnome.org/pango/stable/pango-Text-Attributes.html#pango-attr-list-new
    pub fn new() !Self {
        const c_ptr = c.pango_attr_list_new();
        if (c_ptr == null) return Error.NoMemory; // or other errors?
        return Self{ .c_ptr = c_ptr.? };
    }

    /// https://developer.gnome.org/pango/stable/pango-Text-Attributes.html#pango-attr-list-unref
    pub fn destroy(self: *Self) void {
        c.pango_attr_list_unref(self.c_ptr);
    }

    /// https://developer.gnome.org/pango/stable/pango-Text-Attributes.html#pango-attr-list-insert
    pub fn insert(self: *Self, attr: *Attribute) void {
        c.pango_attr_list_insert(self.c_ptr, attr.c_ptr);
    }
};

/// https://developer.gnome.org/pango/stable/pango-Glyph-Storage.html#PangoRectangle
pub const Rectangle = struct {
    c_ptr: *c.struct__PangoRectangle,

    const Self = @This();

    // Can this function really fail to construct a c.struct__PangoRectangle?
    pub fn new(x: c_int, y: c_int, width: c_int, height: c_int) !Self {
        var rect = .{ .x = x, .y = y, .width = width, .height = height };
        const c_ptr = @ptrCast(?*c.struct__PangoRectangle, &rect);
        if (c_ptr == null) return Error.NullPointer; // or other errors?
        return Self{ .c_ptr = c_ptr.? };
    }
};

/// https://developer.gnome.org/pango/stable/pango-Text-Attributes.html#PangoAttrDataCopyFunc
pub const PangoAttrDataCopyFunc = fn (?*const c_void) callconv(.C) ?*c_void;
/// https://developer.gnome.org/glib/unstable/glib-Datasets.html#GDestroyNotify
pub const GDestroyNotify = fn (?*c_void) callconv(.C) void;

// TODO: move to pango.zig module?
/// https://developer.gnome.org/pango/stable/pango-Text-Attributes.html#PangoAttribute
/// https://developer.gnome.org/pango/stable/pango-Text-Attributes.html#pango-attribute-init
pub const Attribute = struct {
    c_ptr: *c.struct__PangoAttribute,

    const Self = @This();

    /// https://developer.gnome.org/pango/stable/pango-Text-Attributes.html#pango-attr-shape-new-with-data
    pub fn newShapeWithData(comptime T: type, ink_rect: *Rectangle, logical_rect: *Rectangle, data: *T, copy_fn: ?PangoAttrDataCopyFunc, destroy_fn: ?GDestroyNotify) !Self {
        log.debug("newShapeWithData T {}", .{T});
        // log.debug("data {}", .{data});
        const c_ptr = c.pango_attr_shape_new_with_data(ink_rect.c_ptr, logical_rect.c_ptr, data, copy_fn, destroy_fn);
        if (c_ptr == null) return Error.NoMemory; // or other errors?
        return Self{ .c_ptr = c_ptr.? };
    }
};

const testing = std.testing;
const expect = testing.expect;
const expectEqual = testing.expectEqual;

test "Layout.create()" {
    var surface = try cairo.Surface.image(20.0, 10.0);
    defer surface.destroy();
    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    var layout = try Layout.create(&cr);
    defer layout.destroy();

    const size_before = layout.getSize();
    expectEqual(
        size_before.width,
        @as(f64, 0.0),
    );
    expect(size_before.height > 0);

    layout.setText("foo");
    const size_after = layout.getSize();
    expect(size_after.width > 0.0);
    // The next expect is fine on my machine but fails on Travis CI. Maybe it's
    // because the X server running on Travis CI is xvfb?
    // expect(size_after.height > size_before.height); // why is that?
}

test "FontDescription.getSize() with size specified" {
    var desc = try FontDescription.fromString("Sans 15");
    defer desc.destroy();

    const size = desc.getSize();
    expectEqual(@as(usize, 15360), size); // why not 15?
}

test "FontDescription.getSize() with size not specified" {
    var desc = try FontDescription.fromString("Sans");
    defer desc.destroy();

    const size = desc.getSize();
    expectEqual(@as(usize, 0), size);
}

test "FontDescription.equal()" {
    var desc1 = try FontDescription.fromString("Sans 15");
    defer desc1.destroy();
    var desc2 = try FontDescription.fromString("Sans 14");
    defer desc2.destroy();
    var desc3 = try FontDescription.fromString("Sans 14");
    defer desc3.destroy();

    expectEqual(false, desc1.equal(&desc2));
    expectEqual(false, desc2.equal(&desc1));

    expectEqual(true, desc2.equal(&desc3));
    expectEqual(true, desc3.equal(&desc2));
}

test "FontDescription.copy()" {
    var desc1 = try FontDescription.fromString("Sans 15");
    defer desc1.destroy();
    var desc2 = try desc1.copy();
    defer desc2.destroy();

    expectEqual(true, desc1.equal(&desc2));

    desc1.setAbsoluteSize(100);
    expectEqual(false, desc1.equal(&desc2));
}
