package main

import "core:log"
import "core:fmt"
import "core:math"
import "core:time"
import "core:sync"
import "core:image"
import "core:strconv"
import "core:container/small_array"

_ :: log

import "spl"

software_render :: proc(timer: ^spl.Timer, was_init: bool) {
	// local world state
	@static local_world: World
	@static local_level: Level
	@static local_settings: Settings
	// rendering stuff
	@static canvas, scene_texture: Texture2D
	@static canvas_cache, canvas_cache_slow: Region_Cache
	@static tiles_updated: Tile_Queue
	// other state
	@static previous_tick: time.Tick
	@static offset: [2]f32
	@static intro_alpha: u8

	if !was_init {
		if len(canvas.pixels) > 0 do texture_destroy(&canvas)
		canvas = texture_make(BUFFER_W, BUFFER_H)

		if len(scene_texture.pixels) > 0 do texture_destroy(&scene_texture)
		scene_texture = texture_make(BUFFER_W, BUFFER_H)
	}

	start_tick := time.tick_now()

	canvas_redraw, cache_slow_redraw, scene_redraw: bool

	old_world := local_world
	old_settings := local_settings

	if sync.atomic_load(&world_updated) {
		sync.guard(&world_lock)
		defer sync.atomic_store(&world_updated, false)

		if copy_level(&local_level, &world_level, &tiles_updated) {
			scene_redraw = true
		}

		local_world = world
		local_settings = settings
		previous_tick = global_state.previous_tick
	}

	if !was_init || old_world.scene != local_world.scene || old_settings.campaign != local_settings.campaign {
		scene_redraw = true
	}
	if !was_init || old_world.fade.state || local_world.fade.state ||
	old_world.scoreboard_page != local_world.scoreboard_page || old_world.selected_option != local_world.selected_option ||
	old_settings.selected_levels != local_settings.selected_levels || old_settings.language != local_settings.language {
		cache_slow_redraw = true
	}

	diff := array_cast([2]int{TILES_W, TILES_H} - local_level.size, f32)

	player_pos: [2]f32
	frame_delta := get_frame_delta(previous_tick)
	@static prev_player_delta: f32
	if local_world.scene == .Pause_Menu || (local_world.player.walking.state && local_world.player.dying.state) {
		frame_delta = prev_player_delta
	} else {
		prev_player_delta = frame_delta
	}
	player_pos = interpolate_tile_position(local_world.player, frame_delta)

	draw_world_background: bool
	#partial switch local_world.scene {
	case .Game: // calculate offset
		old_offset := offset
		offset = {}

		if diff.x > 0 {
			offset.x = diff.x / 2
			draw_world_background = true
		} else {
			off := (f32(TILES_W) / 2) - (f32(player_pos.x) + 0.5)
			if diff.x > off {
				offset.x = diff.x
			} else {
				offset.x = min(off, 0)
			}
		}

		if diff.y > 0 {
			offset.y = diff.y / 2
			draw_world_background = true
		} else {
			off := (f32(TILES_H) / 2) - (f32(player_pos.y) + 0.5)
			if diff.y > off {
				offset.y = diff.y
			} else {
				offset.y = min(off, 0)
			}
		}

		// redraw scene if camera moved
		if old_offset != offset {
			scene_redraw = true
		}

		if !scene_redraw {
			lvl_offset := array_cast(offset * TILE_SIZE, int)

			// draw updated tiles to scene texture
			for tile_idx in small_array.pop_back_safe(&tiles_updated) {
				pos: [2]int = {tile_idx%local_level.size[0], tile_idx/local_level.size[0]}
				sprite := get_sprite_from_pos(pos, local_level)

				region: Rect
				region.pos = (pos * TILE_SIZE) + lvl_offset
				region.size = {TILE_SIZE, TILE_SIZE}

				software_draw_from_texture(&scene_texture, region.pos, textures[.Atlas], sprite)
				small_array.push_back(&canvas_cache, region)
			}
		} else {
			small_array.clear(&tiles_updated)
		}
	case .Intro: // do not redraw the intro after alpha became 0
		old_intro_alpha := intro_alpha
		intro_alpha = get_intro_alpha(local_world.intro, get_frame_delta(previous_tick))
		if old_intro_alpha != 0 || intro_alpha != 0 {
			scene_redraw = true
		}
	}

	if scene_redraw {
		switch local_world.scene {
		case .Game:
			lvl_offset := array_cast(offset * TILE_SIZE, int)

			if draw_world_background { // TODO: only draw needed parts, not the entire thing
				bg_pos: [2]int
				bg_pos.x = int(abs(offset.x - f32(int(offset.x))) * TILE_SIZE)
				bg_pos.y = int(abs(offset.y - f32(int(offset.y))) * TILE_SIZE)
				for y in 0..=TILES_H do for x in 0..=TILES_W {
					pos := ([2]int{x, y} * TILE_SIZE) - bg_pos
					software_draw_from_texture(&scene_texture, pos, textures[.Grass], {{}, {TILE_SIZE, TILE_SIZE}})
				}
			}
			for _, idx in local_level.tiles {
				pos: [2]int = {idx%local_level.size[0], idx/local_level.size[0]}
				sprite := get_sprite_from_pos(pos, local_level)
				software_draw_from_texture(&scene_texture, (pos * TILE_SIZE) + lvl_offset, textures[.Atlas], sprite)
			}
		case .Pause_Menu, .Main_Menu, .Scoreboard:
			if local_world.scene == .Pause_Menu {
				software_draw_from_texture(&scene_texture, {}, canvas, {{}, scene_texture.size})
			} else {
				bg_texture := textures[manu_campaign_textures[local_settings.campaign]]
				for y in 0..<TILES_H do for x in 0..<TILES_W {
					pos := [2]int{x, y} * TILE_SIZE
					software_draw_from_texture(&scene_texture, pos, bg_texture, {{}, {TILE_SIZE, TILE_SIZE}})
				}
			}
			software_draw_rect(&scene_texture, {{}, scene_texture.size}, {0, 0, 0, 0xAA})
		case .Intro:
			texture_clear(&scene_texture, BLACK)

			off := (scene_texture.size - sprites[.Intro_Splash].size) / 2
			software_draw_from_texture(&scene_texture, off, textures[.Atlas], sprites[.Intro_Splash])
			software_draw_rect(&scene_texture, {off, sprites[.Intro_Splash].size}, {0, 0, 0, intro_alpha})
		case .End:
			texture_clear(&scene_texture, BLACK)

			off := (scene_texture.size - sprites[.End_Splash].size) / 2
			software_draw_from_texture(&scene_texture, off, textures[.Atlas], sprites[.End_Splash])
		case .Credits:
			texture_clear(&scene_texture, BLACK)

			software_draw_credits(&scene_texture, local_settings.language)
		case .None:
			texture_clear(&scene_texture, BLACK)
		}

		canvas_redraw = true
	}

	if canvas_redraw {
		small_array.clear(&canvas_cache)
		small_array.clear(&canvas_cache_slow)
		software_draw_from_texture(&canvas, {}, scene_texture, {{}, scene_texture.size})
	} else { // cached rendering
		for cache_region in small_array.pop_back_safe(&canvas_cache) {
			software_draw_from_texture(&canvas, cache_region.pos, scene_texture, cache_region)
		}
	}

	if canvas_redraw || cache_slow_redraw {
		for cache_region in small_array.pop_back_safe(&canvas_cache_slow) {
			software_draw_from_texture(&canvas, cache_region.pos, scene_texture, cache_region)
		}

		// slow cached drawing
		#partial switch local_world.scene {
		case .Main_Menu, .Pause_Menu:
			software_draw_menu(&canvas, &canvas_cache_slow, small_array.slice(&local_world.menu_options), local_world.selected_option)
		case .Scoreboard:
			software_draw_scoreboard(&canvas, &canvas_cache_slow, small_array.slice(&local_world.scoreboard), local_world.scoreboard_page)
		}
	}

	// do scene specific drawing that gets into fast cache, such as player/HUD/etc
	if local_world.scene == .Game {
		// draw player
		if !local_level.ended || (local_level.ended && local_world.player.fading.state) {
			pos := array_cast((player_pos + offset) * TILE_SIZE, int)
			ppos := pos + local_world.player.sprite.offset

			software_draw_from_texture(&canvas, ppos, textures[.Atlas], local_world.player.sprite)
			small_array.push_back(&canvas_cache, Rect{ppos, local_world.player.sprite.size})
		}

		// HUD
		if !local_level.ended {
			milliseconds := local_level.score.time
			seconds := milliseconds / 1000
			minutes := seconds / 60
			// left part
			{
				tbuf: [8]byte
				time_str := fmt.bprintf(
					tbuf[:], "{:02i}:{:02i}",
					int(minutes),
					int(seconds) % 60,
				)
				small_array.push_back(&canvas_cache, software_draw_text(&canvas, hud_font, time_str, {2, 2}))
			}
			// level begin screen
			if seconds < 2 {
				tbuf: [16]byte
				level_str := fmt.bprintf(tbuf[:], "{} {}", language_strings[settings.language][.Level], local_level.current + 1)
				size := measure_text(general_font, level_str)
				pos := (canvas.size - size) / 2
				small_array.push_back(&canvas_cache, software_draw_text(&canvas, general_font, level_str, pos))
			}
			// right part
			{
				pos: [2]int = {canvas.size[0] - 2, 2}

				if local_level.carrots > 0 {
					sprite := sprites[.HUD_Carrot]
					pos.x -= sprite.size[0]
					software_draw_from_texture(&canvas, pos, textures[.Atlas], sprite)
					small_array.push_back(&canvas_cache, Rect{pos, sprite.size})
					pos.x -= 2

					tbuf: [8]byte
					str := strconv.itoa(tbuf[:], local_level.carrots)
					{
						size := measure_text(hud_font, str)
						pos.x -= size[0]
					}
					small_array.push_back(&canvas_cache, software_draw_text(&canvas, hud_font, str, {pos.x, pos.y + 3}))
					pos.y += sprite.size[1] + 2
					pos.x = canvas.size[0] - 2
				}

				if local_level.eggs > 0 {
					sprite := sprites[.HUD_Egg]
					pos.x -= sprite.size[0]
					software_draw_from_texture(&canvas, pos, textures[.Atlas], sprite)
					small_array.push_back(&canvas_cache, Rect{pos, sprite.size})
					pos.x -= 2

					tbuf: [8]byte
					str := strconv.itoa(tbuf[:], local_level.eggs)
					{
						size := measure_text(hud_font, str)
						pos.x -= size[0]
					}
					small_array.push_back(&canvas_cache, software_draw_text(&canvas, hud_font, str, {pos.x, pos.y + 3}))
					pos.y += sprite.size[1] + 2
					pos.x = canvas.size[0] - 2
				}

				if local_world.player.silver_key {
					sprite := sprites[.HUD_Silver_Key]
					pos.x -= sprite.size[0]
					software_draw_from_texture(&canvas, pos, textures[.Atlas], sprite)
					small_array.push_back(&canvas_cache, Rect{pos, sprite.size})
					pos.x -= 2
				}
				if local_world.player.golden_key {
					sprite := sprites[.HUD_Golden_Key]
					pos.x -= sprite.size[0]
					software_draw_from_texture(&canvas, pos, textures[.Atlas], sprite)
					small_array.push_back(&canvas_cache, Rect{pos, sprite.size})
					pos.x -= 2
				}
				if local_world.player.copper_key {
					sprite := sprites[.HUD_Copper_Key]
					pos.x -= sprite.size[0]
					software_draw_from_texture(&canvas, pos, textures[.Atlas], sprite)
					small_array.push_back(&canvas_cache, Rect{pos, sprite.size})
					pos.x -= 2
				}
			}
		}

		// level end screen
		if local_level.ended && !local_world.player.fading.state {
			total_h: int
			success := sprites[.HUD_Success]
			success_x := (canvas.size[0] - success.size[0]) / 2
			total_h += success.size[1] + (general_font.glyph_size[1] * 2)

			milliseconds := local_level.score.time
			seconds := milliseconds / 1000
			minutes := seconds / 60

			tbuf: [64]byte
			time_str := fmt.bprintf(tbuf[:32], "{}: {:02i}:{:02i}:{:03i}",
				language_strings[settings.language][.Time],
				int(minutes),
				int(seconds) % 60,
				int(milliseconds) % 1000,
			)
			time_x, time_h: int
			{
				size := measure_text(general_font, time_str)
				time_x = (canvas.size[0] - size[0]) / 2
				time_h = size[1]
			}
			total_h += time_h + general_font.glyph_size[1]

			steps_str := fmt.bprintf(tbuf[32:], "{}: {}", language_strings[settings.language][.Steps], local_level.score.steps)
			steps_x, steps_h: int
			{
				size := measure_text(general_font, steps_str)
				steps_x = (canvas.size[0] - size[0]) / 2
				steps_h = size[1]
			}
			total_h += steps_h + (general_font.glyph_size[1] * 2)

			hint_str := language_strings[settings.language][.Press_Any_Key]
			hint_x, hint_h: int
			{
				size := measure_text(general_font, hint_str)
				hint_x = (canvas.size[0] - size[0]) / 2
				hint_h = size[1]
			}
			total_h += hint_h

			pos: [2]int
			pos.x = (canvas.size[0] - success.size[0]) / 2
			pos.y = (canvas.size[1] - total_h) / 2
			software_draw_from_texture(&canvas, pos, textures[.Atlas], success)
			small_array.push_back(&canvas_cache, Rect{pos, success.size})
			pos.y += success.size[1] + (general_font.glyph_size[1] * 2)

			small_array.push_back(&canvas_cache, software_draw_text(&canvas, general_font, time_str, {time_x, pos.y}))
			pos.y += time_h + general_font.glyph_size[1]

			small_array.push_back(&canvas_cache, software_draw_text(&canvas, general_font, steps_str, {steps_x, pos.y}))
			pos.y += steps_h + (general_font.glyph_size[1] * 2)

			small_array.push_back(&canvas_cache, software_draw_text(&canvas, general_font, hint_str, {hint_x, pos.y}))
		}
	}

	fade_alpha := get_fade_alpha(local_world.fade, get_frame_delta(previous_tick))
	if fade_alpha != 0 {
		software_draw_rect(&canvas, {{}, canvas.size}, {0, 0, 0, fade_alpha})
		small_array.clear(&canvas_cache_slow)
		small_array.clear(&canvas_cache)
		small_array.push_back(&canvas_cache, Rect{{}, canvas.size})
	}

	if settings.show_stats {
		calculate_stats()
		software_draw_stats(&canvas, &canvas_cache)
	}

	software_display(&canvas)

	sync.atomic_store(&global_state.frame_work, time.tick_since(start_tick))

	if !settings.vsync || !spl.wait_vblank() {
		spl.wait_timer(timer)
	}

	sync.atomic_store(&global_state.frame_time, time.tick_since(start_tick))
}

