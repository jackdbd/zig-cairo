//! Cairo interface to underlying rendering system.
//! Devices are the abstraction Cairo employs for the rendering system used by a
//! cairo_surface_t.
const std = @import("std");
const c = @import("../c.zig");
const enums = @import("../enums.zig");
const DeviceType = enums.DeviceType;
const Format = enums.Format;
const ScriptMode = enums.ScriptMode;
const error_handling = @import("../utilities/error_handling.zig");
const Error = error_handling.Error;
const statusToError = error_handling.statusToError;

pub const Device = struct {
    /// The original cairo_device_t C struct.
    /// A cairo_device_t represents the driver interface for drawing operations
    /// to a cairo_surface_t.
    /// Memory management of cairo_device_t is done with
    /// cairo_device_reference() and cairo_device_destroy().
    /// https://www.cairographics.org/manual/cairo-cairo-device-t.html
    c_ptr: *c.struct__cairo_device,

    const Self = @This();

    /// Acquire the device for the current thread. This function will block
    /// until no other thread has acquired the device.
    /// If the returned value is void, you successfully acquired the device.
    /// If the device is in an error state you will get a zig error and will not
    /// acquire the device.
    /// After a successful call to acquire(), a matching call to release() is
    /// required.
    /// https://www.cairographics.org/manual/cairo-cairo-device-t.html#cairo-device-acquire
    pub fn acquire(self: *Self) !void {
        return statusToError(c.cairo_device_acquire(self.c_ptr));
    }

    /// Decrease the reference count on the C cairo_device_t struct by one.
    /// https://www.cairographics.org/manual/cairo-cairo-device-t.html#cairo-device-destroy
    pub fn destroy(self: *Self) void {
        c.cairo_device_destroy(self.c_ptr);
    }

    /// https://www.cairographics.org/manual/cairo-cairo-device-t.html#cairo-device-finish
    pub fn finish(self: *Self) void {
        c.cairo_device_finish(self.c_ptr);
    }

    /// https://www.cairographics.org/manual/cairo-cairo-device-t.html#cairo-device-flush
    pub fn flush(self: *Self) void {
        c.cairo_device_flush(self.c_ptr);
    }

    /// https://www.cairographics.org/manual/cairo-cairo-device-t.html#cairo-device-get-reference-count
    pub fn getReferenceCount(self: *Self) c_uint {
        return c.cairo_device_get_reference_count(self.c_ptr);
    }

    /// https://www.cairographics.org/manual/cairo-cairo-device-t.html#cairo-device-get-type
    pub fn getType(self: *Self) DeviceType {
        return DeviceType.fromCairoEnum(c.cairo_device_get_type(self.c_ptr));
    }

    pub fn getUserData(self: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// https://www.cairographics.org/manual/cairo-cairo-device-t.html#cairo-device-observer-elapsed
    pub fn observerElapsed(self: *Self) f64 {
        return c.cairo_device_observer_elapsed(self.c_ptr);
    }

    /// https://www.cairographics.org/manual/cairo-cairo-device-t.html#cairo-device-observer-fill-elapsed
    pub fn observerFillElapsed(self: *Self) f64 {
        return c.cairo_device_observer_fill_elapsed(self.c_ptr);
    }

    /// https://www.cairographics.org/manual/cairo-cairo-device-t.html#cairo-device-observer-glyphs-elapsed
    pub fn observerGlyphsElapsed(self: *Self) f64 {
        return c.cairo_device_observer_glyphs_elapsed(self.c_ptr);
    }

    pub fn observerMaskElapsed(self: *Self) f64 {
        return c.cairo_device_observer_mask_elapsed(self.c_ptr);
    }

    pub fn observerPaintElapsed(self: *Self) f64 {
        return c.cairo_device_observer_paint_elapsed(self.c_ptr);
    }

    pub fn observerPrint(self: *Self) void {
        @panic("TODO: to be implemented");
    }

    pub fn observerStrokeElapsed(self: *Self) f64 {
        return c.cairo_device_observer_stroke_elapsed(self.c_ptr);
    }

    /// https://www.cairographics.org/manual/cairo-cairo-device-t.html#cairo-device-reference
    pub fn reference(self: *Self) *c.struct__cairo_device {
        const c_ptr = c.cairo_device_reference(self.c_ptr);
        return c_ptr.?; // not sure if this should be optional or not
    }

    /// Release a device previously acquired using acquire().
    /// https://www.cairographics.org/manual/cairo-cairo-device-t.html#cairo-device-release
    pub fn release(self: *Self) void {
        // TODO: calling cairo_device_release without a matching
        // cairo_device_acquire causes an assertion error in the C code. Should
        // we deal with it here?
        c.cairo_device_release(self.c_ptr);
    }

    pub fn setUserData(self: *Self) void {
        @panic("TODO: to be implemented");
    }

    /// https://www.cairographics.org/manual/cairo-cairo-device-t.html#cairo-device-status
    pub fn status(self: *Self) !void {
        return statusToError(c.cairo_device_status(self.c_ptr));
    }
};

const testing = std.testing;
const expect = testing.expect;
const expectEqual = testing.expectEqual;
const expectError = testing.expectError;
const script_surface = @import("./script.zig");

// CairoScript file
const OUTPUT_DEVICE_FILENAME = "test-script-surface.cairoscript";

fn testDevice(filename: []const u8) !Device {
    var c_ptr = try script_surface.create(filename);
    return Device{ .c_ptr = c_ptr };
}

test "reference() and destroy() modify the reference count as expected" {
    var device = try testDevice(OUTPUT_DEVICE_FILENAME);

    expectEqual(@as(c_uint, 1), device.getReferenceCount());

    _ = device.reference();
    expectEqual(@as(c_uint, 2), device.getReferenceCount());

    device.destroy();
    expectEqual(@as(c_uint, 1), device.getReferenceCount());

    // calling destroy() again does NOT give a refcount of 0. Why? Is it a bug in Cairo?
    // device.destroy();
    // expectEqual(@as(c_uint, 0), device.getReferenceCount());
}

test "getType() returns the expected device type" {
    var device = try testDevice(OUTPUT_DEVICE_FILENAME);
    defer device.destroy();

    expectEqual(DeviceType.script, device.getType());
}

test "the script surface has the expected mode (ASCII)" {
    var device = try testDevice(OUTPUT_DEVICE_FILENAME);
    defer device.destroy();

    expectEqual(ScriptMode.ascii, script_surface.getMode(device.c_ptr));
}

test "acquire() after finish() returns the expected error" {
    var device = try testDevice(OUTPUT_DEVICE_FILENAME);

    // acquire() before finish() is fine
    _ = try device.acquire();
    device.finish();

    // acquire() after finish() is not
    expectError(Error.DeviceFinished, device.acquire());
    expectEqual(@as(c_uint, 1), device.getReferenceCount());

    var errored = false;
    _ = device.status() catch |err| {
        errored = true;
        expectEqual(Error.DeviceFinished, err);
    };
    expectEqual(true, errored);
}

test "acquire() a device after destroy() returns the expected error" {
    var device = try testDevice(OUTPUT_DEVICE_FILENAME);
    device.destroy();

    expectError(Error.DeviceFinished, device.acquire());
}
