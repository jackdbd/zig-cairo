//! Example code to show how to use pangocairo to render arbitrary shapes inside
//! a text layout, positioned by Pango.
//! https://gitlab.gnome.org/GNOME/pango/-/blob/master/examples/cairoshape.c
const std = @import("std");
const log = std.log;
const pi = std.math.pi;
const cos = std.math.cos;
const cairo = @import("cairo");
const pc = @import("pangocairo");

const BULLET = "•";

const text =
    \\The GNOME project provides two things:
    \\
    \\  • The GNOME desktop environment
    \\  • The GNOME development platform
    \\  • Planet GNOME
;

const path =
    \\M 86.068,1 C 61.466,0 56.851,35.041 70.691,35.041 C 84.529,35.041 110.671,0 86.068,0 z
    \\M 45.217,30.699 C 52.586,31.149 60.671,2.577 46.821,4.374 C 32.976,6.171 37.845,30.249 45.217,30.699 z
    \\M 11.445,48.453 C 16.686,46.146 12.12,23.581 3.208,29.735 C -5.7,35.89 6.204,50.759 11.445,48.453 z
    \\M 26.212,36.642 C 32.451,35.37 32.793,9.778 21.667,14.369 C 10.539,18.961 19.978,37.916 26.212,36.642 L 26.212,36.642 z
    \\M 58.791,93.913 C 59.898,102.367 52.589,106.542 45.431,101.092 C 22.644,83.743 83.16,75.088 79.171,51.386 C 75.86,31.712 15.495,37.769 8.621,68.553 C 3.968,89.374 27.774,118.26 52.614,118.26 C 64.834,118.26 78.929,107.226 81.566,93.248 C 83.58,82.589 57.867,86.86 58.791,93.913 L 58.791,93.913 z
;

// I don't know if the multiline string works or I have to use a single string
// const path = "M 86.068,1 C 61.466,0 56.851,35.041 70.691,35.041 C 84.529,35.041 110.671,0 86.068,0 z M 45.217,30.699 C 52.586,31.149 60.671,2.577 46.821,4.374 C 32.976,6.171 37.845,30.249 45.217,30.699 z M 11.445,48.453 C 16.686,46.146 12.12,23.581 3.208,29.735 C -5.7,35.89 6.204,50.759 11.445,48.453 z M 26.212,36.642 C 32.451,35.37 32.793,9.778 21.667,14.369 C 10.539,18.961 19.978,37.916 26.212,36.642 L 26.212,36.642 z M 58.791,93.913 C 59.898,102.367 52.589,106.542 45.431,101.092 C 22.644,83.743 83.16,75.088 79.171,51.386 C 75.86,31.712 15.495,37.769 8.621,68.553 C 3.968,89.374 27.774,118.26 52.614,118.26 C 64.834,118.26 78.929,107.226 81.566,93.248 C 83.58,82.589 57.867,86.86 58.791,93.913 L 58.791,93.913 z ";

// TODO: add render method? (it would replace the miniSvgRender function)
const MiniSvg = struct {
    width: f64,
    height: f64,
    path: []const u8,
};

var gnome_foot_logo = MiniSvg{
    .width = 96.2152,
    .height = 118.26,
    .path = path,
};

// TODO: miniSvgRender
fn miniSvgRender(shape: *MiniSvg, cr: ?cairo.CContext, do_path: c_int) void {
    log.debug("miniSvgRender", .{});
    if (do_path == 1) {
        log.debug("do_path is TRUE", .{});
    } else {
        log.debug("do_path is FALSE", .{});
    }
}

fn shapeRenderer(cr: ?cairo.CContext, attr: pc.PangoAttrShape, do_path: c_int, data: ?*c_void) callconv(.C) void {
    log.debug("shapeRenderer", .{});
    if (do_path == 1) {
        log.debug("do_path is TRUE", .{});
    } else {
        log.debug("do_path is FALSE", .{});
    }
    // log.debug("attr {}", .{ attr });
    // log.debug("PangoAttrShape {}", .{ attr.* });
    log.debug("PangoAttrShape.data {}", .{attr.*.data});
    // TODO: how to cast PangoAttrShape.data into *MiniSvg ? The alignment
    // doesn't match.
    // const shape = @ptrCast(*MiniSvg, attr.*.data.?);
    // const shape = (MiniSvg *) attr.data; // @ptrCast a MiniSvg ?

    log.debug("ink_rect.width {}", .{attr.*.ink_rect.width});
    log.debug("ink_rect.height {}", .{attr.*.ink_rect.height});

    // scale_x = (double) attr->ink_rect.width  / (PANGO_SCALE * shape->width );
    // scale_y = (double) attr->ink_rect.height / (PANGO_SCALE * shape->height);

    // cr.relMoveTo((double) attr->ink_rect.x / PANGO_SCALE, (double) attr->ink_rect.y / PANGO_SCALE);
    // cr.scale(scale_x, scale_y);
    // miniSvgRender(shape, cr, do_path);
    // this should probably be:
    // miniSvg.render(cr, do_path);

    // @panic("TODO: remove me when shapeRenderer is correct");
}

