const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const Button = struct {
    rect: c.SDL_Rect,
    text: []const u8,
    is_hovered: bool = false,

    pub fn isPointInside(self: Button, x: i32, y: i32) bool {
        return x >= self.rect.x and
            x <= self.rect.x + self.rect.w and
            y >= self.rect.y and
            y <= self.rect.y + self.rect.h;
    }
};

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) < 0) {
        std.debug.print("SDL2 initialization failed: {s}\n", .{c.SDL_GetError()});
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const window = c.SDL_CreateWindow(
        "Three Buttons Example",
        c.SDL_WINDOWPOS_CENTERED,
        c.SDL_WINDOWPOS_CENTERED,
        800,
        600,
        c.SDL_WINDOW_SHOWN,
    ) orelse {
        std.debug.print("Window creation failed: {s}\n", .{c.SDL_GetError()});
        return error.WindowCreationFailed;
    };
    defer c.SDL_DestroyWindow(window);

    const renderer = c.SDL_CreateRenderer(window, -1, c.SDL_RENDERER_ACCELERATED) orelse {
        std.debug.print("Renderer creation failed: {s}\n", .{c.SDL_GetError()});
        return error.RendererCreationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    // Create three buttons
    const button_width: i32 = 150;
    const button_height: i32 = 50;
    const spacing: i32 = 20;
    const total_width = button_width * 3 + spacing * 2;
    const start_x = (800 - total_width) / 2;
    const start_y = (600 - button_height) / 2;

    var buttons = [_]Button{
        .{
            .rect = .{
                .x = start_x,
                .y = start_y,
                .w = button_width,
                .h = button_height,
            },
            .text = "Button 1",
        },
        .{
            .rect = .{
                .x = start_x + button_width + spacing,
                .y = start_y,
                .w = button_width,
                .h = button_height,
            },
            .text = "Button 2",
        },
        .{
            .rect = .{
                .x = start_x + (button_width + spacing) * 2,
                .y = start_y,
                .w = button_width,
                .h = button_height,
            },
            .text = "Button 3",
        },
    };

    var quit = false;
    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                c.SDL_MOUSEMOTION => {
                    const mouse_x = event.motion.x;
                    const mouse_y = event.motion.y;
                    for (&buttons) |*button| {
                        button.is_hovered = button.isPointInside(mouse_x, mouse_y);
                    }
                },
                c.SDL_MOUSEBUTTONDOWN => {
                    if (event.button.button == c.SDL_BUTTON_LEFT) {
                        const mouse_x = event.button.x;
                        const mouse_y = event.button.y;
                        for (buttons, 0..) |button, i| {
                            if (button.isPointInside(mouse_x, mouse_y)) {
                                std.debug.print("Button {} clicked!\n", .{i + 1});
                            }
                        }
                    }
                },
                else => {},
            }
        }

        // Clear screen
        _ = c.SDL_SetRenderDrawColor(renderer, 240, 240, 240, 255);
        _ = c.SDL_RenderClear(renderer);

        // Draw buttons
        for (buttons) |button| {
            if (button.is_hovered) {
                _ = c.SDL_SetRenderDrawColor(renderer, 100, 150, 255, 255);
            } else {
                _ = c.SDL_SetRenderDrawColor(renderer, 70, 130, 240, 255);
            }
            _ = c.SDL_RenderFillRect(renderer, &button.rect);

            // Draw button border
            _ = c.SDL_SetRenderDrawColor(renderer, 50, 50, 50, 255);
            _ = c.SDL_RenderDrawRect(renderer, &button.rect);
        }

        c.SDL_RenderPresent(renderer);
        c.SDL_Delay(16); // Cap at ~60 FPS
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
