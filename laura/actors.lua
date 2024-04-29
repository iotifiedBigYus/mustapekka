--actors
--3.4.2024


function init_actor_data()
	actor_data = {
	[SPR_PLAYER] = { --> player
		--size
		cx = -1/16, --> sprite center deviation
		w2 = 5/8 * .5, --> half width
		h  = 1,
		--motion
		r  = 0,
		vt = 0,
		vt1 = 0,
		vt2 = 0,
		vx = .125, -- walking speed
		vy = .2, -- jump speed
		--umbrella
		u_d        = 0,
		u_v        = 0.125,
		u_diff     = nil, --> initial difference to terminal speed
		u_friction = 0.9,
		u_ddx      = U_DDX,
		u_drag_x   = U_DRAG_X,
		u_drag_y   = U_DRAG_Y,
		u_t        = 0,
		u_f_t      = 0,
		u_h        = 1.375, --> height with umbrella
		u_s_x      = {24, 24, 27, 25},
		u_s_y      = {34, 37, 36, 32},
		u_s_w      = {1, 3, 5, 7},
		u_s_h      = {2, 3, 4, 4},
		--state
		is_player  = true,
		strafing   = false,
		traction   = false, --> false when sliding on ground
		jumped     = false,
		descending = false,
		gliding    = false,
		walking    = false,
		t_jump     = 0,
		t_coyote   = 0,
		--drawing
		f_t       = 0,
		f_y       = 0,
		f_x       = 0,
		f_vx      = .04,
		--methods
		update = update_player,
		draw   = draw_player
	},
	[SPR_SOFA] = {
		w2 = 1,
		h  = 1,
		friction = 0.05,
		is_furniture = true,
		draw = draw_sofa
	}
	}
end


function make_actor(k,x,y,d)
	if (count(actors) >= MAX_ACTORS) then
		return
	end

	local a = {
		k = k, --> sprite id of actor
		standing = true,
		frame = 0,
		t = 0,
		--motion
		x        = x,
		y        = y,
		dx       = 0,
		dy       = 0,
		ddy      = .02, -- gravity
		drag     = .02, --air drag
		friction = .9, -- exponential deacceleration
		d        = d or -1, --(looking direction)
		--sprite
		cx = 0,
		w2 = .5,
		h  = 1,
		--methods
		update = update_actor,
		draw   = draw_actor,
		clear  = clear_cell
	}

	for attr,v in pairs(actor_data[k]) do
		a[attr]=v
	end

	add(actors, a)

	return a
end


function spawn_player()
	local a = make_actor(SPR_PLAYER, world_x+.5, world_y+1, 1)

	for x=world_x,world_x+world_w-1 do
		for y=world_y,world_y+world_h-1 do
			if mget(x,y) == SPR_PLAYER then
				a.x = x+0.5+a.cx
				a.y = y+1

				clear_cell(x,y)
			end
		end
	end
	return a
end


function spawn_actor(k,x,y,d)
	return make_actor(k,x,y,d)
end


function spawn_sofa(x,y)
	return make_actor(SPR_SOFA,x,y,1)
end


function update_player(a)
	--umbrella
	local u = false
	if btn(❎) and not a.standing then
		local y1 = a.y+a.dy-a.u_h
		local xl = snap8(a.x+a.dx-a.w2)
		local xr = snap8(a.x+a.dx+a.w2)-E

		u = not (solid(xl, y1) or solid(xr, y1))
	end

	if u then
		if (not a.gliding) then
			a.gliding = true
			a.traction = false
		end
		if (a.u_t < U_DRAG_RESPONSE) a.u_t += 1
		if (a.u_f_t < U_OPEN_FRAMES) a.u_f_t += .5
		if (a.u_f_t == 2) sfx(SFX_UMBRELLA_UP)
	else
		a.gliding = false
		a.u_diff = nil
		a.u_t = max(0, a.u_t-5)
		if (a.u_f_t > 0) a.u_f_t -= .5
		if (a.u_f_t == 4) sfx(SFX_UMBRELLA_DOWN)
	end

	--strafing
	if a.gliding then
		update_gliding(a)
	else
		update_walking(a)
	end

	--jumping
	if btn(🅾️) then
		if (a.standing or a.t_coyote > 0) and (not a.jumped or AUTO_JUMP) then
			--begin (trying to) jump
			a.dy = -a.vy
			a.t_jump = JUMP_MAX
		elseif not a.standing and a.t_jump > 0 then
			a.t_jump -= 1
			a.dy = -a.vy
		end
	else
		consume_jump_press()
		a.jumped = false
		a.t_jump = 0
	end

	debug.in_jump = input_jump
	debug.in_jump = input_jump

	--going down platforms
	a.descending = btn(⬇️) and a.standing

	--walking animation
	a.walking = (a.standing and (a.strafing or abs(a.dx) >= a.vx or a.f_t % 4 != 0))

	--recenter the spirte
	a.f_x = a.f_x > 0 and max(0, a.f_x - a.f_vx) or min(0, a.f_x + a.f_vx)

	if not a.standing then
		--1 going up, 2 going down
		a.frame = a.dy < a.ddy and 17 or 18
		if (a.u_t > 0) a.frame += 16
		a.f_t = 4;
	elseif a.walking then
		local t = flr(a.f_t%4)
		a.frame = a.u_t > 0 and 32+t or 16+t
		a.f_t = abs(a.dx) > 1.25 * a.vx and flr(3*a.f_t+1.5)/3 or flr(4*a.f_t+1.5)/4 -->three or four ticks per frame
		-- sfx
		if (a.f_t % 4 == 3) sfx(SFX_STEP)
	else
		--standing still
		a.frame = min(2, a.u_f_t)
	end

	--> apply world collisions and velocities
	update_actor(a)