software_display :: proc(canvas: ^Texture2D) {
	client_size := array_cast(get_from_i64(&global_state.client_size), uint)
	scale := get_buffer_scale(client_size)
	buf_size := CANVAS_SIZE * int(scale)
	off := (array_cast(client_size, int) - buf_size) / 2
	spl.display_pixels(&window, canvas.pixels, array_cast(canvas.size, uint), off, array_cast(buf_size, uint))
}

software_draw_scoreboard :: proc(t: ^Texture2D, q: ^Region_Cache, labels: []Text_Label, page: int) {
	if len(labels) == 0 do return

	DISABLED :: image.RGB_Pixel{75, 75, 75}
	SELECTED :: image.RGB_Pixel{255, 255, 255}

	pages := ((len(labels) - 1) / 10) + 1
	label_idx := page * 10

	page_labels := labels[label_idx:min(label_idx + 10, len(labels))]

	// 10 lables per page + 9 lines between them
	page_h := general_font.glyph_size[1] * 19
	y := (BUFFER_H - page_h) / 2

	up_arrow, down_arrow: Rect
	up_arrow.size = sprites[.HUD_Arrow_Up].size
	down_arrow.size = sprites[.HUD_Arrow_Up].size

	up_arrow.x = (BUFFER_W - sprites[.HUD_Arrow_Up].size[0]) / 2
	down_arrow.x = up_arrow.x

	up_arrow.y = (y - sprites[.HUD_Arrow_Up].size[1]) / 2
	down_arrow.y = BUFFER_H - up_arrow.y

	for label in page_labels {
		region := label.rect
		region.y = y
		text_buf := label.text_buf
		text := string(text_buf[:label.text_len])

		software_draw_text(t, general_font, text, region.pos, SELECTED)
		small_array.push_back(q, region)

		y += region.size[1] + general_font.glyph_size[1]
	}

	{
		color := SELECTED
		if page == 0 {
			color = DISABLED
		}
		software_draw_from_texture(t, up_arrow.pos, textures[.Atlas], sprites[.HUD_Arrow_Up], {}, color)
		small_array.push_back(q, up_arrow)
	}
	{
		color := SELECTED
		if page == pages - 1 {
			color = DISABLED
		}
		software_draw_from_texture(t, down_arrow.pos, textures[.Atlas], sprites[.HUD_Arrow_Up], {.Vertical}, color)
		small_array.push_back(q, down_arrow)
	}
}

