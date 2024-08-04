--dog
--sam westerlund
--6.6.24

function init_dog_data()
	local a = {}

	a.w2 = .375
	a.h  = .875
	a.walk_speed    = 1.5 / 8
	a.walk_accel    = 1.5 / 128
	a.jump_speed    = .3
	a.jumped        = false
	a.jump          = false
	a.descend       = false
	a.strafing_x    = 0
	a.update        = update_dog
	a.update_sprite = update_dog_sprite
	a.draw          = draw_dog
	a.has_target    = false
	a.target        = nil
	a.t_target      = 0
	a.target_x      = 0
	a.target_y      = 0
	a.target_dir_x  = 0
	a.path_jump     = 2
	a.path_fall     = 5

	return a
end


function spawn_dog(x,y)
	return make_actor(SPR_DOG, x, y, -1)
end

--[[
function spawn_dogs()
	local dogs = {}

	for c in all(find_sprites(SPR_DOG)) do
		local x, y = unpack(c)
		add(dogs, make_actor(SPR_DOG, x+.5, y+1, -1))
		clear_cell(x,y)
	end

	return dogs
end
--]]


function update_dog(a)

	if MANUAL_DOG then
		update_manual_dog(a)
		return
	end

	-- target
	update_target(a)

	-- chase target
	local dir
	if a.has_target then
		update_path_to(a, a.target_x, a.target_y, DOG_JUMP_HEIGHT, DOG_FALL_HEIGHT)

		local x, y = get_center_floored(a)
		dir = get_path_direction(x, y)
		dir_above = get_path_direction(x, y-1)
		dir_below = get_path_direction(x, y+1)
	end

	update_movement(a, dir, dir_above, dir_below)

	if a.strafing_x != 0 then a.d = a.strafing_x end

	-- velocity
	a.speed_x = approach(
		a.speed_x,
		a.walk_speed * a.strafing_x,
		a.walk_accel * get_situation_acceleration(a)
	)

	--jumping
	if a.jump and a.standing then
		a.speed_y = -a.jump_speed
	end

	--> apply world collisions and velocities
	update_actor(a)

	--going down platforms
	a.descending = a.descend and a.standing
end


function update_movement(a, dir, dir_above, dir_below)
	if not dir then
		a.strafing_x = 0
		a.jump = false
		a.descend = false
		return
	end

	local jump = dir == 3
	local descend = dir == 4

	local strafe
	local dir_x  = {-1,1,0,0}

	local above_strafe = jump    and a.speed_y < 0 and dir_above and dir_x[dir_above] != 0
	local below_strafe = descend and a.speed_y > 0 and dir_below and dir_x[dir_below] != 0

	if above_strafe then
		strafe = dir_x[dir_above]
	elseif below_strafe then
		strafe = dir_x[dir_below]
	else
		strafe = dir_x[dir]
	end

	a.strafing_x = strafe
	a.jump = jump
	a.descend = descend
end


function update_manual_dog(a)
	update_input2()

	a.strafing_x = input2_x
	if(input2_x != 0) a.d = input2_x
	a.jump = input2_jump or input2_jump_grace > 0

	local accel = .1 --> airborn
	if abs(a.speed_x) > a.walk_speed and a.d == sgn(a.speed_x) then
		accel = .05 --> going too fast (probably wont happen)
	elseif a.standing then
		accel = .1 --> on ground
	elseif strafing_x != 0 then
		accel = .2 --> strafing while airborn
	end

	a.speed_x = approach(a.speed_x, a.strafing_x * a.walk_speed, accel * a.walk_speed)

	if a.jump then
		if a.standing and (not a.jumped or AUTO_JUMP) then
			--begin (trying to) jump
			a.speed_y = -a.jump_speed
		end
	else
		a.jumped = false
	end

	--> apply world collisions and velocities
	update_actor(a)

	--going down platforms
	a.descending = input2_down and a.standing
end