end


function update_actor(a)
	-- x movement 
	collide_side(a)
	-- y movement
	if(a.dy < 0)collide_up(a)
	if(a.dy >= 0)collide_down(a)

	--jumping
	if(a.dy < 0) a.jumped = true

	--moving
	a.x += a.dx
	a.y += a.dy

	--snapping
	if(a.dx == 0)a.x = snap8(a.x,a.cx)
	if(a.dy == 0)a.y = snap8(a.y,0)

	--[[
	--friction
	--if not a.gliding and not a.strafing then
	if not a.gliding then
		if (a == player) debug.friction = true
		a.dx *= a.friction
		if (abs(a.dx) < MV) a.dx = 0
	end
	--]]

	--friction
	if (a.standing and not a.traction) a.dx *= a.friction

	--gravity
	a.dy += a.ddy

	--air resistance
	a.dy -= sgn(a.dy) * a.dy * a.dy * a.drag

	--timers
	a.t += 1
end


function update_gliding(a)
	--[[
	if(btn(⬅️) and not btn(➡️))then
		a.u_d = -1
	elseif(btn(➡️) and not btn(⬅️))then
		a.u_d = 1
	else
		a.u_d = 0
	end
	--]]

	a.u_d = input_x

	--only apply drag when descending too fast
	if(a.dy < a.u_v)return

	--speed difference
	if(not a.u_diff)a.u_diff = a.dy - a.u_v

	--player looks in the movement direction
	if(a.dx != 0)a.d = sgn(a.dx)

	--player looks in the acceleration direction
	--if(a.u_d != 0)a.d = a.u_d

	a.dx += a.u_ddx * a.u_d

	a.dx -= sgn(a.dx) * a.dx * a.dx * a.u_drag_x
	
	a.u_diff *= a.u_friction
	a.dy = a.u_v + a.u_diff
end


function update_gliding_old(a) --> unused
	if(btn(⬅️) and not btn(➡️))then
		a.u_d = -1
	elseif(btn(➡️) and not btn(⬅️))then
		a.u_d = 1
	else
		a.u_d = 0
	end

	--only apply drag when descending
	if(a.dy <= 0)return

	--player looks in the movement direction
	if(a.dx != 0)a.d = sgn(a.dx)

	--player looks in the acceleration direction
	--if(a.u_d != 0)a.d = a.u_d

	local r = a.u_t/U_DRAG_RESPONSE
	a.dx += a.u_ddx * a.u_d * r - sgn(a.dx) * a.dx * a.dx * a.u_drag_x
	a.dy -= a.dy * a.dy * a.u_drag_y * r
end 


