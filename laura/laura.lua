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

    player = make_player()
    position_player()
    make_camera()
    info_string = '🅾️/z jump\n❎/x glide'
    info_x = player.x*8-16
    info_y = player.y*8-16
    music_playing = PLAY_MUSIC
    make_menu()
	pal(c,1)
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
	a.frame = 1
    a.f_t   = 0
    a.f_y   = 0
    a.f_x   = 0
    a.f_vx  = FVX
    --timer
	a.t		= 0
	if (count(actors) < MAX_ACTORS) then
		--> actor is global
		add(actors, a)
	end
	return a
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
    if music_playing then
        music(MUSIC, MUSIC_FADE_IN)
        menuitem( 1, 'music: on', music_toggle)
    else
        music(-1)
        menuitem( 1, 'music: off', music_toggle)
    end
end


function _update60()
    t += 1
    if FREEZE and not btnp(🅾️,1) then return end
    if t % SLOWDOWN ~= 0 then return end
    debug.t += 1

	foreach(actors, update_actor)
    update_camera()

    --debug.camera = tostr(camera_x.pos)..'  '..tostr(camera_y.pos)
end


function update_actor(a)
    if(a.kind == 1)update_player(a)
end


function collide_side(a)
    --> true if touching
    local d = a.dx ~= 0 and sgn(a.dx) or a.d
    local x1 = a.x + a.dx + d * (.5*a.w)
    local xe = d > 0 and 0 or -E --> stay outside edges
    if solid(x1+xe,a.y-E) or solid(x1+xe,a.y-a.h) then
        -- hit wall
        -- search for contact point
        while not (solid(a.x+d*(a.w*.5+E)+xe, a.y-E) or solid(a.x+d*(a.w*.5+E)+xe, a.y-a.h)) do
            a.x += sgn(a.dx) * E
        end
        a.x = snap8(a.x,a.cx)
        a.dx = 0 --> do this after contact point, because sgn(0) is not 1
    end
end


function collide_up(a, d)
    local y1 = a.y+a.dy-a.h
    local xl = snap8(a.x+a.dx-a.w*.5)
    local xr = snap8(a.x+a.dx+a.w*.5)-E
    local nudges
    if a.standing then nudges = {0}
    elseif a.dx > 0 then nudges = NUDGES_RIGHT
    elseif a.dx < 0 then nudges = NUDGES_LEFT
    else nudges = NUDGES_CENTER end

    for _,n in ipairs(nudges) do
        if not (solid(xl+n, y1) or solid(xr+n, y1)) then
            a.standing = false
            a.x += n
            a.f_x -= n
            a.state = a.umbrella and 'umbrella' or 'falling'
            --debug.solid_up = false
            return
        end
    end
    --> hit
    -- search up for collision point
    while (not (solid(xl, a.y-a.h-E) or solid(xr, a.y-a.h-E))) do
        a.y = a.y - E
    end

    a.dy=0
    a.boost_t = 0
    --debug.solid_up = true
end


function collide_down(a)
    local y1 = a.y+a.dy
    local xl = a.x-a.w*.5+a.dx
    local xr = a.x+a.w*.5+a.dx-E
    local nudges = a.dx == 0 and NUDGES_CENTER or {0}

    local hit = false
    if a.descending then
        --> look for platforms nearby nudge player above them
        for _,n in ipairs(nudges) do
            if platform(xl+n, y1) and platform(xr+n, y1) then
                decend = true
                a.x   += n
                a.f_x -= n
                xl    += n
                xr    += n
                break
            end
        end
    end

    if(solid(xl, y1) or solid(xr, y1))then
        --hit solid
        hit = true
        while not (solid(xl, a.y+E) or solid(xr, a.y+E)) do a.y += E end
    elseif (platform(xl, y1) or platform(xr, y1))
    and ceil(a.y) == flr(y1)
    and not a.descending then
        --hit platform
        hit = true
        while not(platform(xl, a.y+E) or platform(xr, a.y+E)) do a.y += E end
        a.descending=false
    end

    if hit then
        a.y = snap8(a.y)
        if not a.standing then
            a.state = abs(a.dx) < VX and 'still' or 'walking'
            sfx(SFX_STEP)
        end
        a.standing=true
        a.dy = 0
    else
        --coyote time
        if (a.coyote_t > 0) a.coyote_t -= 1
        if (a.standing) a.coyote_t = a.coyote_max

        a.state = a.umbrella and 'umbrella' or 'falling'
        a.standing = false
    end
