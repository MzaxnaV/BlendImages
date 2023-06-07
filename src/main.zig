const std = @import("std");

const DEBUG = false;

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

var filePath: [256]u8 = [1]u8{0} ** 256;

pub fn run() !void {
    const screenWidth = 816;
    const screenHeight = 528;

    var makeImageVisible = false;

    rl.InitWindow(screenWidth, screenHeight, "BlendImages");
    defer rl.CloseWindow();

    const imagesPanel: rl.Rectangle = .{ .x = 552, .y = 24, .width = 240, .height = 480 };
    var imagesPanelBoundsOffset = rl.Vector2{ .x = 4, .y = 4 };
    var imagesPanelContentRec: rl.Rectangle = .{
        .x = imagesPanel.x,
        .y = imagesPanel.y,
        .width = imagesPanel.width - imagesPanelBoundsOffset.x,
        // .height = 4,
        .height = imagesPanel.height - imagesPanelBoundsOffset.y,
    };
    var imagesPanelScrollView = rl.Rectangle{ .x = 0, .y = 0, .width = 0, .height = 0 };
    var imagesPanelScrollOffset = rl.Vector2{ .x = 0, .y = 0 };

    const previewBox: rl.Rectangle = .{ .x = 24, .y = 24, .width = 504, .height = 480 };
    const previewPanel: rl.Rectangle = .{ .x = 32, .y = 32, .width = 488, .height = 464 };

    const imageBox: rl.Rectangle = .{ .x = 12, .y = 12, .width = 216, .height = 120 };
    var imagePanel: rl.Rectangle = .{ .x = 20, .y = 20, .width = 200, .height = 104 };

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        { // Update
            const mousePos = rl.GetMousePosition();
            if (rl.CheckCollisionPointRec(mousePos, imagesPanel) and rl.IsFileDropped()) {
                const droppedFiles = rl.LoadDroppedFiles();
                defer rl.UnloadDroppedFiles(droppedFiles);

                _ = rl.TextCopy(filePath[0..].ptr, droppedFiles.paths[0]);

                makeImageVisible = true;
            }
        }

        { // Draw
            rl.BeginDrawing();
            defer rl.EndDrawing();

            rl.ClearBackground(rl.GetColor(@bitCast(u32, rl.GuiGetStyle(rl.DEFAULT, rl.BACKGROUND_COLOR))));

            _ = rl.GuiGroupBox(previewBox, "Preview");
            _ = rl.GuiPanel(previewPanel, null);

            _ = rl.GuiScrollPanel(imagesPanel, null, imagesPanelContentRec, &imagesPanelScrollOffset, &imagesPanelScrollView);

            {
                rl.BeginScissorMode(
                    @floatToInt(i32, imagesPanelContentRec.x),
                    @floatToInt(i32, imagesPanelContentRec.y),
                    @floatToInt(i32, imagesPanelContentRec.width),
                    @floatToInt(i32, imagesPanelContentRec.height),
                );

                defer rl.EndScissorMode();

                if (makeImageVisible) {
                    _ = rl.GuiGroupBox(.{
                        .x = imageBox.x + imagesPanel.x + imagesPanelScrollOffset.x,
                        .y = imageBox.y + imagesPanel.y + imagesPanelScrollOffset.y,
                        .width = imageBox.width,
                        .height = imageBox.height,
                    }, filePath[0..].ptr);
                    _ = rl.GuiPanel(.{
                        .x = imagePanel.x + imagesPanel.x + imagesPanelScrollOffset.x,
                        .y = imagePanel.y + imagesPanel.y + imagesPanelScrollOffset.y,
                        .width = imagePanel.width,
                        .height = imagePanel.height,
                    }, null);
                } else {
                    rl.DrawText(
                        "Drop your files\nTo this window!",
                        @floatToInt(i32, 30 + imageBox.x + imagesPanel.x + imagesPanelScrollOffset.x),
                        @floatToInt(i32, imagesPanel.height / 2 + imageBox.y + imagesPanel.y + imagesPanelScrollOffset.y - 40),
                        20,
                        rl.DARKGRAY,
                    );
                }
            }

            rl.DrawRectangle(
                @floatToInt(i32, imagesPanel.x + imagesPanelScrollOffset.x),
                @floatToInt(i32, imagesPanel.y + imagesPanelScrollOffset.y),
                @floatToInt(i32, imagesPanelContentRec.width),
                @floatToInt(i32, imagesPanelContentRec.height),
                rl.Fade(rl.RED, 0.1),
            );
        }
    }
}

pub fn main() !void {
    return if (DEBUG) scroll_panel.run() else run();
}
