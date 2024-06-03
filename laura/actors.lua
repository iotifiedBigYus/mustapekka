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
		vx   = .125, -- walking speed
		vy   = .3, -- jump speed
		mass = 1,
		--umbrella
		u_d        = 0,
		u_v        = 0.125,
		u_diff     = nil, --> initial difference to terminal speed
		u_friction = 0.9,
		u_ddx      = U_DDX,
		u_drag_x   = U_DRAG_X,
		u_drag_y   = U_DRAG_Y,
		t_u_frame  = 0,
		u_h        = 1.375, --> height with umbrella
		u_s_x      = {24, 24, 27, 25},
		u_s_y      = {34, 37, 36, 32},
		u_s_w      = {1, 3, 5, 7},
		u_s_h      = {2, 3, 4, 4},
		--state
		is_player  = true,
		strafing   = false,
		traction   = false, --> false: no friction
		jumped     = false,
		descending = false,
		gliding    = false,
		walking    = false,
		t_coyote   = 0,
		--drawing
		t_frame   = 0,
		f_y       = 0,
		f_x       = 0,
		f_vx      = .04,
		--methods
		update = update_player,
		update_sprite = update_player_sprite,
		draw   = draw_player
		
	},
	[SPR_SOFA] = {
		w2 = 1,
		h  = 1,
		mass = 2,
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
		traction = true,
		d        = d or -1, --(looking direction)
		mass     = 1,
		--sprite
		cx  = 0,
		w2  = .5,
		h   = 1,
		f_x = 0,
		fade = 1,
		--pushing
		pushing_actors = {},
		pushing_actor = nil,
		pushed_by_actor = nil,

		--methods
		update        = update_actor,
		update_sprite = function() end,
		draw          = draw_actor,
		clear         = clear_cell
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
		if (a.t_u_frame < U_OPEN_FRAMES) a.t_u_frame += .5
		if (a.t_u_frame == 2) sfx(SFX_UMBRELLA_UP)
	else
		a.gliding = false
		a.u_diff = nil
		if (a.t_u_frame > 0) a.t_u_frame -= .5
		if (a.t_u_frame == 4) sfx(SFX_UMBRELLA_DOWN)
	end


	--falling

	--[
	if a.gliding and a.dy >= a.u_v then
		if(not a.u_diff)a.u_diff = a.dy - a.u_v
		a.dy = a.u_v + a.u_diff
		a.u_diff *= a.u_friction
	end
	--]]


	--strafing

	a.strafing = input_x != 0
	if(input_x != 0)a.d = input_x

	local accel = .1 --> airborn
	if abs(a.dx) > a.vx and a.d == sgn(a.dx) then
		accel = .05 --> going too fast (probably wont happen)
	elseif a.standing then
		accel = .25 --> on ground
	elseif a.strafing and a.gliding then
		accel = .1 --> strafing while gliding
	elseif a.strafing then
		accel = .2 --> strafing while airborn
	elseif a.gliding then
		accel = 0 --> gliding
	end


	-- velocity

	local mass_mul = 1 / a.mass
	if a.pushing_actor then
		mass_mul = 1 / (a.mass + a.pushing_actor.mass)
	end

	a.dx = approach(a.dx, input_x * a.vx, accel * a.vx) * mass_mul

	b = a.pushing_actor
	while b do
		b.dx = a.dx
		b = b.pushing_actor
	end

	--jumping

	if input_jump or input_jump_grace > 0 then
		if (a.standing or a.t_coyote > 0) and (not a.jumped or AUTO_JUMP) then
			--begin (trying to) jump
			a.dy = -a.vy
		end
	else
		a.jumped = false
	end


	--> apply world collisions and velocities
	update_actor(a)


	--going down platforms
	a.descending = btn(⬇️) and a.standing
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

	--friction
	if (a.standing and a.traction) a.dx *= a.friction

	--gravity
	a.dy += a.ddy

	--air resistance
	a.dy -= sgn(a.dy) * a.dy * a.dy * a.drag

	--timers
	a.t += 1
end


function update_player_sprite(a)
	--walking animation
	a.walking = (a.standing and (a.strafing or abs(a.dx) >= a.vx or a.t_frame % 4 != 0))

	--recenter the spirte
	a.f_x = approach(a.f_x, 0, a.f_vx)

	if not a.standing then
		a.frame = a.dy < a.ddy and 17 or 18
		a.t_frame = 3
		if (a.t_u_frame > 0) a.frame += 16
	elseif a.walking then
		if (a.t_frame % 4 == 3) sfx(SFX_STEP)
		local t = flr(a.t_frame%4)
		a.frame = a.t_u_frame > 0 and 32+t or 16+t
		a.t_frame = (a.t_frame + 0.25) % 4--flr(4*a.t_frame+1.5)/4 -->four ticks per frame
		-- sfx
	else
		--standing still
		a.frame = min(2, a.t_u_frame)
	end

	debug.walk = a.walking
	debug.ft4 = a.t_frame % 4
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
	if (fget(fr,3) and a.standing) y-=1

	--umbrella
	if (a.t_u_frame >= 3) then
		local x1 = a.d > 0 and x+1.5 or x+6.5 --> shift
		local n = flr(a.t_u_frame) - 2
		
		sspr(a.u_s_x[n], a.u_s_y[n], a.u_s_w[n], a.u_s_h[n],
			 x1-.5*a.u_s_w[n], y+1-a.u_s_h[n])
	end

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

	spr(fr, x,y,1,1,a.d<0)

	--palette reset
	pal()
	pal(ALT_COLORS,1)
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