function update_walking(a)
	a.strafing = input_x != 0

	if(input_x != 0)a.d = input_x

	--[
	-- running
	local target, accel = 0, 0.2/16
	if abs(a.dx) > 2/16 and a.strafing then
		target,accel = 2/16, 0.1/16
	elseif a.standing then
		target, accel = 2/16, 0.8/16
	elseif a.strafing then
		target, accel = 2/16, 0.4/16
	end

	a.dx = approach(a.dx, input_x * target, accel)

	debug.dx = a.dx
end


function update_walking_old(a) --> unused
	--side movement
	if(btn(➡️) and not btn(⬅️))then
		a.d = 1
		a.strafing = true
	elseif(btn(⬅️)and not btn(➡️))then
		a.d = -1
		a.strafing = true
	else
		a.r = 0
		a.strafing = false
	end

	--debug.strafing = a.strafing

	if a.strafing then
		if a.d * a.dx > a.vx then
			--going too fast
			local dv = (a.dx - a.vx) * a.friction -- next velocity difference
			a.dx = abs(dv) > E and a.vx + dv or a.vx
			a.r = 1 --> no further acceleration needed
		elseif a.d * a.dx < 0 then
			--going the worng direction
			a.r = 0
		else
			--> quadratic
			a.dx = a.d * max(MV,a.vx * a.r * a.r)
		end

		a.r = min(a.r+1/DDXT, 1)
	end

	--going down platforms
	a.descending = btn(⬇️) and a.standing
end


--[[

actor position is center bottom
.   _______
.  |       |
.  | (x,y) |
.  |___.___|

.    O       O       O       O    
. --@@@-- --@@@-- --@@@-- --@@@-- 
.   @@@\    @@@\   _@@@    _@@@  
.   |      /           \      |   

--]]


function draw_player(a)
	local fr = a.k + a.frame

	local x = .5+8*(a.x+a.f_x-.5-sgn(a.d)*a.cx)
	local y = .5+8*(a.y+a.f_y-1)

	-- sprite flag 3 (green):
	-- draw one pixel up
	if (fget(fr,3)) y-=1

	--umbrella
	if (a.u_f_t >= 3) then
		local x1 = a.d > 0 and x+1.5 or x+6.5 --> shift
		local n = flr(a.u_f_t) - 2
		
		sspr(a.u_s_x[n], a.u_s_y[n], a.u_s_w[n], a.u_s_h[n],
			 x1-.5*a.u_s_w[n], y+1-a.u_s_h[n])
	end


	spr(fr, x,y,1,1,a.d<0)
end


function draw_player_old(a)
	--front end logic

	--recenter the spirte
	if (a.f_x > 0) a.f_x = max(0, a.f_x - a.f_vx)
	if (a.f_x < 0) a.f_x = min(0, a.f_x + a.f_vx)

	--umbrella
	local s = a.u_f_t >= 2 and SPR_U_WALKING or SPR_WALKING
	if not a.standing then
		if a.dy < a.ddy then --> going up
			a.frame = a.strafing and s+1 or s
		else --> going down
			a.frame = a.strafing and s+2 or s+3
		end
		a.f_y = 0
		a.f_t = a.strafing and 3 or 4
	else
		if not a.strafing and abs(a.dx) < a.vx and a.f_t%4 == 0 then
			-- stop walking
			a.frame = SPR_PLAYER + min(2, a.u_f_t)
			a.f_y = 0
			a.f_t = 0
		else
			local t = flr(a.f_t%4)
			a.frame = s+t
			a.f_y = a.walking_y[t+1]
			a.f_t = abs(a.dx) > 1.25 * a.vx and flr(3*a.f_t+1.5)/3 or flr(4*a.f_t+1.5)/4 -->three or four ticks per frame
			-- sfx
			if (a.f_t % 4 == 3) sfx(SFX_STEP)
		end
	end

	local x = 8*(a.x+a.f_x-.5-sgn(a.d)*a.cx)+.5
	local y = 8*(a.y+a.f_y-1)+.5
	

	--umbrella
	if (a.u_f_t >= 3) then
		local x1 = a.d > 0 and x+1.5 or x+6.5 --> shift
		local n = flr(a.u_f_t) - 2
		
		sspr(a.u_s_x[n], a.u_s_y[n], a.u_s_w[n], a.u_s_h[n],
			 x1-.5*a.u_s_w[n], y+1-a.u_s_h[n])
	end

	spr(a.frame, x, y,1,1,a.d<0)
end


function draw_sofa(a)
	local x = 8*(a.x-1)+.5
	local y = 8*(a.y-1)+.5

	spr(a.k, x,   y)
	spr(a.k, x+8, y,1,1,true)
end


function draw_hitbox(a)
	rect(
		8*snap8(a.x-a.w2),
		8*snap8(a.y-a.h),
		8*(snap8(a.x+a.w2)-E),
		8*(snap8(a.y)-E),
		8
	)  
end