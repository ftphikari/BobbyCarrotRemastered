//+private
package spl

import "core:container/small_array"
import "core:math/linalg"
import win32 "core:sys/windows"

Event_Q :: small_array.Small_Array(128, Event)

Window_OS_Specific :: struct {
	id: win32.HWND,
	icon: win32.HICON,
	main_fiber, message_fiber: rawptr,
	old_style: u32,
	old_pos: [2]int,
	old_size: [2]uint,
	event_q: Event_Q,
	processing_event: bool,
}

// need to store pointer to the window for _default_window_proc
@private window_handle: ^Window

_create :: proc(window: ^Window, title: string, pos: Window_Pos, size: Maybe([2]uint), flags: Window_Flags) -> bool {
	if window_handle != nil {
		return false
	}

	instance := cast(win32.HINSTANCE)win32.GetModuleHandleW(nil)
	black_brush := cast(win32.HBRUSH)win32.GetStockObject(win32.BLACK_BRUSH)
	icon := win32.LoadIconA(nil, win32.IDI_APPLICATION)
	cursor: win32.HCURSOR
	if .Hide_Cursor not_in flags {
		cursor = win32.LoadCursorA(nil, win32.IDC_ARROW)
	}

	window_title := win32.utf8_to_wstring(title)
	class_style := win32.CS_OWNDC | win32.CS_HREDRAW | win32.CS_VREDRAW | win32.CS_DBLCLKS
	window_style := win32.WS_OVERLAPPEDWINDOW &~(win32.WS_THICKFRAME | win32.WS_MAXIMIZEBOX) | win32.WS_CLIPCHILDREN | win32.WS_CLIPSIBLINGS

	if .Maximized in flags {
		window_style |= win32.WS_THICKFRAME | win32.WS_MAXIMIZEBOX | win32.WS_MAXIMIZE
	}

	if .Resizable in flags {
		window_style |= win32.WS_THICKFRAME | win32.WS_MAXIMIZEBOX
	}

	x, y: i32 = win32.CW_USEDEFAULT, win32.CW_USEDEFAULT
	w, h: i32 = win32.CW_USEDEFAULT, win32.CW_USEDEFAULT

	if v, ok := pos.([2]int); ok {
		x, y = i32(v.x), i32(v.y)
	}

	if v, ok := size.([2]uint); ok {
		w, h = i32(v[0]), i32(v[1])
	}

	crect: win32.RECT
	if x >= 0 do crect.left = x
	if y >= 0 do crect.top = y
	if w >= 0 do crect.right = crect.left + w
	if h >= 0 do crect.bottom = crect.top + h

	// Windows will make a window with specified size as window size, not as client size, AdjustWindowRect gets the client size needed
	win32.AdjustWindowRect(&crect, window_style, false)

	if x >= 0 do x = crect.left
	if y >= 0 do y = crect.top
	if w >= 0 do w = crect.right - crect.left
	if h >= 0 do h = crect.bottom - crect.top

	window_class: win32.WNDCLASSW = {
		style = class_style,
		lpfnWndProc = _default_window_proc,
		hInstance = instance,
		hIcon = icon,
		hCursor = cursor,
		hbrBackground = black_brush,
		lpszClassName = window_title,
	}
	win32.RegisterClassW(&window_class)

	winid := win32.CreateWindowW(
		lpClassName = window_title, lpWindowName = window_title, dwStyle = window_style, lpParam = nil,
		X = x, Y = y, nWidth = w, nHeight = h, hWndParent = nil, hMenu = nil, hInstance = instance,
	)

	if winid == nil {
		return false
	}

	{
		dc := win32.GetDC(winid)
		defer win32.ReleaseDC(winid, dc)

		pixel_format: win32.PIXELFORMATDESCRIPTOR = {
			nSize = size_of(win32.PIXELFORMATDESCRIPTOR),
			nVersion = 1,
			iPixelType = win32.PFD_TYPE_RGBA,
			dwFlags = win32.PFD_SUPPORT_OPENGL | win32.PFD_DRAW_TO_WINDOW | win32.PFD_DOUBLEBUFFER,
			cColorBits = 24,
			cAlphaBits = 8,
			iLayerType = win32.PFD_MAIN_PLANE,
		}

		format_index := win32.ChoosePixelFormat(dc, &pixel_format)
		win32.DescribePixelFormat(dc, format_index, size_of(format_index), &pixel_format)
		win32.SetPixelFormat(dc, format_index, &pixel_format)
	}

	{
		style := cast(u32)win32.GetWindowLongPtrW(winid, win32.GWL_STYLE)
		if .Resizable in flags {
			style |= win32.WS_MAXIMIZEBOX | win32.WS_THICKFRAME
		} else {
			style &~= win32.WS_MAXIMIZEBOX | win32.WS_THICKFRAME
		}
		win32.SetWindowLongPtrW(winid, win32.GWL_STYLE, cast(int)style)
	}

	// get decorations size
	wr, cr: win32.RECT
	point: win32.POINT
	win32.GetWindowRect(winid, &wr)
	win32.GetClientRect(winid, &cr)
	win32.ClientToScreen(winid, &point)
	window_pos := [2]int{cast(int)wr.left, cast(int)wr.top}
	window_size := [2]uint{uint(wr.right - wr.left), uint(wr.bottom - wr.top)}
	client_size := [2]uint{cast(uint)cr.right, cast(uint)cr.bottom}
	dec_size := [2]uint{uint(wr.right - wr.left - cr.right), uint(wr.bottom - wr.top - cr.bottom)}

	// NOTE: if .Maximized is present, this won't save centered position to be restored later. Seems like a Windows bug to me.
	if v, ok := pos.(Window_Pos_Variant); ok && v == .Centered {
		area_pos, area_size := get_working_area()

		mid_pos := (linalg.array_cast(area_size, int) - linalg.array_cast(window_size, int)) / 2
		pos := area_pos + mid_pos
		win32.SetWindowPos(winid, nil, i32(pos.x), i32(pos.y), 0, 0, win32.SWP_NOSIZE | win32.SWP_NOZORDER | win32.SWP_NOACTIVATE)
	}

	if .Maximized in flags {
		win32.ShowWindow(winid, win32.SW_MAXIMIZE)
	} else {
		win32.ShowWindow(winid, win32.SW_SHOW)
	}

	is_focused := win32.GetForegroundWindow() == winid
	win32.PostMessageW(winid, win32.WM_NCACTIVATE, cast(uintptr)is_focused, 0)

	window^ = {
		pos = window_pos,
		size = window_size,
		client_size = client_size,
		flags = flags,
		dec_size = dec_size,
		is_focused = is_focused,
	}

	// OS-specific
	window.id = winid
	window.icon = win32.LoadIconW(instance, win32.L("icon"))
	if window.icon != nil {
		win32.SetClassLongPtrW(winid, win32.GCLP_HICON, auto_cast cast(uintptr)window.icon)
	}
	window.main_fiber = win32.ConvertThreadToFiber(nil)
	window.message_fiber = win32.CreateFiber(0, _message_fiber_proc, window.id)

	window_handle = window

	return true
}

