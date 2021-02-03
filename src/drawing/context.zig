//! The Cairo drawing context.
const std = @import("std");
const c = @import("../c.zig");
const enums = @import("../enums.zig");
const Antialias = enums.Antialias;
const Content = enums.Content;
const FillRule = enums.FillRule;
const FontSlant = enums.FontSlant;
const FontWeight = enums.FontWeight;
const LineCap = enums.LineCap;
const LineJoin = enums.LineJoin;
const Operator = enums.Operator;
const Surface = @import("../surfaces/surface.zig").Surface;
const FontOptions = @import("../fonts/font_options.zig").FontOptions;
const Pattern = @import("./pattern.zig").Pattern;
const Path = @import("./path.zig").Path;
const transformations = @import("./transformations.zig");
const tags_and_links = @import("./tags_and_links.zig");
const scaled_font = @import("../fonts/scaled_font.zig");
const Matrix = @import("../utilities/matrix.zig").Matrix;
const Error = @import("../utilities/error_handling.zig").Error;

/// Wrapper for the Cairo cairo_t C struct.
pub const Context = struct {
    /// The original cairo_t C struct.
    /// Memory management of cairo_t is done with cairo_reference() and
    /// cairo_destroy().
    /// https://cairographics.org/manual/cairo-cairo-t.html
    c_ptr: *c.struct__cairo,

    const Self = @This();

    // TODO: this should be *const Path, not *Path
    /// https://cairographics.org/manual/cairo-Paths.html#cairo-append-path
    pub fn appendPath(self: *Self, path: *const Path) !void {
        _ = try Path.status(path.c_ptr);
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

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-clip-extents
    pub fn clipExtents(self: *Self, x1: *f64, y1: *f64, x2: *f64, y2: *f64) void {
        c.cairo_clip_extents(self.c_ptr, x1, y1, x2, y2);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-clip-preserve
    pub fn clipPreserve(self: *Self) void {
        c.cairo_clip_preserve(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-close-path
    pub fn closePath(self: *Self) void {
        c.cairo_close_path(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-copy-clip-rectangle-list
    pub fn copyClipRectangleList(self: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-copy-page
    pub fn copyPage(self: *Self) void {
        c.cairo_copy_page(self.c_ptr);
    }

    /// Create a copy of the current Cairo path, check that it is valid, then
    /// wrap it in a Path struct and return it. The caller owns the returned
    /// object and should call destroy on it when he no longer needs it.
    /// https://cairographics.org/manual/cairo-Paths.html#cairo-copy-path
    pub fn copyPath(self: *Self) !Path {
        const c_ptr = c.cairo_copy_path(self.c_ptr);
        // It seems that Cairo allows us to copy an empty path. But what for?
        // Wouldn't be better to return Error.InvalidPathData?
        if (c_ptr.*.num_data == 0) {
            std.log.warn("you are copying an empty path!", .{});
            // return Error.InvalidPathData;
        }
        // cairo_copy_path always return a valid pointer, but the result can be
        // a Cairo path with no data if either of the following conditions hold:
        // 1. if there is insufficient memory to copy the path.
        // 2. If the wrapped cairo_t is already in an error state.
        _ = try Path.status(c_ptr.?); // check condition 1
        _ = try Context.status(self.c_ptr); // check condition 2
        return Path{ .c_ptr = c_ptr.? };
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-copy-path-flat
    pub fn copyPathFlat(self: *Self) !Path {
        const c_ptr = c.cairo_copy_path_flat(self.c_ptr);
        if (c_ptr.*.num_data == 0) {
            std.log.warn("you are copying an empty path!", .{});
            // return Error.InvalidPathData;
        }
        _ = try Path.status(c_ptr.?);
        _ = try Context.status(self.c_ptr);
        return Path{ .c_ptr = c_ptr.? };
    }

    /// Create a new Context with all graphics state parameters set to default
    /// values and with target as a target Surface.
    /// The newly allocated cairo_t (wrapped by the Context struct) will have a
    /// reference count of 1. When you are done using the returned Context,
    /// release the reference count by calling destroy on it.
    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-create
    pub fn create(target: *Surface) !Self {
        var c_ptr = c.cairo_create(target.c_ptr);
        // cairo_create performs a memory allocation, so it might fail. We know
        // it didn't fail if Context.status(c_ptr) returns no error.
        _ = try Context.status(c_ptr);
        // cairo_create never returns NULL, but Zig doesn't know it, so we have
        // to unwrap the optional value.
        return Self{ .c_ptr = c_ptr.? };
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-curve-to
    pub fn curveTo(self: *Self, x1: f64, y1: f64, x2: f64, y2: f64, x3: f64, y3: f64) void {
        c.cairo_curve_to(self.c_ptr, x1, y1, x2, y2, x3, y3);
    }

    /// Decrease the reference count on the C cairo_t struct by one.
    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-destroy
    pub fn destroy(self: *Self) void {
        c.cairo_destroy(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-fill
    pub fn fill(self: *Self) void {
        c.cairo_fill(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-fill-extents
    pub fn fillExtents(self: *Self, x1: *f64, y1: *f64, x2: *f64, y2: *f64) void {
        c.cairo_fill_extents(self.c_ptr, x1, y1, x2, y2);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-fill-preserve
    pub fn fillPreserve(self: *Self) void {
        c.cairo_fill_preserve(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-get-antialias
    pub fn getAntialias(self: *Self) Antialias {
        return Antialias.fromCairoEnum(c.cairo_get_antialias(self.c_ptr));
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-get-current-point
    pub fn getCurrentPoint(self: *Self, x: *f64, y: *f64) void {
        c.cairo_get_current_point(self.c_ptr, x, y);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-get-dash
    pub fn getDash(self: *Self, dashes: []f64, offset: [*c]f64) void {
        c.cairo_get_dash(self.c_ptr, dashes.ptr, offset);
    }

    // TODO: why is this function leaking memory? Isn't list.toOwnedSlice() enough?
    pub fn getDashAlternative(self: *Self, comptime T: type, allocator: *std.mem.Allocator) !DashResult(T) {
        const n = self.getDashCount();
        var offset_ptr = try allocator.create(T);
        defer allocator.destroy(offset_ptr);

        var list = std.ArrayList(T).init(allocator);
        defer list.deinit();
        var i: usize = 0;
        while (i < n) : (i += 1) {
            try list.append(0.0);
        }

        // defer allocator.free(slice);
        // var list = std.ArrayList(T).fromOwnedSlice(allocator, slice);
        c.cairo_get_dash(self.c_ptr, list.items[0..].ptr, offset_ptr);
        return DashResult(T){ .dash = list.toOwnedSlice(), .offset = offset_ptr.* };
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-get-dash-count
    pub fn getDashCount(self: *Self) usize {
        return @intCast(usize, c.cairo_get_dash_count(self.c_ptr));
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-get-fill-rule
    pub fn getFillRule(self: *Self) FillRule {
        return FillRule.fromCairoEnum(c.cairo_get_fill_rule(self.c_ptr));
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-get-group-target
    pub fn getGroupTarget(self: *Self) !Surface {
        const c_ptr = c.cairo_get_group_target(self.c_ptr);
        // cairo_get_group_target always return a valid pointer, but the result
        // can be a "nil" surface. That's why we check the surface status.
        _ = try Surface.status(c_ptr);
        return Surface{ .c_ptr = c_ptr.? };
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-get-line-cap
    pub fn getLineCap(self: *Self) LineCap {
        return LineCap.fromCairoEnum(c.cairo_get_line_cap(self.c_ptr));
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-get-line-join
    pub fn getLineJoin(self: *Self) LineJoin {
        return LineJoin.fromCairoEnum(c.cairo_get_line_join(self.c_ptr));
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-get-line-width
    pub fn getLineWidth(self: *Self) f64 {
        return c.cairo_get_line_width(self.c_ptr);
    }

    pub fn getMatrix(self: *Self, matrix: *Matrix) void {
        transformations.getMatrix(self.c_ptr, matrix);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-get-miter-limit
    pub fn getMiterLimit(self: *Self) f64 {
        return c.cairo_get_miter_limit(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-get-operator
    pub fn getOperator(self: *Self) Operator {
        return Operator.fromCairoEnum(c.cairo_get_operator(self.c_ptr));
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-get-reference-count
    pub fn getReferenceCount(self: *Self) c_uint {
        return c.cairo_get_reference_count(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-source-surface
    pub fn getSource(self: *Self) Pattern {
        const c_ptr = c.cairo_get_source(self.c_ptr);
        return Pattern{ .c_ptr = c_ptr.? };
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-get-target
    pub fn getTarget(self: *Self) !Surface {
        const c_ptr = c.cairo_get_target(self.c_ptr);
        // cairo_get_target always return a valid pointer, but the result can be
        // a "nil" surface. That's why we check the surface status.
        _ = try Surface.status(c_ptr);
        return Surface{ .c_ptr = c_ptr.? };
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-get-tolerance
    pub fn getTolerance(self: *Self) f64 {
        return c.cairo_get_tolerance(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-get-user-data
    pub fn getUserData(self: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-glyph-path
    pub fn glyphPath(self: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-has-current-point
    pub fn hasCurrentPoint(self: *Self) bool {
        return if (c.cairo_has_current_point(self.c_ptr) == 1) true else false;
    }

    pub fn identityMatrix(self: *Self) void {
        transformations.identityMatrix(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-in-clip
    pub fn inClip(self: *Self, x: f64, y: f64) bool {
        return if (c.cairo_in_clip(self.c_ptr, x, y) == 1) true else false;
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-in-fill
    pub fn inFill(self: *Self, x: f64, y: f64) bool {
        return if (c.cairo_in_fill(self.c_ptr, x, y) == 1) true else false;
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-in-stroke
    pub fn inStroke(self: *Self, x: f64, y: f64) bool {
        return if (c.cairo_in_stroke(self.c_ptr, x, y) == 1) true else false;
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-line-to
    pub fn lineTo(self: *Self, x: f64, y: f64) void {
        c.cairo_line_to(self.c_ptr, x, y);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-mask
    pub fn mask(self: *Self, pattern: *Pattern) void {
        c.cairo_mask(self.c_ptr, pattern.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-mask-surface
    pub fn maskSurface(self: *Self, surface: *Surface, surface_x: f64, surface_y: f64) void {
        c.cairo_mask(self.c_ptr, surface.c_ptr, surface_x, surface_y);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-move-to
    pub fn moveTo(self: *Self, x: f64, y: f64) void {
        // TODO: check status
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

    /// Paint the current source everywhere within the current clip region.
    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-paint
    pub fn paint(self: *Self) void {
        c.cairo_paint(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-paint-with-alpha
    pub fn paintWithAlpha(self: *Self, alpha: f64) void {
        c.cairo_paint_with_alpha(self.c_ptr, alpha);
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-path-extents
    pub fn pathExtents(self: *Self, x1: *f64, y1: *f64, x2: *f64, y2: *f64) void {
        c.cairo_path_extents(self.c_ptr, x1, y1, x2, y2);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-pop-group
    pub fn popGroup(self: *Self) !Pattern {
        const c_ptr = c.cairo_pop_group(self.c_ptr);
        // we check the status because the caller might have called popGroup
        // without a matching pushGroup(). If that's the case, it's an error.
        _ = try Context.status(self.c_ptr);
        return Pattern{ .c_ptr = c_ptr.? };
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-pop-group-to-source
    pub fn popGroupToSource(self: *Self) !void {
        c.cairo_pop_group_to_source(self.c_ptr);
        // we check the status because the caller might have called
        // popGroupToSource without a matching pushGroup().
        _ = try Context.status(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-push-group
    pub fn pushGroup(self: *Self) void {
        c.cairo_push_group(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-push-group-with-content
    pub fn pushGroupWithContent(self: *Self, content: Content) void {
        c.cairo_push_group_with_content(self.c_ptr, content.toCairoEnum());
    }

    /// https://cairographics.org/manual/cairo-Paths.html#cairo-rectangle
    pub fn rectangle(self: *Self, x: f64, y: f64, w: f64, h: f64) void {
        c.cairo_rectangle(self.c_ptr, x, y, w, h);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-rectangle-list-destroy
    pub fn rectangleListDestroy(self: *Self) void {
        @panic("TODO: to be implemented");
    }

    // TODO: should we return the original C pointer? Wrap it? Cast it? Should
    // we call Context.status?
    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-reference
    pub fn reference(self: *Self) *c.struct__cairo {
        const c_ptr = c.cairo_reference(self.c_ptr);
        // _ = try = Context.status();
        return c_ptr.?; // not sure if this should be optional or not
    }

    /// Relative-coordinate version of curveTo().
    /// It's an error to call this function with no current point.
    /// https://cairographics.org/manual/cairo-Paths.html#cairo-rel-curve-to
    pub fn relCurveTo(self: *Self, dx1: f64, dy1: f64, dx2: f64, dy2: f64, dx3: f64, dy3: f64) !void {
        c.cairo_rel_curve_to(self.c_ptr, dx1, dy1, dx2, dy2, dx3, dy3);
        // If cairo_rel_curve_to was called with no current point, cairo_t will
        // have a status of CAIRO_STATUS_NO_CURRENT_POINT.
        _ = try Context.status(self.c_ptr);
    }

    /// Relative-coordinate version of lineTo().
    /// It's an error to call this function with no current point.
    /// https://cairographics.org/manual/cairo-Paths.html#cairo-rel-line-to
    pub fn relLineTo(self: *Self, dx: f64, dy: f64) !void {
        c.cairo_rel_line_to(self.c_ptr, dx, dy);
        // If cairo_rel_line_to was called with no current point, cairo_t will
        // have a status of CAIRO_STATUS_NO_CURRENT_POINT.
        _ = try Context.status(self.c_ptr);
    }

    /// Relative-coordinate version of moveTo().
    /// It's an error to call this function with no current point.
    /// https://cairographics.org/manual/cairo-Paths.html#cairo-rel-move-to
    pub fn relMoveTo(self: *Self, dx: f64, dy: f64) !void {
        c.cairo_rel_move_to(self.c_ptr, dx, dy);
        // If cairo_rel_move_to was called with no current point, cairo_t will
        // have a status of CAIRO_STATUS_NO_CURRENT_POINT.
        _ = try Context.status(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-reset-clip
    pub fn resetClip(self: *Self) void {
        c.cairo_reset_clip(self.c_ptr);
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
    pub fn selectFontFace(self: *Self, family: [*]const u8, slant: FontSlant, weight: FontWeight) void {
        const font_slant = @intToEnum(c.enum__cairo_font_slant, @enumToInt(slant));
        const font_weight = @intToEnum(c.enum__cairo_font_weight, @enumToInt(weight));
        c.cairo_select_font_face(self.c_ptr, family, font_slant, font_weight);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-antialias
    pub fn setAntialias(self: *Self, antialias: Antialias) void {
        c.cairo_set_antialias(self.c_ptr, antialias.toCairoEnum());
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-dash
    pub fn setDash(self: *Self, dashes: []f64, offset: f64) void {
        c.cairo_set_dash(self.c_ptr, dashes.ptr, @intCast(c_int, dashes.len), offset);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-fill-rule
    pub fn setFillRule(self: *Self, fill_rule: FillRule) void {
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
    pub fn setLineCap(self: *Self, line_cap: LineCap) void {
        c.cairo_set_line_cap(self.c_ptr, line_cap.toCairoEnum());
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-line-join
    pub fn setLineJoin(self: *Self, line_join: LineJoin) void {
        c.cairo_set_line_join(self.c_ptr, line_join.toCairoEnum());
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-line-width
    pub fn setLineWidth(self: *Self, w: f64) void {
        c.cairo_set_line_width(self.c_ptr, w);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-miter-limit
    pub fn setMiterLimit(self: *Self, limit: f64) void {
        c.cairo_set_miter_limit(self.c_ptr, limit);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-operator
    pub fn setOperator(self: *Self, operator: Operator) void {
        c.cairo_set_operator(self.c_ptr, operator.toCairoEnum());
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

    /// Create a cairo.Pattern from the `surface` cairo.Surface, then set that
    /// Pattern as the source for the `self` cairo.Surface.
    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-source-surface
    pub fn setSourceSurface(self: *Self, surface: *Surface, x: f64, y: f64) void {
        c.cairo_set_source_surface(self.c_ptr, surface.c_ptr, x, y);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-tolerance
    pub fn setTolerance(self: *Self, tolerance: f64) void {
        c.cairo_set_tolerance(self.c_ptr, tolerance);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-set-user-data
    pub fn setUserData(self: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-show-page
    pub fn showPage(self: *Self) void {
        c.cairo_show_page(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-text.html#cairo-show-text
    pub fn showText(self: *Self, char: [*]const u8) void {
        c.cairo_show_text(self.c_ptr, char);
    }

    /// Check whether an error has previously occurred for this context.
    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-status
    fn status(c_ptr: ?*c.struct__cairo) !void {
        const c_integer = @enumToInt(c.cairo_status(c_ptr));
        return switch (c_integer) {
            c.CAIRO_STATUS_SUCCESS => {}, // nothing to do if successful
            c.CAIRO_STATUS_NO_MEMORY => Error.NoMemory,
            c.CAIRO_STATUS_INVALID_RESTORE => Error.InvalidRestore,
            c.CAIRO_STATUS_INVALID_POP_GROUP => Error.InvalidPopGroup,
            c.CAIRO_STATUS_NO_CURRENT_POINT => Error.NoCurrentPoint,
            c.CAIRO_STATUS_INVALID_MATRIX => Error.InvalidMatrix,
            c.CAIRO_STATUS_INVALID_STATUS => Error.InvalidStatus,
            c.CAIRO_STATUS_NULL_POINTER => Error.NullPointer,
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
            c.CAIRO_STATUS_FONT_TYPE_MISMATCH => Error.FontTypeMismatch,
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
            else => std.debug.panic("cairo_status_t member {} not handled.", .{c_integer}),
        };
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-stroke
    pub fn stroke(self: *Self) void {
        c.cairo_stroke(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-stroke-preserve
    pub fn strokePreserve(self: *Self) void {
        c.cairo_stroke_preserve(self.c_ptr);
    }

    /// https://cairographics.org/manual/cairo-cairo-t.html#cairo-stroke-extents
    pub fn strokeExtents(self: *Self, x1: *f64, y1: *f64, x2: *f64, y2: *f64) void {
        c.cairo_stroke_extents(self.c_ptr, x1, y1, x2, y2);
    }

    pub fn tagBegin(self: *Self, tag_name: []const u8, attributes: ?[]const u8) void {
        tags_and_links.tagBegin(self.c_ptr, tag_name, attributes);
    }

    pub fn tagEnd(self: *Self, tag_name: []const u8) void {
        tags_and_links.tagEnd(self.c_ptr, tag_name);
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

pub fn DashResult(comptime T: type) type {
    return struct {
        dash: []T,
        offset: T,
    };
}

const testing = std.testing;
const expect = testing.expect;
const expectEqual = testing.expectEqual;
const expectError = testing.expectError;

fn testContext() !Context {
    var surface = try Surface.image(320, 240);
    defer surface.destroy();

    var cr = try Context.create(&surface);
    return cr;
}

test "reference() and destroy() modify the reference count as expected" {
    var cr = try testContext();

    expectEqual(@as(c_uint, 1), cr.getReferenceCount());
    _ = cr.reference();
    expectEqual(@as(c_uint, 2), cr.getReferenceCount());
    cr.destroy();
    expectEqual(@as(c_uint, 1), cr.getReferenceCount());
    cr.destroy();
    expectEqual(@as(c_uint, 0), cr.getReferenceCount());
}

test "appendPath() behaves as expected" {
    var cr = try testContext();
    defer cr.destroy();

    var x1: f64 = 0.0;
    var y1: f64 = 0.0;
    var x2: f64 = 0.0;
    var y2: f64 = 0.0;
    cr.pathExtents(&x1, &y1, &x2, &y2);

    expectEqual(@as(f64, 0.0), x1);
    expectEqual(@as(f64, 0.0), y1);
    expectEqual(@as(f64, 0.0), x2);
    expectEqual(@as(f64, 0.0), y2);

    cr.rectangle(1, 2, 20, 30); // adds a path
    cr.pathExtents(&x1, &y1, &x2, &y2);

    expectEqual(@as(f64, 1.0), x1);
    expectEqual(@as(f64, 2.0), y1);
    expectEqual(@as(f64, 21.0), x2);
    expectEqual(@as(f64, 32.0), y2);

    var path = try cr.copyPath();
    defer path.destroy();

    cr.newPath(); // clears the current path
    cr.pathExtents(&x1, &y1, &x2, &y2);

    expectEqual(@as(f64, 0.0), x1);
    expectEqual(@as(f64, 0.0), y1);
    expectEqual(@as(f64, 0.0), x2);
    expectEqual(@as(f64, 0.0), y2);

    try cr.appendPath(&path);
    cr.pathExtents(&x1, &y1, &x2, &y2);

    expectEqual(@as(f64, 1.0), x1);
    expectEqual(@as(f64, 2.0), y1);
    expectEqual(@as(f64, 21.0), x2);
    expectEqual(@as(f64, 32.0), y2);
}

test "appendPath() returns the expected error when path.status is not success" {
    var cr = try testContext();
    defer cr.destroy();

    var path = try cr.copyPath();
    defer path.destroy();

    path.c_ptr.status = @intToEnum(c.enum__cairo_status, c.CAIRO_STATUS_NO_MEMORY);
    expectError(error.NoMemory, cr.appendPath(&path));
    path.c_ptr.status = @intToEnum(c.enum__cairo_status, c.CAIRO_STATUS_INVALID_PATH_DATA);
    expectError(error.InvalidPathData, cr.appendPath(&path));
}

test "clip() and clipExtents() behave as expected" {
    var cr = try testContext();
    defer cr.destroy();

    var x1: f64 = 0.0;
    var y1: f64 = 0.0;
    var x2: f64 = 0.0;
    var y2: f64 = 0.0;

    const width: f64 = 100;
    const height: f64 = 200;
    cr.rectangle(10.0, 20.0, width, height);
    cr.clip();
    cr.clipExtents(&x1, &y1, &x2, &y2);

    expectEqual(@as(f64, 10.0), x1);
    expectEqual(@as(f64, 20.0), y1);
    expectEqual(width + 10.0, x2);
    expectEqual(height + 20.0, y2);
}

test "fillExtents() behaves as expected" {
    var cr = try testContext();
    defer cr.destroy();

    var x1: f64 = 0.0;
    var y1: f64 = 0.0;
    var x2: f64 = 0.0;
    var y2: f64 = 0.0;

    const x0_rect_a: f64 = -10.0;
    const y0_rect_a: f64 = 20;
    const width_rect_a: f64 = 100;
    const height_rect_a: f64 = 205;
    cr.rectangle(x0_rect_a, y0_rect_a, width_rect_a, height_rect_a);
    const x0_rect_b: f64 = 80;
    const y0_rect_b: f64 = 150;
    const width_rect_b: f64 = 40;
    const height_rect_b: f64 = 30;
    cr.rectangle(x0_rect_b, y0_rect_b, width_rect_b, height_rect_b);

    cr.fillExtents(&x1, &y1, &x2, &y2);

    expectEqual(x0_rect_a, x1);
    expectEqual(y0_rect_a, y1);
    expectEqual(@as(f64, 120.0), x2);
    expectEqual(@as(f64, 225.0), y2);
}

test "getAntialias() returns the expected antialias" {
    var cr = try testContext();
    defer cr.destroy();

    const A = Antialias;
    expectEqual(A.default, cr.getAntialias());
    cr.setAntialias(A.fast);
    expectEqual(A.fast, cr.getAntialias());
    cr.setAntialias(A.good);
    expectEqual(A.good, cr.getAntialias());
    cr.setAntialias(A.best);
    expectEqual(A.best, cr.getAntialias());
}

test "hasCurrentPoint() and getCurrentPoint() behave as expected" {
    var cr = try testContext();
    defer cr.destroy();

    // there is no current path, so no current point
    expectEqual(false, cr.hasCurrentPoint());

    // we add a path, so there will be a current point
    const x0: f64 = -10.0;
    const y0: f64 = 20;
    const width: f64 = 100;
    const height: f64 = 205;
    cr.rectangle(x0, y0, width, height);
    expectEqual(true, cr.hasCurrentPoint());

    // the current point is the final point reached by the path so far
    var x: f64 = 0.0;
    var y: f64 = 0.0;
    cr.getCurrentPoint(&x, &y);
    expectEqual(x0, x);
    expectEqual(y0, y);
}

test "getDash() returns the expected dashes" {
    var cr = try testContext();
    defer cr.destroy();

    var dash_expected = [_]f64{ 20.0, 15.0, 10.0, 5.0 }; // ink, skip, ink, skip
    const offset_expected: f64 = 3.0;
    cr.setDash(dash_expected[0..], offset_expected);

    var dash_actual = [_]f64{ 20.0, 15.0, 10.0, 5.0 };
    var offset_actual = [_]f64{3.0};
    cr.getDash(dash_actual[0..], offset_actual[0..]);
    expectEqual(@as(f64, dash_expected[0]), dash_actual[0]);
    expectEqual(@as(f64, dash_expected[1]), dash_actual[1]);
    expectEqual(@as(f64, dash_expected[2]), dash_actual[2]);
    expectEqual(@as(f64, dash_expected[3]), dash_actual[3]);
    expectEqual(@as(f64, offset_expected), offset_actual[0]);
}

test "getDashAlternative() returns the expected dashes" {
    var cr = try testContext();
    defer cr.destroy();

    var dash_expected = [_]f64{ 20.0, 15.0, 10.0, 5.0 }; // ink, skip, ink, skip
    const offset_expected: f64 = 3.0;
    cr.setDash(dash_expected[0..], offset_expected);

    var allocator = std.heap.page_allocator;
    // var allocator = std.testing.allocator; // TODO: this shows that the function leaks
    const result = try cr.getDashAlternative(f64, allocator);
    expectEqual(@as(usize, 4), result.dash.len);
    expectEqual(dash_expected[0], result.dash[0]);
    expectEqual(dash_expected[1], result.dash[1]);
    expectEqual(dash_expected[2], result.dash[2]);
    expectEqual(dash_expected[3], result.dash[3]);
    expectEqual(offset_expected, result.offset);
}

test "getDashCount() returns the expected dashes count" {
    var cr = try testContext();
    defer cr.destroy();

    expectEqual(@as(usize, 0), cr.getDashCount());
    var dash = [_]f64{ 10.0, 10.0, 10.0, 10.0 }; // ink, skip, ink, skip
    const offset = 0.0;
    cr.setDash(dash[0..], offset);
    expectEqual(@as(usize, 4), cr.getDashCount());
    cr.setDash(dash[0..2], offset);
    expectEqual(@as(usize, 2), cr.getDashCount());
}

test "getFillRule() returns the expected fill rule" {
    var cr = try testContext();
    defer cr.destroy();

    expectEqual(FillRule.winding, cr.getFillRule());
    cr.setFillRule(FillRule.even_odd);
    expectEqual(FillRule.even_odd, cr.getFillRule());
}

test "getLineCap() returns the expected line cap" {
    var cr = try testContext();
    defer cr.destroy();

    const L = LineCap;
    expectEqual(L.butt, cr.getLineCap());
    cr.setLineCap(L.round);
    expectEqual(L.round, cr.getLineCap());
    cr.setLineCap(L.square);
    expectEqual(L.square, cr.getLineCap());
}

test "getLineJoin() returns the expected line join" {
    var cr = try testContext();
    defer cr.destroy();

    const L = LineJoin;
    expectEqual(L.miter, cr.getLineJoin());
    cr.setLineJoin(L.round);
    expectEqual(L.round, cr.getLineJoin());
    cr.setLineJoin(L.bevel);
    expectEqual(L.bevel, cr.getLineJoin());
}

test "getTarget() returns the expected Surface" {
    var surface = try Surface.image(320, 240);
    defer surface.destroy();

    var cr = try Context.create(&surface);
    defer cr.destroy();

    var target = try cr.getTarget();
    // surface and target are just containers for the same C pointer.
    const addr_1 = @ptrToInt(surface.c_ptr);
    const addr_2 = @ptrToInt(target.c_ptr);
    expectEqual(addr_1, addr_2);
}

test "getGroupTarget() returns different Surfaces before and after pushGroup()" {
    var surface = try Surface.image(320, 240);
    defer surface.destroy();

    var cr = try Context.create(&surface);
    defer cr.destroy();

    var target = try cr.getGroupTarget();
    const addr_1 = @ptrToInt(surface.c_ptr);
    const addr_2 = @ptrToInt(target.c_ptr);
    expectEqual(addr_1, addr_2);

    cr.pushGroup();
    var target_after = try cr.getGroupTarget();
    const addr_3 = @ptrToInt(target_after.c_ptr);
    expect(addr_3 != addr_2);
}

test "getLineWidth() returns the expected line width" {
    var cr = try testContext();
    defer cr.destroy();

    expectEqual(@as(f64, 2.0), cr.getLineWidth());
    cr.setLineWidth(4.0);
    expectEqual(@as(f64, 4.0), cr.getLineWidth());
}

test "getMiterLimit() returns the expected miter limit" {
    var cr = try testContext();
    defer cr.destroy();

    expectEqual(@as(f64, 10.0), cr.getMiterLimit());
    cr.setMiterLimit(12.3);
    expectEqual(@as(f64, 12.3), cr.getMiterLimit());
}

test "getOperator() returns the expected operator" {
    var cr = try testContext();

    const Op = Operator;
    expectEqual(Op.over, cr.getOperator());
    cr.setOperator(Op.clear);
    expectEqual(Op.clear, cr.getOperator());
}

test "getSource() returns a pattern" {
    var cr = try testContext();
    defer cr.destroy();

    var pattern = cr.getSource();
    expectEqual(@as(c_uint, 1), pattern.getReferenceCount());
}

test "getTolerance() returns the expected tolerance" {
    var cr = try testContext();
    defer cr.destroy();

    expectEqual(@as(f64, 0.1), cr.getTolerance());
    cr.setTolerance(0.01);
    expectEqual(@as(f64, 0.01), cr.getTolerance());
}

test "inClip() behave as expected" {
    var cr = try testContext();
    defer cr.destroy();

    const x0: f64 = 10.0;
    const y0: f64 = 20.0;
    const width: f64 = 100;
    const height: f64 = 200;
    cr.rectangle(x0, y0, width, height);
    cr.clip();

    // note the difference with inFill()
    expectEqual(true, cr.inClip(x0 + width - 1.0, y0 + height - 1.0));
    expectEqual(false, cr.inClip(x0 + width, y0 + height - 1.0));
    expectEqual(false, cr.inClip(x0 + width - 1.0, y0 + height));
    expectEqual(false, cr.inClip(x0 + width, y0 + height));
    expectEqual(false, cr.inClip(x0 + width + 1.0, y0 + height + 1.0));
}

test "inFill() behave as expected" {
    var cr = try testContext();
    defer cr.destroy();

    const x0: f64 = 10.0;
    const y0: f64 = 20.0;
    const width: f64 = 100;
    const height: f64 = 200;
    cr.rectangle(x0, y0, width, height);

    // note the difference with inClip()
    expectEqual(true, cr.inFill(x0 + width - 1.0, y0 + height - 1.0));
    expectEqual(true, cr.inFill(x0 + width, y0 + height - 1.0));
    expectEqual(true, cr.inFill(x0 + width - 1.0, y0 + height));
    expectEqual(true, cr.inFill(x0 + width, y0 + height));
    expectEqual(false, cr.inFill(x0 + width + 1.0, y0 + height + 1.0));
}

test "inStroke() behave as expected" {
    var cr = try testContext();
    defer cr.destroy();

    const x0: f64 = 10.0;
    const y0: f64 = 20.0;
    const width: f64 = 100;
    const height: f64 = 200;
    cr.rectangle(x0, y0, width, height);
    const lw = cr.getLineWidth();

    expectEqual(false, cr.inStroke(x0 + width - lw, y0 + height - lw));
    expectEqual(true, cr.inStroke(x0 + width, y0 + height - lw));
    expectEqual(true, cr.inStroke(x0 + width - lw, y0 + height));
    expectEqual(true, cr.inStroke(x0 + width, y0 + height));
    expectEqual(false, cr.inStroke(x0 + width + lw, y0 + height + lw));
}

test "newPath() clears the current path and the current point" {
    var cr = try testContext();
    defer cr.destroy();

    var x1: f64 = 0.0;
    var y1: f64 = 0.0;
    var x2: f64 = 0.0;
    var y2: f64 = 0.0;

    const x0: f64 = 10.0;
    const y0: f64 = 20.0;
    const width: f64 = 100;
    const height: f64 = 200;
    cr.rectangle(x0, y0, width, height);
    cr.pathExtents(&x1, &y1, &x2, &y2);

    expectEqual(true, cr.hasCurrentPoint());
    expectEqual(x0, x1);
    expectEqual(y0, y1);
    expectEqual(x0 + width, x2);
    expectEqual(y0 + height, y2);

    cr.newPath();
    cr.pathExtents(&x1, &y1, &x2, &y2);

    expectEqual(false, cr.hasCurrentPoint());
    expectEqual(@as(f64, 0.0), x1);
    expectEqual(@as(f64, 0.0), y1);
    expectEqual(@as(f64, 0.0), x2);
    expectEqual(@as(f64, 0.0), y2);
}

test "Path.iterator() returns the expected num_data" {
    var cr = try testContext();
    defer cr.destroy();
    var path = try cr.copyPath();
    defer path.destroy();

    var iter = path.iterator();
    expectEqual(@as(c_int, 0.0), iter.num_data);

    cr.rectangle(0, 0, 100, 200);
    path = try cr.copyPath();
    iter = path.iterator();
    expectEqual(@as(c_int, 11.0), iter.num_data);

    cr.lineTo(150, 250);
    path = try cr.copyPath();
    iter = path.iterator();
    expectEqual(@as(c_int, 13.0), iter.num_data);

    cr.newPath();
    cr.lineTo(150, 250);
    path = try cr.copyPath();
    iter = path.iterator();
    expectEqual(@as(c_int, 2.0), iter.num_data);
}

test "pathExtents() behaves as expected" {
    var cr = try testContext();
    defer cr.destroy();

    var x1: f64 = 0.0;
    var y1: f64 = 0.0;
    var x2: f64 = 0.0;
    var y2: f64 = 0.0;

    const x0_rect_a: f64 = -10.0;
    const y0_rect_a: f64 = 20;
    const width_rect_a: f64 = 100;
    const height_rect_a: f64 = 205;
    cr.rectangle(x0_rect_a, y0_rect_a, width_rect_a, height_rect_a);
    const x0_rect_b: f64 = 80;
    const y0_rect_b: f64 = 150;
    const width_rect_b: f64 = 40;
    const height_rect_b: f64 = 30;
    cr.rectangle(x0_rect_b, y0_rect_b, width_rect_b, height_rect_b);

    cr.pathExtents(&x1, &y1, &x2, &y2);

    expectEqual(x0_rect_a, x1);
    expectEqual(y0_rect_a, y1);
    expectEqual(@as(f64, 120.0), x2);
    expectEqual(@as(f64, 225.0), y2);
}

test "popGroup() returns a pattern" {
    var cr = try testContext();
    defer cr.destroy();

    cr.pushGroupWithContent(Content.color);
    var pattern = try cr.popGroup();
    expectEqual(@as(c_uint, 1), pattern.getReferenceCount());
}

test "popGroup() returns the expected error if we don't call pushGroup() first" {
    var cr = try testContext();
    defer cr.destroy();

    expectError(error.InvalidPopGroup, cr.popGroup());
}

test "popGroupToSource() returns the expected error if we don't call pushGroup() first" {
    var cr = try testContext();
    defer cr.destroy();

    expectError(error.InvalidPopGroup, cr.popGroupToSource());
}

test "relCurveTo() returns the expected error when there is no current point" {
    var cr = try testContext();
    defer cr.destroy();

    expectEqual(false, cr.hasCurrentPoint());
    expectError(error.NoCurrentPoint, cr.relCurveTo(1, 2, 3, 4, 5, 6));
}

test "relLineTo() returns the expected error when there is no current point" {
    var cr = try testContext();
    defer cr.destroy();

    expectEqual(false, cr.hasCurrentPoint());
    expectError(error.NoCurrentPoint, cr.relLineTo(1, 2));
}

test "relMoveTo() returns the expected error when there is no current point" {
    var cr = try testContext();
    defer cr.destroy();

    expectEqual(false, cr.hasCurrentPoint());
    expectError(error.NoCurrentPoint, cr.relMoveTo(1, 2));
}

test "resetClip() reset the current clip region to its original, unrestricted state" {
    var cr = try testContext();
    defer cr.destroy();

    cr.rectangle(0, 0, 100, 200);
    cr.clip();

    expectEqual(false, cr.inClip(10000, 10000));
    cr.resetClip();
    expectEqual(true, cr.inClip(10000, 10000));
}

test "strokeExtents() behaves as expected" {
    var cr = try testContext();
    defer cr.destroy();

    var x1: f64 = 0.0;
    var y1: f64 = 0.0;
    var x2: f64 = 0.0;
    var y2: f64 = 0.0;

    const x0_rect_a: f64 = -10.0;
    const y0_rect_a: f64 = 20;
    const width_rect_a: f64 = 100;
    const height_rect_a: f64 = 205;
    cr.rectangle(x0_rect_a, y0_rect_a, width_rect_a, height_rect_a);
    const x0_rect_b: f64 = 80;
    const y0_rect_b: f64 = 150;
    const width_rect_b: f64 = 40;
    const height_rect_b: f64 = 30;
    cr.rectangle(x0_rect_b, y0_rect_b, width_rect_b, height_rect_b);

    cr.strokeExtents(&x1, &y1, &x2, &y2);
    const lw = cr.getLineWidth();

    expectEqual(x0_rect_a - (lw / 2.0), x1);
    expectEqual(y0_rect_a - (lw / 2.0), y1);
    expectEqual(@as(f64, 120.0 + (lw / 2.0)), x2);
    expectEqual(@as(f64, 225.0 + (lw / 2.0)), y2);
}

test "Context.status() returns no error" {
    var cr = try testContext();
    defer cr.destroy();

    var errored = false;
    _ = Context.status(cr.c_ptr) catch |err| {
        errored = true;
    };
    expectEqual(false, errored);
}
