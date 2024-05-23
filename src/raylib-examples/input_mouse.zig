const std = @import("std");

pub const rl = @cImport({
    @cInclude("raylib.h");
});

pub fn run() !void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - mouse input");
    defer rl.CloseWindow();

    var ballPosition: rl.Vector2 = .{ .x = -100.0, .y = -100.0 };
    var ballColour = rl.DARKGRAY;

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        { // Update
            ballPosition = rl.GetMousePosition();

            if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_LEFT)) {
                ballColour = rl.MAROON;
            } else if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_MIDDLE)) {
                ballColour = rl.LIME;
            } else if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_RIGHT)) {
                ballColour = rl.DARKBLUE;
            } else if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_SIDE)) {
                ballColour = rl.PURPLE;
            } else if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_EXTRA)) {
                ballColour = rl.YELLOW;
            } else if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_FORWARD)) {
                ballColour = rl.ORANGE;
            } else if (rl.IsMouseButtonPressed(rl.MOUSE_BUTTON_BACK)) {
                ballColour = rl.BEIGE;
            }
        }

        { // Draw
            rl.BeginDrawing();
            defer rl.EndDrawing();

            rl.ClearBackground(rl.RAYWHITE);
            rl.DrawCircleV(ballPosition, 40, ballColour);
            rl.DrawText("move ball with mouse and click mouse button to change color", 10, 10, 20, rl.DARKGRAY);
        }
    }
}