software_draw_menu :: proc(t: ^Texture2D, q: ^Region_Cache, options: []Menu_Option, selected: int) {
	DISABLED :: image.RGB_Pixel{75, 75, 75}
	NORMAL :: image.RGB_Pixel{145, 145, 145}
	SELECTED :: image.RGB_Pixel{255, 255, 255}

	for option, idx in options {
		region := option.rect
		text_buf := option.text_buf
		text := string(text_buf[:option.text_len])

		color := NORMAL
		if idx == selected {
			color = SELECTED
		}

		x := option.x
		if option.arrows != nil {
			color := color
			if !option.arrows.?[0].enabled {
				color = DISABLED
			}
			software_draw_from_texture(t, {x, option.y - 1}, textures[.Atlas], sprites[.HUD_Arrow_Right], {.Horizontal}, color)
			x += sprites[.HUD_Arrow_Right].size[0] + SPACE_BETWEEN_ARROW_AND_TEXT
			region.size[0] += (sprites[.HUD_Arrow_Right].size[0] + SPACE_BETWEEN_ARROW_AND_TEXT) * 2
			region.y -= 1
			region.size[1] += 2
		}

		software_draw_text(t, general_font, text, {x, option.y}, color)

		if option.arrows != nil {
			color := color
			if !option.arrows.?[1].enabled {
				color = DISABLED
			}
			x += option.size[0] + SPACE_BETWEEN_ARROW_AND_TEXT
			software_draw_from_texture(t, {x, option.y - 1}, textures[.Atlas], sprites[.HUD_Arrow_Right], {}, color)
		}

		small_array.push_back(q, region)
	}
}

