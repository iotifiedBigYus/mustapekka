--laura
--sam westerlund
--23.2.24


-- *-------------------*
-- | initial functions |
-- *-------------------*


function _init()

	cartdata( 'iotifiedbigyus_mustapekka' )


	debug = {t=0} --debug object / namespace
	
	init_actor_data()

	cleared_cells = {}

	reset_game()
end


function reset_game()
	state = 'play'
	level_index = LEVEL_N

	music_playing = PLAY_MUSIC

	make_menu()

	pal(ALT_COLORS,1)

	init_level()
	
	--t_started = 0
end


function init_level()
	reset_cells()

	t_finished = 0
	t_started = 1
	world_x, world_y, world_w, world_h = unpack(level_data[level_index])

	make_path_graph()

	actors = {}
	player = spawn_player()
	cat = spawn_cat()

	info_message = {"", player.x*8-16, player.y*8-16, 7}

	make_camera()

	iris_x = pos8(player.x)-camera_axis_x.pos+63.5
	iris_y = pos8(player.y-.5)-camera_axis_y.pos+63.5

	debug.off = 6.1 % 1
end


function make_menu()
	menuitem( 1, '', music_toggle)
	update_music()
end


function music_toggle()
	music_playing = not music_playing
	update_music()
	return true
end

-- *------------------*
-- | update functions |
-- *------------------*


function update_music()
	local title
	if music_playing then
		title = 'music: on'
		music(MUSIC, MUSIC_FADE_IN)
	else
		title = 'music: off'
		music(-1)
	end
	menuitem( 1, title, music_toggle)
end


function _update60()

	debug.t += 1
	if FREEZE and not btnp(🅾️,1) then return end
	if debug.t % SLOWDOWN ~= 0 then return end

	if state == 'play' then
		update_play()
	end
end


function update_play()
	update_input()

	for a in all(actors) do a:update() end

	if (t_finished == 0) update_camera()

	collisions()

	for a in all(actors) do a:update_sprite() end

	update_spawning(player.x, player.y-player.h*.5)

	update_outgame()
end


function update_outgame()
	if t_started > 0 then
		if t_started == STARTED_TIME then
			t_started = 0
		else
			t_started += 1
		end
	end

	if t_finished > 0 then
		if t_finished == FINISHED_TIME  then
			next_level()
		else
			t_finished += 1
		end
	end
end


function finish_level()
	debug.next_level = true
	if t_finished > 0 then return end

	t_finished = 1
	music(VICTORY_JINGLE)
end


function next_level()
	level_index += 1
	if level_index > #level_data then
		level_index = 1
	end

	init_level()
end


-- *-------------------*
-- | drawing functions |
-- *-------------------*


function _draw()
	FREEZE = false
	if FREEZE and not btnp(🅾️,1) then return end
	if debug.t % SLOWDOWN ~= 0 then return end


	if state == 'play' then
		draw_play()
	end

	--debug
	draw_debug()
end


function draw_play()
	--background
	draw_background(camera_x, camera_y)

	--foreground
	pal(12,0) --> blue drawn as black
	camera(pos8(camera_x), pos8(camera_y))


	print(unpack(info_message))
	map()

	--actors
	if (HITBOX) foreach(actors, draw_hitbox)
	for a in all(actors) do a:draw() end

	if PATH_NEIGHBORS then draw_path_nodes() end
	if PATH_HEIGHTS then draw_path_heights() end
	if PATH_DIRECTIONS then draw_path_directions(player) end

	--m = blank_map(-1)
	--draw map
	--draw_map(m)
	camera(0,0)

	draw_overlay()
end


function draw_background(x, y)

	-- mountains
	camera( 0,0)
	cls(12)
	--local mx = px * 0 % 128
	--map(MOUNTAINS_X, MOUNTAINS_Y, mx - 128, 16, MOUNTAINS_W, MOUNTAINS_H)
	--map(MOUNTAINS_X, MOUNTAINS_Y, mx, 16, MOUNTAINS_W, MOUNTAINS_H)
	map(MOUNTAINS_X, MOUNTAINS_Y, 0, 16, MOUNTAINS_W, MOUNTAINS_H)
	rectfill(0,48,127,127,13)

	-- trees

	pal(3,2)

	camera(0,0)
	local tx = -x * 4 % 128
	local ty = 32

	map(TREES_X, TREES_Y, tx - 128, ty, TREES_W, TREES_H)
	map(TREES_X, TREES_Y, tx, ty, TREES_W, TREES_H)
	rectfill(0,ty+32,127,127,3)

	pal(3,3)
end


function draw_overlay()
	if t_finished > 0 then
		local x0 = pos8(cat.x)-camera_axis_x.pos+63.5
		local y0 = pos8(cat.y-.5)-camera_axis_y.pos+63.5
		draw_iris_out(x0,y0, IRIS_RADIUS * (1 - t_finished / FINISHED_TIME))
	end

	if t_started > 0 then
		draw_iris_out(iris_x,iris_y,  2 * t_started)
	end
end


function draw_iris_out(x0,y0,r)
	-- diamond shape

	x0, y0, r = flr(x0), flr(y0), flr(r)
	for x = 0, x0-r-1 do
		line(x, 0, x, 127, 0)
	end

	for dx = -r,r do
		local dy = r - abs(dx)
		
		line(x0 + dx, y0 - dy, x0 + dx, -1, 0)
		line(x0 + dx, y0 + dy, x0 + dx, 128, 0)
	end

	for x = x0+r+1, 127 do
		line(x, 0, x, 127, 0)
	end

end


function draw_debug()
	camera(0,0)
	cursor(1,1)
	color(7)
	print('v'..VERSION)
	if DEBUGGING then
		print('mem: '..tostring(stat(0)/2048))
		print('cpu: '..tostring(stat(1)))
		for k,v in pairs(debug) do
			print(k..': '..tostring(v))
		end
	end
end