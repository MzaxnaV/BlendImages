const std = @import("std");

const basic_window = @import("raylib-examples/basic-window.zig");
const input_keys = @import("raylib-examples/input-keys.zig");
const input_mouse = @import("raylib-examples/input-mouse.zig");
const input_gestures = @import("raylib-examples/input-gestures.zig");
const drop_files = @import("raylib-examples/drop-files.zig");
const scroll_pane = @import("raylib-examples/scroll-pane.zig");


pub fn main() !void {
    return scroll_pane.run();
}