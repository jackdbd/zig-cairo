const std = @import("std");
const c = @import("c.zig");
const status = @import("status.zig");
const deviceStatusAsEnum = status.deviceStatusAsEnum;
const surfaceStatus = status.surfaceStatus;
const surfaceStatusAsEnum = status.surfaceStatusAsEnum;
const Status = status.Status;
const SurfaceStatus = status.SurfaceStatus;
const StatusEnum = status.StatusEnum;
const Device = @import("surface/device.zig").Device;
const image_surface = @import("surface/image.zig");
const Format = image_surface.Format;
const pdf_surface = @import("surface/pdf.zig");
const png_surface = @import("surface/png.zig");
const svg_surface = @import("surface/svg.zig");
const xcb_surface = @import("surface/xcb.zig");

/// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-type-t
pub const SurfaceType = enum {
    Image,
    Pdf,
    Ps,
    Xlib,
    Xcb,
    Glitz,
    Quartz,
    Win32,
    BeOs,
    DirectFb,
    Svg,
    Os2,
    Win32Printing,
    QuartzImage,
    Script,
    Qt,
    Recording,
    Vg,
    Gl,
    Drm,
    Tee,
    Xml,
    Skia,
    Subsurface,
    Cogl,
};

pub const Surface = struct {
    surface: *c.struct__cairo_surface,

    const Self = @This();

    pub fn getType(self: *Self) SurfaceType {
        const c_enum = c.cairo_surface_get_type(self.surface);
        const c_integer = @enumToInt(c_enum);
        return @intToEnum(SurfaceType, @intCast(u5, c_integer));
    }

    pub fn image(comptime width: u16, comptime height: u16) !Surface {
        var surface = try image_surface.create(Format.Argb32, width, height);
        std.debug.assert(SurfaceStatus.Success == surfaceStatusAsEnum(surface));
        std.debug.assert(Format.Argb32 == image_surface.getFormat(surface));
        std.debug.assert(width == image_surface.getWidth(surface));
        std.debug.assert(height == image_surface.getHeight(surface));
        return Self{ .surface = surface };
    }

    pub fn setSize(self: *Self, width: f64, height: f64) void {
        const st = self.getType();
        switch (st) {
            SurfaceType.Xcb => xcb_surface.setSize(self.surface, @floatToInt(u16, width), @floatToInt(u16, height)),
            SurfaceType.Pdf => pdf_surface.setSize(self.surface, width, height),
            else => std.debug.print("`setSize` not implemented for {}\n", .{st}),
        }
    }

    /// https://www.cairographics.org/manual/cairo-SVG-Surfaces.html#cairo-svg-surface-get-document-unit
    pub fn getDocumentUnit(self: *Self) !svg_surface.Unit {
        const st = self.getType();
        if (st != SurfaceType.Svg) {
            // std.debug.print("`getDocumentUnit` not implemented for {}\n", .{st});
            return Status.SurfaceTypeMismatch;
        } else {
            return svg_surface.getDocumentUnit(self.surface);
        }
    }

    pub fn pdf(comptime filename: [*]const u8, comptime width_pt: f64, comptime height_pt: f64) !Surface {
        var surface = try pdf_surface.create(filename, width_pt, height_pt);
        std.debug.assert(SurfaceStatus.Success == surfaceStatusAsEnum(surface));
        return Self{ .surface = surface };
    }

    pub fn png(filename: [*]const u8) Error!Surface {
        var surface = try png_surface.createFromPng(filename);
        const s = Surface.status(surface);
        std.debug.assert(Status.Success == s);
        return Self{ .surface = surface };
    }

    pub fn status(self: *Self) !bool {
        return surfaceStatus(self.surface);
    }

    pub fn statusAsEnum(cairo_surface: *c.struct__cairo_surface) SurfaceStatus {
        std.debug.print("Surface Status: {}\n", .{status.surfaceStatusAsString(cairo_surface)});
        return surfaceStatusAsEnum(cairo_surface);
    }

    pub fn svg(comptime filename: [*]const u8, comptime width_pt: f64, comptime height_pt: f64) !Surface {
        var surface = try svg_surface.create(filename, width_pt, height_pt);
        std.debug.assert(SurfaceStatus.Success == surfaceStatusAsEnum(surface));
        return Self{ .surface = surface };
    }

    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-get-device
    pub fn getDevice(cairo_surface: *c.struct__cairo_surface) !Device {
        const device = c.cairo_surface_get_device(cairo_surface);
        if (device == null) return Status.NullPointer;
        return Device{ .device = device.? };
    }

    pub fn xcb(conn: ?*c.struct_xcb_connection_t, drawable: u32, visual: ?*c.struct_xcb_visualtype_t, width: u16, height: u16) !Surface {
        var surface = try xcb_surface.create(conn, drawable, visual, width, height);
        std.debug.assert(SurfaceStatus.Success == surfaceStatusAsEnum(surface));
        var device = try Surface.getDevice(surface);
        std.debug.assert(StatusEnum.Success == deviceStatusAsEnum(device));
        return Self{ .surface = surface };
    }

    /// Decrease the reference count on surface by one.
    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-destroy
    pub fn destroy(self: *Self) void {
        c.cairo_surface_destroy(self.surface);
        // std.debug.print("cairo.Surface {} destroyed\n", .{self});
    }

    /// Do any pending drawing for the surface and also restore any temporary modifications cairo has made to the surface's state.
    /// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-flush/
    pub fn flush(self: *Self) void {
        c.cairo_surface_flush(self.surface);
    }

    /// Write the contents of surface to a new file filename as a PNG image.
    /// https://cairographics.org/manual/cairo-PNG-Support.html#cairo-surface-write-to-png
    /// TODO: cast C string
    pub fn writeToPng(self: *Self, filename: [*]const u8) c.enum__cairo_status {
        const s = c.cairo_surface_write_to_png(self.surface, filename);
        return s;
    }
};

