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
    if ((x>WX and val0 == 0) or (x<WX+WW-1 and val1 == 0)) then
        mset(x,y,0)
    elseif (not fget(val1,1)) then
        mset(x,y,val1)
    elseif (not fget(val0,1)) then
        mset(x,y,val0)
    else
        mset(x,y,0)
    end
end


function make_camera()
    local x = mid(WX+8, player.x, WX+WW-8)
    local y = mid(WY+8, player.y, WY+WH-8)
    camera_system_x = new_system(CAMERA_F, CAMERA_Z, CAMERA_R, x)
    camera_system_y = new_system(CAMERA_F, CAMERA_Z, CAMERA_R, y)
    camera_x = x
    camera_y = y
    camera_locked_horz = false
    camera_locked_x = 0
    camera_locked_vert = false
    camera_locked_y = 0
end


function make_actor(kind,x,y,d)
	--TODO what is d?? maybe draing priority
	local a = {}
	a.kind  = kind --1: player, 2: pickup, 3:monster
    --motion
	a.x   = x
	a.y   = y
	a.dx  = 0
	a.dy  = 0
    a.r   = 1
    a.vx  = VX
    a.vy  = VY
    a.ddx = DDX
	a.ddy = G -- gravity
    a.drag = C
	a.d   = d --pickup 1, monster -1 (looking direction)
    --state
    a.state    = 'still'
	a.standing = true
    --size
    a.cx = .4375 --> sprite center x
    a.w  = .625
    a.h  = 1
    a.standing_h = 1
    a.falling_h  = 0.875
    --drawing
	a.frame = 1
    a.f_t   = 0
    a.f_y   = 0
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
    --update_camera()

    --debug.camera = tostr(camera_x)..'  '..tostr(camera_y)
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
        a.x = (flr( 8*(a.x+a.cx)+.5) - 8*a.cx) * .125
        a.dx = 0 --> do this after contact point, because sgn(0) is not 1
    end
end


function collide_up(a, d)
    local y1 = a.y+a.dy-a.h
    if (solid(a.x-a.w*.5+a.dx, y1) or solid(a.x+a.w*.5-E+a.dx, y1)) then
        -- search up for collision point
        while (not (solid(a.x-a.w*.5+a.dx, a.y-a.h-E)
        or solid(a.x+a.w*.5-E+a.dx, a.y-a.h-E))) do
            a.y = a.y - E
        end

        a.dy=0
        a.boost_t = 0
        --debug.solid_up = true
    else
        a.standing = false
        a.state = a.umbrella and 'umbrella' or 'falling'
        --debug.solid_up = false
    end
end


function collide_down(a)
    local xl = a.x-a.w*.5+a.dx
    local xr = a.x+a.w*.5+a.dx-E
    if(solid(xl, a.y+a.dy) or solid(xr, a.y+a.dy))then
        --snap down
        while not (solid(xl, a.y+E) or solid(xr, a.y+E)) do
            a.y += E
        end
        a.y = flr(8*a.y+.5)/8

        if not a.standing then
            a.state = abs(a.dx) < VX and 'still' or 'walking'
            sfx(SFX_STEP)
        end
        a.standing=true
        a.dy = 0
    elseif (platform(xl, a.y+a.dy) or platform(xr, a.y+a.dy))
    and ceil(a.y) == flr(a.y+a.dy)
    and not a.decending then
        while not(platform(xl, a.y+E) or platform(xr, a.y+E)) do
            a.y += E
        end
        a.y = flr(8*a.y+.5)/8
        if not a.standing then
            a.state = abs(a.dx) < VX and 'still' or 'walking'
            sfx(SFX_STEP)
        end
        a.standing=true
        a.decending=false
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
	if (x < WX or x >= WX+WW) then
        return true
    end
				
	local val = mget(x, y)
	return fget(val, 1)
end


function platform(x,y)
    local val = mget(x, y)
	return fget(val, 2)
end


function update_camera()
    local x, dx = update_system(camera_system_x, player.x)
    if(abs(dx) > MV)camera_x = x
    camera_x = mid(WX+8, camera_x, WX+WW-8)
    camera_system_x.b = camera_x

    local y, dy = update_system(camera_system_y, player.y)
    if(abs(dy) > MV)camera_y = y
    camera_y = mid(WY+8, camera_y, WY+WH-8)
    camera_system_y.b = camera_y
