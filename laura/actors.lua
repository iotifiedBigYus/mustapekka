--actors
--3.4.2024


function make_actor(kind,x,y,d)
	local a = {}
	a.kind  = kind --1: player, 2: pickup, 3:monster
	--motion
	a.x    = x
	a.y    = y
	a.dx   = 0
	a.dy   = 0
	a.r    = 1
	a.vx   = VX
	a.vy   = VY
	a.ddx  = DDX
	a.ddy  = G -- gravity
	a.drag = DRAG
	a.d    = d --pickup 1, monster -1 (looking direction)
	--state
	a.state    = 'still'
	a.standing = true
	--size
	a.cx = -1/16 --> sprite center deviation
	a.w  = .625
	a.h  = 1
	a.standing_h = 1
	a.falling_h  = 0.875
	--drawing
	a.frame = 0
	a.f_t   = 0
	a.f_y   = 0
	a.f_x   = 0
	a.f_vx  = FVX
	--timer
	a.t = 0
	if (count(actors) < MAX_ACTORS) then
		--> actor is global
		add(actors, a)
	end
	return a
end


function make_player(x, y, d)
	x = x or 0
	y = y or 0
	d = d or 1
	a = make_actor(1, x, y, d) --> kind: 1
	--motion
	a.u_d      = 0
	a.u_ddx    = U_DDX
	a.u_drag_y = U_DRAG_Y
	a.u_t      = 0
	a.u_max    = U_DRAG_RESPONSE
	a.u_frame  = 0
	a.u_f_x    = 0
	a.u_f_y    = 0
	--state
	a.strafing   = false
	a.jumped     = false
	a.descending = false
	a.umbrella   = false
	a.boost_t    = 0
	a.boost_max  = BOOST
	a.coyote_t   = 0
	a.coyote_max = COYOTE
	--drawing
	a.walking_y = {0,-.125,-.125,0}
	return a
end


function position_player()
	player.x = world_x + .5
	player.y = world_y + 1
    for x=world_x,world_x+world_w-1 do
        for y=world_y,world_y+world_h-1 do
            if mget(x,y) == SPR_STILL then
                player.x = x+0.5+player.cx
                player.y = y+1

                clear_cell(x,y)
                break
            end
        end
    end
end


function update_actor(a)
    if(a.kind == 1)update_player(a)
end


function update_player(a)
    --umbrella
	if btn(❎) and not a.standing then
		if not a.umbrella then
			a.u_t = a.u_max + 1
			a.umbrella = true
		end
	else
    	a.umbrella = false
	end

    if a.umbrella then
        update_umbrella(a)
    else
        update_walking(a)
    end
	update_jumping(a)

    a.h = a.standing and a.standing_h or a.falling_h

    -- x movement 
    collide_side(a)
    -- y movement
    if(a.dy < 0)collide_up(a)
    if(a.dy >= 0)collide_down(a)

    --moving
    a.x += a.dx
    a.y += a.dy

    --sprite
    update_body(a)

    --gravity
    a.dy += a.ddy

    --air resistance
    if not a.standing then
        a.dy -= sgn(a.dy) * a.dy * a.dy * a.drag
        a.dx -= sgn(a.dx) * a.dx * a.dx * a.drag
    end

    --snapping
    if(a.dx == 0)a.x = snap8(a.x,a.cx)
    if(a.dy == 0)a.y = snap8(a.y,0)

    --timers
    a.t += 1
end


function update_umbrella(a)
	a.state = 'umbrella'

	if(a.u_t > 0)a.u_t -= 1

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

	local r = 1 - a.u_t/a.u_max
	a.dx += a.u_ddx * a.u_d * r
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
        a.r = 1
        a.strafing = false
    end

    --debug.strafing = a.strafing

    if a.strafing then
        --> inverse exponential
        --a.r *= EI
        --a.dx = a.d * a.vx * (1-a.r)

        --> linear
        --a.r = max(0, a.r-1/DDXT)
        --a.dx = a.d * a.vx * (1-a.r)

        --> exponential
        --a.r = min(1/MV, a.r*EA)
        --a.dx = a.d * a.vx * MV * (a.r-1)

        --> quadratic
        a.r = max(0, a.r-1/DDXT)
        a.dx = a.d * max(MV,a.vx * (1-a.r) * (1-a.r))

        --if(a.d * a.dx < 0)a.dx = 0 --> change of direction
        --if(a.d * a.dx < a.vx)a.dx += a.d * a.ddx

        if(a.standing)then
            if not a.state == 'walking' then
                sfx(SFX_STEP)
            end
            a.state = 'walking'
        end
    else
        --friction

        a.dx *= EF
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
        if (a.standing or a.coyote_t > 0) and (not a.jumped or AUTO_BOOSTUMP) then
            --begin (trying to) jump
            a.dy = -a.vy
            a.boost_t = a.boost_max
        --elseif a.umbrella then
        --    a.boost_t = 0
        elseif not a.standing and a.boost_t > 0 then
            a.boost_t -= 1
            a.dy = -a.vy
        end
    else
        a.jumped = false
        a.boost_t = 0
    end
