--laura
--sam westerlund
--23.2.24


-- *-------------------*
-- | initial functions |
-- *-------------------*


function _init()
	t = 0

	--debug object / namespace
	debug = {t=0}   
	
	actors = {}
	local l = levels[LEVEL_N]
	world_x = l[1]
	world_y = l[2]
	world_w = l[3]
	world_h = l[4]

	init_actor_data()

	player = spawn_player()
	sofa = spawn_sofa(SOFA_X, SOFA_Y)
	sofa2 = spawn_sofa(SOFA2_X, SOFA2_Y)
	dogs = spawn_dogs()

	make_camera()

	info_string = '🅾️/z jump\n❎/x glide'
	info_x = player.x*8-16
	info_y = player.y*8-16

	music_playing = PLAY_MUSIC

	make_menu()

	pal(ALT_COLORS,1)
end


function clear_cell(x, y)
	--straight up copied from jelpi
	local val0 = mget(x-1,y)
	local val1 = mget(x+1,y)
	if ((x>world_x and val0 == 0) or (x<world_x+world_w-1 and val1 == 0)) then
		mset(x,y,0)
	elseif (not fget(val1,1)) then
		mset(x,y,val1)
	elseif (not fget(val0,1)) then
		mset(x,y,val0)
	else
		mset(x,y,0)
	end
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

	update_input()

	for a in all(actors) do a:update() end
	update_camera()

	collisions()

	for a in all(actors) do a:update_sprite() end

	update_spawning(player.x,player.y)
end


function pos8(x)
	return .5 + 8*x
end


function snap8(val, shift)
	shift = shift or 0
	return flr(8*(val+shift)+.5) * .125 - shift
end


function update_spawning(x0, y0)

	x0=flr(x0)
	y0=flr(y0)
	
	-- spawn actors close to x0,y0

	for y=0,16 do
		for x=flr(x0)-10,max(16,x0+14) do
			local val = mget(x,y)
			
			-- actor
			if (fget(val, 5)) then    
				m = spawn_actor(val,x,y,d)
				clear_cel(x,y)
			end
			
		end
	end
end


function approach(x, target, max_delta)
	return x < target and min(x + max_delta, target) or max(x - max_delta, target)
end


function fade_out(a)

	dpal={0,1,1, 2,1,13,6,
	   4,4,9,3, 13,1,13,14}
	
	
					
	-- palette fade
	for i=0,40 do
		for j=1,15 do
			col = j
			for k=1,((i+(j%5))/4) do
				col=dpal[col]
			end
			pal(j,col,1)
		end
		flip()
	end
	
end


function dda(x1, y1, x2, y2)
	--digital differential analysis
	--source: youtu.be/NbSee-XM7WA?si=SdPCtOXWTj_hdpCn
	local map_x = flr(x1)
	local map_y = flr(y1)
	local dx = x2 - x1
	local dy = y2 - y1
	local sx = sqrt(1 + dy / dx * dy / dx)
	local sy = sqrt(1 + dx / dy * dx / dy)
	local step_x = sgn(dx)
	local step_y = sgn(dy)
	local ray_x = dx < 0 and (x1 - map_x) * sx or (map_x + 1 - x1) * sx
	local ray_y = dy < 0 and (y1 - map_y) * sy or (map_y + 1 - y1) * sy
	local dist = 0
	local len = sqrt(dx * dx + dy * dy)
	local found = false

	while not found and dist < len do
		if sx != 0 and (sy == 0 or ray_x < ray_y) then
			map_x += step_x
			dist = ray_x
			ray_x += sx
		else
			map_y += step_y
			dist = ray_y
			ray_y += sy
		end

		if solid(map_x, map_y) then
			found = true
		end
	end
	
	local blocked = found and dist < len
	local bx = blocked and x1 + dist / len * dx or x2
	local by = blocked and y1 + dist / len * dy or y2

	return blocked, min(dist, len), bx, by, step_x
end

-- *-------------------*
-- | drawing functions |
-- *-------------------*


function _draw()
	if FREEZE and not btnp(🅾️,1) then return end
	if debug.t % SLOWDOWN ~= 0 then return end

	--camera coords
	local cx = camera_x.pos-63.5
	local cy = camera_y.pos-63.5
	
	--background
	draw_background(cx, cy)


	--foreground
	pal(12,0,0) --> blue drawn as black
	camera(cx, cy)
	color(7)
	print(info_string, info_x, info_y)
	map()

	--actors
	if (HITBOX) foreach(actors, draw_hitbox)
	for a in all(actors) do a:draw() end

	--pset(camera_x.pos+.5, camera_y.pos+.5,7)

	--debug
	camera(0,0)
	cursor(1,1)
	color(7)
	print('v'..VERSION)
	if DEBUGGING then
		for k,v in pairs(debug) do
			print(k..': '..tostring(v))
		end
	end
end


function draw_background(x, y)
	cls(BG)
	camera(0,0)
	map(BACKGROUND_X, BACKGROUND_Y, 0, 0)
end