--dog
--sam westerlund
--6.6.24

function init_dog_data()
	local a = {}

	a.w2 = .375
	a.h  = .875
	a.eye_pos_x    =  .25
	a.eye_pos_y    = -.75
	a.eye_global_x = 0
	a.eye_global_y = 0
	a.walk_speed   = .1875
	a.traction     = false
	a.strafing_x   = 0
	a.update        = update_dog
	a.update_sprite = update_dog_sprite
	a.draw          = draw_dog
	a.has_target    = false
	a.t_target      = 0
	a.target_x      = 0
	a.target_y      = 0
	a.target_dir_x  = 0

	return a
end


function spawn_dog(x,y)
	return make_actor(SPR_DOG,x,y,1)
end


function update_dog(a)
	if btn(0,1) then
		a.strafing_x = -1
	elseif btn(1,1) then
		a.strafing_x = 1
	end

	--strafing

	local strafing = strafing_x != 0
	if(a.strafing_x != 0)a.d = a.strafing_x

	local accel = .1 --> airborn
	if abs(a.dx) > a.walk_speed and a.d == sgn(a.dx) then
		accel = .05 --> going too fast (probably wont happen)
	elseif a.standing then
		accel = .25 --> on ground
	elseif strafing then
		accel = .2 --> strafing while airborn
	end

	a.dx = approach(a.dx, a.strafing_x * a.walk_speed, accel * a.walk_speed)

	--> apply world collisions and velocities
	update_actor(a)

	--eye sight
	a.eye_global_x = a.x + a.d * a.eye_pos_x
	a.eye_global_y = a.y + a.eye_pos_y

	local x1, y1 = a.eye_global_x, a.eye_global_y
	local x2, y2 = player.x, player.y-.5
	local dx = x2 -x1
	local dy = y2 -y1

	--eye line
	local blocked, dist, tx, ty, dir = dda(x1,y1,x2,y2)


	local target_prev = a.has_target
	a.has_target = not blocked and dist < DOG_SIGHT_DIST
	if a.has_target and not target_prev then
		a.d = dir
	end

	a.target_x, a.target_y = tx, ty
	a.target_dir_x = dir

	if a.has_target then

		if a.t_target == 30 then
			sfx(SFX_BARK)
		elseif a.t_target == 0 then
			a.strafing_x = a.target_dir_x
		end
		a.t_target = max(a.t_target - 1)
	else
		a.t_target = DOG_TARGET_TIME
		a.strafing_x = 0
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


function update_dog_sprite(a)
	--walking animation
	a.walking = (a.standing and (a.strafing_x != 0 or abs(a.dx) >= a.walk_speed or a.t_frame % 4 != 0))

	if a.walking then
		--if (a.t_frame % 4 == 3) sfx(SFX_STEP)
		local t = flr(a.t_frame)
		a.frame = 16+t
		a.t_frame = flr(3*a.t_frame+1.5)/3 % 4 -->four ticks per frame
	else
		--standing still
		a.frame = 0
	end
end


function draw_dog(a)
	local fr = a.k + a.frame

	local x = pos8(a.x-.5)--.5+8*(a.x-.5)
	local y = pos8(a.y-1)

	spr(fr, x, y,1,1,a.d<0)

	if( a.walking) spr(a.k+1, x+a.d, y+1,1,1,a.d<0)

	--eye line

	pset(pos8(a.eye_global_x), pos8(a.eye_global_y), 8)

	--debug.tx = a.target_x

	if a.has_target then
		--line(pos8(a.eye_global_x), pos8(a.eye_global_y), pos8(a.target_x), pos8(a.target_y), 11)
	else
		--line(pos8(a.eye_global_x), pos8(a.eye_global_y), pos8(a.target_x), pos8(a.target_y), 8)
	end
end
