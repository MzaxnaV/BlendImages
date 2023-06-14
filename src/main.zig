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
    @cInclude("raymath.h");
    @cDefine("RAYGUI_IMPLEMENTATION", {});
    @cInclude("raygui.h");
});

const image_box = struct {
    size: rl.Rectangle,
    previewTexture: rl.Texture2D,
    filename: [256]u8,
};

const images_panel = struct {
    pub const offset = 8;

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

            _ = rl.DrawTextureV(box.previewTexture, .{
                .x = self.size.x + box.size.x + (box.size.width - @intToFloat(f32, box.previewTexture.width)) / 2 + self.scrollOffset.x,
                .y = self.size.y + box.size.y + (box.size.height - @intToFloat(f32, box.previewTexture.height)) / 2 + self.scrollOffset.y,
            }, rl.WHITE);
        }
    }
};

const preview_panel = struct {
    const offset = 8;

    size: rl.Rectangle,
    content: rl.Rectangle,
    texture: rl.Texture2D,
};

const status = enum { visible, not_supported, invisible };

pub fn run() !void {
    const screenWidth = 816;
    const screenHeight = 528;

    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer if (gpa.deinit() == .leak) std.debug.print("LEAKING MEMORY!", .{});

    var gpa = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer gpa.deinit();

    const allocator = gpa.allocator();

    var imageStatus = status.invisible;

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
            rl.UnloadTexture(imagebox.previewTexture);
        }
        panel.boxes.deinit();
    }

    var previewPanel = preview_panel{
        .size = .{ .x = 24, .y = 24, .width = 504, .height = 480 },
        .content = .{ .x = 32, .y = 32, .width = 488, .height = 464 },
        .texture = undefined,
    };

    previewPanel.texture = rl.LoadTextureFromImage(rl.GenImageChecked(
        @floatToInt(i32, previewPanel.content.width),
        @floatToInt(i32, previewPanel.content.height),
        32,
        32,
        rl.GRAY,
        rl.WHITE,
    ));
    defer rl.UnloadTexture(previewPanel.texture);

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        { // Update
            const mousePos = rl.GetMousePosition();
            if (rl.IsFileDropped()) {
                const droppedFiles = rl.LoadDroppedFiles();
                defer rl.UnloadDroppedFiles(droppedFiles);

                if (rl.CheckCollisionPointRec(mousePos, panel.size)) {
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

                            const width = @intToFloat(f32, image.width);
                            const height = @intToFloat(f32, image.height);
                            const containerWidth = (box.size.width - 2 * (images_panel.offset + 1));
                            const containerHeight = (box.size.height - 2 * (images_panel.offset + 1));

                            var scale_w = @as(f32, 1);
                            var scale_h = @as(f32, 1);

                            const imageAspectRatio = width / height;

                            const containerAspectRatio = containerWidth / containerHeight;

                            if (imageAspectRatio > containerAspectRatio) {
                                scale_w = containerWidth / width;
                                scale_h = scale_w;
                            } else {
                                scale_h = containerHeight / height;
                                scale_w = scale_h;
                            }

                            rl.ImageResize(&image, @floatToInt(i32, width * scale_w), @floatToInt(i32, height * scale_h));

                            box.previewTexture = rl.LoadTextureFromImage(image);

                            var count = @as(i32, 0);
                            var splits = rl.TextSplit(droppedFiles.paths[i], '\\', &count);
                            _ = rl.TextCopy(box.filename[0..].ptr, splits[@intCast(u32, count - 1)]);

                            panel.contentSize.height += box.size.height + 8;

                            imageStatus = status.visible;
                        } else {
                            if (imageStatus != status.visible) {
                                imageStatus = status.not_supported;
                            }
                        }
                    }

                    rl.UnloadTexture(previewPanel.texture);
                    previewPanel.texture = rl.LoadTexture(droppedFiles.paths[droppedFiles.count - 1]);
                }
            }
        }

        { // Draw
            rl.BeginDrawing();
            defer rl.EndDrawing();

            rl.ClearBackground(rl.GetColor(@bitCast(u32, rl.GuiGetStyle(rl.DEFAULT, rl.BACKGROUND_COLOR))));

            _ = rl.GuiGroupBox(previewPanel.size, "Preview");
            _ = rl.GuiPanel(previewPanel.content, null);

            // temporarily crop the preview texture
            if (previewPanel.texture.width > @floatToInt(i32, previewPanel.content.width) or previewPanel.texture.height > @floatToInt(i32, previewPanel.content.height)) {
                _ = rl.DrawTextureRec(
                    previewPanel.texture,
                    .{ .x = 0, .y = 0, .width = previewPanel.content.width, .height = previewPanel.content.height },
                    .{ .x = previewPanel.content.x, .y = previewPanel.content.y },
                    rl.WHITE,
                );
            } else {
                _ = rl.DrawTexture(previewPanel.texture, @floatToInt(i32, previewPanel.content.x), @floatToInt(i32, previewPanel.content.y), rl.WHITE);
            }

            _ = rl.GuiScrollPanel(panel.size, null, panel.contentSize, &panel.scrollOffset, &panel.scrollView);

            {
                rl.BeginScissorMode(
                    @floatToInt(i32, panel.size.x),
                    @floatToInt(i32, panel.size.y + 1),
                    @floatToInt(i32, panel.size.width - 12),
                    @floatToInt(i32, panel.size.height - 14),
                );

                defer rl.EndScissorMode();

                switch (imageStatus) {
                    status.invisible => {
                        rl.DrawText(
                            "Drop your images\nin this area!",
                            @floatToInt(i32, 30 + panel.size.x + panel.scrollOffset.x),
                            @floatToInt(i32, panel.size.height / 2 + panel.size.y + panel.scrollOffset.y - 40),
                            20,
                            rl.DARKGRAY,
                        );
                    },
                    status.visible => panel.draw(),
                    status.not_supported => {
                        rl.DrawText(
                            "Format Not Supported\nDrop your images\nin this area!",
                            @floatToInt(i32, 30 + panel.size.x + panel.scrollOffset.x),
                            @floatToInt(i32, panel.size.height / 2 + panel.size.y + panel.scrollOffset.y - 40),
                            20,
                            rl.DARKGRAY,
                        );
                    },
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
