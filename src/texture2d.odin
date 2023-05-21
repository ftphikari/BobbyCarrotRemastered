package main

import "core:mem"
import "core:slice"
import "core:image"

WHITE  :: image.RGB_Pixel{255, 255, 255}
BLACK  :: image.RGB_Pixel{0,   0,   0}
RED    :: image.RGB_Pixel{237, 28,  36}
GREEN  :: image.RGB_Pixel{28,  237, 36}
BLUE   :: image.RGB_Pixel{63,  72,  204}
YELLOW :: image.RGB_Pixel{255, 255, 72}
ORANGE :: image.RGB_Pixel{255, 127, 39}

Flip :: enum {
	Horizontal,
	Vertical,
}

Color3 :: [3]u8
Color4 :: [4]u8

Texture2D :: struct {
	pixels: []Color4,
	size: [2]int,
	allocator: mem.Allocator,
}

texture_make :: proc(w, h: int, allocator := context.allocator) -> (t: Texture2D) {
	t.size = {w, h}
	t.allocator = allocator
	t.pixels = make([]Color4, t.size[0] * t.size[1], t.allocator)
	return
}

texture_destroy :: proc(t: ^Texture2D) {
	delete(t.pixels, t.allocator)
	t^ = {}
}

texture_clear :: proc(t: ^Texture2D, color: Color3) {
	ccol: Color4
	ccol.rgb = platform_color(color)
	ccol.a = 255
	slice.fill(t.pixels, ccol)
}

platform_color :: #force_inline proc(p: image.RGB_Pixel) -> Color3 {
	when ODIN_OS == .Windows {
		return p.bgr
	} else {
		return p
	}
}
