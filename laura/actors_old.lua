--actors
--3.4.2024


function init_actor_data()
	actor_data = {
	[SPR_STILL] = { --> player
		--size
		cx = -1/16, --> sprite center deviation
		w2 = 5/8 * .5, --> half width
		h  = 1,
		--motion
		r  = 0,
		vx = .125, -- walking speed
		vy = .2, -- jump speed
		--umbrella
		u_d      = 0,
		u_ddx    = U_DDX,
		u_drag_x = U_DRAG_X,
		u_drag_y = U_DRAG_Y,
		u_t      = 0,
		u_f_t    = 0,
		u_h      = 1.375, --> height with umbrella
		u_s_x    = {24, 24, 27, 25},
		u_s_y    = {34, 37, 36, 32},
		u_s_w    = {1, 3, 5, 7},
		u_s_h    = {2, 3, 4, 4},
		--state
		is_player  = true,
		strafing   = false,
		jumped     = false,
		descending = false,
		gliding    = false,
		jump_t     = 0,
		coyote_t   = 0,
		--drawing
		f_t       = 0,
		f_y       = 0,
		f_x       = 0,
		f_vx      = .04,
		walking_y = {0,-.125,-.125,0},
		--methods
		update = update_actor_old,
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
		ddy      = 0.02, -- gravity
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
	local a = make_actor(SPR_STILL, world_x+.5, world_y+1, 1)

	for x=world_x,world_x+world_w-1 do
		for y=world_y,world_y+world_h-1 do
			if mget(x,y) == SPR_STILL then
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

function update_actor_old(a)
	if(a.k == SPR_STILL)update_player(a)

	debug.d = a.d
	debug.dx = a.dx

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

	--gravity
	a.dy += a.ddy

	--air resistance
	a.dy -= sgn(a.dy) * a.dy * a.dy * a.drag

	--snapping
	if(a.dx == 0)a.x = snap8(a.x,a.cx)
	if(a.dy == 0)a.y = snap8(a.y,0)

	--timers
	a.t += 1
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

	--gravity
	a.dy += a.ddy

	--air resistance
	a.dy -= sgn(a.dy) * a.dy * a.dy * a.drag

	--timers
	a.t += 1
end

function update_player_input(a)
    --umbrella
	local u = false
	if btn(❎) and not a.standing then
		local y1 = a.y+a.dy-a.u_h
		local xl = snap8(a.x+a.dx-a.w2)
		local xr = snap8(a.x+a.dx+a.w2)-E
		u = not (solid(xl, y1) or solid(xr, y1))
	end

	if u then
		if (not a.gliding) a.gliding = true
		if (a.u_t < U_DRAG_RESPONSE) a.u_t += 1
		if (a.u_f_t < U_OPEN_FRAMES) a.u_f_t += .5
		if (a.u_f_t == 2) sfx(SFX_UMBRELLA_UP)

		update_gliding(a)
	else
		a.gliding = false
		a.u_t = max(0, a.u_t-5)
		if (a.u_f_t > 0) a.u_f_t -= .5
		if (a.u_f_t == 4) sfx(SFX_UMBRELLA_DOWN)
		
		update_walking(a)
	end

	--strafing
	if a.gliding then
		update_gliding(a)
	else
		update_walking(a)
	end

	--jumping
	if btn(🅾️) then
		if (a.standing or a.coyote_t > 0) and (not a.jumped or AUTO_JUMP) then
			--begin (trying to) jump
			a.dy = -a.vy
			a.jump_t = JUMP_MAX
		elseif not a.standing and a.jump_t > 0 then
			a.jump_t -= 1
			a.dy = -a.vy
		end
	else
		a.jumped = false
		a.jump_t = 0
	end
	
	--going down platforms
	a.descending = btn(⬇️) and a.standing
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
		if (not a.gliding) a.gliding = true
		if (a.u_t < U_DRAG_RESPONSE) a.u_t += 1
		if (a.u_f_t < U_OPEN_FRAMES) a.u_f_t += .5
		update_gliding(a)
	else
		a.gliding = false
		a.u_t = 0
		if (a.u_f_t > 0) a.u_f_t -= .5
		update_walking(a)
	end

	debug.u_t = a.u_t

	update_jumping(a)
end


function update_gliding(a)
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
			a.dx = abs(dv) > E and a.dx * EF or 0
			a.r = 0
		else
			--> quadratic
			a.dx = a.d * max(MV,a.vx * a.r * a.r)
		end

		a.r = min(a.r+1/DDXT, 1)
	else
		--friction
		a.dx *= a.friction
		if(abs(a.dx) < MV)a.dx = 0
	end

	--going down platforms
	if btn(⬇️) then
		if (a.standing) a.descending = true
	else
		a.descending = false
	end
end


function update_jumping(a)
	--jumping
	if btn(🅾️) then
		if (a.standing or a.coyote_t > 0) and (not a.jumped or AUTO_JUMP) then
			--begin (trying to) jump
			a.dy = -a.vy
			a.jump_t = JUMP_MAX
		--elseif a.gliding then
		--    a.jump_t = 0
		elseif not a.standing and a.jump_t > 0 then
			a.jump_t -= 1
			a.dy = -a.vy
		end
	else
		a.jumped = false
		a.jump_t = 0
	end
end


--[[

.    O       O       O       O    
. --@@@-- --@@@-- --@@@-- --@@@-- 
.   @@@\    @@@\   _@@@    _@@@  
.   |      /           \      |   

--]]

function update_body(a)
	--front end logic

	--recenter the spirte
	if (a.f_x > 0) a.f_x = max(0, a.f_x - a.f_vx)
	if (a.f_x < 0) a.f_x = min(0, a.f_x + a.f_vx)

	--umbrella
	local s = a.u_f_t >= 2 and SPR_U_WALKING or SPR_WALKING

	if not a.standing then
		if a.dy < a.ddy then --> going up
			a.frame = abs(a.dx) > 0 and s+1 or s
		else --> going down
			a.frame = abs(a.dx) > 0 and s+2 or s+3
		end
		a.f_y = 0
		a.f_t = 4
	else
		if not a.strafing and abs(a.dx) < a.vx and a.f_t%4 == 0 then
			-- stop walking
			a.frame = SPR_STILL + min(2, a.u_f_t)
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
end


--[[

actor position is center bottom
_______
|       |
| (x,y) |
|___.___|

--]]

function draw_actor(a)
	if(a.k == SPR_STILL)draw_player(a)
end


function draw_player(a)
	update_body(a)

	local x = 8*(a.x+a.f_x-.5-sgn(a.d)*a.cx)+.5
	local y = 8*(a.y+a.f_y-1)+.5

	if (a.u_f_t >= 3) then
		local s = a.d > 0 and 0 or 1 --> shift
		local n = flr(a.u_f_t) - 2

		debug.n = n

		if n==1 then
			sspr(SPR_UMBRELLA_1_X, SPR_UMBRELLA_1_Y, 1, 4, s*5+x+1, y-3)
		elseif n==2 then
			sspr(SPR_UMBRELLA_2_X, SPR_UMBRELLA_2_Y, 3, 4, s*5+x, y-3)
		elseif n==3 then
			sspr(SPR_UMBRELLA_3_X, SPR_UMBRELLA_3_Y, 5, 4, s*5+x-1, y-3)
		else
			sspr(SPR_UMBRELLA_C_X, SPR_UMBRELLA_C_Y, 7, 4, s*5+x-2, y-3)
		end
	end

	spr(a.frame, x, y,1,1,a.d<0)
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