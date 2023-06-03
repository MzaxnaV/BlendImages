const std = @import("std");

const rl = @cImport({
    @cInclude("raylib.h");
});

const Rectangle = rl.Rectangle;
const Vector2 = rl.Vector2;

pub fn main() !void {
    const width = 800;
    const height = 450;
    const fps = 60;

    rl.InitWindow(width, height, "BlendImages");
    defer rl.CloseWindow();

    rl.SetTargetFPS(fps);

    var panelScroll = Vector2{ .x = 99, .y = -20 };

    while (!rl.WindowShouldClose()) {
        { // Update

        }
        
        { // Drawing
            rl.BeginDrawing();
            defer rl.EndDrawing();

            rl.ClearBackground(rl.RAYWHITE);
            rl.DrawText(rl.TextFormat("[%f, %f]", panelScroll.x, panelScroll.y), 4, 4, 20, rl.RED);
        }
    }
}

test "simple test" {
    // _-_
}
