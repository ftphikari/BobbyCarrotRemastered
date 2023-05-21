package gl

import gl "vendor:OpenGL"

when !gl.GL_DEBUG {
	// VERSION_1_0
	End :: proc "c" () {impl_End()}
	MatrixMode :: proc "c" (mode: GLenum) {impl_MatrixMode(mode)}
	LoadIdentity :: proc "c" () {impl_LoadIdentity()}
	EnableClientState :: proc "c" (array: GLenum) {implEnableClientState(array)}
	DisableClientState :: proc "c" (array: GLenum) {implDisableClientState(array)}
	TexCoordPointer :: proc "c" (size: GLint, type: GLenum, stride: GLsizei, pointer: rawptr) {implTexCoordPointer(size, type, stride, pointer)}
	VertexPointer :: proc "c" (size: GLint, type: GLenum, stride: GLsizei, pointer: rawptr) {implVertexPointer(size, type, stride, pointer)}
	ColorPointer :: proc "c" (size: GLint, type: GLenum, stride: GLsizei, pointer: rawptr) {implColorPointer(size, type, stride, pointer)}
} else {
	debug_helper :: gl.debug_helper

	// VERSION_1_0
	End :: proc "c" (loc := #caller_location) {impl_End(); debug_helper(loc, 0)}
	MatrixMode :: proc "c" (mode: GLenum, loc := #caller_location) {impl_MatrixMode(mode); debug_helper(loc, 0, mode)}
	LoadIdentity :: proc "c" (loc := #caller_location) {impl_LoadIdentity(); debug_helper(loc, 0)}
	EnableClientState :: proc "c" (array: GLenum, loc := #caller_location) {implEnableClientState(array); debug_helper(loc, 0, array)}
	DisableClientState :: proc "c" (array: GLenum, loc := #caller_location) {implDisableClientState(array); debug_helper(loc, 0, array)}
	TexCoordPointer :: proc "c" (size: GLint, type: GLenum, stride: GLsizei, pointer: rawptr, loc := #caller_location) {implTexCoordPointer(size, type, stride, pointer); debug_helper(loc, 0, size, type, stride, pointer)}
	VertexPointer :: proc "c" (size: GLint, type: GLenum, stride: GLsizei, pointer: rawptr, loc := #caller_location) {implVertexPointer(size, type, stride, pointer); debug_helper(loc, 0, size, type, stride, pointer)}
	ColorPointer :: proc "c" (size: GLint, type: GLenum, stride: GLsizei, pointer: rawptr, loc := #caller_location) {implColorPointer(size, type, stride, pointer); debug_helper(loc, 0, size, type, stride, pointer)}
}