software_draw_credits :: proc(t: ^Texture2D, language: Language) {
	str := language_strings[language][.Credits_Original]
	str2 := language_strings[language][.Credits_Remastered]

	str_size := measure_text(general_font, str)
	str2_size := measure_text(general_font, str2)
	size_h := str_size[1] + general_font.glyph_size[1] + sprites[.Logo].size[1] + general_font.glyph_size[1] + str2_size[1]
	off_y := (t.size[1] - size_h) / 2

	software_draw_text(t, general_font, str, {(t.size[0] - str_size[0]) / 2, off_y})
	off_y += str_size[1] + general_font.glyph_size[1]
	software_draw_from_texture(t, {(t.size[0] - sprites[.Logo].size[0]) / 2, off_y}, textures[.Atlas], sprites[.Logo])
	off_y += sprites[.Logo].size[1] + general_font.glyph_size[1]
	software_draw_text(t, general_font, str2, {(t.size[0] - str2_size[0]) / 2, off_y})
}

software_draw_stats :: proc(t: ^Texture2D, q: ^Region_Cache) {
	offset := t.size
	offset -= 2

	pos := offset
	draw_stats :: proc(t: ^Texture2D, pos: ^[2]int, format: string, args: ..any) -> Rect {
		tbuf: [64]byte
		text := fmt.bprintf(tbuf[:], format, ..args)

		size := measure_text(general_font, text)
		pos.x -= int(size[0])
		pos.y -= int(size[1])
		return software_draw_text(t, general_font, text, {int(pos.x), int(pos.y)})
	}

	small_array.push_back(q, draw_stats(t, &pos, "{}TPS {}ms last", u32(math.round(global_state.tps.average)), global_state.last_update.average))
	pos.x = offset.x
	small_array.push_back(q, draw_stats(t, &pos, "{}FPS {}ms last", u32(math.round(global_state.fps.average)), global_state.last_frame.average))
	pos.x = offset.x
	small_array.push_back(q, draw_stats(t, &pos, "{}{}", settings.renderer, "/VSYNC" if settings.vsync else ""))
}