_destroy :: proc(window: ^Window) {
	winid := window.id
	window_handle = nil
	win32.DestroyWindow(winid)
}

_maximize :: proc(window: ^Window) {
	win32.ShowWindow(window.id, win32.SW_MAXIMIZE)
}

_minimize :: proc(window: ^Window) {
	win32.ShowWindow(window.id, win32.SW_MINIMIZE)
}

_restore :: proc(window: ^Window) {
	win32.ShowWindow(window.id, win32.SW_RESTORE)
}

_set_fullscreen :: proc(window: ^Window, fullscreen: bool) {
	if !window.is_fullscreen {
		window.old_style = cast(u32)win32.GetWindowLongPtrW(window.id, win32.GWL_STYLE)
		window.old_pos = window.pos
		window.old_size = window.size
	}

	if fullscreen {
		style := cast(u32)win32.GetWindowLongPtrW(window.id, win32.GWL_STYLE)
		style &~= win32.WS_CAPTION | win32.WS_THICKFRAME
		win32.SetWindowLongPtrW(window.id, win32.GWL_STYLE, cast(int)style)

		monitor_info: win32.MONITORINFO = {
			cbSize = size_of(win32.MONITORINFO),
		}
		win32.GetMonitorInfoW(win32.MonitorFromWindow(window.id, .MONITOR_DEFAULTTONEAREST), &monitor_info)

		win32.SetWindowPos(
			window.id, nil,
			monitor_info.rcMonitor.left, monitor_info.rcMonitor.top,
			monitor_info.rcMonitor.right - monitor_info.rcMonitor.left, monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top,
			win32.SWP_NOZORDER | win32.SWP_NOACTIVATE | win32.SWP_FRAMECHANGED,
		)

		window.is_fullscreen = true
	} else {
		win32.SetWindowLongPtrW(window.id, win32.GWL_STYLE, cast(int)window.old_style)

		win32.SetWindowPos(
			window.id, nil,
			cast(i32)window.old_pos.x, cast(i32)window.old_pos.y,
			cast(i32)window.old_size[0], cast(i32)window.old_size[1],
			win32.SWP_NOZORDER | win32.SWP_NOACTIVATE | win32.SWP_FRAMECHANGED,
		)

		window.is_fullscreen = false
	}
}

