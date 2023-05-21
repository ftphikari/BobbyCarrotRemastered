package spl

Message_Box_Flags :: enum {
	Error,
	Warning,
	Info,
	OkCancel,
}

Message_Box_Result :: enum {
	None,
	Ok,
	Cancel,
}

show_message_box :: #force_inline proc(type: Message_Box_Flags, title, message: string, window: ^Window = nil) -> Message_Box_Result {
	return _show_message_box(type, title, message, window)
}