/// The cairo drawing context.
/// https://cairographics.org/manual/cairo-cairo-t.html
pub const Context = struct {
    cr: *c.struct__cairo,

    const Self = @This();

    pub fn fromSurface(cs: *Surface) !Self {
        var cr: ?*c.cairo_t = c.cairo_create(cs.surface);
        if (cr == null) return Status.NullPointer;
        return Self{ .cr = cr.? };
    }

    pub fn destroy(self: *Self) void {
        c.cairo_destroy(self.cr);
        // std.debug.print("cairo.Context {} destroyed\n", .{self});
    }

    pub fn setSourceRgb(self: *Self, r: f64, g: f64, b: f64) void {
        c.cairo_set_source_rgb(self.cr, r, g, b);
    }

    pub fn setSourceRgba(self: *Self, r: f64, g: f64, b: f64, alpha: f64) void {
        c.cairo_set_source_rgba(self.cr, r, g, b, alpha);
    }

    pub fn paint(self: *Self) void {
        c.cairo_paint(self.cr);
    }

    pub fn paintWithAlpha(self: *Self, alpha: f64) void {
        c.cairo_paint_with_alpha(self.cr, alpha);
    }

    pub fn setLineWidth(self: *Self, w: f64) void {
        c.cairo_set_line_width(self.cr, w);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-move-to
    pub fn moveTo(self: *Self, x: f64, y: f64) void {
        c.cairo_move_to(self.cr, x, y);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-line-to
    pub fn lineTo(self: *Self, x: f64, y: f64) void {
        c.cairo_line_to(self.cr, x, y);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-stroke
    pub fn stroke(self: *Self) void {
        c.cairo_stroke(self.cr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-fill
    pub fn fill(self: *Self) void {
        c.cairo_fill(self.cr);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-rectangle
    pub fn rectangle(self: *Self, x: f64, y: f64, w: f64, h: f64) void {
        c.cairo_rectangle(self.cr, x, y, w, h);
    }

    /// https://cairographics.org/manual/cairo-text.html#cairo-select-font-face
    /// https://github.com/freedesktop/cairo/blob/577477207a300fd75c93da93dbb233256d8b48d8/util/cairo-trace/trace.c#L2948
    pub fn selectFontFace(self: *Self, family: [*]const u8, slant: FontSlant, weight: FontWeight) void {
        const font_slant = @intToEnum(c.enum__cairo_font_slant, @enumToInt(slant));
        const font_weight = @intToEnum(c.enum__cairo_font_weight, @enumToInt(weight));
        c.cairo_select_font_face(self.cr, family, font_slant, font_weight);
    }

    /// https://cairographics.org/manual/cairo-text.html#cairo-set-font-size
    pub fn setFontSize(self: *Self, size: f64) void {
        c.cairo_set_font_size(self.cr, size);
    }

    /// https://cairographics.org/manual/cairo-text.html#cairo-text-extents
    pub fn textExtents(self: *Self, char: [*]const u8) TextExtents {
        c.cairo_text_extents(self.cr, char, &te);
        return TextExtents{
            .x_bearing = te.x_bearing,
            .x_advance = te.x_advance,
            .y_bearing = te.y_bearing,
            .y_advance = te.y_advance,
            .width = te.width,
            .height = te.height,
        };
    }

    /// https://cairographics.org/manual/cairo-text.html#cairo-show-text
    pub fn showText(self: *Self, char: [*]const u8) void {
        c.cairo_show_text(self.cr, char);
    }
};

// https://github.com/freedesktop/cairo/blob/6a6ab2475906635fcc5ba0c73182fae73c4f7ee8/src/cairoint.h#L691
// https://github.com/freedesktop/cairo/blob/577477207a300fd75c93da93dbb233256d8b48d8/util/cairo-trace/trace.c#L2925
pub const FontSlant = enum {
    Normal,
    Italic,
    Oblique,
};

// https://github.com/freedesktop/cairo/blob/577477207a300fd75c93da93dbb233256d8b48d8/util/cairo-trace/trace.c#L2938
pub const FontWeight = enum {
    Normal,
    Bold,
};

var te: c.cairo_text_extents_t = undefined;

// https://cairographics.org/manual/cairo-cairo-scaled-font-t.html#cairo-text-extents-t
pub const TextExtents = struct {
    x_bearing: f64,
    y_bearing: f64,
    width: f64,
    height: f64,
    x_advance: f64,
    y_advance: f64,
};

const testing = std.testing;
const expect = testing.expect;
const expectEqual = testing.expectEqual;

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

test "surfaceStatusAsEnum() returns Success" {
    var surface_image = try Surface.image(320, 240);
    defer surface_image.destroy();
    expectEqual(SurfaceStatus.Success, surfaceStatusAsEnum(surface_image.surface));
}

test "Surface.status() returns no error" {
    var surface_image = try Surface.image(320, 240);
    defer surface_image.destroy();
    expectEqual(true, try surface_image.status());
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
        expectEqual(Status.SurfaceTypeMismatch, err);
    };
}

test "Surface.getDevice() returns NullPointer when the surface does not have an associated device" {
    var surface_image = try Surface.image(320, 240);
    defer surface_image.destroy();
    var caught = false;
    _ = Surface.getDevice(surface_image.surface) catch |err| {
        expectEqual(Status.NullPointer, err);
        caught = true;
    };
    expectEqual(true, caught);
}
