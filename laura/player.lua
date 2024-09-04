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
	a.walk_speed = 1 / 8 -- walking speed
	a.walk_accel = 1 / 32
	a.jump_speed = .3 -- jump speed
	a.mass = 1
	a.strafing_x = 0
	--state
	a.is_player  = true
	a.jumped     = false
	a.descending = false
	a.gliding    = false
	a.walking    = false
	a.t_coyote   = 0
	a.t_damage   = 0
	a.regen      = 0.01
	--drawing
	a.f_y       = 0
	a.f_x       = 0
	a.f_vx      = .04
	--paths
	a.path_x = {}
	a.path_y = {}
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
	if not a.alive then return end
	--strafing
	a.strafing_x = input_x
	if(a.strafing_x != 0)a.d = input_x

	-- velocity
	a.speed_x = approach(
		a.speed_x,
		input_x * a.walk_speed,
		a.walk_accel * get_situation_acceleration(a)
	)

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

	--> health
	if a.hp < a.max_hp then
		a.hp = approach(a.hp, a.max_hp, a.regen)
		a.t_damage += 1 / remap(a.hp / a.max_hp, 0.1, 1, 6, 30)
	else
		a.t_damage = 0
	end

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
	debug.ball_r = ball.x + ball.w2
	debug.ball_l = ball.x - ball.w2
	debug.ball_sp = ball.speed_x
end


function update_player_sprite(a)
	--walking animation
	a.walking = (a.standing and (a.strafing_x != 0 or abs(a.speed_x) >= a.walk_speed or a.t_frame % 4 != 0))

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
end



function draw_player(a)
	local fr = a.k + a.frame

	local x = pos8(a.x+a.f_x-.5-sgn(a.d)*a.cx)
	local y = pos8(a.y+a.f_y-1)

	-- sprite flag 3 (green):
	-- draw one pixel up
	if (fget(fr,3) and a.standing) y-=1

	local damage_colors = {
		[1]  = 4,
		[9]  = 8,
		[10] = 15,
		[12] = 2,
		[15] = 9
	}

	local i_damage_colors = {
		[1]  = 1,
		[9]  = 9,
		[10] = 10,
		[12] = 0,
		[15] = 15
	}

	if a.hp < a.max_hp * .1 or a.hp < a.max_hp and flr(a.t_damage % 2) == 0 then
		pal(damage_colors,0)
	end

	--draw body
	spr(fr, x,y,1,1,a.d<0)

	--palette reset
	pal(i_damage_colors,0)
end