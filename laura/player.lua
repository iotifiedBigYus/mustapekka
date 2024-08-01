--player
--sam westerlund
--6.6.24


function init_player_data()
	local a = {}

	--size
	a.cx = -1/16 --> sprite center deviation
	a.w2 = 5/8 * .5 --> half width
	a.h  = 1
	--motion
	a.walk_speed = .125 -- walking speed
	a.jump_speed = .3 -- jump speed
	a.mass = 1
	--state
	a.is_player  = true
	a.strafing_x = false
	a.jumped     = false
	a.descending = false
	a.gliding    = false
	a.walking    = false
	a.t_coyote   = 0
	--drawing
	a.f_y       = 0
	a.f_x       = 0
	a.f_vx      = .04
	--methods
	a.update        = update_player
	a.update_sprite = update_player_sprite
	a.draw          = draw_player

	return a
end


function spawn_player()
	local a = make_actor(SPR_PLAYER, world_x+.5, world_y+1, 1)

	for c in all(find_sprites(SPR_PLAYER)) do
		local x, y = unpack(c)
		a.x = x+0.5+a.cx
		a.y = y+1
		clear_cell(x,y)
	end

	return a

	--[[
	local x, y = find_sprites(SPR_PLAYER, true)
	clear_cell(x,y)

	return make_actor(SPR_PLAYER, x+.5, y+1, 1)
	--]]
end


function update_player(a)
	--strafing

	a.strafing_x = input_x != 0
	if(input_x != 0)a.d = input_x

	local accel = .1 --> airborn
	if abs(a.speed_x) > a.walk_speed and a.d == sgn(a.speed_x) then
		accel = .05 --> going too fast (probably wont happen)
	elseif a.standing then
		accel = .25 --> on ground
	elseif a.strafing_x then
		accel = .2 --> strafing while airborn
	end

	-- velocity

	a.speed_x = approach(a.speed_x, input_x * a.walk_speed, accel * a.walk_speed)

	--jumping

	if input_jump or input_jump_grace > 0 then
		if (a.standing or a.t_coyote > 0) and (not a.jumped or AUTO_JUMP) then
			--begin (trying to) jump
			a.speed_y = -a.jump_speed
		end
	else
		a.jumped = false
	end

	--balls

	if input_alt_pressed == 1 then
		throw_ball(a)
	end

	--> apply world collisions and velocities
	update_actor(a)

	--going down platforms
	a.descending = input_down and a.standing
end


function throw_ball(a)
	ball = spawn_ball(
		a.x+BALL_POS_X*a.d,
		a.y+BALL_POS_Y,
		a.speed_x+BALL_SPEED_X*a.d,
		a.speed_y+BALL_SPEED_Y
	)
end


function update_player_sprite(a)
	--walking animation
	a.walking = (a.standing and (a.strafing_x or abs(a.speed_x) >= a.walk_speed or a.t_frame % 4 != 0))

	--recenter the spirte
	a.f_x = approach(a.f_x, 0, a.f_vx)

	if not a.standing then
		a.frame = a.speed_y < a.accel_y and 2 or 3
		a.t_frame = 3
	elseif a.walking then
		if (a.t_frame == 3) sfx(SFX_STEP)
		a.frame = 1 + flr(a.t_frame)
		a.t_frame = (a.t_frame + 0.25) % 4 -->four ticks per frame
	else
		--standing still
		a.frame = 0
	end

	--[[
	if not a.standing then
		a.frame = a.speed_y < a.accel_y and 17 or 18
		a.t_frame = 3
		if (a.t_u_frame > 0) a.frame += 16
	elseif a.walking then
		if (a.t_frame == 3) sfx(SFX_STEP)
		local t = flr(a.t_frame)
		a.frame = a.t_u_frame > 0 and 32+t or 16+t
		a.t_frame = (a.t_frame + 0.25) % 4--flr(4*a.t_frame+1.5)/4 -->four ticks per frame
		-- sfx
	else
		--standing still
		a.frame = min(2, a.t_u_frame)
	end

	--]]
end


function draw_player(a)
	local fr = a.k + a.frame

	local x = pos8(a.x+a.f_x-.5-sgn(a.d)*a.cx)
	local y = pos8(a.y+a.f_y-1)

	-- sprite flag 3 (green):
	-- draw one pixel up
	if (fget(fr,3) and a.standing) y-=1

	--fade to black
	if a.fade < 1 do
		local n = flr(a.fade * 4 + 1.5)

		local c = {
			{0,1,5,15,10},
			{0,2,1,6,15},
			{0,2,2,14,9},
			{0,0,0,2,1}
		}

		for i = 1,4 do
			pal(c[i][5], c[i][n], 0)
		end
	end

	--draw body
	spr(fr, x,y,1,1,a.d<0)

	--palette reset
	if a.fade < 1 then
		for i = 1,4 do
			pal(c[i][5], c[i][5], 0)
		end
	end
end