const std = @import("std");

pub const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raygui.h");
});

pub fn run() !void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 960;
    const screenHeight = 560;

    rl.InitWindow(screenWidth, screenHeight, "rayguii - controls test suite");
    rl.SetExitKey(0);
    defer rl.CloseWindow(); // Close window and OpenGL context

    // GUI controls initialization
    //----------------------------------------------------------------------------------
    var dropdownBox000Active: i32 = 0;
    var dropDown000EditMode = false;

    var dropdownBox001Active: i32 = 0;
    var dropDown001EditMode = false;

    var spinner001Value: i32 = 0;
    var spinnerEditMode = false;

    var valueBox002Value: i32 = 0;
    var valueBoxEditMode = false;

    var textBoxText = [_:0]u8{ 'T', 'e', 'x', 't', ' ', 'b', 'o', 'x' } ++ [1:0]u8{0} ** (64 - 8);
    var textBoxEditMode = false;

    var textBoxMultiText = [1:0]u8{0} ** 1024;
    const text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\n\nThisisastringlongerthanexpectedwithoutspacestotestcharbreaksforthosecases,checkingifworkingasexpected.\n\nExcepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

    for (0.., text) |i, c| {
        textBoxMultiText[i] = c;
    }

    var textBoxMultiEditMode = false;

    var listViewScrollIndex: i32 = 0;
    var listViewActive: i32 = -1;

    var listViewExScrollIndex: i32 = 0;
    var listViewExActive: i32 = 2;
    var listViewExFocus: i32 = -1;
    var listViewExList = [_][*]const u8{ "This", "is", "a", "list view", "with", "disable", "elements", "amazing!" };

    var colorPickerValue = rl.RED;

    var sliderValue: f32 = 50.0;
    var sliderBarValue: f32 = 60;
    var progressValue: f32 = 0.1;

    var forceSquaredChecked = false;

    var alphaValue: f32 = 0.5;

    //int comboBoxActive = 1;
    var visualStyleActive: i32 = 0;
    var prevVisualStyleActive: i32 = 0;

    var toggleGroupActive: i32 = 0;
    var toggleSliderActive: i32 = 0;

    var viewScroll = rl.Vector2{ .x = 0, .y = 0 };
    // //----------------------------------------------------------------------------------

    // // Custom GUI font loading
    // // var font = rl.LoadFontEx("fonts/rainyhearts16.ttf", 12, 0, 0);
    // // rl.GuiSetFont(font);

    var exitWindow = false;
    var showMessageBox = false;

    var textInput: [256:0]u8 = [1:0]u8{0} ** 256;
    var textInputFileName: [256:0]u8 = [1:0]u8{0} ** 256;
    var showTextInputBox = false;

    var alpha: f32 = 1.0;

    // DEBUG: Testing how those two properties affect all controls!
    // rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_PADDING, 0);
    // rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_ALIGNMENT, rl.TEXT_ALIGN_CENTER);

    rl.SetTargetFPS(60);

    //--------------------------------------------------------------------------------------
    // Main game loop
    while (!exitWindow) { // Detect window close button or ESC key
        { // Update
            exitWindow = rl.WindowShouldClose();

            if (rl.IsKeyPressed(rl.KEY_ESCAPE)) showMessageBox = !showMessageBox;

            if (rl.IsKeyDown(rl.KEY_LEFT_CONTROL) and rl.IsKeyPressed(rl.KEY_S)) showTextInputBox = true;

            if (rl.IsFileDropped()) {
                const droppedFiles = rl.LoadDroppedFiles();

                if ((droppedFiles.count > 0) and rl.IsFileExtension(droppedFiles.paths[0], ".rgs")) rl.GuiLoadStyle(droppedFiles.paths[0]);

                rl.UnloadDroppedFiles(droppedFiles); // Clear internal buffers
            }

            //alpha -= 0.002f;
            if (alpha < 0.0) alpha = 0.0;
            if (rl.IsKeyPressed(rl.KEY_SPACE)) alpha = 1.0;

            rl.GuiSetAlpha(alpha);

            //progressValue += 0.002f;
            if (rl.IsKeyPressed(rl.KEY_LEFT)) {
                progressValue -= 0.1;
            } else if (rl.IsKeyPressed(rl.KEY_RIGHT)) {
                progressValue += 0.1;
            }
            if (progressValue > 1.0) {
                progressValue = 1.0;
            } else if (progressValue < 0.0) {
                progressValue = 0.0;
            }

            if (visualStyleActive != prevVisualStyleActive) {
                rl.GuiLoadStyleDefault();

                switch (visualStyleActive) {
                    0 => {}, // Default style
                    // 1 => GuiLoadStyleJungle(),
                    // 2 => GuiLoadStyleLavanda(),
                    // 3 => GuiLoadStyleDark(),
                    // 4 => GuiLoadStyleBluish(),
                    // 5 => GuiLoadStyleCyber(),
                    // 6 => GuiLoadStyleTerminal(),
                    else => {},
                }

                rl.GuiSetStyle(rl.LABEL, rl.TEXT_ALIGNMENT, rl.TEXT_ALIGN_LEFT);

                prevVisualStyleActive = visualStyleActive;
            }
        }

        { // Draw
            rl.BeginDrawing();
            defer rl.EndDrawing();

            rl.ClearBackground(rl.GetColor(@bitCast(rl.GuiGetStyle(rl.DEFAULT, rl.BACKGROUND_COLOR))));

            // raygui: controls drawing
            //----------------------------------------------------------------------------------
            // Check all possible events that require GuiLock
            if (dropDown000EditMode or dropDown001EditMode) rl.GuiLock();

            // First GUI column
            // rl.GuiSetStyle(rl.CHECKBOX, rl.TEXT_ALIGNMENT, rl.TEXT_ALIGN_LEFT);
            _ = rl.GuiCheckBox(rl.Rectangle{ .x = 25, .y = 108, .width = 15, .height = 15 }, "FORCE CHECK!", &forceSquaredChecked);

            rl.GuiSetStyle(rl.TEXTBOX, rl.TEXT_ALIGNMENT, rl.TEXT_ALIGN_CENTER);
            //GuiSetStyle(VALUEBOX, TEXT_ALIGNMENT, TEXT_ALIGN_LEFT);
            if (rl.GuiSpinner(rl.Rectangle{ .x = 25, .y = 135, .width = 125, .height = 30 }, null, &spinner001Value, 0, 100, spinnerEditMode) != 0) spinnerEditMode = !spinnerEditMode;
            if (rl.GuiValueBox(rl.Rectangle{ .x = 25, .y = 175, .width = 125, .height = 30 }, null, &valueBox002Value, 0, 100, valueBoxEditMode) != 0) valueBoxEditMode = !valueBoxEditMode;
            rl.GuiSetStyle(rl.TEXTBOX, rl.TEXT_ALIGNMENT, rl.TEXT_ALIGN_LEFT);
            if (rl.GuiTextBox(rl.Rectangle{ .x = 25, .y = 215, .width = 125, .height = 30 }, textBoxText[0..].ptr, 64, textBoxEditMode) != 0) textBoxEditMode = !textBoxEditMode;

            rl.GuiSetStyle(rl.BUTTON, rl.TEXT_ALIGNMENT, rl.TEXT_ALIGN_CENTER);

            if (rl.GuiButton(rl.Rectangle{ .x = 25, .y = 255, .width = 125, .height = 30 }, rl.GuiIconText(rl.ICON_FILE_SAVE, "Save File")) != 0) showTextInputBox = true;

            _ = rl.GuiGroupBox(rl.Rectangle{ .x = 25, .y = 310, .width = 125, .height = 150 }, "STATES");
            // rl.GuiLock();
            rl.GuiSetState(rl.STATE_NORMAL);
            if (rl.GuiButton(rl.Rectangle{ .x = 30, .y = 320, .width = 115, .height = 30 }, "NORMAL") != 0) {}
            rl.GuiSetState(rl.STATE_FOCUSED);
            if (rl.GuiButton(rl.Rectangle{ .x = 30, .y = 355, .width = 115, .height = 30 }, "FOCUSED") != 0) {}
            rl.GuiSetState(rl.STATE_PRESSED);
            if (rl.GuiButton(rl.Rectangle{ .x = 30, .y = 390, .width = 115, .height = 30 }, "#15#PRESSED") != 0) {}
            rl.GuiSetState(rl.STATE_DISABLED);
            if (rl.GuiButton(rl.Rectangle{ .x = 30, .y = 425, .width = 115, .height = 30 }, "DISABLED") != 0) {}
            rl.GuiSetState(rl.STATE_NORMAL);
            // rl.GuiUnlock();

            _ = rl.GuiComboBox(rl.Rectangle{ .x = 25, .y = 480, .width = 125, .height = 30 }, "default;Jungle;Lavanda;Dark;Bluish;Cyber;Terminal", &visualStyleActive);

            // NOTE: GuiDropdownBox must draw after any other control that can be covered on unfolding
            rl.GuiUnlock();
            rl.GuiSetStyle(rl.DROPDOWNBOX, rl.TEXT_PADDING, 4);
            rl.GuiSetStyle(rl.DROPDOWNBOX, rl.TEXT_ALIGNMENT, rl.TEXT_ALIGN_LEFT);
            if (rl.GuiDropdownBox(rl.Rectangle{ .x = 25, .y = 65, .width = 125, .height = 30 }, "#01#ONE;#02#TWO;#03#THREE;#04#FOUR", &dropdownBox001Active, dropDown001EditMode) != 0) dropDown001EditMode = !dropDown001EditMode;
            rl.GuiSetStyle(rl.DROPDOWNBOX, rl.TEXT_ALIGNMENT, rl.TEXT_ALIGN_CENTER);
            rl.GuiSetStyle(rl.DROPDOWNBOX, rl.TEXT_PADDING, 0);

            if (rl.GuiDropdownBox(rl.Rectangle{ .x = 25, .y = 25, .width = 125, .height = 30 }, "ONE;TWO;THREE", &dropdownBox000Active, dropDown000EditMode) != 0) dropDown000EditMode = !dropDown000EditMode;

            // Second GUI column
            _ = rl.GuiListView(rl.Rectangle{ .x = 165, .y = 25, .width = 140, .height = 124 }, "Charmander;Bulbasaur;#18#Squirtel;Pikachu;Eevee;Pidgey", &listViewScrollIndex, &listViewActive);
            _ = rl.GuiListViewEx(rl.Rectangle{ .x = 165, .y = 162, .width = 140, .height = 184 }, @ptrCast(listViewExList[0..].ptr), 8, &listViewExScrollIndex, &listViewExActive, &listViewExFocus);

            // _ = rl.GuiToggle(rl.Rectangle{ .x = 165, .y = 400, .width = 140, .height = 25 }, "#1#ONE", @ptrCast(&toggleGroupActive));
            _ = rl.GuiToggleGroup(rl.Rectangle{ .x = 165, .y = 360, .width = 140, .height = 24 }, "#1#ONE\n#3#TWO\n#8#THREE\n#23#", &toggleGroupActive);
            // rl.GuiDisable();
            rl.GuiSetStyle(rl.SLIDER, rl.SLIDER_PADDING, 2);
            _ = rl.GuiToggleSlider(rl.Rectangle{ .x = 165, .y = 480, .width = 140, .height = 30 }, "ON;OFF", &toggleSliderActive);
            rl.GuiSetStyle(rl.SLIDER, rl.SLIDER_PADDING, 0);

            // Third GUI column
            _ = rl.GuiPanel(rl.Rectangle{ .x = 320, .y = 25, .width = 225, .height = 140 }, "Panel Info");
            _ = rl.GuiColorPicker(rl.Rectangle{ .x = 320, .y = 185, .width = 196, .height = 192 }, null, &colorPickerValue);

            // rl.GuiDisable();
            _ = rl.GuiSlider(rl.Rectangle{ .x = 355, .y = 400, .width = 165, .height = 20 }, "TEST", rl.TextFormat("%2.2f", sliderValue), &sliderValue, -50, 100);
            _ = rl.GuiSliderBar(rl.Rectangle{ .x = 320, .y = 430, .width = 200, .height = 20 }, null, rl.TextFormat("%i", @as(i32, @intFromFloat(sliderBarValue))), &sliderBarValue, 0, 100);

            _ = rl.GuiProgressBar(rl.Rectangle{ .x = 320, .y = 460, .width = 200, .height = 20 }, null, rl.TextFormat("%i%%", @as(i32, @intFromFloat(progressValue * 100))), &progressValue, 0.0, 1.0);
            rl.GuiEnable();

            // NOTE: View rectangle could be used to perform some scissor test
            var view = rl.Rectangle{ .x = 0, .y = 0, .width = 0, .height = 0 };
            _ = rl.GuiScrollPanel(rl.Rectangle{ .x = 560, .y = 25, .width = 102, .height = 354 }, null, rl.Rectangle{ .x = 560, .y = 25, .width = 300, .height = 1200 }, &viewScroll, &view);

            var mouseCell = rl.Vector2{ .x = 0, .y = 0 };
            _ = rl.GuiGrid(rl.Rectangle{ .x = 560, .y = 25 + 180 + 195, .width = 100, .height = 120 }, null, 20, 3, &mouseCell);

            _ = rl.GuiColorBarAlpha(rl.Rectangle{ .x = 320, .y = 490, .width = 200, .height = 30 }, null, &alphaValue);

            rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_ALIGNMENT_VERTICAL, rl.TEXT_ALIGN_TOP); // WARNING: Word-wrap does not work as expected in case of no-top alignment
            rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_WRAP_MODE, rl.TEXT_WRAP_WORD); // WARNING: If wrap mode enabled, text editing is not supported
            if (rl.GuiTextBox(rl.Rectangle{ .x = 678, .y = 25, .width = 258, .height = 492 }, @ptrCast(textBoxMultiText[0..].ptr), 1024, textBoxMultiEditMode) != 0) textBoxMultiEditMode = !textBoxMultiEditMode;
            rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_WRAP_MODE, rl.TEXT_WRAP_NONE);
            rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_ALIGNMENT_VERTICAL, rl.TEXT_ALIGN_MIDDLE);

            rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_ALIGNMENT, rl.TEXT_ALIGN_LEFT);
            _ = rl.GuiStatusBar(rl.Rectangle{ .x = 0, .y = @floatFromInt(rl.GetScreenHeight() - 20), .width = @floatFromInt(rl.GetScreenWidth()), .height = 20 }, "This is a status bar");
            rl.GuiSetStyle(rl.DEFAULT, rl.TEXT_ALIGNMENT, rl.TEXT_ALIGN_CENTER);
            // rl.GuiSetStyle(rl.STATUSBAR, rl.TEXT_INDENTATION, 20); // TEXT_INDENTATION doesn't seem to exist

            if (showMessageBox) {
                rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.Fade(rl.RAYWHITE, 0.8));
                const result = rl.GuiMessageBox(rl.Rectangle{ .x = @as(f32, @floatFromInt(rl.GetScreenWidth())) / 2 - 125, .y = @as(f32, @floatFromInt(rl.GetScreenHeight())) / 2 - 50, .width = 250, .height = 100 }, rl.GuiIconText(rl.ICON_EXIT, "Close Window"), "Do you really want to exit?", "Yes;No");

                if ((result == 0) or (result == 2)) {
                    showMessageBox = false;
                } else if (result == 1) {
                    exitWindow = true;
                }
            }

            if (showTextInputBox) {
                rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.Fade(rl.RAYWHITE, 0.8));
                const result = rl.GuiTextInputBox(rl.Rectangle{ .x = @as(f32, @floatFromInt(rl.GetScreenWidth())) / 2 - 120, .y = @as(f32, @floatFromInt(rl.GetScreenHeight())) / 2 - 60, .width = 240, .height = 140 }, rl.GuiIconText(rl.ICON_FILE_SAVE, "Save file as..."), "Introduce output file name:", "Ok;Cancel", @ptrCast(textInput[0..].ptr), 255, null);

                if (result == 1) {
                    // TODO: Validate textInput value and save

                    _ = rl.TextCopy(@ptrCast(textInputFileName[0..].ptr), @ptrCast(textInput[0..].ptr));
                }

                if ((result == 0) or (result == 1) or (result == 2)) {
                    showTextInputBox = false;
                    _ = rl.TextCopy(@ptrCast(textInput[0..].ptr), " ");
                }
            }
        }
    }
}