end


function update_smart8_system()
    local x, dx = update_system(camera_system_x, player.x)
    if(abs(dx) < MV)then
        --> do not move
    elseif(abs(dx - player.dx) > MDV)then
        --> different enough speed
        camera_locked_horz = false
        camera_x = x
    elseif camera_locked_horz then
        --> already locked on to the player
        camera_x += player.dx
    else
        --> initiate horizontal lock
        camera_locked_horz = true
        local r8 = 8*player.x - flr(8*player.x)
        local x8 = flr(8*camera_x+.5) + r8
        camera_x = x8 * .125
    end
    camera_x = mid(WX+8, camera_x, WX+WW-8)
    camera_system_x.b = camera_x
end


-- *-------------------*
-- | drawing functions |
-- *-------------------*


function _draw()
    pal(ALT_COLORS,1)
	cls(BG) 
    camera(8*camera_x-64, 8*camera_y-64)
    color(6)
    print(info_string, info_x, info_y)
    map()
    foreach(actors, draw_actor)

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


-- *------------------*
-- | player functions |
-- *------------------*


function make_player(x, y, d)
    x = x or WX
    y = y or WY
    d = d or 1
    a = make_actor(1, x, y, d) --> kind: 1
    --motion
    a.u_drag   = UC
    a.u_d      = 0
    a.u_tilt   = 0.1
    --state
    a.strafe     = false
    a.jumped     = false
    a.decending  = false
    a.umbrella   = false
    a.boost_t    = 0
    a.boost_max  = J
    a.coyote_t   = 0
    a.coyote_max = COYOTE
    --drawing
    a.walking_y = {0,-.125,-.125,0}
    return a
end


function position_player()
    for x=WX,WW-1 do
        for y=WY,WH-1 do
            if mget(x,y) == SPR_STILL then
                player.x = x+player.cx
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

    update_camera()

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
    if(a.dx == 0)a.x = (flr(8*(a.x+a.cx)+.5) - 8*a.cx) * .125
    if(a.dy == 0)a.y =  flr(8 * a.y + .5) * 0.125

    --timers
    a.t += 1
end


function update_umbrella(a)
    --umbrella
    a.state = 'umbrella'

    a.boost_t = 0

    if(btn(⬅️) and not btn(➡️) and not a.strafe)then
        a.u_d = -1
    elseif(btn(➡️) and not btn(⬅️) and not a.strafe)then
        a.u_d = 1
    else
        if(not btn(⬅️) and not btn(➡️))a.strafe = false
        a.u_d = 0
    end

    if(a.dy <= 0)return
    --> only apply drag when decending

    --player looks in the movement direction
    if(a.dx != 0)a.d = sgn(a.dx)

    a.u_x =  sin(-a.u_d * a.u_tilt)
    a.u_y = -cos(-a.u_d * a.u_tilt)

    local v = sqrt(a.dx * a.dx + a.dy * a.dy)
    local c = -(a.dx * a.u_x + a.dy * a.u_y) * a.u_drag * v

    a.dx += c * a.u_x
    a.dy += c * a.u_y
end


function update_walking(a)
    --side movement
    if(btn(➡️) and not btn(⬅️))then
        a.d = 1
        a.strafe = true
    elseif(btn(⬅️)and not btn(➡️))then
        a.d = -1
        a.strafe = true
    else
        a.r = 1
        a.strafe = false
    end

    debug.strafe = a.strafe

    if a.strafe then
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
        a.dx = a.d * a.vx * (1-a.r) * (1-a.r)

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
    a.decending = (btn(⬇️) and a.standing)
end


function update_jumping(a)
    --jumping
    if btn(🅾️) then
        if (a.standing or a.coyote_t > 0) and (not a.jumped or AUTO_JUMP) then
            --begin (trying to) jump
            a.dy = -a.vy
            a.boost_t = a.boost_max
        elseif a.umbrella then
            a.boost_t = 0
        elseif a.state == 'falling' and a.boost_t > 0 then
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
    debug.state = a.state
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
        debug.u_d = a.u_d
    else
        a.f_y   = 0
        a.frame = SPR_STILL
    end
end


function draw_player(a)
    local x = a.d>0 and 8*(a.x-a.cx)+.5 or 8*(a.x-1+a.cx)+.5
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