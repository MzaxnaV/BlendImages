const std = @import("std");

pub const rl = @cImport({
    @cInclude("raylib.h");
});

const MAX_GESTURE_STRINGS = 20;

const g = struct {
    count: u32 = 0,
    strings: [MAX_GESTURE_STRINGS][32]u8,
    current: i32 = rl.GESTURE_NONE,
    last: i32 = rl.GESTURE_NONE,
};

pub fn run() !void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - input gestures");
    defer rl.CloseWindow();

    var touchPosition: rl.Vector2 = .{ .x = 0, .y = 0 };
    var touchArea = rl.Rectangle{ .x = 220, .y = 10, .width = screenWidth - 230.0, .height = screenHeight - 20.0 };

    var gesture: g = .{
        .strings = [1][32]u8{[1]u8{0} ** 32} ** MAX_GESTURE_STRINGS,
    };

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        { // Update
            gesture.last = gesture.current;
            gesture.current = rl.GetGestureDetected();
            touchPosition = rl.GetTouchPosition(0);

            if (rl.CheckCollisionPointRec(touchPosition, touchArea) and (gesture.current != rl.GESTURE_NONE)) {
                _ = rl.TextCopy(&gesture.strings[gesture.count], switch (gesture.current) {
                    rl.GESTURE_TAP => "GESTURE_TAP",
                    rl.GESTURE_DOUBLETAP => "GESTURE_DOUBLETAP",
                    rl.GESTURE_HOLD => "GESTURE_HOLD",
                    rl.GESTURE_DRAG => "GESTURE_DRAG",
                    rl.GESTURE_SWIPE_RIGHT => "GESTURE_SWIPE_RIGHT",
                    rl.GESTURE_SWIPE_LEFT => "GESTURE_SWIPE_LEFT",
                    rl.GESTURE_SWIPE_UP => "GESTURE_SWIPE_UP",
                    rl.GESTURE_SWIPE_DOWN => "GESTURE_SWIPE_DOWN",
                    rl.GESTURE_PINCH_IN => "GESTURE_PINCH_IN",
                    rl.GESTURE_PINCH_OUT => "GESTURE_PINCH_OUT",
                    else => "",
                });

                gesture.count += 1;

                if (gesture.count >= MAX_GESTURE_STRINGS) {
                    var i = @as(u32, 0);
                    while (i < MAX_GESTURE_STRINGS) : (i += 1) {
                        _ = rl.TextCopy(&gesture.strings[i], "");
                    }

                    gesture.count = 0;
                }
            }
        }

        { // Draw
            rl.BeginDrawing();
            defer rl.EndDrawing();

            rl.ClearBackground(rl.RAYWHITE);

            rl.DrawRectangleRec(touchArea, rl.GRAY);
            rl.DrawRectangle(225, 15, screenWidth - 240, screenHeight - 30, rl.RAYWHITE);

            rl.DrawText("GESTURES TEST AREA", screenWidth - 270, screenHeight - 40, 20, rl.Fade(rl.GRAY, 0.5));

            var i = @as(u32, 0);
            while (i < gesture.count) : (i += 1) {
                rl.DrawRectangle(10, 30 + 20 * @as(i32, @intCast(i)), 200, 20, rl.Fade(rl.LIGHTGRAY, if (i % 2 == 0) 0.5 else 0.3));

                rl.DrawText(&gesture.strings[i], 35, 36 + 20 * @as(i32, @intCast(i)), 10, if (i < gesture.count - 1) rl.DARKGRAY else rl.MAROON);
            }

            rl.DrawRectangleLines(10, 29, 200, screenHeight - 50, rl.GRAY);
            rl.DrawText("DETECTED GESTURES", 50, 15, 10, rl.GRAY);

            if (gesture.current != rl.GESTURE_NONE) rl.DrawCircleV(touchPosition, 30, rl.MAROON);
        }
    }
}
