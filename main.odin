package main
// The package name

// import core and vendor packages
import "core:fmt"
import SDL "vendor:sdl2"
import SDL_Image "vendor:sdl2_image"

WINDOW_FLAGS :: SDL.WINDOW_SHOWN
RENDER_FLAGS :: SDL.RENDERER_ACCELERATED
TARGET_DT :: 1000 / 60

Game :: struct {
	perf_frequency: f64,
	renderer:       ^SDL.Renderer,
}

game := Game{}

main :: proc() {
	assert(SDL.Init(SDL.INIT_VIDEO) == 0, SDL.GetErrorString())
	// Garbage collection
	defer SDL.Quit()

    window := SDL.CreateWindow(
        "Odin Space Shooter",
        SDL.WINDOWPOS_CENTERED,
        SDL.WINDOWPOS_CENTERED,
        640,
        480,
        WINDOW_FLAGS
    )
    assert(window != nil, SDL.GetErrorString())
    defer SDL.DestroyWindow(window)

    game.renderer = SDL.CreateRenderer(window, -1, RENDER_FLAGS)
    assert(game.renderer != nil, SDL.GetErrorString())
    defer SDL.DestroyRenderer(game.renderer)

    game.perf_frequency = f64(SDL.GetPerformanceFrequency())
    start : f64
    end : f64

    event : SDL.Event
    state : [^]u8

    game_loop : for
    {
        start = get_time()

        // Begin loop code

        // 1. Get the keyboard state
        state = SDL.GetKeyboardState(nil)

        // 2. Handle input
        if SDL.PollEvent(&event)
        {
            #partial switch event.type
            {
                case SDL.EventType.QUIT:
                    break game_loop
                case SDL.EventType.KEYDOWN:
                    #partial switch event.key.keysym.scancode
                    {
                        case .ESCAPE:
                            break game_loop
                    }
            }
        }

        // 3. Update and Render
        // TODO: Update and Render

        // End loop code

        end = get_time()
        for end - start < TARGET_DT
        {
            end = get_time()
        }

        fmt.println("FPS : ", 1000 / (end - start))

        SDL.RenderPresent(game.renderer)

        SDL.SetRenderDrawColor(game.renderer, 0, 0, 0, 100)

        SDL.RenderClear(game.renderer)
    }
}

get_time :: proc() -> f64 {
    return f64(SDL.GetPerformanceCounter()) * 1000 / game.perf_frequency
}
