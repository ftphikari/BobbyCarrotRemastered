package spl

import "core:image"

Window_Flag :: enum {
	Hide_Cursor,
	Resizable,
	Maximized,
	// TODO: Borderless,
	// also replace Windows chrome at some point as well
	// TODO?: Capture_Cursor,
}
Window_Flags :: distinct bit_set[Window_Flag; u8]

Window_Mode :: enum {
	Static,
	Moving,
	Resizing,
}

Window_Pos_Variant :: enum {
	Centered,
}

Window_Pos :: union {
	Window_Pos_Variant,
	[2]int,
}

Window :: struct {
	// can modify
	must_close: bool,
	clear_color: image.RGB_Pixel,

	// read-only
	pos:                  [2]int,
	size, client_size:    [2]uint,
	is_key_down:          [Key_Code]bool,
	is_mouse_button_down: [Mouse_Button]bool,
	is_maximized:         bool,
	is_minimized:         bool,
	is_fullscreen:        bool,
	is_focused:           bool,
	is_mouse_inside:      bool,
	mode:                 Window_Mode,

	// read-only, not very useful
	min_size: [2]uint,
	dec_size: [2]uint, // TODO: remove decorations and use custom window chrome???
	flags:    Window_Flags,

	// internal
	using specific: Window_OS_Specific,
}

create :: proc(window: ^Window, name: string = "Window", pos: Window_Pos = nil, size: Maybe([2]uint) = nil, flags: Window_Flags = {}) -> bool {
	return _create(window, name, pos, size, flags)
}

destroy :: #force_inline proc(window: ^Window) { _destroy(window) }

next_event :: #force_inline proc(window: ^Window) -> Event { return _next_event(window) }

send_user_event :: #force_inline proc(window: ^Window, ev: User_Event) { _send_user_event(window, ev) }

get_working_area :: #force_inline proc() -> (pos: [2]int, size: [2]uint) { return _get_working_area() }

move :: #force_inline proc(window: ^Window, pos: [2]int) { _move(window, pos) }

resize :: #force_inline proc(window: ^Window, size: [2]uint) { _resize(window, size) }

set_resizable :: #force_inline proc(window: ^Window, resizable: bool) { _set_resizable(window, resizable) }

set_min_size :: #force_inline proc(window: ^Window, size: [2]uint) {
	window.min_size = size
	_resize(window, window.client_size)
}

maximize :: #force_inline proc(window: ^Window) { _maximize(window) }
minimize :: #force_inline proc(window: ^Window) { _minimize(window) }
restore  :: #force_inline proc(window: ^Window) { _restore(window) }

set_fullscreen :: #force_inline proc(window: ^Window, fullscreen: bool) { _set_fullscreen(window, fullscreen) }

display_pixels :: #force_inline proc(window: ^Window, pixels: [][4]u8, pixels_size: [2]uint, pos: [2]int, size: [2]uint) {
	_display_pixels(window, pixels, pixels_size, pos, size)
}

wait_vblank :: #force_inline proc() -> bool { return _wait_vblank() }
