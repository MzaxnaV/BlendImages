const std = @import("std");

pub const rl = @cImport({
    @cInclude("raylib.h");
});

const MAX_FILEPATH_RECORDED = 4096;
const MAX_FILEPATH_SIZE = 2048;

const file_path = struct {
    counter: u32,
    paths: [MAX_FILEPATH_RECORDED][]u8,
};

pub fn run() !void {

    // @breakpoint() // TODO: check why breakpoint corrupts stack

    const screenWidth = 800;
    const screenHeight = 450;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) std.debug.print("LEAKING MEMORY!", .{});
    const allocator = gpa.allocator();

    rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - drop files");
    defer rl.CloseWindow();

    var files = file_path{
        .counter = 0,
        .paths = undefined,
    };

    for (0..MAX_FILEPATH_RECORDED) |i| {
        files.paths[i] = try allocator.alloc(u8, MAX_FILEPATH_SIZE);
    }
    defer {
        for (0..MAX_FILEPATH_RECORDED) |i| {
            allocator.free(files.paths[i]);
        }
    }

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        { // Update
            if (rl.IsFileDropped()) {
                const droppedFiles = rl.LoadDroppedFiles();
                defer rl.UnloadDroppedFiles(droppedFiles);

                var i = @as(u32, 0);
                var offset = files.counter;
                while (i < droppedFiles.count) : (i += 1) {
                    if (files.counter < (MAX_FILEPATH_RECORDED - 1)) {
                        _ = rl.TextCopy(files.paths[offset + i].ptr, droppedFiles.paths[i]);
                        files.counter += 1;
                    }
                }
            }
        }

        { // Draw
            rl.BeginDrawing();
            defer rl.EndDrawing();

            rl.ClearBackground(rl.RAYWHITE);

            if (files.counter == 0) {
                rl.DrawText("Drop your files to this window!", 100, 40, 20, rl.DARKGRAY);
            } else {
                rl.DrawText("Dropped Files:", 100, 40, 20, rl.DARKGRAY);

                for (0..files.counter) |i| {
                    rl.DrawRectangle(0, 85 + 40 * @intCast(i32, i), screenWidth, 40, rl.Fade(rl.LIGHTGRAY, if (i % 2 == 0) 0.5 else 0.3));

                    rl.DrawText(files.paths[i].ptr, 120, 100 + 40 * @intCast(i32, i), 10, rl.GRAY);
                }

                rl.DrawText("Drop new files ...", 100, 110 + 40 * @intCast(i32, files.counter), 20, rl.DARKGRAY);
            }
        }
    }
}
