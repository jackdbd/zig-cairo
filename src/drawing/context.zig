//! The cairo drawing context
//! https://cairographics.org/manual/cairo-cairo-t.html
const std = @import("std");
const log = std.log;
const c = @import("../c.zig");
const enums = @import("../enums.zig");
const Surface = @import("../surfaces/surface.zig").Surface;
const FontOptions = @import("../fonts/font_options.zig").FontOptions;
const Pattern = @import("./pattern.zig").Pattern;
const Path = @import("./path.zig").Path;
const scaled_font = @import("../fonts/scaled_font.zig");
const Error = @import("../errors.zig").Error;

pub const CContext = *c.struct__cairo;

pub const Context = struct {
    c_ptr: *c.struct__cairo,

    const Self = @This();

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-append-path
    pub fn appendPath(self: *Self, path: Path) void {
        c.cairo_append_path(self.c_ptr, path.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-arc
    pub fn arc(self: *Self, xc: f64, yc: f64, radius: f64, angle1: f64, angle2: f64) void {
        c.cairo_arc(self.c_ptr, xc, yc, radius, angle1, angle2);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-arc-negative
    pub fn arcNegative(self: *Self, xc: f64, yc: f64, radius: f64, angle1: f64, angle2: f64) void {
        c.cairo_arc_negative(self.c_ptr, xc, yc, radius, angle1, angle2);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-clip
    pub fn clip(self: *Self) void {
        c.cairo_clip(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-close-path
    pub fn closePath(self: *Self) void {
        c.cairo_close_path(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-copy-path
    pub fn copyPath(self: *Self) !Path {
        const c_ptr = c.cairo_copy_path(self.c_ptr);
        // log.debug("copyPath c_ptr {}", .{@typeInfo(@TypeOf(c_ptr))});
        if (c_ptr == null) return Error.NoMemory; // or NullPointer?
        return Path{ .c_ptr = c_ptr };
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-copy-path-flat
    pub fn copyPathFlat(self: *Self) !Path {
        const c_ptr = c.cairo_copy_path_flat(self.c_ptr);
        // log.debug("copyPathFlat c_ptr {}", .{@typeInfo(@TypeOf(c_ptr))});
        if (c_ptr == null) return Error.NoMemory; // or NullPointer?
        return Path{ .c_ptr = c_ptr };
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-create
    pub fn create(surface: *Surface) !Self {
        var c_ptr = c.cairo_create(surface.c_ptr);
        if (c_ptr == null) return Error.NullPointer;
        try checkStatus(c_ptr);
        return Self{ .c_ptr = c_ptr.? };
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-curve-to
    pub fn curveTo(self: *Self, x1: f64, y1: f64, x2: f64, y2: f64, x3: f64, y3: f64) void {
        c.cairo_curve_to(self.c_ptr, x1, y1, x2, y2, x3, y3);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-destroy
    pub fn destroy(self: *Self) void {
        c.cairo_destroy(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-fill
    pub fn fill(self: *Self) void {
        c.cairo_fill(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-fill-preserve
    pub fn fillPreserve(self: *Self) void {
        c.cairo_fill_preserve(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-get-line-width
    pub fn getLineWidth(self: *Self) f64 {
        return c.cairo_get_line_width(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-line-to
    pub fn lineTo(self: *Self, x: f64, y: f64) void {
        c.cairo_line_to(self.c_ptr, x, y);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-mask
    pub fn mask(self: *Self, pattern: *Pattern) void {
        c.cairo_mask(self.c_ptr, pattern.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-move-to
    pub fn moveTo(self: *Self, x: f64, y: f64) void {
        c.cairo_move_to(self.c_ptr, x, y);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-new-path
    pub fn newPath(self: *Self) void {
        c.cairo_new_path(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-new-sub-path
    pub fn newSubPath(self: *Self) void {
        c.cairo_new_sub_path(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-paint
    pub fn paint(self: *Self) void {
        c.cairo_paint(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-paint-with-alpha
    pub fn paintWithAlpha(self: *Self, alpha: f64) void {
        c.cairo_paint_with_alpha(self.c_ptr, alpha);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-pop-group-to-source
    pub fn popGroupToSource(self: *Self) void {
        c.cairo_pop_group_to_source(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-push-group
    pub fn pushGroup(self: *Self) void {
        c.cairo_push_group(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-rectangle
    pub fn rectangle(self: *Self, x: f64, y: f64, w: f64, h: f64) void {
        c.cairo_rectangle(self.c_ptr, x, y, w, h);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-rel-curve-to
    pub fn relCurveTo(self: *Self, dx1: f64, dy1: f64, dx2: f64, dy2: f64, dx3: f64, dy3: f64) void {
        c.cairo_rel_curve_to(self.c_ptr, dx1, dy1, dx2, dy2, dx3, dy3);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-rel-line-to
    pub fn relLineTo(self: *Self, dx: f64, dy: f64) void {
        c.cairo_rel_line_to(self.c_ptr, dx, dy);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-restore
    pub fn restore(self: *Self) void {
        c.cairo_restore(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-Transformations.html#cairo-rotate
    pub fn rotate(self: *Self, radians: f64) void {
        c.cairo_rotate(self.c_ptr, radians);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-save
    pub fn save(self: *Self) void {
        c.cairo_save(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-Transformations.html#cairo-scale
    pub fn scale(self: *Self, sx: f64, sy: f64) void {
        c.cairo_scale(self.c_ptr, sx, sy);
    }

    /// https://cairographics.org/manual/cairo-text.html#cairo-select-font-face
    /// https://github.com/freedesktop/cairo/blob/577477207a300fd75c93da93dbb233256d8b48d8/util/cairo-trace/trace.c#L2948
    pub fn selectFontFace(self: *Self, family: [*]const u8, slant: enums.FontSlant, weight: enums.FontWeight) void {
        const font_slant = @intToEnum(c.enum__cairo_font_slant, @enumToInt(slant));
        const font_weight = @intToEnum(c.enum__cairo_font_weight, @enumToInt(weight));
        c.cairo_select_font_face(self.c_ptr, family, font_slant, font_weight);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-dash
    pub fn setDash(self: *Self, dashes: []f64, offset: f64) void {
        c.cairo_set_dash(self.c_ptr, dashes.ptr, @intCast(c_int, dashes.len), offset);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-fill-rule
    pub fn setFillRule(self: *Self, fill_rule: enums.FillRule) void {
        c.cairo_set_fill_rule(self.c_ptr, fill_rule.toCairoEnum());
    }

    /// https://cairographics.org/manual/cairo-text.html#cairo-set-font-size
    pub fn setFontSize(self: *Self, size: f64) void {
        c.cairo_set_font_size(self.c_ptr, size);
    }

    pub fn setFontOptions(self: *Self, font_options: FontOptions) void {
        c.cairo_set_font_options(self.c_ptr, font_options.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-line-cap
    pub fn setLineCap(self: *Self, line_cap: enums.LineCap) void {
        c.cairo_set_line_cap(self.c_ptr, line_cap.toCairoEnum());
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-line-join
    pub fn setLineJoin(self: *Self, line_join: enums.LineJoin) void {
        c.cairo_set_line_join(self.c_ptr, line_join.toCairoEnum());
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-line-width
    pub fn setLineWidth(self: *Self, w: f64) void {
        c.cairo_set_line_width(self.c_ptr, w);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-source
    pub fn setSource(self: *Self, source: *Pattern) void {
        c.cairo_set_source(self.c_ptr, source.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-source-rgb
    pub fn setSourceRgb(self: *Self, r: f64, g: f64, b: f64) void {
        c.cairo_set_source_rgb(self.c_ptr, r, g, b);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-source-rgba
    pub fn setSourceRgba(self: *Self, r: f64, g: f64, b: f64, alpha: f64) void {
        c.cairo_set_source_rgba(self.c_ptr, r, g, b, alpha);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-source-surface
    pub fn setSourceSurface(self: *Self, surface: *Surface, x: f64, y: f64) void {
        c.cairo_set_source_surface(self.c_ptr, surface.c_ptr, x, y);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-tolerance
    pub fn setTolerance(self: *Self, tolerance: f64) void {
        c.cairo_set_tolerance(self.c_ptr, tolerance);
    }

    /// https://cairographics.org/manual/cairo-text.html#cairo-show-text
    pub fn showText(self: *Self, char: [*]const u8) void {
        c.cairo_show_text(self.c_ptr, char);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-stroke
    pub fn stroke(self: *Self) void {
        c.cairo_stroke(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-text.html#cairo-text-extents
    pub fn textExtents(self: *Self, char: [*]const u8) scaled_font.TextExtents {
        c.cairo_text_extents(self.c_ptr, char, &scaled_font.te);
        return scaled_font.TextExtents{
            .x_bearing = scaled_font.te.x_bearing,
            .x_advance = scaled_font.te.x_advance,
            .y_bearing = scaled_font.te.y_bearing,
            .y_advance = scaled_font.te.y_advance,
            .width = scaled_font.te.width,
            .height = scaled_font.te.height,
        };
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-text-path
    pub fn textPath(self: *Self, utf8: []const u8) void {
        c.cairo_text_path(self.c_ptr, utf8.ptr);
    }

    /// https://cairographics.org/manual/cairo-Transformations.html#cairo-translate
    pub fn translate(self: *Self, tx: f64, ty: f64) void {
        c.cairo_translate(self.c_ptr, tx, ty);
    }
};
/// Check whether an error has previously occurred for this Cairo context.
/// https://cairographics.org/manual/cairo-cairo-t.html#cairo-status
// TODO: move to Context? (but keep using c.struct__cairo, not Context)
fn checkStatus(cairo_context: ?*c.struct__cairo) !void {
    if (cairo_context == null) {
        return Error.NullPointer;
    } else {
        const c_enum = c.cairo_status(cairo_context);
        const c_integer = @enumToInt(c_enum);
        return switch (c_integer) {
            c.CAIRO_STATUS_SUCCESS => {},
            c.CAIRO_STATUS_NO_MEMORY => Error.NoMemory,
            c.CAIRO_STATUS_INVALID_RESTORE => Error.InvalidRestore,
            c.CAIRO_STATUS_INVALID_POP_GROUP => Error.InvalidPopGroup,
            c.CAIRO_STATUS_NO_CURRENT_POINT => Error.NoCurrentPoint,
            c.CAIRO_STATUS_INVALID_MATRIX => Error.InvalidMatrix,
            c.CAIRO_STATUS_INVALID_STATUS => Error.InvalidStatus,
            c.CAIRO_STATUS_NULL_POINTER => Error.NullPointer, // is this still possible?
            c.CAIRO_STATUS_INVALID_STRING => Error.InvalidString,
            c.CAIRO_STATUS_INVALID_PATH_DATA => Error.InvalidPathData,
            c.CAIRO_STATUS_READ_ERROR => Error.ReadError,
            c.CAIRO_STATUS_WRITE_ERROR => Error.WriteError,
            c.CAIRO_STATUS_SURFACE_FINISHED => Error.SurfaceFinished,
            c.CAIRO_STATUS_SURFACE_TYPE_MISMATCH => Error.SurfaceTypeMismatch,
            c.CAIRO_STATUS_PATTERN_TYPE_MISMATCH => Error.PatternTypeMismatch,
            c.CAIRO_STATUS_INVALID_CONTENT => Error.InvalidContent,
            c.CAIRO_STATUS_INVALID_FORMAT => Error.InvalidFormat,
            c.CAIRO_STATUS_INVALID_VISUAL => Error.InvalidVisual,
            c.CAIRO_STATUS_FILE_NOT_FOUND => Error.FileNotFound,
            c.CAIRO_STATUS_INVALID_DASH => Error.InvalidDash,
            c.CAIRO_STATUS_INVALID_DSC_COMMENT => Error.InvalidDscComment,
            c.CAIRO_STATUS_INVALID_INDEX => Error.InvalidIndex,
            c.CAIRO_STATUS_CLIP_NOT_REPRESENTABLE => Error.ClipNotRepresentable,
            c.CAIRO_STATUS_TEMP_FILE_ERROR => Error.TempFileError,
            c.CAIRO_STATUS_INVALID_STRIDE => Error.InvalidStride,
            c.CAIRO_STATUS_FONT_TYPE_MISMATCH => Error.FotnTypeMismatch,
            c.CAIRO_STATUS_USER_FONT_IMMUTABLE => Error.UserFontImmutable,
            c.CAIRO_STATUS_USER_FONT_ERROR => Error.UserFontError,
            c.CAIRO_STATUS_NEGATIVE_COUNT => Error.NegativeCount,
            c.CAIRO_STATUS_INVALID_CLUSTERS => Error.InvalidClusters,
            c.CAIRO_STATUS_INVALID_SLANT => Error.InvalidSlant,
            c.CAIRO_STATUS_INVALID_WEIGHT => Error.InvalidWeight,
            c.CAIRO_STATUS_INVALID_SIZE => Error.InvalidSize,
            c.CAIRO_STATUS_USER_FONT_NOT_IMPLEMENTED => Error.UserFontNotImplemented,
            c.CAIRO_STATUS_DEVICE_TYPE_MISMATCH => Error.DeviceTypeMismatch,
            c.CAIRO_STATUS_DEVICE_ERROR => Error.DeviceError,
            c.CAIRO_STATUS_INVALID_MESH_CONSTRUCTION => Error.InvalidMeshConstruction,
            c.CAIRO_STATUS_DEVICE_FINISHED => Error.DeviceFinished,
            c.CAIRO_STATUS_JBIG2_GLOBAL_MISSING => Error.Jbig2GlobalMissing,
            c.CAIRO_STATUS_PNG_ERROR => Error.PngError,
            c.CAIRO_STATUS_FREETYPE_ERROR => Error.FreetypeError,
            c.CAIRO_STATUS_WIN32_GDI_ERROR => Error.Win32GdiError,
            c.CAIRO_STATUS_TAG_ERROR => Error.TagError,
            c.CAIRO_STATUS_LAST_STATUS => Error.LastStatus,
            else => unreachable,
        };
    }
}

const testing = std.testing;
const expect = testing.expect;
const expectEqual = testing.expectEqual;

test "checkStatus() returns no error" {
    var surface = try Surface.image(320, 240);
    defer surface.destroy();

    var cr = try Context.create(&surface);
    defer cr.destroy();

    var errored = false;
    _ = checkStatus(cr.c_ptr) catch |err| {
        errored = true;
    };
    expectEqual(false, errored);
}