function update_target(a)
	--> find target
	local target
	for i = #actors, 1, -1 do
		local a2 = actors[i]
		if (a2.k == SPR_BALL or a2 == player) and check_visibility(a, a2) then
			target = a2
			break
		end
	end

	local visible, x, y = check_visibility(a, target)

	if visible then
		a.has_target = true
		a.target_x   = x
		a.target_y   = y
	elseif overlaps(a, a.target_x, a.target_y) then
		a.has_target = false
	end

	debug.targ = a.has_target
end


function distance_sq(a1, a2)
	local dx = a1.x - a2.x
	local dy = a1.y - a1.h2 - a2.y + a2.h2
	return dx * dx + dy * dy
end


function check_visibility(a, target)
	if not target then return false end

	local x1, y1 = a.x, a.y-a.h2
	local x2, y2 = target.x, target.y-target.h2

	local dx = x2 - x1
	local dy = y2 - y1
	local slope = dy / dx
	local len = sqrt(dx * dx + dy * dy)

	if abs(slope) > DOG_SIGHT_SLOPE then
		return false
	end
	
	if abs(dy) > DOG_SIGHT_HEIGHT then
		return false
	end

	if abs(dx) > DOG_SIGHT_WIDTH then
		return false
	end

	if len > DOG_SIGHT_DIST then
		return false
	end

	--digital differential analysis
	--source: youtu.be/NbSee-XM7WA?si=SdPCtOXWTj_hdpCn
	local map_x = flr(x1)
	local map_y = flr(y1)
	local step_x = sgn(dx)
	local step_y = sgn(dy)
	local sec_x = sqrt(1 + dy / dx * dy / dx) --secant
	local sec_y = sqrt(1 + dx / dy * dx / dy) --cosecant
	local ray_x = dx < 0 and (x1 - map_x) * sec_x or (map_x + 1 - x1) * sec_x
	local ray_y = dy < 0 and (y1 - map_y) * sec_y or (map_y + 1 - y1) * sec_y
	local dist = 0
	local blocked = false

	while not blocked and dist < len do
		if sec_x != 0 and (sec_y == 0 or ray_x < ray_y) then
			map_x += step_x
			dist = ray_x
			ray_x += sec_x
		else
			map_y += step_y
			dist = ray_y
			ray_y += sec_y
		end

		if solid(map_x, map_y) then
			blocked = true
		end
	end
	
	blocked = blocked and dist < len

	local visible = not blocked and dist < DOG_SIGHT_DIST
	local x = blocked and x1 + dist / len * dx or x2
	local y = blocked and y1 + dist / len * dy or y2

	return visible, x, y
end


function update_dog_sprite(a)
	--walking animation
	a.walking = (a.standing and (a.strafing_x != 0 or abs(a.speed_x) >= a.walk_speed or a.t_frame % 4 != 3))

	if not a.standing then
		a.frame = a.speed_y < a.accel_y and 6 or 8
		a.t_frame = 3
	elseif a.walking then
		a.frame = 4 + 2 * flr(a.t_frame)
		a.t_frame = (a.t_frame + 0.25) % 4 --flr(3*a.t_frame+1.5)/3 % 4
	else
		--standing still
		a.frame = 0
	end
end


function draw_dog(a)
	local x = pos8(a.x-.5)
	local y = pos8(a.y-1)


	local fr = a.k + a.frame

	if a.frame == 0 then
		spr(fr, x, y,1,1,a.d<0)
	else
		spr(fr, x-4, y,2,1,a.d<0)
	end


	--[[
	local fr = a.k + a.frame

	local x = pos8(a.x-.5)
	local y = pos8(a.y-1)

	spr(fr, x, y,1,1,a.d<0)

	if( a.walking) spr(a.k+1, x+a.d, y+1,1,1,a.d<0)

	--]]

	if SIGTHLINES and a.has_target then
		line(
			pos8(a.x), pos8(a.y - a.h2),
			pos8(a.target_x), pos8(a.target_y),
			11
		)
	end

	--if PATH_DIRECTIONS and a.direction_map then draw_path_directions2(a.direction_map) end
end