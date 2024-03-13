--laura
--sam westerlund
--23.2.24


-- *--------------------*
-- | "nature" constants |
-- *--------------------*

--horizontal speed
VX = .125
--jump speed
VY = 0.2 --> when pressing fast (~5 ticks) you jump exactly one block
--gravitational acceleration
G = .02
--exponential acceleration
EI = 0.5
--exponential deacceleration
EF = 0.9
--air drag
C = .02
--umbrella drag
UC = .7
--umbrella system
UF = 0.1
UZ = 1
UR = 0
--sideways acceleration (thrust / friction)
--DDX = VX / 4
--maximum jump duration (in ticks)
J = 11
--epsilon (a small number)
E = .01
--world upper left corner x,y; width; height
WX = 0
WY = 32
WW = 32
WH = 32
--minimum velocity
MV = .04

-- *-----------------*
-- | other constants |
-- *-----------------*

--version number
version = 'v0.2.0'
--maximum amount of actors
max_actors = 128
--debug object / namespace
debug = {t=0}
--show debug info
debugging = false
--update the game one frame at a time by pressng ⬆️
freeze =  false
--frames per tick
slowdown = 1
--camera dynamics
camera_f = 0.01
camera_z = 1
camera_r = 0
--auto jump
auto_jump = false
--music
play_music = false

-- *---------------*
-- | color palette |
-- *---------------*

c = {}
c[0]  = 0
c[1]  = 0
c[2]  = 2+128
c[3]  = 3+128
c[4]  = 4+128
c[5]  = 0+128
c[9]  = 9+128
c[11] = 3
c[12] = 13
c[13] = 13+128
c[15] = 15+128
alt_colors = c

--background color
BG = 13

-- *----------------*
-- | initial values |
-- *----------------*

player_x = 7.5
player_y = 48

-- *--------*
-- | sounds |
-- *--------*

SFX_STEP = 63
SFX_JUMP = 62
MUSIC = 0
MUSIC_FADE_IN = 1000

-- *---------*
-- | sprites |
-- *---------*

SPR_STILL = 48
SPR_WALKING = 49
SPR_GLIDING = 61

-- *-------------------*
-- | initial functions |
-- *-------------------*


function _init()
    t = 0
	actors = {}
    player = make_player(player_x,player_y)
    camera_system_x = new_system(camera_f, camera_z, camera_r, player_x)
    camera_system_y = new_system(camera_f, camera_z, camera_r, player_y)
    camera_x = player_x
    camera_y = player_y
    camera_locked = false

    music_playing = play_music
    if(music_playing)music(MUSIC,MUSIC_FADE_IN)
    menu_init()
	pal(c,1)
end


function make_player(x, y, d)
    d = d or 1
    a = make_actor(1, x, y, d) --> kind: 1
    a.walking_y = {0,-.125,-.125,0}
    a.button_jump = 4
    a.jumped   = false
    a.jump_t   = 0
    a.jump_max = 5
    a.umbrella = false
    a.u_drag   = UC
    a.u_a      = 0
    a.u_d      = 0
    a.u_tilt   = 0.1
    a.u_x      = 0 
    a.u_y      = -1
    a.u_system_d = new_system(camera_f, camera_z, camera_r, player_x)
    return a
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
    a.boost_t   = 0
    a.boost_max = J
    a.state     = 'still'
	a.standing  = false
    a.decending = false
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
	if (count(actors) < max_actors) then
		--> actor is global
		add(actors, a)
	end
	return a
end


function menu_init()
    menuitem( 1, 'music: on', music_toggle)
end


function music_toggle()
    music_playing = not music_playing
    if music_playing then
        music(0)
        menuitem( 1, 'music: on')
    else
        menuitem( 1, 'music: off')
        music(-1)
    end
    return true
end


-- *------------------*
-- | update functions |
-- *------------------*


function _update60()
    t += 1
    if freeze and not btnp(⬆️) then return end
    if t % slowdown ~= 0 then return end
    debug.t += 1

    update_btnd()
	foreach(actors, update_actor)
    update_camera()

    --debug.camera = tostr(camera_x)..'  '..tostr(camera_y)
end


function update_actor(a)
    if(a.kind == 1)update_player(a)
    --debug.h = a.h
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
    if(a.dx == 0)a.x = (flr(8*(a.x+a.cx)+.5) - 8*a.cx) * .125
    if(a.dy == 0)a.y =  flr(8 * a.y + .5) * 0.125

    --timers
    a.t += 1
