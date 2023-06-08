const std = @import("std");

const DEBUG = false;

// const basic_window = @import("raylib-examples/basic-window.zig");
// const drop_files = @import("raylib-examples/drop-files.zig");
// const input_keys = @import("raylib-examples/input-keys.zig");
// const input_mouse = @import("raylib-examples/input-mouse.zig");
// const input_gestures = @import("raylib-examples/input-gestures.zig");
// const image_drawing = @import("raylib-examples/image-drawing.zig");
// const raw_data = @import("raylib-examples/raw-data.zig");
// const scroll_panel = @import("raylib-examples/scroll-pane.zig");

pub const rl = @cImport({
    @cInclude("raylib.h");
    @cDefine("RAYGUI_IMPLEMENTATION", {});
    @cInclude("raygui.h");
});

const image_box = struct {
    size: rl.Rectangle,
    texture: rl.Texture2D,
    filename: [256]u8,
};

const images_panel = struct {
    const offset = 8;

    size: rl.Rectangle,
    contentSize: rl.Rectangle,
    scrollOffset: rl.Vector2,
    scrollView: rl.Rectangle,
    boxes: std.ArrayList(image_box),

    fn draw(self: @This()) void {
        for (self.boxes.items) |box| {
            _ = rl.GuiGroupBox(.{
                .x = self.size.x + box.size.x + self.scrollOffset.x,
                .y = self.size.y + box.size.y + self.scrollOffset.y,
                .width = box.size.width,
                .height = box.size.height,
            }, box.filename[0..].ptr);
            
            _ = rl.GuiPanel(.{
                .x = self.size.x + box.size.x + offset + self.scrollOffset.x,
                .y = self.size.y + box.size.y + offset + self.scrollOffset.y,
                .width = box.size.width - 2 * offset,
                .height = box.size.height - 2 * offset,
            }, null);

            _ = rl.DrawTexturePro(
                box.texture,
                .{
                    .x = 0,
                    .y = 0,
                    .width = @intToFloat(f32, box.texture.width),
                    .height = @intToFloat(f32, box.texture.height),
                },
                .{
                    .x = self.size.x + box.size.x + offset + self.scrollOffset.x,
                    .y = self.size.y + box.size.y + offset + self.scrollOffset.y,
                    .width = box.size.width - 2 * offset,
                    .height = box.size.height - 2 * offset,
                },
                .{ .x = 0, .y = 0 },
                0,
                rl.WHITE,
            );
        }
    }
};

pub fn run() !void {
    const screenWidth = 816;
    const screenHeight = 528;

    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer if (gpa.deinit() == .leak) std.debug.print("LEAKING MEMORY!", .{});

    var gpa = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer gpa.deinit();

    const allocator = gpa.allocator();

    var makeImageVisible = false;

    rl.InitWindow(screenWidth, screenHeight, "BlendImages");
    defer rl.CloseWindow();

    var panel = images_panel{
        .size = .{ .x = 552, .y = 24, .width = 240, .height = 480 },
        .contentSize = .{ .x = 552, .y = 24, .width = 240 - 8, .height = 4 },
        .boxes = std.ArrayList(image_box).init(allocator),
        .scrollOffset = .{ .x = 0, .y = 0 },
        .scrollView = .{ .x = 0, .y = 0, .width = 0, .height = 0 },
    };
    defer {
        for (panel.boxes.items[0..]) |imagebox| {
            rl.UnloadTexture(imagebox.texture);
        }
        panel.boxes.deinit();
    }

    const previewBox: rl.Rectangle = .{ .x = 24, .y = 24, .width = 504, .height = 480 };
    const previewPanel: rl.Rectangle = .{ .x = 32, .y = 32, .width = 488, .height = 464 };

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        { // Update
            const mousePos = rl.GetMousePosition();
            if (rl.CheckCollisionPointRec(mousePos, panel.size) and rl.IsFileDropped()) {
                const droppedFiles = rl.LoadDroppedFiles();
                defer rl.UnloadDroppedFiles(droppedFiles);

                for (0..droppedFiles.count) |i| {
                    var image: rl.Image = rl.LoadImage(droppedFiles.paths[i]);
                    defer rl.UnloadImage(image);

                    if (image.data) |_| {
                        var box: *image_box = try panel.boxes.addOne();
                        box.size = .{
                            .x = 12,
                            .y = 12 + @intToFloat(f32, panel.boxes.items.len - 1) * 128,
                            .width = 216,
                            .height = 120,
                        };
                        box.texture = rl.LoadTextureFromImage(image);

                        var count = @as(i32, 0);
                        var splits = rl.TextSplit(droppedFiles.paths[i], '\\', &count);
                        _ = rl.TextCopy(box.filename[0..].ptr, splits[@intCast(u32, count - 1)]);

                        panel.contentSize.height += box.size.height + 8;

                        makeImageVisible = true;
                    }
                }
            }
        }

        { // Draw
            rl.BeginDrawing();
            defer rl.EndDrawing();

            rl.ClearBackground(rl.GetColor(@bitCast(u32, rl.GuiGetStyle(rl.DEFAULT, rl.BACKGROUND_COLOR))));

            _ = rl.GuiGroupBox(previewBox, "Preview");
            _ = rl.GuiPanel(previewPanel, null);

            _ = rl.GuiScrollPanel(panel.size, null, panel.contentSize, &panel.scrollOffset, &panel.scrollView);

            {
                rl.BeginScissorMode(
                    @floatToInt(i32, panel.size.x),
                    @floatToInt(i32, panel.size.y + 1),
                    @floatToInt(i32, panel.size.width - 12),
                    @floatToInt(i32, panel.size.height - 14),
                );

                defer rl.EndScissorMode();

                if (makeImageVisible) {
                    panel.draw();
                } else {
                    rl.DrawText(
                        "Drop your images\nin this area!",
                        @floatToInt(i32, 30 + panel.size.x + panel.scrollOffset.x),
                        @floatToInt(i32, panel.size.height / 2 + panel.size.y + panel.scrollOffset.y - 40),
                        20,
                        rl.DARKGRAY,
                    );
                }
            }

            if (DEBUG) {
                rl.DrawRectangle(
                    @floatToInt(i32, panel.size.x + panel.scrollOffset.x),
                    @floatToInt(i32, panel.size.y + panel.scrollOffset.y),
                    @floatToInt(i32, panel.contentSize.width),
                    @floatToInt(i32, panel.contentSize.height),
                    rl.Fade(rl.RED, 0.1),
                );
            }
        }
    }
}

pub fn main() !void {
    return run();
}
