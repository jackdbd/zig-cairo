//! Manipulating the current transformation matrix.
const std = @import("std");
const c = @import("../c.zig");
const enums = @import("../enums.zig");
const Matrix = @import("../utilities/matrix.zig").Matrix;

/// Transform a coordinate from device space to user space by multiplying the
/// given point by the inverse of the current transformation matrix (CTM).
/// https://cairographics.org/manual/cairo-Transformations.html#cairo-device-to-user
pub fn deviceToUser(c_ptr: *c.struct__cairo, x: *f64, y: *f64) void {
    c.cairo_device_to_user(c_ptr, x, y);
}

/// Transform a distance vector from device space to user space.
/// https://cairographics.org/manual/cairo-Transformations.html#cairo-device-to-user
pub fn deviceToUserDistance(c_ptr: *c.struct__cairo, dx: *f64, dy: *f64) void {
    c.cairo_device_to_user_distance(c_ptr, dx, dy);
}

/// Store the current transformation matrix (CTM) into matrix.
/// https://cairographics.org/manual/cairo-Transformations.html#cairo-get-matrix
pub fn getMatrix(c_ptr: *c.struct__cairo, matrix: *Matrix) void {
    c.cairo_get_matrix(c_ptr, matrix.c_ptr);
}

/// Reset the current transformation matrix (CTM) by setting it equal to the
/// identity matrix.
/// https://cairographics.org/manual/cairo-Transformations.html#cairo-identity-matrix
pub fn identityMatrix(c_ptr: *c.struct__cairo) void {
    c.cairo_identity_matrix(c_ptr);
}

/// Modify the current transformation matrix (CTM) by rotating the user-space
/// axes by angle radians.
/// https://cairographics.org/manual/cairo-Transformations.html#cairo-rotate
pub fn rotate(c_ptr: *c.struct__cairo, angle: f64) void {
    c.cairo_rotate(c_ptr, angle);
}

/// Modify the current transformation matrix (CTM) by scaling the X and Y
/// user-space axes by sx and sy respectively.
/// https://cairographics.org/manual/cairo-Transformations.html#cairo-scale
pub fn scale(c_ptr: *c.struct__cairo, sx: f64, sy: f64) void {
    c.cairo_scale(c_ptr, sx, sy);
}

/// Modify the current transformation matrix (CTM) by setting it equal to matrix.
/// https://cairographics.org/manual/cairo-Transformations.html#cairo-set-matrix
pub fn setMatrix(c_ptr: *c.struct__cairo, matrix: *Matrix) void {
    c.cairo_set_matrix(c_ptr, matrix.c_ptr);
}

/// Modify the current transformation matrix (CTM) by applying matrix as an
/// additional transformation.
/// https://cairographics.org/manual/cairo-Transformations.html#cairo-transform
pub fn transform(c_ptr: *c.struct__cairo, matrix: *Matrix) void {
    c.cairo_transform(c_ptr, matrix.c_ptr);
}

/// Modify the current transformation matrix (CTM) by translating the user-space
/// origin by (tx, ty).
/// https://cairographics.org/manual/cairo-Transformations.html#cairo-translate
pub fn translate(c_ptr: *c.struct__cairo, tx: f64, ty: f64) void {
    c.cairo_translate(c_ptr, tx, ty);
}

/// Transform a coordinate from user space to device space by multiplying the
/// given point by the current transformation matrix (CTM).
/// https://cairographics.org/manual/cairo-Transformations.html#cairo-user-to-device
pub fn userToDevice(c_ptr: *c.struct__cairo, x: *f64, y: *f64) void {
    c.cairo_user_to_device(c_ptr, x, y);
}

/// Transform a distance vector from user space to device space.
/// https://cairographics.org/manual/cairo-Transformations.html#cairo-user-to-device-distance
pub fn userToDeviceDistance(c_ptr: *c.struct__cairo, dx: *f64, dy: *f64) void {
    c.cairo_user_to_device_distance(c_ptr, dx, dy);
}
