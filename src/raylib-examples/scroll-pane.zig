const std = @import("std");

pub const rl = @cImport({
    @cInclude("raylib.h");
    @cDefine("RAYGUI_IMPLEMENTATION", {});
    @cInclude("raygui.h");
});

fn DrawStyleEditControls() void {
    _ = rl.GuiGroupBox(.{ .x = 550, .y = 170, .width = 220, .height = 205 }, "SCROLLBAR STYLE");

    var style = rl.GuiGetStyle(rl.SCROLLBAR, rl.BORDER_WIDTH);
    _ = rl.GuiLabel(.{ .x = 555, .y = 195, .width = 110, .height = 10 }, "BORDER_WIDTH");
    _ = rl.GuiSpinner(.{ .x = 670, .y = 190, .width = 90, .height = 20 }, null, &style, 0, 6, false);
    _ = rl.GuiSetStyle(rl.SCROLLBAR, rl.BORDER_WIDTH, style);

    style = rl.GuiGetStyle(rl.SCROLLBAR, rl.ARROWS_SIZE);
    _ = rl.GuiLabel(.{ .x = 555, .y = 220, .width = 110, .height = 10 }, "ARROWS_SIZE");
    _ = rl.GuiSpinner(.{ .x = 670, .y = 215, .width = 90, .height = 20 }, null, &style, 4, 14, false);
    _ = rl.GuiSetStyle(rl.SCROLLBAR, rl.ARROWS_SIZE, style);

    style = rl.GuiGetStyle(rl.SCROLLBAR, rl.SLIDER_PADDING);
    _ = rl.GuiLabel(.{ .x = 555, .y = 245, .width = 110, .height = 10 }, "SLIDER_PADDING");
    _ = rl.GuiSpinner(.{ .x = 670, .y = 240, .width = 90, .height = 20 }, null, &style, 0, 14, false);
    _ = rl.GuiSetStyle(rl.SCROLLBAR, rl.SLIDER_PADDING, style);

    var scrollbarArrows = rl.GuiGetStyle(rl.SCROLLBAR, rl.ARROWS_VISIBLE);
    _ = rl.GuiCheckBox(
        .{ .x = 565, .y = 280, .width = 20, .height = 20 },
        "ARROWS_VISIBLE",
        @as(*bool, @ptrCast(&scrollbarArrows)), // TODO: hacky \(_-_)/
    );
    _ = rl.GuiSetStyle(rl.SCROLLBAR, rl.ARROWS_VISIBLE, scrollbarArrows);

    style = rl.GuiGetStyle(rl.SCROLLBAR, rl.SLIDER_PADDING);
    _ = rl.GuiLabel(.{ .x = 555, .y = 325, .width = 110, .height = 10 }, "SLIDER_PADDING");
    _ = rl.GuiSpinner(.{ .x = 670, .y = 320, .width = 90, .height = 20 }, null, &style, 0, 14, false);
    _ = rl.GuiSetStyle(rl.SCROLLBAR, rl.SLIDER_PADDING, style);

    style = rl.GuiGetStyle(rl.SCROLLBAR, rl.SLIDER_WIDTH);
    _ = rl.GuiLabel(.{ .x = 555, .y = 350, .width = 110, .height = 10 }, "SLIDER_WIDTH");
    _ = rl.GuiSpinner(.{ .x = 670, .y = 345, .width = 90, .height = 20 }, null, &style, 2, 100, false);
    _ = rl.GuiSetStyle(rl.SCROLLBAR, rl.SLIDER_WIDTH, style);

    const text = if (rl.GuiGetStyle(rl.LISTVIEW, rl.SCROLLBAR_SIDE) == rl.SCROLLBAR_LEFT_SIDE) "SCROLLBAR: LEFT" else "SCROLLBAR: RIGHT";
    var toggleScrollBarSide = rl.GuiGetStyle(rl.LISTVIEW, rl.SCROLLBAR_SIDE) != 0;
    _ = rl.GuiToggle(.{ .x = 560, .y = 110, .width = 200, .height = 35 }, text, &toggleScrollBarSide);
    _ = rl.GuiSetStyle(rl.LISTVIEW, rl.SCROLLBAR_SIDE, @as(i32, @intFromBool(toggleScrollBarSide)));
}

pub fn run() !void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.InitWindow(screenWidth, screenHeight, "raygui - GuiScrollPanel()");
    defer rl.CloseWindow();

    var panelRec = rl.Rectangle{ .x = 20, .y = 40, .width = 200, .height = 150 };
    var panelContentRec = rl.Rectangle{ .x = 0, .y = 0, .width = 340, .height = 340 };

    var panelView = rl.Rectangle{ .x = 0, .y = 0, .width = 0, .height = 0 };
    var panelScroll = rl.Vector2{ .x = -99, .y = -20 };

    var showContentArea = true;

    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        { // Update

        }

        { // Draw
            rl.BeginDrawing();
            defer rl.EndDrawing();

            rl.ClearBackground(rl.RAYWHITE);

            rl.DrawText(rl.TextFormat("[%f %f]", panelScroll.x, panelScroll.y), 4, 4, 20, rl.RED);

            _ = rl.GuiScrollPanel(panelRec, null, panelContentRec, &panelScroll, &panelView);

            {
                rl.BeginScissorMode(@as(i32, @intFromFloat(panelView.x)), @as(i32, @intFromFloat(panelView.y)), @as(i32, @intFromFloat(panelView.width)), @as(i32, @intFromFloat(panelView.height)));
                defer rl.EndScissorMode();

                _ = rl.GuiGrid(.{
                    .x = panelRec.x + panelScroll.x,
                    .y = panelRec.y + panelScroll.y,
                    .width = panelContentRec.width,
                    .height = panelContentRec.height,
                }, null, 16, 3, null);
            }

            if (showContentArea) {
                rl.DrawRectangle(
                    @as(i32, @intFromFloat(panelRec.x + panelScroll.x)),
                    @as(i32, @intFromFloat(panelRec.y + panelScroll.y)),
                    @as(i32, @intFromFloat(panelContentRec.width)),
                    @as(i32, @intFromFloat(panelContentRec.height)),
                    rl.Fade(rl.RED, 0.1),
                );
            }

            DrawStyleEditControls();

            _ = rl.GuiCheckBox(.{ .x = 545, .y = 80, .width = 20, .height = 20 }, "SHOW CONTENT AREA", &showContentArea);

            _ = rl.GuiSliderBar(.{ .x = 590, .y = 385, .width = 145, .height = 15 }, "WIDTH", rl.TextFormat("%i", @as(i32, @intFromFloat(panelContentRec.width))), &panelContentRec.width, 1, 600);
            _ = rl.GuiSliderBar(.{ .x = 590, .y = 410, .width = 145, .height = 15 }, "HEIGHT", rl.TextFormat("%i", @as(i32, @intFromFloat(panelContentRec.height))), &panelContentRec.height, 1, 400);
        }
    }
}
