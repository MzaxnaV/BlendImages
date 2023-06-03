const std = @import("std");

pub const rl = @cImport({
    @cInclude("raylib.h");
});

pub fn run() !void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - keyboard input");
    defer rl.CloseWindow();

    var ballPosition = rl.Vector2{ .x = @as(f32, screenWidth) / 2, .y = @as(f32, screenHeight) / 2 };

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        { // Update
            if (rl.IsKeyDown(rl.KEY_RIGHT)) ballPosition.x += 2.0;
            if (rl.IsKeyDown(rl.KEY_LEFT)) ballPosition.x -= 2.0;
            if (rl.IsKeyDown(rl.KEY_UP)) ballPosition.y -= 2.0;
            if (rl.IsKeyDown(rl.KEY_DOWN)) ballPosition.y += 2.0;
        }

        { // Draw
            rl.BeginDrawing();
            defer rl.EndDrawing();

            rl.ClearBackground(rl.RAYWHITE);
            rl.DrawText("move the ball with arrow keys", 10, 10, 20, rl.DARKGRAY);
            rl.DrawCircleV(ballPosition, 50, rl.MAROON);
        }
    }
}