software_draw_text :: #force_inline proc(
	t: ^Texture2D,
	font: Font,
	text: string,
	pos: [2]int,
	color: image.RGB_Pixel = {255, 255, 255},
	shadow_color: image.RGB_Pixel = {0, 0, 0},
) -> (region: Rect) {
	return measure_or_draw_text(.Software, t, font, text, pos, color, shadow_color)
}

// blend foreground pixel with alpha onto background
blend_alpha_premul :: proc(bg: ^Color4, fg: Color4) {
	// NOTE: these do not necesserily correspond to RGBA mapping, colors can be in any order, as long as alpha is at the same place
	AMASK  :: 0xFF000000
	GMASK  :: 0x0000FF00
	RBMASK :: 0x00FF00FF

	p1 := transmute(^u32)bg
	p2 := transmute(u32)fg

	alpha := u32(p2 & AMASK) >> 24
	inv_a := 255 - alpha
	rb := ((inv_a * (p1^ & RBMASK)) >> 8) | (p2 & RBMASK)
	g  := ((inv_a * (p1^ & GMASK)) >> 8) | (p2 & GMASK)
	p1^ = (rb & RBMASK) + (g & GMASK)
	bg.a = 255
}

software_pixel_mod :: #force_inline proc(dst: ^Color4, mod: Color3) {
	dst.r = u8(cast(f32)dst.r * (cast(f32)mod.r / 255))
	dst.g = u8(cast(f32)dst.g * (cast(f32)mod.g / 255))
	dst.b = u8(cast(f32)dst.b * (cast(f32)mod.b / 255))
}

