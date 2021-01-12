pub usingnamespace @cImport({
    // XCB is only required when using the XCB surface backend for Cairo.
    @cInclude("xcb/xcb.h");
    @cInclude("cairo/cairo-pdf.h");
    @cInclude("cairo/cairo-svg.h");
    @cInclude("cairo/cairo-xcb.h");
    @cInclude("cairo/cairo.h");
});
