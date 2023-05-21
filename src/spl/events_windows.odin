//+private
package spl

import "core:fmt"
import "core:runtime"
import "core:container/small_array"
import win32 "core:sys/windows"

_send_user_event :: proc(window: ^Window, ev: User_Event) {
	win32.PostMessageW(window.id, win32.WM_APP, uintptr(ev.data), ev.index)
}

_next_event :: proc(window: ^Window) -> Event {
	if window.event_q.len > 0 {
		return small_array.pop_front(&window.event_q)
	}

	window.processing_event = true
	win32.SwitchToFiber(window.message_fiber)

	return small_array.pop_front(&window.event_q)
}

_message_fiber_proc :: proc "stdcall" (data: rawptr) {
	id := cast(win32.HWND)data

	for {
		msg: win32.MSG = ---
		win32.GetMessageW(&msg, id, 0, 0)
		win32.TranslateMessage(&msg)
		win32.DispatchMessageW(&msg)
	}
}

_default_window_proc :: proc "stdcall" (winid: win32.HWND, msg: win32.UINT, wparam: win32.WPARAM, lparam: win32.LPARAM) -> (result: win32.LRESULT) {
	if window_handle == nil {
		/*if msg == win32.WM_DESTROY {
			win32.PostQuitMessage(0)
			return 0
		}*/
		return win32.DefWindowProcW(winid, msg, wparam, lparam)
	}

	window := window_handle
	ev: Event
	switch msg {
	case win32.WM_INPUTLANGCHANGE:
		context = runtime.default_context()
		fmt.printf("IC {:x}: {:x} {:x}\n", msg, wparam, lparam)
	case win32.WM_INPUTLANGCHANGEREQUEST:
		context = runtime.default_context()
		fmt.printf("ICR {:x}: {:x} {:x}\n", msg, wparam, lparam)
	case win32.WM_SETCURSOR:
		if win32.LOWORD(u32(lparam)) == win32.HTCLIENT {
			if .Hide_Cursor in window.flags {
				win32.SetCursor(nil)
				return 1
			}
		}
	case win32.WM_WINDOWPOSCHANGING: // limit window size, if need be
		pos := cast(^win32.WINDOWPOS)cast(uintptr)lparam

		dw, dh := int(window.dec_size[0]), int(window.dec_size[1])
		mw, mh := int(window.min_size[0]), int(window.min_size[1])
		nw, nh := int(pos.cx) - dw, int(pos.cy) - dh
		cw, ch := int(window.client_size[0]), int(window.client_size[1])

		if mw > 0 do nw = max(nw, mw)
		if mh > 0 do nh = max(nh, mh)

		px, py := cast(int)pos.x, cast(int)pos.y
		// correct position when resizing from top/left
		if window.mode == .Resizing {
			if px > window.pos.x && cw > mw {
				px = min(px, window.pos.x + cw - mw)
			} else {
				px = min(px, window.pos.x)
			}

			if py > window.pos.y && ch > mh {
				py = min(py, window.pos.y + ch - mh)
			} else {
				py = min(py, window.pos.y)
			}
		}
		pos.x = cast(i32)px
		pos.y = cast(i32)py

		pos.cx, pos.cy = i32(nw + dw), i32(nh + dh)
	case win32.WM_WINDOWPOSCHANGED:
		pos := cast(^win32.WINDOWPOS)cast(uintptr)lparam

		rect: win32.RECT
		win32.GetClientRect(winid, &rect)

		window.pos = {cast(int)pos.x, cast(int)pos.y}
		window.size = {cast(uint)pos.cx, cast(uint)pos.cy}
		window.client_size = {cast(uint)rect.right, cast(uint)rect.bottom}
	case win32.WM_SYSCOMMAND:
		switch t := win32.GET_SC_WPARAM(wparam); t {
		case win32.SC_SIZE:
			window.mode = .Resizing
		case win32.SC_MOVE:
			window.mode = .Moving
		}
	case win32.WM_ENTERSIZEMOVE:
		#partial switch window.mode {
		case .Resizing:
			ev = Resize_Event{
				type = .Start,
			}
		case .Moving:
			ev = Move_Event{
				type = .Start,
			}
		}
	case win32.WM_EXITSIZEMOVE:
		mode := window.mode
		window.mode = .Static

		#partial switch mode {
		case .Resizing:
			ev = Resize_Event{
				type = .End,
			}
		case .Moving:
			ev = Move_Event{
				type = .End,
			}
		}
	case win32.WM_SIZE:
		resize_type: Resize_Type

		switch wparam {
		case win32.SIZE_RESTORED:
			resize_type = .Default
		case win32.SIZE_MAXIMIZED:
			resize_type = .Maximized
		case win32.SIZE_MINIMIZED:
			resize_type = .Minimized
		}

		window.is_maximized = resize_type == .Maximized
		window.is_minimized = resize_type == .Minimized

		ev = Resize_Event{
			type = resize_type,
		}
	case win32.WM_MOVE:
		window.is_minimized = window.pos.x == -32000 && window.pos.y == -32000

		ev = Move_Event{
			type = .Minimized if window.is_minimized else .Default,
		}
	case win32.WM_NCACTIVATE: // this is like WM_ACTIVATEAPP but better (or so it seems)
		window.is_focused = bool(wparam)
		for key in &window.is_key_down do key = false
		ev = Focus_Event{window.is_focused}
	case win32.WM_ERASEBKGND:
		return 1
	case win32.WM_PAINT:
		winrect: win32.RECT = ---
		if win32.GetUpdateRect(winid, &winrect, false) {
			win32.ValidateRect(winid, nil)
		}
		ev = Draw_Event{
			region = {
				uint(winrect.left), uint(winrect.top),
				uint(winrect.right - winrect.left), uint(winrect.bottom - winrect.top),
			},
		}
	case win32.WM_CHAR:
		ev = Character_Event{
			character = cast(rune)wparam,
		}
	case win32.WM_KEYDOWN, win32.WM_KEYUP, win32.WM_SYSKEYDOWN, win32.WM_SYSKEYUP:
		key: Key_Code
		state: Key_State

		scancode := u32(lparam & 0x00ff0000) >> 16
		extended := (lparam & 0x01000000) != 0
		was_pressed := (lparam & (1 << 31)) == 0
		was_released := (lparam & (1 << 30)) != 0
		alt_was_down := (lparam & (1 << 29)) != 0

		if was_pressed && was_released {
			state = .Repeated
		} else if was_released {
			state = .Released
		} else {
			state = .Pressed
		}

		// TODO: Meta key seems to be 0x5b - check on other computers
		key = vk_conversation_table[wparam] or_else .Unknown

		switch wparam {
		case win32.VK_CONTROL:
			key = .RControl if extended else .LControl
		case win32.VK_MENU:
			key = .RAlt if extended else .LAlt
		case win32.VK_SHIFT:
			is_right := win32.MapVirtualKeyW(scancode, win32.MAPVK_VSC_TO_VK_EX) == win32.VK_RSHIFT
			key = .RShift if is_right else .LShift
		}

		if state == .Pressed && alt_was_down && key == .F4 {
			window.must_close = true
		}

		window.is_key_down[key] = (state != .Released)

		ev = Keyboard_Event{
			scancode = scancode,
			key = key,
			state = state,
		}
	case win32.WM_LBUTTONDOWN, win32.WM_RBUTTONDOWN, win32.WM_MBUTTONDOWN, win32.WM_XBUTTONDOWN,
	win32.WM_LBUTTONUP, win32.WM_RBUTTONUP, win32.WM_MBUTTONUP, win32.WM_XBUTTONUP,
	win32.WM_LBUTTONDBLCLK, win32.WM_RBUTTONDBLCLK, win32.WM_MBUTTONDBLCLK, win32.WM_XBUTTONDBLCLK:
		mev: Mouse_Button_Event

		switch msg {
		case win32.WM_LBUTTONDOWN, win32.WM_RBUTTONDOWN, win32.WM_MBUTTONDOWN, win32.WM_XBUTTONDOWN,
		win32.WM_LBUTTONDBLCLK, win32.WM_RBUTTONDBLCLK, win32.WM_MBUTTONDBLCLK, win32.WM_XBUTTONDBLCLK:
			win32.SetCapture(winid)
			mev.clicked = true
		case:
			win32.ReleaseCapture()
			mev.clicked = false
		}

		switch msg {
		case win32.WM_LBUTTONDOWN, win32.WM_LBUTTONUP, win32.WM_LBUTTONDBLCLK:
			mev.button = .Left
		case win32.WM_RBUTTONDOWN, win32.WM_RBUTTONUP, win32.WM_RBUTTONDBLCLK:
			mev.button = .Right
		case win32.WM_MBUTTONDOWN, win32.WM_MBUTTONUP, win32.WM_MBUTTONDBLCLK:
			mev.button = .Middle
		case win32.WM_XBUTTONDOWN, win32.WM_XBUTTONUP, win32.WM_XBUTTONDBLCLK:
			mev.button = .X1 if win32.GET_XBUTTON_WPARAM(wparam) == win32.XBUTTON1 else .X2
		}

		switch msg {
		case win32.WM_LBUTTONDBLCLK, win32.WM_RBUTTONDBLCLK, win32.WM_MBUTTONDBLCLK, win32.WM_XBUTTONDBLCLK:
			mev.double_clicked = true
		}

		window.is_mouse_button_down[mev.button] = mev.clicked

		ev = mev
	case win32.WM_MOUSEMOVE:
		if !window.is_mouse_inside {
			window.is_mouse_inside = true
			tme: win32.TRACKMOUSEEVENT = {
				cbSize = size_of(win32.TRACKMOUSEEVENT),
				dwFlags = win32.TME_LEAVE,
				hwndTrack = winid,
			}
			win32.TrackMouseEvent(&tme)
		}

		pos := transmute([2]i16)cast(i32)lparam
		ev = Mouse_Move_Event{pos, false}
	case win32.WM_MOUSELEAVE:
		window.is_mouse_inside = false
		ev = Mouse_Move_Event{left_window = true}
	case win32.WM_MOUSEWHEEL:
		delta := win32.GET_WHEEL_DELTA_WPARAM(wparam) / 120
		ev = Mouse_Wheel_Event{
			delta = delta,
		}
	case win32.WM_CLOSE:
		window.must_close = true
		ev = Close_Event{}
	case win32.WM_APP:
		ev = User_Event{data = rawptr(wparam), index = lparam}
	}

	if ev != nil {
		small_array.push_back(&window.event_q, ev)

		if window.processing_event {
			window.processing_event = false

			win32.SwitchToFiber(window.main_fiber)

			#partial switch in ev {
			case Close_Event:
				if !window.must_close {
					return 0
				}
			case User_Event:
				return 1
			}
		}
	}

	return win32.DefWindowProcW(winid, msg, wparam, lparam)
}
