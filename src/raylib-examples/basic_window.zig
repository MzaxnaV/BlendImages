const std = @import("std");

pub const rl = @cImport({
    @cInclude("raylib.h");
});

pub fn run() !void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window");
    defer rl.CloseWindow(); // Close window and OpenGL context

    rl.SetTargetFPS(60); // Set our game to run at 60 frames-per-second

    //--------------------------------------------------------------------------------------
    // Main game loop
    while (!rl.WindowShouldClose()) { // Detect window close button or ESC key
        { // Update

        }

        { // Draw
            rl.BeginDrawing();
            defer rl.EndDrawing();

            rl.ClearBackground(rl.RAYWHITE);
        }
    }
}