end


function solid(x, y)
	if (x < world_x or x >= world_x+world_w) then
        return true
    end
				
	local val = mget(x, y)
	return fget(val, 1)
end


function platform(x,y)
    local val = mget(x, y)
	return fget(val, 2)
end


function snap8(val, shift)
    shift = shift or 0
    return flr(8*(val+shift)+.5) * .125 - shift
end


-- *-------------------*
-- | drawing functions |
-- *-------------------*


function _draw()
    pal(ALT_COLORS,1)
	cls(BG) 
    camera(camera_x.pos-63.5, camera_y.pos-63.5)
    color(7)
    print(info_string, info_x, info_y)
    map()
    if (HITBOX) foreach(actors, draw_hitbox)
    foreach(actors, draw_actor)

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


function draw_actor(a)
    if(a.kind == 1)draw_player(a)
end

--[[

actor position is center bottom
 _______
|       |
| (x,y) |
|___.___|

--]]

function draw_hitbox(a)
    rect(
        8*snap8(a.x-a.w*.5),
        8*snap8(a.y-a.h),
        8*(snap8(a.x+a.w*.5)-E),
        8*(snap8(a.y)-E),
        8
    )  
end


-- *------------------*
-- | player functions |
-- *------------------*


function make_player(x, y, d)
    x = x or 0
    y = y or 0
    d = d or 1
    a = make_actor(1, x, y, d) --> kind: 1
    --motion
    a.u_drag   = U_DRAG
    a.u_d      = 0
    a.u_tilt   = U_TILT
    --state
    a.strafing     = false
    a.jumped     = false
    a.descending  = false
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
    for x=world_x,world_w-1 do
        for y=world_y,world_h-1 do
            if mget(x,y) == SPR_STILL then
                player.x = x+0.5+player.cx
                player.y = y+1
                clear_cell(x,y)
                break
            end
        end
    end
end


function update_player(a)
    --umbrella
    a.umbrella = btn(❎) and not a.standing

    if a.umbrella then
        update_umbrella(a)
        update_jumping(a)
    else
        update_walking(a)
        update_jumping(a)
    end

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
    --umbrella
    a.state = 'umbrella'

    --a.boost_t = 0

    if(btn(⬅️) and not btn(➡️) and not a.strafing)then
        a.u_d = -1
    elseif(btn(➡️) and not btn(⬅️) and not a.strafing)then
        a.u_d = 1
    else
        if(not btn(⬅️) and not btn(➡️))a.strafing = false
        a.u_d = 0
    end

    if(a.dy <= 0)return
    --> only apply drag when descending

    --player looks in the movement direction
    if(a.dx != 0)a.d = sgn(a.dx)

    a.u_x =  sin(-a.u_d * a.u_tilt)
    a.u_y = -1-- -cos(-a.u_d * a.u_tilt)

    local v = sqrt(a.dx * a.dx + a.dy * a.dy)
    local c = -(a.dx * a.u_x + a.dy * a.u_y) * a.u_drag * v

    a.dx += c * a.u_x
    a.dy += c * a.u_y
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

    debug.dx = a.dx/a.vx

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
        a.frame = SPR_GLIDING + a.u_d * a.d
    else
        a.f_y   = 0
        a.frame = SPR_STILL
    end
