const std = @import("std");

pub const rl = @cImport({
    @cInclude("raylib.h");
});

const resources = "resources/";

pub fn run() !void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.InitWindow(screenWidth, screenHeight, "raylib [textures] example - image drawing");
    defer rl.CloseWindow();

    var texture: rl.Texture2D = undefined;
    defer rl.UnloadTexture(texture);

    {
        var cat = rl.LoadImage(resources ++ "cat.png");
        defer rl.UnloadImage(cat);

        rl.ImageCrop(&cat, .{ .x = 100, .y = 10, .width = 280, .height = 380 });
        rl.ImageFlipHorizontal(&cat);
        rl.ImageResize(&cat, 200, 200);

        var parrots = rl.LoadImage(resources ++ "parrots.png");
        defer rl.UnloadImage(parrots);

        rl.ImageDraw(
            &parrots,
            cat,
            .{ .x = 0, .y = 0, .width = @as(f32, @floatFromInt(cat.width)), .height = @as(f32, @floatFromInt(cat.height)) },
            .{ .x = 30, .y = 40, .width = @as(f32, @floatFromInt(cat.width)) * 1.5, .height = @as(f32, @floatFromInt(cat.height)) * 1.5 },
            rl.WHITE,
        );
        rl.ImageCrop(&parrots, .{ .x = 0, .y = 50, .width = @as(f32, @floatFromInt(parrots.width)), .height = @as(f32, @floatFromInt(parrots.height)) - 100 });

        rl.ImageDrawPixel(&parrots, 10, 10, rl.RAYWHITE);
        rl.ImageDrawCircleLines(&parrots, 10, 10, 5, rl.RAYWHITE);
        rl.ImageDrawRectangle(&parrots, 5, 20, 10, 10, rl.RAYWHITE);

        const font = rl.LoadFont(resources ++ "custom_jupiter_crash.png");
        defer rl.UnloadFont(font);

        rl.ImageDrawTextEx(&parrots, font, "PARROTS & CAT", .{ .x = 300, .y = 230 }, @as(f32, @floatFromInt(font.baseSize)), -2, rl.WHITE);

        texture = rl.LoadTextureFromImage(parrots);
    }

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        { // Update

        }

        { // Draw
            rl.BeginDrawing();
            defer rl.EndDrawing();

            rl.ClearBackground(rl.RAYWHITE);

            rl.DrawTexture(texture, @divTrunc(screenWidth - texture.width, 2), @divTrunc(screenHeight - texture.height, 2) - 40, rl.WHITE);
            rl.DrawRectangleLines(@divTrunc(screenWidth - texture.width, 2), @divTrunc(screenHeight - texture.height, 2) - 40, texture.width, texture.height, rl.DARKGRAY);

            rl.DrawText("We are drawing only one texture from various images composed!", 240, 350, 10, rl.DARKGRAY);
            rl.DrawText("Source images have been cropped, scaled, flipped and copied one over the other.", 190, 370, 10, rl.DARKGRAY);
        }
    }
}