// TODO: how to return a ?*c_void type?
// fn pangoAttrDataCopyFunc(user_data: ?*const c_void) callconv(.C) ?*c_void {
//     log.debug("pangoAttrDataCopyFunc", .{});
//     log.debug("user_data {}", .{user_data});
//     return @ptrCast(?*c_void, user_data);
// }
const pangoAttrDataCopyFunc: ?pc.PangoAttrDataCopyFunc = null;

fn gDestroyNotify(data: ?*c_void) callconv(.C) void {
    log.debug("gDestroyNotify", .{});
    // log.debug("data {}", .{data.?.*}); // data.? is opaque
}
// const gDestroyNotify: ?pc.GDestroyNotify = null;

fn getLayout(cr: *cairo.Context) !pc.Layout {
    var ink_rect = try pc.Rectangle.new(1 * pc.SCALE, -11 * pc.SCALE, 8 * pc.SCALE, 10 * pc.SCALE);
    var logical_rect = try pc.Rectangle.new(0 * pc.SCALE, -12 * pc.SCALE, 10 * pc.SCALE, 12 * pc.SCALE);

    var layout = try pc.Layout.create(cr);

    var ctx = try layout.getContext();
    ctx.setShapeRenderer(shapeRenderer, null, null);
    layout.setText(text);

    var attrs = try pc.AttrList.new();
    defer attrs.destroy();

    var idx = std.mem.indexOf(u8, text[0..], BULLET);
    while (idx != null) {
        const str = text[idx.?..];
        // log.debug("idx {} str.len {}", .{idx, str.len});
        var attr = try pc.Attribute.newShapeWithData(MiniSvg, &ink_rect, &logical_rect, &gnome_foot_logo, pangoAttrDataCopyFunc, gDestroyNotify);
        // TODO: move this ptrCast and intCast to pango.zig
        // https://stackoverflow.com/questions/18659120/subtracting-two-strings-in-c
        const str_addr = @intCast(c_uint, @ptrToInt(str.ptr));
        const text_addr = @intCast(c_uint, @ptrToInt(text));
        attr.c_ptr.*.start_index = str_addr - text_addr;
        attr.c_ptr.*.end_index = attr.c_ptr.*.start_index + @intCast(c_uint, BULLET.len);
        attrs.insert(&attr);

        // find index for next iteration
        const i_rel = std.mem.indexOf(u8, text[idx.? + BULLET.len ..], BULLET);
        if (i_rel == null) {
            idx = null;
        } else {
            idx = idx.? + i_rel.? + 1;
        }
    }

    layout.setAttributes(&attrs);
    return layout;
}

fn drawText(cr: *cairo.Context, width: ?f64, height: ?f64) !pc.Size {
    log.info("=== drawText ===", .{});
    var layout = try getLayout(cr);
    defer layout.destroy();

    var size = pc.Size{ .width = 0.0, .height = 0.0 };
    const margin = 10.0;

    if ((width != null) or (height != null)) {
        const original_size = layout.getPixelSize();
        if (width != null) {
            size.width = original_size.width + 2.0 * margin;
        }
        if (height != null) {
            size.height = original_size.height + 2.0 * margin;
        }
    }

    cr.moveTo(margin, margin);
    layout.show(cr);

    return size;
}

pub fn main() !void {
    // First create and use a 0x0 surface, to measure how large the final
    // surface needs to be.
    var surface = try cairo.Surface.image(0.0, 0.0);
    defer surface.destroy();

    var cr = try cairo.Context.create(&surface);
    defer cr.destroy();

    const size = try drawText(&cr, null, null);

    // TODO: Now create the final surface and draw to it. Reuse surface and cr?
    var surface2 = try cairo.Surface.image(@floatToInt(u16, size.width), @floatToInt(u16, size.height));
    defer surface2.destroy();

    var cr2 = try cairo.Context.create(&surface);
    defer cr2.destroy();

    cr2.setSourceRgb(1.0, 1.0, 1.0); // white
    cr2.paint();

    cr2.setSourceRgb(0.0, 0.0, 0.5);
    const size2 = try drawText(&cr2, size.width, size.height);

    _ = surface2.writeToPng("examples/generated/pango_shape.png");
}
