//! Compile-time and run-time version checks.
//! https://cairographics.org/manual/cairo-Version-Information.html
const std = @import("std");
const c = @import("../c.zig");

const version_encoded = c.CAIRO_VERSION_ENCODE(c.CAIRO_VERSION_MAJOR, c.CAIRO_VERSION_MINOR, c.CAIRO_VERSION_MICRO);

const CairoVersion = struct {
    major: c_int,
    minor: c_int,
    micro: c_int,
};

pub const Version = CairoVersion{
    .major = c.CAIRO_VERSION_MAJOR,
    .minor = c.CAIRO_VERSION_MINOR,
    .micro = c.CAIRO_VERSION_MICRO,
};

pub fn version() c_int {
    return version_encoded;
}

pub fn versionString() void {
    @panic("TODO: to be implemented");
    // use c.cairo_version_string()?;
}
