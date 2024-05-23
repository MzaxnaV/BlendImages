const std = @import("std");

const DEBUG = false;

// const basic_window = @import("raylib-examples/basic_window.zig");
// const drop_files = @import("raylib-examples/drop_files.zig");
// const input_keys = @import("raylib-examples/input_keys.zig");
// const input_mouse = @import("raylib-examples/input_mouse.zig");
// const input_gestures = @import("raylib-examples/input_gestures.zig");
// const image_drawing = @import("raylib-examples/image_drawing.zig");
// const raw_data = @import("raylib-examples/raw_data.zig");
// const scroll_panel = @import("raylib-examples/scroll_panel.zig");
const controls_test_suite = @import("raylib-examples/controls_test_suite.zig");

pub const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
    @cInclude("raygui.h");

    @cDefine("SUPPORT_FILEFORMAT_JPG", 1);
});

// Blending mode enum
const BlendMode = enum {
    Normal,
    Additive,
    Subtractive,
    Multiply,
    Custom,
};

const Layer = struct {
    image: rl.Image,
    blend_mode: BlendMode,
    preview_texture: ?rl.Texture2D,
    background_textture: rl.Texture2D,
    filename: [256]u8,
};

const LayerPanel = struct {
    pub const offset = 8;
    pub const box_size = .{
        .width = 216,
        .height = 120,
    };

    layer_count: u32,
    size: rl.Rectangle,
    content_size: rl.Rectangle,
    scroll_offset: rl.Vector2,
    scroll_view: rl.Rectangle,
    layers: [3]Layer, // for now limit the no of images to three

    fn draw(self: @This()) void {
        std.debug.assert(self.layer_count <= self.layers.len);
        for (0..self.layer_count) |index| {
            const layer: Layer = self.layers[index];

            const x = 12;
            const y: f32 = @floatFromInt(12 + (index) * 128);

            _ = rl.GuiGroupBox(.{
                .x = self.size.x + x + self.scroll_offset.x,
                .y = self.size.y + y + self.scroll_offset.y,
                .width = box_size.width,
                .height = box_size.height,
            }, layer.filename[0..].ptr);

            _ = rl.GuiPanel(.{
                .x = self.size.x + x + offset + self.scroll_offset.x,
                .y = self.size.y + y + offset + self.scroll_offset.y,
                .width = box_size.width - 2 * offset,
                .height = box_size.height - 2 * offset,
            }, null);

            if (layer.preview_texture) |texture| {
                _ = rl.DrawTextureV(texture, .{
                    .x = self.size.x + x + (box_size.width - @as(f32, @floatFromInt(texture.width))) / 2 + self.scroll_offset.x,
                    .y = self.size.y + y + (box_size.height - @as(f32, @floatFromInt(texture.height))) / 2 + self.scroll_offset.y,
                }, rl.WHITE);
            }
        }
    }
};

const PreviewPanel = struct {
    const offset = 8;

    size: rl.Rectangle,
    content: rl.Rectangle,
    texture: rl.Texture2D,
    background: rl.Texture2D,

    fn draw(self: @This()) void {
        _ = rl.GuiGroupBox(self.size, "Preview");
        _ = rl.GuiPanel(self.content, null);

        {
            rl.BeginScissorMode(
                @intFromFloat(self.content.x),
                @intFromFloat(self.content.y),
                @intFromFloat(self.content.width),
                @intFromFloat(self.content.height),
            );
            defer rl.EndScissorMode();

            _ = rl.DrawTexture(
                self.background,
                @intFromFloat(self.content.x),
                @intFromFloat(self.content.y),
                rl.WHITE,
            );
            _ = rl.DrawTexture(
                self.texture,
                @intFromFloat(self.content.x),
                @intFromFloat(self.content.y),
                rl.WHITE,
            );
        }
    }
};

const status = enum { visible, not_supported, invisible };