end


function update_player(a)
    --umbrella
    if not a.standing and btn(❎) then
        a.umbrella = true
    else
        a.umbrella = false
    end

    if a.umbrella then
        update_umbrella(a)
    else
        update_walking(a)
        update_jumping(a)
    end

    a.h = a.standing and a.standing_h or a.falling_h
end


function update_umbrella(a)
    --umbrella
    a.state = 'umbrella'
    
    if(btn(⬅️) and not btn(➡️))then
        a.u_a = a.u_tilt
        a.u_d = -1
    elseif(btn(➡️) and not btn(⬅️))then
        a.u_a = -a.u_tilt
        a.u_d = 1
    else
        a.u_a = 0
        a.u_d = 0
    end

    if(a.dy <= 0)return
    --> only apply drag when decending

    --player looks in the movement direction
    if(a.dx != 0)a.d = sgn(a.dx)

    a.u_x =  sin(a.u_a)
    a.u_y = -cos(a.u_a)

    local v = sqrt(a.dx * a.dx + a.dy * a.dy)
    local c = -(a.dx * a.u_x + a.dy * a.u_y) * a.u_drag * v

    a.dx += c * a.u_x
    a.dy += c * a.u_y
end


function update_walking(a)
    --side movement
    local moving = false
    if(btn(➡️) and not btn(⬅️))then
        a.d = 1
        moving = true
    elseif(btn(⬅️)and not btn(➡️))then
        a.d = -1
        moving = true
    else
        a.r = 1
    end

    if moving then
        a.r *= EI
        a.dx = a.d * a.vx * (1-a.r)
        --if(a.d * a.dx < 0)a.dx = 0
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
        --if(a.d * a.dx > 0)a.dx -= a.d * a.ddx
        if(abs(a.dx) < MV)a.dx = 0
    end

    debug.dx = a.dx

    a.decending = (btn(⬇️) and a.standing)
end


function update_jumping(a)
    --jumping
    if btn(🅾️) then
        a.jump_t = a.jump_max
        if a.standing and (not a.jumped or auto_jump) then
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
        a.jump_t = a.jump_t > 0 and a.jump_t - 1 or 0
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


function collide_side(a)
    --> true if touching
    local d = a.dx ~= 0 and sgn(a.dx) or a.d
    local x1 = a.x + a.dx + d * (.5*a.w)
    local xe = d > 0 and 0 or -E --> stay outside edges
    --local xe = d > 0 and -E or 0 --> stay inside edges
    if solid(x1+xe,a.y-E) or solid(x1+xe,a.y-a.h) then
        -- hit wall
        -- search for contact point
        while not (solid(a.x+d*(a.w*.5+E)+xe, a.y-E) or solid(a.x+d*(a.w*.5+E)+xe, a.y-a.h)) do
            a.x += sgn(a.dx) * E
        end
        a.x = (flr( 8*(a.x+a.cx)+.5) - 8*a.cx) * .125
        a.dx = 0 --> do this after contact point, because sgn(0) is not 1
        --debug.side = true
    else
        --debug.side = false
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

-- *-------------------*
-- | drawing functions |
-- *-------------------*

function _draw()
    pal(alt_colors,1)
	cls(BG)
    camera(8*camera_x-64, 8*camera_y-64)
    color(6)
    print('🅾️ to jump\n❎ to glide',player_x*8-16,player_y*8-16)
    map()
	pal(alt_colors,1)
    foreach(actors, draw_actor)

    --debug
    camera(0,0)
    cursor(1,1)
    color(7)
    print(version)
    if debugging then
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

]]
function draw_player(a)
    local x = a.d>0 and 8*(a.x-a.cx)+.5 or 8*(a.x-1+a.cx)+.5
    local y = 8*(a.y+a.f_y-1)+.5

    --draw umbrella
    if(a.umbrella)then
        local s = a.d > 0 and 0 or 1 --> shift
        if a.u_d < 0 then
            sspr(104, 18, 5, 5, x-4+s, y-2)
        elseif a.u_d > 0 then
            sspr(114, 18, 5, 5, x+6+s, y-2)
        else
            local ux = a.d>0 and x-2+s or x+2+s
            sspr(108, 17, 7, 4, ux, y-3)
        end
    end

    spr(a.frame, x, y,1,1,a.d<0)
end