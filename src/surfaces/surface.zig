//! Cairo Surfaces
//! https://www.cairographics.org/manual/cairo-cairo-surface-t.html
const std = @import("std");
const c = @import("../c.zig");
const Device = @import("device.zig").Device;
const Error = @import("../errors.zig").Error;
const enums = @import("../enums.zig");
const Content = enums.Content;
const Format = enums.Format;
const image_surface = @import("image.zig");
const pdf_surface = @import("pdf.zig");
const png_surface = @import("png.zig");
const script_surface = @import("script.zig");
const svg_surface = @import("svg.zig");
const xcb_surface = @import("xcb.zig");

/// Possible return values for cairo_surface_status()
/// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-status
pub const Status = enum {
    Success = c.CAIRO_STATUS_SUCCESS, // 0
    NoMemory = c.CAIRO_STATUS_NO_MEMORY, // 1
    NullPointer = c.CAIRO_STATUS_NULL_POINTER, // 7
    ReadError = c.CAIRO_STATUS_READ_ERROR, // 10
    InvalidContent = c.CAIRO_STATUS_INVALID_CONTENT, // 15
    InvalidFormat = c.CAIRO_STATUS_INVALID_FORMAT, // 16
    InvalidVisual = c.CAIRO_STATUS_INVALID_VISUAL, // 17
    // SurfaceTypeMismatch, // I think this should be included, even if cairo does not mention it.
};
/// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-type-t
pub const SurfaceType = enum {
    Image = c.CAIRO_SURFACE_TYPE_IMAGE,
    Pdf = c.CAIRO_SURFACE_TYPE_PDF,
    Ps = c.CAIRO_SURFACE_TYPE_PS,
    Xlib = c.CAIRO_SURFACE_TYPE_XLIB,
    Xcb = c.CAIRO_SURFACE_TYPE_XCB,
    Glitz = c.CAIRO_SURFACE_TYPE_GLITZ,
    Quartz = c.CAIRO_SURFACE_TYPE_QUARTZ,
    Win32 = c.CAIRO_SURFACE_TYPE_WIN32,
    BeOs = c.CAIRO_SURFACE_TYPE_BEOS,
    DirectFb = c.CAIRO_SURFACE_TYPE_DIRECTFB,
    Svg = c.CAIRO_SURFACE_TYPE_SVG,
    Os2 = c.CAIRO_SURFACE_TYPE_OS2,
    Win32Printing = c.CAIRO_SURFACE_TYPE_WIN32_PRINTING,
    QuartzImage = c.CAIRO_SURFACE_TYPE_QUARTZ_IMAGE,
    Script = c.CAIRO_SURFACE_TYPE_SCRIPT,
    Qt = c.CAIRO_SURFACE_TYPE_QT,
    Recording = c.CAIRO_SURFACE_TYPE_RECORDING,
    Vg = c.CAIRO_SURFACE_TYPE_VG,
    Gl = c.CAIRO_SURFACE_TYPE_GL,
    Drm = c.CAIRO_SURFACE_TYPE_DRM,
    Tee = c.CAIRO_SURFACE_TYPE_TEE,
    Xml = c.CAIRO_SURFACE_TYPE_XML,
    Skia = c.CAIRO_SURFACE_TYPE_SKIA,
    Subsurface = c.CAIRO_SURFACE_TYPE_SUBSURFACE,
    Cogl = c.CAIRO_SURFACE_TYPE_COGL,
};