pub fn run() !void {
    const screen_width = 816;
    const screen_height = 528;

    const empty = rl.ColorAlpha(rl.WHITE, 0);

    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer if (gpa.deinit() == .leak) std.debug.print("LEAKING MEMORY!", .{});

    // var gpa = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    // defer gpa.deinit();

    // const allocator = gpa.allocator();

    var imageStatus = status.invisible;

    rl.InitWindow(screen_width, screen_height, "BlendImages");
    defer rl.CloseWindow();

    var panel = LayerPanel{
        .layer_count = 0,
        .size = .{ .x = 552, .y = 24, .width = 240, .height = 480 },
        .content_size = .{ .x = 552, .y = 24, .width = 240 - 8, .height = 4 },
        .layers = [1]Layer{undefined} ** 3,
        .scroll_offset = .{ .x = 0, .y = 0 },
        .scroll_view = .{ .x = 0, .y = 0, .width = 0, .height = 0 },
    };
    defer {
        for (0..panel.layer_count) |index| {
            if (panel.layers[index].preview_texture) |texture| {
                rl.UnloadTexture(texture);
            }
        }
    }

    var previewPanel = PreviewPanel{
        .size = .{ .x = 24, .y = 24, .width = 504, .height = 480 },
        .content = .{ .x = 32, .y = 32, .width = 488, .height = 464 },
        .texture = undefined,
        .background = undefined,
    };

    previewPanel.background = rl.LoadTextureFromImage(rl.GenImageChecked(
        @intFromFloat(previewPanel.content.width),
        @intFromFloat(previewPanel.content.height),
        32,
        32,
        rl.GRAY,
        rl.WHITE,
    ));
    previewPanel.texture = rl.LoadTextureFromImage(rl.GenImageColor(
        @intFromFloat(previewPanel.content.width),
        @intFromFloat(previewPanel.content.height),
        empty,
    ));

    defer rl.UnloadTexture(previewPanel.background);
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

                        if ((image.data != null) and (panel.layer_count < panel.layers.len)) {
                            var layer: *Layer = &panel.layers[panel.layer_count];
                            panel.layer_count += 1;

                            const width: f32 = @floatFromInt(image.width);
                            const height: f32 = @floatFromInt(image.height);
                            const containerWidth = (LayerPanel.box_size.width - 2 * (LayerPanel.offset + 1));
                            const containerHeight = (LayerPanel.box_size.height - 2 * (LayerPanel.offset + 1));

                            const scaleWidth: f32 = containerWidth / width;
                            const scaleHeight: f32 = containerHeight / height;
                            const scale: f32 = if (scaleWidth < scaleHeight) scaleWidth else scaleHeight;

                            rl.ImageResize(&image, @intFromFloat(width * scale), @intFromFloat(height * scale));

                            layer.preview_texture = rl.LoadTextureFromImage(image);

                            var count = @as(i32, 0);
                            const splits = rl.TextSplit(droppedFiles.paths[i], '\\', &count);
                            _ = rl.TextCopy(layer.filename[0..].ptr, splits[@intCast(count - 1)]);

                            panel.content_size.height += LayerPanel.box_size.height + 8;

                            imageStatus = status.visible;

                            rl.UnloadTexture(previewPanel.texture);
                            previewPanel.texture = rl.LoadTexture(droppedFiles.paths[droppedFiles.count - 1]);
                        } else {
                            if (imageStatus != status.visible) {
                                imageStatus = status.not_supported;
                            }
                        }
                    }
                }
            }
        }

        { // Draw
            rl.BeginDrawing();
            defer rl.EndDrawing();

            rl.ClearBackground(rl.GetColor(@bitCast(rl.GuiGetStyle(rl.DEFAULT, rl.BACKGROUND_COLOR))));

            previewPanel.draw();

            _ = rl.GuiScrollPanel(panel.size, null, panel.content_size, &panel.scroll_offset, &panel.scroll_view);

            {
                rl.BeginScissorMode(
                    @intFromFloat(panel.size.x),
                    @intFromFloat(panel.size.y + 1),
                    @intFromFloat(panel.size.width - 12),
                    @intFromFloat(panel.size.height - 14),
                );

                defer rl.EndScissorMode();

                switch (imageStatus) {
                    status.invisible => {
                        rl.DrawText(
                            "Drop your images\nin this area!",
                            @intFromFloat(30 + panel.size.x + panel.scroll_offset.x),
                            @intFromFloat(panel.size.height / 2 + panel.size.y + panel.scroll_offset.y - 40),
                            20,
                            rl.DARKGRAY,
                        );
                    },
                    status.visible => panel.draw(),
                    status.not_supported => {
                        rl.DrawText(
                            "Format Not Supported\nDrop your images\nin this area!",
                            @intFromFloat(30 + panel.size.x + panel.scroll_offset.x),
                            @intFromFloat(panel.size.height / 2 + panel.size.y + panel.scroll_offset.y - 40),
                            20,
                            rl.DARKGRAY,
                        );
                    },
                }
            }

            if (DEBUG) {
                rl.DrawRectangle(
                    @intFromFloat(panel.size.x + panel.scroll_offset.x),
                    @intFromFloat(panel.size.y + panel.scroll_offset.y),
                    @intFromFloat(panel.content_size.width),
                    @intFromFloat(panel.content_size.height),
                    rl.Fade(rl.RED, 0.1),
                );
            }
        }
    }
}

pub fn main() !void {
    return controls_test_suite.run();
}
