--dog
--sam westerlund
--6.6.24

function init_dog_data()
	local a = {}

	a.w2 = .375
	a.h  = .875
	a.walk_speed    = .1875
	a.jump_speed    = .3
	a.traction      = false
	a.strafing_x    = 0
	a.update        = update_dog
	a.update_sprite = update_dog_sprite
	a.draw          = draw_dog
	a.has_target    = false
	a.t_target      = 0
	a.target_x      = 0
	a.target_y      = 0
	a.target_dir_x  = 0
	a.path          = nil

	return a
end


function spawn_dogs()
	local dogs = {}

	for c in all(find_sprites(SPR_DOG)) do
		local x, y = unpack(c)
		add(dogs, make_actor(SPR_DOG, x+.5, y+1, -1))
		clear_cell(x,y)
	end

	return dogs
end


function is_valid_neighbor ( node, neighbor )
	local x1, y1 = node.x, node.y
	local dx = neighbor.x - node.x
	local dy = neighbor.y - node.y

	if not neighbor.is_walkable then
		return false --> in the air
	elseif abs(dy) > 3 or abs(dx) > 1 then
		return false --> too far
	elseif dy == 0 and abs(dx) == 1 then
		return true --> side to side
	elseif node.is_descendable and dy > 0 and dx == 0 then
		return true --> straight descend
	elseif dy == -1 and dx == 0 and neighbor.is_descendable then
		return true 
	end

	local u1 = not solid(x1, y1-1)
	local u2 = u1 and not solid(x1, y1-2)
	if dy == -1 and abs(dx) == 1 and u1 then
		return true --> up an edge
	elseif dy == -1 and x == 0 and neighbor.is_descendable then
		return true --> up a platform
	elseif dy == -2 and abs(dx) == 1 and u2 then
		return true --> two-high edge
	elseif dy == -2 and x == 0 and u1 and neighbor.is_descendable then
		return true --> two-high platform
	end

	local s0 = not solid(x1+dx, y1)
	local s1 = s0 and not solid(x1+dx, y1+1)
	local s2 = s1 and not solid(x1+dx, y1+2)
	if dy == 1 and abs(dx) == 1 and s0 then
		return true --> down an edge
	elseif dy == 2 and abs(dx) == 1 and s1 then
		return true --> two-high edge
	elseif dy == 3 and abs(dx) == 1 and s2 then
		return true --> three-high edge
	end

	return false
end


function update_dog(a)

	update_input2()


	-- target

	update_target(a)

	--[[
	if a.standing and a.has_target then
		local start = find_node(level_nodes, a.x, a.y)
		local goal = find_node(level_nodes, a.target_x, a.target_y)
		a.path = path ( start, goal, level_nodes, false, is_valid_neighbor )
	end
	--]]

	--[[
	if a.has_target then
		if (a.t_target == 0) a.strafing_x = a.target_dir_x
		a.t_target = approach(a.t_target)
	else
		a.t_target = DOG_TARGET_TIME
		a.strafing_x = 0
	end

	local accel = .1 --> airborn
	if abs(a.speed_x) > a.walk_speed and a.d == sgn(a.speed_x) then
		accel = .05 --> going too fast (probably wont happen)
	elseif a.standing and a.has_target then
		accel = .25 --> on ground with target
	elseif a.standing then
		accel = .05 --> on ground
	elseif strafing_x != 0 then
		accel = .2 --> strafing while airborn
	end
	--]]

	a.strafing_x = input2_x
	if(input2_x != 0) a.d = input2_x

	-- velocity

	local accel = .1 --> airborn
	if abs(a.speed_x) > a.walk_speed and a.d == sgn(a.speed_x) then
		accel = .05 --> going too fast (probably wont happen)
	elseif a.standing then
		accel = .1 --> on ground
	elseif strafing_x != 0 then
		accel = .2 --> strafing while airborn
	end

	a.speed_x = approach(a.speed_x, a.strafing_x * a.walk_speed, accel * a.walk_speed)


	--jumping
	
	if input2_jump or input2_jump_grace > 0 then
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
	local x1, y1 = a.x, a.y - .5 * a.h
	
	--> choose player if no ball is present
	local x2, y2 = player.x, player.y-.5
	for a2 in all(actors) do
		if a2.k == SPR_BALL then
			x2, y2 = a2.x, a2.y-.5*a2.h
			break
		end
	end

	local dx = x2 - x1
	local dy = y2 - y1
	local slope = dy / dx
	local len = sqrt(dx * dx + dy * dy)

	if abs(slope) > DOG_SIGHT_SLOPE then
		a.has_target = false
		return
	end
	
	if abs(dy) > DOG_SIGHT_HEIGHT then
		a.has_target = false
		return
	end

	if abs(dx) > DOG_SIGHT_WIDTH then
		a.has_target = false
		return
	end

	if len > DOG_SIGHT_DIST then
		a.has_target = false
		return
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
	a.has_target = not blocked and (a.has_target or dist < DOG_SIGHT_DIST)
	if (not a.has_target) return

	a.target_x = blocked and x1 + dist / len * dx or x2
	a.target_y = blocked and y1 + dist / len * dy or y2
	a.target_dir_x = step_x
	a.d = step_x
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
			pos8(a.x), pos8(a.y - .5 * a.h),
			pos8(a.target_x), pos8(a.target_y),
			11
		)
	end

	draw_path(a)
end


function draw_path(a)
	if not a.path then return end

	for i = 2, #a.path do
		n1, n2 = a.path[i-1], a.path[i]

		line(
			pos8(n1.x), pos8(n1.y),
			pos8(n2.x), pos8(n2.y),
			8
		)
	end
end