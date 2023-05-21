package gl

import spl ".."

Vsync_Type :: enum {
	Off,
	On,
	Adaptive,
}

init :: proc(window: ^spl.Window) -> (success: bool) { return _init(window) }
deinit :: proc(window: ^spl.Window) { _deinit(window) }

set_vsync :: proc(v: Vsync_Type) -> (success: bool) { return _set_vsync(v) }
swap_buffers :: proc(window: ^spl.Window) { _swap_buffers(window) }
