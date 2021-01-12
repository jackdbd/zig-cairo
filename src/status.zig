//! Errors that can occurr when using Cairo
const std = @import("std");
const c = @import("c.zig");
const Device = @import("surface/device.zig").Device;

/// Possible return values for cairo_surface_status()
/// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-status
pub const SurfaceStatus = enum {
    Success,
    NullPointer,
    NoMemory,
    ReadError,
    InvalidContent,
    InvalidFormat,
    InvalidVisual,
    // SurfaceTypeMismatch, // I think this should be included, even if cairo does not mention it.
};

/// Possible return values for cairo_region_status ()
/// https://www.cairographics.org/manual/cairo-Regions.html#cairo-region-status
pub const RegionStatus = enum {
    Success,
    NoMemory,
};

/// Possible return values for cairo_pattern_status ()
/// https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-status
pub const PatternStatus = enum {
    Success,
    NoMemory,
    InvalidMatrix,
    PatternTypeMismatch,
    InvalidMeshConstruction,
};

/// Possible return values for cairo_scaled_font_status ()
/// https://www.cairographics.org/manual/cairo-cairo-scaled-font-t.html#cairo-scaled-font-status
pub const ScaledFontStatus = enum {
    Success,
    NoMemory,
};

/// Possible return values for cairo_font_face_status ()
/// https://www.cairographics.org/manual/cairo-cairo-font-face-t.html#cairo-font-face-status
pub const FontFaceStatus = enum {
    Success,
    NoMemory,
};

// TODO: can I avoid repeating the same field for the enum and the error?

/// https://www.cairographics.org/manual/cairo-Error-handling.html#cairo-status-t
pub const StatusEnum = enum {
    Success,
    NoMemory,
    InvalidRestore,
    InvalidPopGroup,
    NoCurrentPoint,
    InvalidMatrix,
    InvalidStatus,
    NullPointer,
    InvalidString,
    InvalidPathData,
    ReadError,
    WriteError,
    SurfaceFinished,
    SurfaceTypeMismatch,
    PatternTypeMismatch,
    InvalidContent,
    InvalidFormat,
    InvalidVisual,
    FileNotFound,
    InvalidDash,
    InvalidDscComment,
    InvalidIndex,
    ClipNotRepresentable,
    TempFileError,
    InvalidStride,
    FotnTypeMismatch,
    UserFontImmutable,
    UserFontError,
    NegativeCount,
    InvalidClusters,
    InvalidSlant,
    InvalidWeight,
    InvalidSize,
    UserFontNotImplemented,
    DeviceTypeMismatch,
    DeviceError,
    InvalidMeshConstruction,
    DeviceFinished,
    Jbig2GlobalMissing,
    PngError,
    FreetypeError,
    Win32GdiError,
    TagError,
    LastStatus,
};

pub const Status = error{
    Success,
    NoMemory,
    InvalidRestore,
    InvalidPopGroup,
    NoCurrentPoint,
    InvalidMatrix,
    InvalidStatus,
    NullPointer,
    InvalidString,
    InvalidPathData,
    ReadError,
    WriteError,
    SurfaceFinished,
    SurfaceTypeMismatch,
    PatternTypeMismatch,
    InvalidContent,
    InvalidFormat,
    InvalidVisual,
    FileNotFound,
    InvalidDash,
    InvalidDscComment,
    InvalidIndex,
    ClipNotRepresentable,
    TempFileError,
    InvalidStride,
    FotnTypeMismatch,
    UserFontImmutable,
    UserFontError,
    NegativeCount,
    InvalidClusters,
    InvalidSlant,
    InvalidWeight,
    InvalidSize,
    UserFontNotImplemented,
    DeviceTypeMismatch,
    DeviceError,
    InvalidMeshConstruction,
    DeviceFinished,
    Jbig2GlobalMissing,
    PngError,
    FreetypeError,
    Win32GdiError,
    TagError,
    LastStatus,
};

/// Checks whether an error has previously occurred for this surface.
/// https://www.cairographics.org/manual/cairo-cairo-surface-t.html#cairo-surface-status
pub fn surfaceStatusAsEnum(cairo_surface: *c.struct__cairo_surface) SurfaceStatus {
    const c_enum = c.cairo_surface_status(cairo_surface);
    const c_integer = @enumToInt(c_enum);
    return @intToEnum(SurfaceStatus, @intCast(u3, c_integer));
}

/// Check whether an error has previously occurred for this surface. Return an
/// error if there were any.
pub fn surfaceStatus(cairo_surface: *c.struct__cairo_surface) !bool {
    const c_enum = c.cairo_surface_status(cairo_surface);
    const c_integer = @enumToInt(c_enum);
    return switch (@intToEnum(SurfaceStatus, @intCast(u3, c_integer))) {
        SurfaceStatus.Success => true, // or maybe StatusEnum.Success ?
        SurfaceStatus.NullPointer => Status.NullPointer,
        SurfaceStatus.NoMemory => Status.NoMemory,
        SurfaceStatus.ReadError => Status.ReadError,
        SurfaceStatus.InvalidContent => Status.InvalidContent,
        SurfaceStatus.InvalidFormat => Status.InvalidFormat,
        SurfaceStatus.InvalidVisual => Status.InvalidVisual,
    };
}

/// https://github.com/freedesktop/cairo/blob/6a6ab2475906635fcc5ba0c73182fae73c4f7ee8/src/cairo-misc.c#L90
pub fn surfaceStatusAsString(cairo_surface: *c.struct__cairo_surface) [:0]const u8 {
    const c_enum = c.cairo_surface_status(cairo_surface);
    return std.mem.span(c.cairo_status_to_string(c_enum)); // or spanZ?
}

/// https://www.cairographics.org/manual/cairo-cairo-device-t.html#cairo-device-status
pub fn deviceStatusAsEnum(device: Device) StatusEnum {
    const c_enum = c.cairo_device_status(device.device);
    const c_integer = @enumToInt(c_enum);
    return @intToEnum(StatusEnum, @intCast(u6, c_integer));
}