end


--[[

   O       O       O       O    
--@@@-- --@@@-- --@@@-- --@@@-- 
  @@@\    @@@\   _@@@    _@@@  
  |      /           \      |   

--]]

function update_body(a)
    --debug.state = a.state

    --recenter the spirte
    if (a.f_x > 0) a.f_x = max(0, a.f_x - a.f_vx)
    if (a.f_x < 0) a.f_x = min(0, a.f_x + a.f_vx)

    if a.state == 'falling' then
        a.f_y = 0
        a.f_t = 3
        if a.dy < 0 then --> going up
            a.frame = abs(a.dx) > 0 and SPR_WALKING+1 or SPR_WALKING
            a.jumped = true
        else --> going down
            a.frame = abs(a.dx) > 0 and SPR_WALKING+2 or SPR_WALKING+3
        end
    elseif a.state == 'walking' then
        a.f_t = flr(a.f_t * 4 + 1.5) / 4 --> four ticks per frame
        if(a.f_t % 4 == 3)sfx(SFX_STEP) --> tip tap
        if abs(a.dx) < VX and a.f_t%4 == 0 then
            -- stop
            a.frame = SPR_STILL
            a.f_y = 0
            a.f_t = 0
            a.walking = false
            a.state = 'still'
        else
            a.frame = SPR_WALKING + flr(a.f_t%4)
            a.f_y = a.walking_y[flr(a.f_t%4)+1]
        end
    elseif a.state == 'umbrella' then
        a.f_y = 0
		--a.frame = (a.u_t > a.u_max-U_OPEN) and SPR_GLIDING or SPR_GLIDING + a.u_d * a.d
		a.frame = SPR_GLIDING
    else
        a.f_y   = 0
        a.frame = SPR_STILL
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
    if(a.kind == 1)draw_player(a)
end


function draw_player(a)
	local x = 8*(a.x+a.f_x-.5-sgn(a.d)*a.cx)+.5
	local y = 8*(a.y+a.f_y-1)+.5

	if(a.umbrella)then
		local s = a.d > 0 and 0 or 1 --> shift
		if a.u_t > a.u_max-U_OPEN then
			local n = flr((a.u_max - a.u_t) * .5)

			if n==0 then
				sspr(SPR_UMBRELLA_1_X, SPR_UMBRELLA_1_Y, 1, 4, x+1+s*5, y-3)
			elseif n==1 then
				sspr(SPR_UMBRELLA_2_X, SPR_UMBRELLA_2_Y, 3, 4, x+s*5, y-3)
			elseif n==2 then
				sspr(SPR_UMBRELLA_3_X, SPR_UMBRELLA_3_Y, 5, 4, x-1+s*5, y-3)
			end
		else
			if a.u_d < 0 then
				sspr(SPR_UMBRELLA_L_X, SPR_UMBRELLA_L_Y, 5, 5, x-4+s, y-2)
			elseif a.u_d > 0 then
				sspr(SPR_UMBRELLA_L_X, SPR_UMBRELLA_L_Y, 5, 5, x+6+s, y-2, 5, 5, true)
			else
				local ux = a.d>0 and x-2+s or x+2+s
				sspr(SPR_UMBRELLA_C_X, SPR_UMBRELLA_C_Y, 7, 4, ux, y-3)
			end

			--local ux = a.d>0 and x-2+s or x+2+s
			--sspr(SPR_UMBRELLA_C_X, SPR_UMBRELLA_C_Y, 7, 4, ux, y-3)
		end
	end

	spr(a.frame, x, y,1,1,a.d<0)
end


function draw_hitbox(a)
    rect(
        8*snap8(a.x-a.w*.5),
        8*snap8(a.y-a.h),
        8*(snap8(a.x+a.w*.5)-E),
        8*(snap8(a.y)-E),
        8
    )  
end