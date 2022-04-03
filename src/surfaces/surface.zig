//! Cairo Surfaces
//! https://www.cairographics.org/manual/cairo-cairo-surface-t.html
const std = @import("std");
const c = @import("../c.zig");

const error_handling = @import("../utilities/error_handling.zig");
const Error = error_handling.Error;
const statusToError = error_handling.statusToError;

const enums = @import("../enums.zig");
const Content = enums.Content;
const Format = enums.Format;
const PdfMetadata = enums.PdfMetadata;
const SurfaceType = enums.SurfaceType;
const Unit = enums.Unit;

const Device = @import("device.zig").Device;
const image_surface = @import("image.zig");
const pdf_surface = @import("pdf.zig");
const png_surface = @import("png.zig");
const script_surface = @import("script.zig");
const svg_surface = @import("svg.zig");
const xcb_surface = @import("xcb.zig");

/// Wrapper for the Cairo cairo_surface_t C struct.
pub const Surface = struct {
    /// The original cairo_surface_t C struct.
    c_ptr: *c.struct__cairo_surface,

    const Self = @This();

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-copy-page
    pub fn copyPage(self: *Self) void {
        c.cairo_surface_copy_page(self.c_ptr);
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-create-for-rectangle
    pub fn createForRectangle(_: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// https://www.cairographics.org/manual/cairo-PNG-Support.html#cairo-image-surface-create-from-png
    pub fn createFromPng(filename: []const u8) !Surface {
        var c_ptr = try png_surface.createFromPng(filename);
        try Self.status(c_ptr);
        return Self{ .c_ptr = c_ptr };
    }

    /// Create a new surface that is as compatible as possible with an existing
    /// surface. The caller owns the returned object and should call destroy on
    /// it when he no longer needs it.
    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-create-similar
    pub fn createSimilar(other: *Self, content: Content, width: u16, height: u16) !Self {
        var c_ptr = c.cairo_surface_create_similar(other.c_ptr, content.toCairoEnum(), @intCast(c_int, width), @intCast(c_int, height));
        // cairo_surface_create_similar always return a valid pointer, but it
        // can return a pointer to a "nil" surface if the `other` surface is
        // already in an error state, or if any other error occurs.
        try Self.status(c_ptr);
        return Self{ .c_ptr = c_ptr.? };
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-create-similar-image
    pub fn createSimilarImage(other: *Self, format: Format, width: u16, height: u16) !Self {
        var c_ptr = c.cairo_surface_create_similar_image(other.c_ptr, format.toCairoEnum(), @intCast(c_int, width), @intCast(c_int, height));
        // cairo_surface_create_similar_image always return a valid pointer, but
        // it can return a pointer to a "nil" surface if the `other` surface is
        // already in an error state, or if any other error occurs.
        try Self.status(c_ptr);
        return Self{ .c_ptr = c_ptr.? };
    }

    /// Decrease the reference count on surface by one.
    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-destroy
    pub fn destroy(self: *Self) void {
        c.cairo_surface_destroy(self.c_ptr);
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-finish
    pub fn finish(self: *Self) void {
        c.cairo_surface_finish(self.c_ptr);
    }

    /// Do any pending drawing for the surface and also restore any temporary modifications cairo has made to the surface's state.
    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-flush/
    pub fn flush(self: *Self) void {
        c.cairo_surface_flush(self.c_ptr);
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-get-content
    pub fn getContent(_: *Self) void {
        @panic("TODO: to be implemented");
    }
    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-get-device
    // pub fn getDevice(cairo_surface: *c.struct__cairo_surface) !Device {
    pub fn getDevice(self: *Self) !Device {
        const c_ptr = c.cairo_surface_get_device(self.c_ptr);
        // The C pointer is null if the surface does not have an associated
        // device (for example, if the user called surface.writeComment() on a
        // non-script surface). I am not sure which error would be more
        // appropriate to return.
        // 1. CAIRO_STATUS_DEVICE_TYPE_MISMATCH?
        // 2. CAIRO_STATUS_DEVICE_ERROR?
        // 3. something else?
        if (c_ptr == null) return error.OperationNotAvailableForSurface;
        return Device{ .c_ptr = c_ptr.? };
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-get-device-offset
    pub fn getDeviceOffset(_: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-get-device-scale
    pub fn getDeviceScale(_: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-get-document-unit
    pub fn getDocumentUnit(self: *Self) !Unit {
        const st = self.getType();
        if (st != SurfaceType.svg) {
            return Error.SurfaceTypeMismatch;
        } else {
            return svg_surface.getDocumentUnit(self.c_ptr);
        }
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-get-fallback-resolution
    pub fn getFallbackResolution(_: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-get-font-options
    pub fn getFontOptions(_: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-get-height
    pub fn getHeight(self: *Self) !u16 {
        const st = self.getType();
        if (st != SurfaceType.image) {
            std.log.warn("`getHeight` not implemented for {}", .{st});
            return Error.SurfaceTypeMismatch;
        } else {
            return @intCast(u16, c.cairo_image_surface_get_height(self.c_ptr));
        }
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-get-mime-data
    pub fn getMimeData(_: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-get-reference-count
    pub fn getReferenceCount(self: *Self) c_uint {
        return c.cairo_surface_get_reference_count(self.c_ptr);
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-get-type
    pub fn getType(self: *Self) SurfaceType {
        return SurfaceType.fromCairoEnum(c.cairo_surface_get_type(self.c_ptr));
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-get-user-data
    pub fn getUserData(_: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-get-width
    pub fn getWidth(self: *Self) !u16 {
        const st = self.getType();
        if (st != SurfaceType.image) {
            std.log.warn("`getWidth` not implemented for {}", .{st});
            return Error.SurfaceTypeMismatch;
        } else {
            return @intCast(u16, c.cairo_image_surface_get_width(self.c_ptr));
        }
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-has-show-text-glyphs
    pub fn hasShowTextGlyphs(_: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// Create an image surface of the specified format and dimensions.
    /// https://cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-create
    pub fn image(width: u16, height: u16) !Self {
        var c_ptr = try image_surface.create(Format.argb32, width, height);
        try Self.status(c_ptr);
        return Self{ .c_ptr = c_ptr };
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-map-to-image
    pub fn mapToImage(_: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-mark-dirty
    pub fn markDirty(self: *Self) void {
        c.cairo_surface_mark_dirty(self.c_ptr);
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-mark-dirty-rectangle
    pub fn markDirtyRectangle(_: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// Create a PDF surface of the specified size in points to be written to filename.
    /// https://www.cairographics.org/manual/cairo-PDF-Surfaces.html#cairo-pdf-surface-create
    pub fn pdf(comptime filename: []const u8, width_pt: f64, height_pt: f64) !Self {
        var c_ptr = try pdf_surface.create(filename, width_pt, height_pt);
        try Self.status(c_ptr);
        return Self{ .c_ptr = c_ptr };
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-reference
    pub fn reference(_: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// Create a new surface that will emit its rendering through a cairoscript file.
    /// https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-surface-create
    pub fn script(filename: []const u8, content: Content, width: f64, height: f64) !Self {
        var c_ptr = try script_surface.surfaceCreate(filename, content, width, height);
        // Cairo guarantees that c_ptr is a valid pointer, but it could be a
        // pointer to a "nil" surface if an error such as out of memory occurs.
        // That's why we check the surface's status.
        try Self.status(c_ptr);
        return Self{ .c_ptr = c_ptr };
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-set-device-offset
    pub fn setDeviceOffset(self: *Self, x_offset: f64, y_offset: f64) void {
        c.cairo_surface_set_device_offset(self.c_ptr, x_offset, y_offset);
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-set-device-scale
    pub fn setDeviceScale(self: *Self, x_scale: f64, y_scale: f64) void {
        c.cairo_surface_set_device_scale(self.c_ptr, x_scale, y_scale);
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-set-fallback-resolution
    pub fn setFallbackResolution(self: *Self, x_pixels_per_inch: f64, y_pixels_per_inch: f64) void {
        c.cairo_surface_set_fallback_resolution(self.c_ptr, x_pixels_per_inch, y_pixels_per_inch);
    }

    pub fn setMetadata(self: *Self, metadata: PdfMetadata, char: []const u8) !void {
        if (self.getType() != SurfaceType.pdf) {
            return Error.SurfaceTypeMismatch;
        } else {
            pdf_surface.setMetadata(self.c_ptr, metadata, char);
        }
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-set-mime-data
    pub fn setMimeData(_: *Self) void {
        @panic("TODO: to be implemented");
    }

    pub fn setSize(self: *Self, width: f64, height: f64) void {
        const st = self.getType();
        switch (st) {
            SurfaceType.xcb => xcb_surface.setSize(self.c_ptr, @floatToInt(u16, width), @floatToInt(u16, height)),
            SurfaceType.pdf => pdf_surface.setSize(self.c_ptr, width, height),
            else => std.log.warn("`setSize` not implemented for {}", .{st}),
        }
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-set-user-data
    pub fn setUserData(_: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-show-page
    pub fn showPage(self: *Self) void {
        c.cairo_surface_show_page(self.c_ptr);
    }

    /// Check whether an error has previously occurred for this surface.
    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-status
    pub fn status(c_ptr: ?*c.struct__cairo_surface) !void {
        return try statusToError(c.cairo_surface_status(c_ptr));
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-supports-mime-type
    pub fn supportsMimeData(_: *Self) void {
        @panic("TODO: to be implemented");
    }

    pub fn svg(comptime filename: []const u8, width_pt: f64, height_pt: f64) !Surface {
        var c_ptr = try svg_surface.create(filename, width_pt, height_pt);
        try Self.status(c_ptr);
        return Self{ .c_ptr = c_ptr };
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-unmap-image
    pub fn unmapImage(_: *Self) void {
        @panic("TODO: to be implemented");
    }

    pub fn xcb(conn: ?*c.struct_xcb_connection_t, drawable: u32, visual: ?*c.struct_xcb_visualtype_t, width: u16, height: u16) !Surface {
        var c_ptr = try xcb_surface.surfaceCreate(conn, drawable, visual, width, height);
        try Self.status(c_ptr);
        return Self{ .c_ptr = c_ptr };
    }

    /// Emit a string verbatim into the script.
    /// Available only for Cairo Script surfaces.
    /// https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-write-comment
    pub fn writeComment(self: *Self, comment: []const u8) !void {
        var device = try self.getDevice();
        // I don't know if we really need to acquire/release the device
        try device.acquire();
        script_surface.writeComment(device.c_ptr, comment);
        device.release();
    }

    /// Write the contents of surface to a new file filename as a PNG image.
    /// https://cairographics.org/manual/cairo-PNG-Support.html#cairo-surface-write-to-png
    /// TODO: cast C string
    pub fn writeToPng(self: *Self, filename: []const u8) c.enum__cairo_status {
        const s = c.cairo_surface_write_to_png(self.c_ptr, filename.ptr);
        return s;
    }
};

/// https://github.com/freedesktop/cairo/blob/6a6ab2475906635fcc5ba0c73182fae73c4f7ee8/src/cairo-misc.c#L90
pub fn statusAsString(cairo_surface: *c.struct__cairo_surface) [:0]const u8 {
    const c_enum = c.cairo_surface_status(cairo_surface);
    return std.mem.span(c.cairo_status_to_string(c_enum)); // or spanZ?
}

const testing = std.testing;
const expect = testing.expect;
const expectEqual = testing.expectEqual;
const expectError = testing.expectError;

test "Surface.getType() returns the expected SurfaceType" {
    var surface_image = try Surface.image(320, 240);
    defer surface_image.destroy();
    try expectEqual(SurfaceType.image, surface_image.getType());

    var surface_svg = try Surface.svg("examples/generated/test.svg", 320, 240);
    defer surface_svg.destroy();
    try expectEqual(SurfaceType.svg, surface_svg.getType());

    var surface_pdf = try Surface.pdf("examples/generated/test.pdf", 320, 240);
    defer surface_pdf.destroy();
    try expectEqual(SurfaceType.pdf, surface_pdf.getType());
}

test "status() returns no error" {
    var surface = try Surface.image(320, 240);
    defer surface.destroy();

    var errored = false;
    _ = Surface.status(surface.c_ptr) catch {
        errored = true;
    };
    try expectEqual(false, errored);
}

test "getDocumentUnit() returns expected unit for SVG surfaces" {
    var surface_svg = try Surface.svg("examples/generated/test.svg", 320, 240);
    defer surface_svg.destroy();
    const unit = try surface_svg.getDocumentUnit();
    try expectEqual(Unit.pt, unit);
}

test "getDocumentUnit() returns SurfaceTypeMismatch for non-SVG surfaces" {
    var surface = try Surface.image(320, 240);
    defer surface.destroy();
    _ = surface.getDocumentUnit() catch |err| {
        try expectEqual(Error.SurfaceTypeMismatch, err);
    };
}

test "getDevice() returns expected error when called on an image surface" {
    var surface = try Surface.image(320, 240);
    defer surface.destroy();

    try expectError(error.OperationNotAvailableForSurface, surface.getDevice());
}

test "writeComment() returns expected error when called on an image surface" {
    var surface = try Surface.image(320, 240);
    defer surface.destroy();

    try expectError(error.OperationNotAvailableForSurface, surface.writeComment("foo"));
}
