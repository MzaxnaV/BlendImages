const std = @import("std");

const DEBUG = true;

// const basic_window = @import("raylib-examples/basic-window.zig");
// const drop_files = @import("raylib-examples/drop-files.zig");
// const input_keys = @import("raylib-examples/input-keys.zig");
// const input_mouse = @import("raylib-examples/input-mouse.zig");
// const input_gestures = @import("raylib-examples/input-gestures.zig");
// const image_drawing = @import("raylib-examples/image-drawing.zig");
// const raw_data = @import("raylib-examples/raw-data.zig");
const scroll_panel = @import("raylib-examples/scroll-pane.zig");

pub const rl = @cImport({
    @cInclude("raylib.h");
    @cDefine("RAYGUI_IMPLEMENTATION", {});
    @cInclude("raygui.h");
});

pub fn run() !void {
    const screenWidth = 816;
    const screenHeight = 528;

    rl.InitWindow(screenWidth, screenHeight, "BlendImages");
    defer rl.CloseWindow();

    var imagesPanelScrollView = rl.Rectangle{ .x = 0, .y = 0, .width = 0, .height = 0 };
    var imagesPanelScrollOffset = rl.Vector2{ .x = 0, .y = 0 };
    var imagesPanelBoundsOffset = rl.Vector2{ .x = 0, .y = 0 };

    const previewRect : rl.Rectangle = .{ .x = 24, .y = 24, .width = 504, .height = 480 };
    const previewPanelRect: rl.Rectangle = .{ .x = 32, .y = 32, .width = 488, .height = 464 };
    const imagesScollPanelRect: rl.Rectangle = .{ .x = 552, .y = 24, .width = 240, .height = 480 };
    
    // const imageRect: rl.Rectangle = .{ .x = 552, .y = 24, .width = 240, .height = 120 };
    // var imagePanel: rl.Rectangle = .{ .x = 560, .y = 536, .width = 224, .height = 104 };

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        { // Update

        }

        { // Draw
            rl.BeginDrawing();
            defer rl.EndDrawing();

            rl.ClearBackground(rl.GetColor(@bitCast(u32, rl.GuiGetStyle(rl.DEFAULT, rl.BACKGROUND_COLOR))));

            _ = rl.GuiGroupBox(previewRect, "Preview");
            _ = rl.GuiScrollPanel(
                .{ .x = 552, .y = 24, .width = 240 - imagesPanelBoundsOffset.x, .height = 480 - imagesPanelBoundsOffset.y },
                null,
                imagesScollPanelRect,
                &imagesPanelScrollOffset,
                &imagesPanelScrollView
            );
            
            _ = rl.GuiPanel(previewPanelRect, null);

            // _ = rl.GuiGroupBox(imageRect, "Image.extension");
            // _ = rl.GuiPanel(imagePanel, null);
        }
    }
}

pub fn main() !void {
    return if (DEBUG) scroll_panel.run() else run();
}