end


function draw_player(a)
    local x = 8*(a.x+a.f_x-.5-sgn(a.d)*a.cx)+.5
    local y = 8*(a.y+a.f_y-1)+.5

    --draw umbrella
    if(a.umbrella)then
        local s = a.d > 0 and 0 or 1 --> shift
        if a.u_d < 0 then
            sspr(SPR_UMBRELLA_L_X, SPR_UMBRELLA_L_Y, 5, 5, x-4+s, y-2)
        elseif a.u_d > 0 then
            sspr(SPR_UMBRELLA_R_X, SPR_UMBRELLA_R_Y, 5, 5, x+6+s, y-2)
        else
            local ux = a.d>0 and x-2+s or x+2+s
            sspr(SPR_UMBRELLA_C_X, SPR_UMBRELLA_C_Y, 7, 4, ux, y-3)
        end
    end

    spr(a.frame, x, y,1,1,a.d<0)
end


-- *------------------*
-- | camera functions |
-- *------------------*


function make_camera()
    camera_x = make_camera_axis(8*player.x, 8*(world_x+8), 8*(world_x+world_w-8))
    camera_y = make_camera_axis(8*player.y, 8*(world_y+8), 8*(world_y+world_h-8))
end


function make_camera_axis(pos, min, max)
	--f (frequency): natural frequency

	--z (damping): how the atem comes to settle at the target
	--damping = 0: atem is undamped, never settles
	--0<damping<1: atem is underdamped.
	--damping = 1: critical damping
	--damping >= 1: atem does not vibrate

	--r (response): inital response of the atem
	--response = 0: atem takes time to accelerate
	--response > 0: reacts immediately
	--response > 1: atem will overshoot
	--response < 0: atem will anitcipate
	--response = 2 is typical for mechanical atems

	local c = {}

	--compute constants
	local p = 0.5/3.1415/CAMERA_F --> angular period
	c.k1 = 2*CAMERA_Z*p
	c.k2 = p*p
	c.k3 = CAMERA_R*CAMERA_Z*p

	--init variables
	c.target_pos = pos or 0
	c.pos = pos or 0
	c.vel = 0
    c.locked = false
	c.diff = 0
    c.min = min
    c.max = max
	c.bounded = min and max
	
	return c
end


function update_camera()
    update_camera_axis(camera_x, 8*(player.x-sgn(player.d)*player.cx))
    update_camera_axis(camera_y, 8*player.y)
end


function update_camera_axis(c, p)
	local target_vel = p - c.target_pos
	c.target_pos = p

	--if abs(target_vel) > CAMERA_MIN_V and abs(c.vel - target_vel) < CAMERA_LOCK_V then
	if abs(c.vel - target_vel) < CAMERA_LOCK_V then
		--> camera is locked on to the target
		if not c.locked then
			c.diff = flr(c.pos + c.vel - p + .5)
			c.locked = true
		end
		c.pos = p + c.diff
	else
		c.locked = false
		if(abs(c.vel) > CAMERA_MIN_V) then
			c.pos += c.vel
		end
	end

	debug.locked = c.locked
	debug.diff = c.locked and c.diff or nil

	if(c.bounded)c.pos = mid(c.min, c.pos, c.max)
	c.vel += (p + c.k3 * target_vel - c.pos - c.k1 * c.vel) / c.k2
end


function get_screen_pos(v, cam)
    return flr(v+.5) - flr(cam+.5) + 64
end


function update_camera_axis_old(sys, pl)
    local target_vel = pl - sys.target_pos
    sys.target_pos = pl

    if(abs(sys.vel) > CAMERA_MIN_V)then
        sys.pos += sys.vel
    end

	if(sys.bounded)sys.pos = mid(sys.min, sys.pos, sys.max)
    sys.vel += (pl + sys.k3 * target_vel - sys.pos - sys.k1 * sys.vel) / sys.k2
end