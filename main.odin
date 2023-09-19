package main
// The package name

// import core and vendor packages
import "core:fmt"
import SDL "vendor:sdl2"
import SDL_IMAGE "vendor:sdl2/image"

WINDOW_FLAGS :: SDL.WINDOW_SHOWN
RENDER_FLAGS :: SDL.RENDERER_ACCELERATED
TARGET_DT :: 1000 / 60
WINDOW_WIDTH :: 640
WINDOW_HEIGHT :: 480

Game :: struct {
	perf_frequency: f64,
	renderer:       ^SDL.Renderer,

	// player
	player:         Entity,
}

Entity :: struct {
	tex:  ^SDL.Texture,
	dest: SDL.Rect,
}

game := Game{}

main :: proc() {
	assert(SDL.Init(SDL.INIT_VIDEO) == 0, SDL.GetErrorString())
	assert(SDL_IMAGE.Init(SDL_IMAGE.INIT_PNG) != nil, SDL.GetErrorString())
	// Garbage collection
	defer SDL.Quit()

	window := SDL.CreateWindow(
		"Odin Space Shooter",
		SDL.WINDOWPOS_CENTERED,
		SDL.WINDOWPOS_CENTERED,
		WINDOW_WIDTH,
		WINDOW_HEIGHT,
		WINDOW_FLAGS,
	)
	assert(window != nil, SDL.GetErrorString())
	defer SDL.DestroyWindow(window)

	game.renderer = SDL.CreateRenderer(window, -1, RENDER_FLAGS)
	assert(game.renderer != nil, SDL.GetErrorString())
	defer SDL.DestroyRenderer(game.renderer)

	// Load assets - start

	player_texture := SDL_IMAGE.LoadTexture(game.renderer, "assets/player.png")
	assert(player_texture != nil, SDL.GetErrorString())

	// init with starting position
	destination := SDL.Rect {
		x = 20,
		y = WINDOW_HEIGHT / 2,
	}
	SDL.QueryTexture(player_texture, nil, nil, &destination.w, &destination.h)
	// reduce the source size by 10x
	destination.w /= 10
	destination.h /= 10

	game.player = Entity {
		tex  = player_texture,
		dest = destination,
	}

	game.perf_frequency = f64(SDL.GetPerformanceFrequency())
	start: f64
	end: f64

	event: SDL.Event
	state: [^]u8

	game_loop: for {
		start = get_time()

		// Begin loop code

		// 1. Get the keyboard state
		state = SDL.GetKeyboardState(nil)

		// 2. Handle input
		if SDL.PollEvent(&event) {
			#partial switch event.type 
			{
			case SDL.EventType.QUIT:
				break game_loop
			case SDL.EventType.KEYDOWN:
				#partial switch event.key.keysym.scancode 
				{
				case .ESCAPE:
					break game_loop
				case .UP:
					game.player.dest.y = max(0, game.player.dest.y - 10)
				case .DOWN:
					game.player.dest.y = min(
						WINDOW_HEIGHT - game.player.dest.h,
						game.player.dest.y + 10,
					)
				case .LEFT:
					game.player.dest.x = max(0, game.player.dest.x - 10)
				case .RIGHT:
					game.player.dest.x = min(
						WINDOW_WIDTH - game.player.dest.w,
						game.player.dest.x + 10,
					)
				}
			}
		}

		// 3. Update and Render

		// update player position, etc...
		// then render the updated entity:
		SDL.RenderCopy(game.renderer, game.player.tex, nil, &game.player.dest)

		// End loop code

		end = get_time()
		for end - start < TARGET_DT {
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
