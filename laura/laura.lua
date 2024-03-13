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
--sideways acceleration (thrust / friction)
--DDX = VX / 4
--maximum jump duration (in ticks)
J = 11
--epsilon (a small number)
E = .01
--world width
WW = 128
--world height
WH = 32
--minimum velocity
MV = .04

-- *-----------------*
-- | other constants |
-- *-----------------*

--version number
version = 'v0.2.1'
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

player_x = 6
player_y = 16

function _init()
    t = 0
	actors = {}
    player = make_player(player_x,player_y)
    camera_system_x = new_system(camera_f, camera_z, camera_r, player_x)
    camera_system_y = new_system(camera_f, camera_z, camera_r, player_y)
    camera_x = player_x
    camera_y = player_y

    music_playing = true
    music(0)
    menu_init()
	pal(c,1)
end


function make_player(x, y, d)
    d = d or 1
    a = make_actor(1, x, y, d) --> kind: 1
    a.walking_y = {0,-.125,-.125,0}
    a.button_jump = 4
    a.jumped = false
    a.jump_t = 0
    a.jump_max = 5
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

    debug.camera = tostr(camera_x)..'  '..tostr(camera_y)
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


    debug.jumped = a.jumped

    --gravity
    a.dy += a.ddy

    --snapping
    if(a.dx == 0)a.x = (flr(8*(a.x+a.cx)+.5) - 8*a.cx) * .125
    if(a.dy == 0)a.y =  flr(8 * a.y + .5) * 0.125

    --timers
    a.t += 1
end


function update_player(a)
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
                sfx(7)
            end
            a.state = 'walking'
        end
    else
        --friction
        a.dx *= EF
        --if(a.d * a.dx > 0)a.dx -= a.d * a.ddx
        if abs(a.dx) < MV then
            a.dx = 0
        end
    end

    debug.dx = a.dx

    --jumping
    if btn(🅾️) then
        a.jump_t = a.jump_max
        if a.standing and (not a.jumped or auto_jump) then
            --begin jump
            a.dy = -a.vy
            a.boost_t = a.boost_max
        elseif a.state == 'falling' and a.boost_t > 0 then
            a.boost_t -= 1
            a.dy = -a.vy
        end
    else
        a.jumped = false
        a.boost_t = 0
        a.jump_t = a.jump_t > 0 and a.jump_t - 1 or 0
    end

    debug.jump_t = a.jump_t

    a.decending = (btn(⬇️) and a.standing)
    a.h = a.standing and a.standing_h or a.falling_h
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
        a.f_t = 3
        if a.dy < 0 then --> going up
            a.frame = abs(a.dx) > 0 and 50 or 49
            a.jumped = true
        else --> going down
            a.frame = abs(a.dx) > 0 and 51 or 52
        end
    elseif a.state == 'walking' then
        a.f_t = flr(a.f_t * 4 + 1.5) / 4 --> four ticks per frame
        if(a.f_t % 4 == 3)sfx(7) --> tip tap
        if abs(a.dx) < VX and a.f_t%4 == 0 then
            -- stop
            a.frame = 48
            a.f_y = 0
            a.f_t = 0
            a.walking = false
            a.state = 'still'
        else
            a.frame = 49 + flr(a.f_t%4)
            a.f_y = a.walking_y[flr(a.f_t%4)+1]
        end
    else
        a.f_y   = 0
        a.frame = 48
    end
    debug.f_t = a.f_t
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
        if a.standing then
            a.standing = false
        end
        a.state = 'falling'
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

        if(a.state == 'falling') then
            a.state = abs(a.dx) < VX and 'still' or 'walking'
            sfx(7)
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
        if(a.state == 'falling') then
            a.state = abs(a.dx) < VX and 'still' or 'walking'
            sfx(7)
        end
        a.standing=true
        a.decending=false
        a.dy = 0
    else
        a.state = 'falling'
        a.standing = false
    end
end


function solid(x, y)
	if (x < 0 or x >= WW) then
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
    camera_x = mid(8, camera_x, WW-8)
    camera_system_x.b = camera_x

    local y, dy = update_system(camera_system_y, player.y)
    if(abs(dy) > MV)camera_y = y
    camera_y = mid(8, camera_y, WH-8)
    camera_system_y.b = camera_y
end

-- *-------------------*
-- | drawing functions |
-- *-------------------*

function _draw()
    pal(alt_colors,1)
	cls(BG)
    camera(8*camera_x-64, 8*camera_y-64)
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
    spr(a.frame, x, 8*(a.y+a.f_y-1)+.5,1,1,a.d<0)
end