const std = @import("std");
const exp = std.math.exp;
const pi = std.math.pi;
const log = std.log;
const cairo = @import("cairo");
const Format = cairo.image_surface.Format;
const setBackground = @import("utils.zig").setBackground;

/// https://www.cairographics.org/samples/image/
fn image(cr: *cairo.Context) !void {
    var surface = try cairo.Surface.createFromPng("data/romedalen.png");
    defer surface.destroy();

    const w = try surface.getWidth();
    const h = try surface.getHeight();

    cr.translate(128.0, 128.0);
    cr.rotate(45 * pi / 180.0);
    cr.scale(256.0 / @intToFloat(f64, w), 256.0 / @intToFloat(f64, h));
    cr.translate(-0.5 * @intToFloat(f64, w), -0.5 * @intToFloat(f64, h));

    cr.setSourceSurface(&surface, 0, 0);
    cr.paint();
}

/// https://www.cairographics.org/cookbook/blur.c/
fn blurImageSurface(allocator: *std.mem.Allocator, surface: *cairo.Surface, radius: u16) !void {
    try cairo.checkSurfaceStatus(surface.surface);

    const width = try surface.getWidth();
    const height = try surface.getHeight();
    const width_f64 = @intToFloat(f64, width);

    // check that we are starting from a Cairo image surface
    switch (cairo.image_surface.getFormat(surface.surface)) {
        Format.A1 => {
            return error.GaussianBlurNotImplementedForThisSurface;
        },
        Format.A8 => log.debug("Can blur but set width /= 4;", .{}),
        Format.Argb32 => {
            log.debug("Ok, can blur", .{});
        },
        Format.Rgb24 => {
            log.debug("Ok, can blur", .{});
        },
        else => |format| {
            log.debug("Format: {}", .{format});
            return error.GaussianBlurNotImplementedForThisSurface;
        },
    }

    var tmp = try cairo.image_surface.create(Format.Argb32, width, height);
    // defer tmp.destroy();
    try cairo.checkSurfaceStatus(tmp);

    const src = try cairo.image_surface.getData(surface.surface);
    // log.debug("src {}", .{src});
    const src_stride = cairo.image_surface.getStride(surface.surface);
    // log.debug("src_stride {}", .{src_stride});

    const dest = try cairo.image_surface.getData(tmp);
    const dest_stride = cairo.image_surface.getStride(tmp);

    // build the gaussian kernel ///////////////////////////////////////////////
    // TODO: add link to mathematical function
    const size: usize = 17;
    const half = @intToFloat(f64, size) / 2.0;
    var kernel = std.ArrayList(f64).init(allocator);
    var a: f64 = 0;
    var i: usize = 0;
    while (i < size) : (i += 1) {
        const f = @intToFloat(f64, i) - half;
        const coeff = exp(-f * f / 30.0) * 80.0;
        try kernel.append(coeff);
        a += coeff;
    }

    // blur the image //////////////////////////////////////////////////////////

    // const s_addr = (@ptrToInt(src) + src_stride); // double-check the parentheses
    // const s = @intToPtr([*]u32, s_addr);
    // log.debug("s {}\n", .{@typeInfo(@TypeOf(s))});

    // Horizontally blur from surface -> tmp
    i = 0;
    while (i < height) : (i += 1) {
        // log.debug("height px {}/{}", .{i+1, height});
        const s_addr = (@ptrToInt(src) + i * src_stride); // double-check the parentheses
        const d_addr = (@ptrToInt(dest) + i * dest_stride);
        const s = @intToPtr([*]u32, s_addr);
        const d = @intToPtr([*]u32, d_addr);
        // std.debug.print("s {}\n", .{@typeInfo(@TypeOf(s))});
        var j: usize = 0;
        while (j < width) : (j += 1) {
            // log.debug("width px {}/{}", .{j+1, width});
            if (radius < j and j < (width - radius)) {
                // log.debug("d[j] = s[j]", .{});
                d[j] = s[j];
                continue;
            } else {
                // log.debug("ELSE", .{});
                var x: f64 = 0;
                var y: f64 = 0;
                var z: f64 = 0;
                var w: f64 = 0;

                var k: usize = 0;
                while (k < size) : (k += 1) {
                    const k_f64 = @intToFloat(f64, k);
                    const j_f64 = @intToFloat(f64, j);
                    if ((j_f64 - half + k_f64 < 0) or (j_f64 - half + k_f64 >= width_f64)) {
                        continue;
                    } else {
                        const idx = @floatToInt(usize, j_f64 - half + k_f64);
                        const p = s[idx];
                        // what are these things? What does this shifting mean?
                        const px = @intToFloat(f64, (p >> 24) & 0xff);
                        const py = @intToFloat(f64, (p >> 16) & 0xff);
                        const pz = @intToFloat(f64, (p >> 8) & 0xff);
                        const pw = @intToFloat(f64, (p >> 0) & 0xff);
                        x += px * kernel.items[k];
                        y += py * kernel.items[k];
                        z += pz * kernel.items[k];
                        w += pw * kernel.items[k];
                    }
                }
                // d[j] = (x / a << 24) | (y / a << 16) | (z / a << 8) | w / a;
                const a_u32 = @floatToInt(u32, a);
                const cond1 = x / @intToFloat(f64, (a_u32 << 24));
                const cond2 = y / @intToFloat(f64, (a_u32 << 16));
                const cond3 = z / @intToFloat(f64, (a_u32 << 8));
                const cond4 = w / a;
                // d[j] = cond1 | cond2 | cond3 | cond4;
            }
        }
    }

    // TODO: Then vertically blur from tmp -> surface

    cairo.c.cairo_surface_destroy(tmp);
    cairo.c.cairo_surface_mark_dirty(surface.surface);
}

pub fn main() !void {
    const width: u16 = 256;
    const height: u16 = 256;
    std.debug.print("gaussian_blur example ({}x{} px)\n", .{ width, height });

    var surface = try cairo.Surface.image(width, height);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    setBackground(&cr);
    try image(&cr);

    const radius: u16 = 20;
    try blurImageSurface(std.testing.allocator, &surface, radius);

    _ = surface.writeToPng("examples/generated/gaussian_blur.png");
}