_get_working_area :: #force_inline proc() -> (pos: [2]int, size: [2]uint) {
	winrect: win32.RECT
	win32.SystemParametersInfoW(win32.SPI_GETWORKAREA, 0, &winrect, 0)
	return {cast(int)winrect.left, cast(int)winrect.top}, {uint(winrect.right - winrect.left), uint(winrect.bottom - winrect.top)}
}

_move :: proc(window: ^Window, pos: [2]int) {
	win32.SetWindowPos(window.id, nil, i32(pos.x), i32(pos.y), 0, 0, win32.SWP_NOSIZE | win32.SWP_NOZORDER | win32.SWP_NOACTIVATE)
}

_resize :: proc(window: ^Window, size: [2]uint) {
	w, h := i32(size[0]), i32(size[1])
	crect: win32.RECT = {0, 0, w, h}

	style := cast(u32)win32.GetWindowLongPtrW(window.id, win32.GWL_STYLE)
	win32.AdjustWindowRect(&crect, style, false)
	w, h = crect.right - crect.left, crect.bottom - crect.top

	win32.SetWindowPos(window.id, nil, 0, 0, w, h, win32.SWP_NOMOVE | win32.SWP_NOZORDER)
}

_set_resizable :: proc(window: ^Window, resizable: bool) {
	winid := window.id
	style := cast(u32)win32.GetWindowLongPtrW(winid, win32.GWL_STYLE)
	if resizable {
		style |= win32.WS_THICKFRAME
		style |= win32.WS_MAXIMIZEBOX
	} else {
		style &~= win32.WS_THICKFRAME
		style &~= win32.WS_MAXIMIZEBOX
	}
	win32.SetWindowLongPtrW(winid, win32.GWL_STYLE, cast(int)style)
}

_display_pixels :: proc(window: ^Window, pixels: [][4]u8, pixels_size: [2]uint, pos: [2]int, size: [2]uint) {
	dc := win32.GetDC(window.id)
	defer win32.ReleaseDC(window.id, dc)

	bitmap_info: win32.BITMAPINFO = {
		bmiHeader = {
			biSize = size_of(win32.BITMAPINFOHEADER),
			biPlanes = 1,
			biBitCount = 32,
			biCompression = win32.BI_RGB,
			biWidth = cast(i32)pixels_size[0],
			biHeight = -cast(i32)pixels_size[1],
		},
	}

	win32.SelectObject(dc, win32.GetStockObject(win32.DC_BRUSH))
	win32.SetDCBrushColor(dc, win32.RGB(expand_values(window.clear_color)))

	{ // clear
		dx, dy, dr, db, cw, ch: i32
		dx = i32(pos.x)
		dy = i32(pos.y)
		dr = dx + i32(size[0])
		db = dy + i32(size[1])
		cw = i32(window.client_size[0])
		ch = i32(window.client_size[1])

		if dx > 0 do win32.PatBlt(dc, 0, 0, dx, ch, win32.PATCOPY)
		if dr < cw do win32.PatBlt(dc, dr, 0, cw - dr, ch, win32.PATCOPY)
		if dy > 0 do win32.PatBlt(dc, dx, 0, dr - dx, dy, win32.PATCOPY)
		if db < ch do win32.PatBlt(dc, dx, db, dr - dx, ch - db, win32.PATCOPY)
	}

	win32.StretchDIBits(
		dc,
		cast(i32)pos.x, cast(i32)pos.y, cast(i32)size[0], cast(i32)size[1],
		0, 0, cast(i32)pixels_size[0], cast(i32)pixels_size[1], raw_data(pixels),
		&bitmap_info, win32.DIB_RGB_COLORS, win32.SRCCOPY,
	)
}

_wait_vblank :: proc() -> bool {
	return win32.DwmFlush() == 0
}
