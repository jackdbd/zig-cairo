//! Rendering to replayable scripts.
const std = @import("std");
const c = @import("../c.zig");
const enums = @import("../enums.zig");
const Content = enums.Content;
const ScriptMode = enums.ScriptMode;
const Error = @import("../errors.zig").Error;
const statusToError = @import("../errors.zig").statusToError;

/// Create a output device for emitting the script, used when creating the
/// individual surfaces. The caller owns the returned device and should call
/// cairo_device_destroy() when done with it.
/// https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-create
pub fn create(filename: []const u8) !*c.struct__cairo_device {
    var c_ptr = c.cairo_script_create(filename.ptr);
    // cairo_script_create always returns a valid pointer, but it will return a
    // pointer to a "nil" device if an error such as out of memory occurs. That
    // is why we check that everything is ok with cairo_device_status.
    _ = try statusToError(c.cairo_device_status(c_ptr));
    return c_ptr.?;
}

/// https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-create-for-stream
pub fn createForStream() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-surface-create-for-target
pub fn createForTarget() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-from-recording-surface
pub fn fromRecordingSurface() void {
    @panic("TODO: to be implemented");
}

/// https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-get-mode
pub fn getMode(script: *c.struct__cairo_device) ScriptMode {
    const c_enum = c.cairo_script_get_mode(script);
    return ScriptMode.fromCairoEnum(c_enum);
}

/// https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-set-mode
pub fn setMode(script: *c.struct__cairo_device, mode: ScriptMode) void {
    const c_integer = mode.toCInt();
    std.debug.panic("Cannot cast c_int={} to a C enum because cairo_script_mode_t is an unnamed enum.", .{c_integer});
    // TODO: how to get this c_enum to pass to the C function?
    // c.cairo_script_set_mode(script, c_enum);
}

/// Create a Script Surface
/// https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-surface-create
pub fn surfaceCreate(filename: []const u8, content: Content, width: f64, height: f64) !*c.struct__cairo_surface {
    var script_c_ptr = try create(filename);
    // cairo_script_surface_create always returns a valid pointer, but it will
    // return a pointer to a "nil" surface if an error such as out of memory
    // occurs. You can use cairo_surface_status() to check for this.
    return c.cairo_script_surface_create(script_c_ptr, content.toCairoEnum(), width, height).?;
}

/// https://www.cairographics.org/manual/cairo-Script-Surfaces.html#cairo-script-write-comment
pub fn writeComment(script: *c.struct__cairo_device, comment: []const u8) void {
    c.cairo_script_write_comment(script, comment.ptr, @intCast(c_int, comment.len));
}