pub const Surface = struct {
    c_ptr: *c.struct__cairo_surface,

    const Self = @This();

    pub fn getType(self: *Self) SurfaceType {
        const c_enum = c.cairo_surface_get_type(self.c_ptr);
        const c_integer = @enumToInt(c_enum);
        return @intToEnum(SurfaceType, @intCast(u5, c_integer));
    }

    /// https://cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-create
    pub fn image(width: u16, height: u16) !Surface {
        var c_ptr = try image_surface.create(Format.argb32, width, height);
        try Surface.status(c_ptr);
        return Self{ .c_ptr = c_ptr };
    }

    pub fn setSize(self: *Self, width: f64, height: f64) void {
        const st = self.getType();
        switch (st) {
            SurfaceType.Xcb => xcb_surface.setSize(self.c_ptr, @floatToInt(u16, width), @floatToInt(u16, height)),
            SurfaceType.Pdf => pdf_surface.setSize(self.c_ptr, width, height),
            else => std.debug.print("`setSize` not implemented for {}\n", .{st}),
        }
    }

    /// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-get-document-unit
    pub fn getDocumentUnit(self: *Self) !svg_surface.Unit {
        const st = self.getType();
        if (st != SurfaceType.Svg) {
            return Error.SurfaceTypeMismatch;
        } else {
            return svg_surface.getDocumentUnit(self.c_ptr);
        }
    }

    pub fn pdf(comptime filename: []const u8, width_pt: f64, height_pt: f64) !Surface {
        var c_ptr = try pdf_surface.create(filename.ptr, width_pt, height_pt);
        try Surface.status(c_ptr);
        return Self{ .c_ptr = c_ptr };
    }

    pub fn createFromPng(filename: []const u8) !Surface {
        var c_ptr = try png_surface.create(filename.ptr);
        try Surface.status(c_ptr);
        return Self{ .c_ptr = c_ptr };
    }

    /// https://cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-get-width
    pub fn getWidth(self: *Self) !u16 {
        const st = self.getType();
        if (st != SurfaceType.Image) {
            std.debug.print("`getWidth` not implemented for {}\n", .{st});
            return Error.SurfaceTypeMismatch;
        } else {
            return @intCast(u16, c.cairo_image_surface_get_width(self.c_ptr));
        }
    }

    /// https://cairographics.org/manual/cairo-Image-Surfaces.html#cairo-image-surface-get-height
    pub fn getHeight(self: *Self) !u16 {
        const st = self.getType();
        if (st != SurfaceType.Image) {
            std.debug.print("`getHeight` not implemented for {}\n", .{st});
            return Error.SurfaceTypeMismatch;
        } else {
            return @intCast(u16, c.cairo_image_surface_get_height(self.c_ptr));
        }
    }

    /// Create a Script Surface
    /// https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-surface-create
    pub fn script(filename: []const u8, content: Content, width: f64, height: f64) !Self {
        var c_ptr = try script_surface.surfaceCreate(filename, content, width, height);
        // Cairo guarantees that c_ptr is a valid pointer, but it could be a
        // pointer to a "nil" surface if an error such as out of memory occurs.
        // That's why we check the surface's status.
        _ = try Self.status(c_ptr);
        return Self{ .c_ptr = c_ptr };
    }

    /// Check whether an error has previously occurred for this surface.
    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-status
    pub fn status(c_ptr: ?*c.struct__cairo_surface) !void {
        const c_integer = @enumToInt(c.cairo_surface_status(c_ptr));
        return switch (c_integer) {
            c.CAIRO_STATUS_SUCCESS => {}, // nothing to do if successful
            c.CAIRO_STATUS_NO_MEMORY => Error.NoMemory,
            c.CAIRO_STATUS_NULL_POINTER => Error.NullPointer,
            c.CAIRO_STATUS_READ_ERROR => Error.ReadError,
            c.CAIRO_STATUS_INVALID_CONTENT => Error.InvalidContent,
            c.CAIRO_STATUS_INVALID_FORMAT => Error.InvalidFormat,
            c.CAIRO_STATUS_INVALID_VISUAL => Error.InvalidVisual,
            else => std.debug.panic("cairo_status_t member {} not handled.", .{c_integer}),
        };
    }

    pub fn svg(comptime filename: []const u8, width_pt: f64, height_pt: f64) !Surface {
        var c_ptr = try svg_surface.create(filename.ptr, width_pt, height_pt);
        try Surface.status(c_ptr);
        return Self{ .c_ptr = c_ptr };
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

    pub fn xcb(conn: ?*c.struct_xcb_connection_t, drawable: u32, visual: ?*c.struct_xcb_visualtype_t, width: u16, height: u16) !Surface {
        var c_ptr = try xcb_surface.surfaceCreate(conn, drawable, visual, width, height);
        try Self.status(c_ptr);
        var surface = Self{ .c_ptr = c_ptr };
        // var device = try surface.getDevice();
        // return Self{ .c_ptr = c_ptr };
        return surface;
    }

    /// Decrease the reference count on surface by one.
    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-destroy
    pub fn destroy(self: *Self) void {
        c.cairo_surface_destroy(self.c_ptr);
    }

    /// Do any pending drawing for the surface and also restore any temporary modifications cairo has made to the surface's state.
    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-flush/
    pub fn flush(self: *Self) void {
        c.cairo_surface_flush(self.c_ptr);
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-mark-dirty
    pub fn markDirty(self: *Self) void {
        c.cairo_surface_mark_dirty(self.c_ptr);
    }

    /// Write the contents of surface to a new file filename as a PNG image.
    /// https://cairographics.org/manual/cairo-PNG-Support.html#cairo-surface-write-to-png
    /// TODO: cast C string
    pub fn writeToPng(self: *Self, filename: []const u8) c.enum__cairo_status {
        const s = c.cairo_surface_write_to_png(self.c_ptr, filename.ptr);
        return s;
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

    /// https://cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-get-reference-count
    pub fn getReferenceCount(self: *Self) c_uint {
        return c.cairo_surface_get_reference_count(self.c_ptr);
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
    expectEqual(SurfaceType.Image, surface_image.getType());

    var surface_svg = try Surface.svg("examples/generated/test.svg", 320, 240);
    defer surface_svg.destroy();
    expectEqual(SurfaceType.Svg, surface_svg.getType());

    var surface_pdf = try Surface.pdf("examples/generated/test.pdf", 320, 240);
    defer surface_pdf.destroy();
    expectEqual(SurfaceType.Pdf, surface_pdf.getType());
}

test "Surface.status() returns no error" {
    var surface_image = try Surface.image(320, 240);
    defer surface_image.destroy();
    var errored = false;
    _ = Surface.status(surface_image.c_ptr) catch |err| {
        errored = true;
    };
    expectEqual(false, errored);
}

test "Surface.getDocumentUnit() returns expected unit for SVG surfaces" {
    var surface_svg = try Surface.svg("examples/generated/test.svg", 320, 240);
    defer surface_svg.destroy();
    const unit = try surface_svg.getDocumentUnit();
    expectEqual(svg_surface.Unit.Pt, unit);
}

test "Surface.getDocumentUnit() returns SurfaceTypeMismatch for non-SVG surfaces" {
    var surface_image = try Surface.image(320, 240);
    defer surface_image.destroy();
    _ = surface_image.getDocumentUnit() catch |err| {
        expectEqual(Error.SurfaceTypeMismatch, err);
    };
}

test "getDevice() returns expected error when called on an image surface" {
    var surface = try Surface.image(320, 240);
    defer surface.destroy();

    expectError(error.OperationNotAvailableForSurface, surface.getDevice());
}

test "writeComment() returns expected error when called on an image surface" {
    var surface = try Surface.image(320, 240);
    defer surface.destroy();

    expectError(error.OperationNotAvailableForSurface, surface.writeComment("foo"));
}
