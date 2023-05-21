package gl

import win32 "core:sys/windows"

import spl ".."

_init :: proc(window: ^spl.Window) -> (success: bool) {
	dc := win32.GetDC(window.id)
	defer win32.ReleaseDC(window.id, dc)

	rc := win32.wglCreateContext(dc)
	if !win32.wglMakeCurrent(dc, rc) {
		win32.wglDeleteContext(rc)
		return
	}

	win32.wglSwapIntervalEXT = auto_cast win32.wglGetProcAddress("wglSwapIntervalEXT")
	if win32.wglSwapIntervalEXT == nil {
		win32.wglDeleteContext(rc)
		return
	}

	load_1_1(win32.gl_set_proc_address)

	return true
}

// NOTE: This must be called in the same thread init was called
_deinit :: proc(window: ^spl.Window) {
	module := win32.GetModuleHandleW(win32.L("opengl32.dll"))
	if module != nil {
		win32.FreeLibrary(module)
	}

	rc := win32.wglGetCurrentContext()
	win32.wglMakeCurrent(nil, nil)
	win32.wglDeleteContext(rc)
}

_set_vsync :: proc(v: Vsync_Type) -> (success: bool) {
	if win32.wglSwapIntervalEXT == nil {
		return
	}

	switch v {
	case .Off:
		return win32.wglSwapIntervalEXT(0)
	case .On:
		return win32.wglSwapIntervalEXT(1)
	case .Adaptive:
		return win32.wglSwapIntervalEXT(-1)
	}

	return
}

_swap_buffers :: proc(window: ^spl.Window) {
	dc := win32.GetDC(window.id)
	defer win32.ReleaseDC(window.id, dc)

	win32.SwapBuffers(dc)
}