software_draw_from_texture :: proc(dst: ^Texture2D, pos: [2]int, src: Texture2D, src_rect: Rect, flip: bit_set[Flip] = {}, mod: image.RGB_Pixel = {255, 255, 255}) {
	needs_mod := mod != {255, 255, 255}
	mod_color := platform_color(mod.rgb)

	endx := min(pos.x + src_rect.size[0], dst.size[0])
	endy := min(pos.y + src_rect.size[1], dst.size[1])

	for y in max(0, pos.y)..<endy do for x in max(0, pos.x)..<endx {
		px, py := x - pos.x, y - pos.y
		spx := src_rect.size[0] - px - 1 if .Horizontal in flip else px
		spy := src_rect.size[1] - py - 1 if .Vertical in flip else py

		sp := (src_rect.y + spy) * src.size[0] + (src_rect.x + spx)
		dp := y * dst.size[0] + x
		src_pixel := src.pixels[sp]
		if needs_mod do software_pixel_mod(&src_pixel, mod_color.rgb)
		blend_alpha_premul(&dst.pixels[dp], src_pixel)
	}
}

software_draw_rect :: proc(dst: ^Texture2D, rect: Rect, color: image.RGBA_Pixel) {
	color := color
	color.rgb = platform_color(color.rgb)
	endx := min(rect.x + rect.size[0], dst.size[0])
	endy := min(rect.y + rect.size[1], dst.size[1])

	for y in max(0, rect.y)..<endy do for x in max(0, rect.x)..<endx {
		dp := y * dst.size[0] + x
		blend_alpha_premul(&dst.pixels[dp], color)
	}
}
