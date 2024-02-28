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
--friction deacceleration
F = 0.9
--inverse friction
I = 0.6
--maximum jump duration (in ticks)
J = 11
--epsilon (a small number)
E = .01
--world width
WW = 32
--minimum velocity
MV = .04

-- *-----------------*
-- | other constants |
-- *-----------------*

--maximum amount of actors
max_actors = 128
--debug object / namespace
debug = {t=0}
--show debug info
debugging = false
--update the game one frame at a time by pressng 🅾️
freeze =  false
--frames per tick
slowdown = 1
--camera dynamics
camera_f = 0.01
camera_z = 1
camera_r = 0

-- *---------------*
-- | color palette |
-- *---------------*

c = {}
c[0]  = 0
c[1]  = 0
c[2]  = 1+128
c[3]  = 3+128
c[4]  = 4+128
c[5]  = 0+128
c[9]  = 9+128
c[11] = 3
c[12] = 13
c[13] = 13+128
c[15] = 15+128
alt_colors = c

-- *----------------*
-- | initial values |
-- *----------------*

player_x = 8
player_y = 8

function _init()
    t = 0
	actors = {}
    player = make_player(player_x,player_y,1)
    camera_system = new_system(camera_f, camera_z, camera_r, player_x)
    camera_x = player_x

	pal(c,1)
end


function make_player(x, y, d)
    --?? pl.pal
    a = make_actor(1, x, y, d) --> kind: 1
    a.walking_y = {0,-.125,-.125,0}
    a.sprinting = false
    a.charge = 0
    a.super  = 0
    a.score  = 0
    a.bounce = 0 --> bounce is removed
    a.delay  = 0
    a.id     = 0 -- player 1
    a.pal    = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
    return a
end


function make_actor(kind,x,y,d)
	--TODO what is d?? maybe draing priority
	local a = {}
	a.kind  = kind --1: player, 2: pickup, 3:monster
	--a.life	 = 1
	a.x     = x
	a.y     = y
	a.dx    = 0
	a.dy    = 0
    a.r     = 1
    a.cx    = .4375 --> sprite center x
    a.vx    = VX
    a.vy    = VY
	a.ddy   = G -- gravity
	a.d     = d --pickup 1, monster -1 (normalized looking x)
    a.w     = .625
    a.h     = 1
    a.standing_h = 1
    a.falling_h = 0.9
	--a.bounce   = .8
	a.frame = 1
	--a.f0    = 0 --default frame (sprite)
    a.f_t   = 0
    a.f_y   = 0
	a.t		= 0
    a.state = 'still'
	a.standing = false
    a.jump_t = 0
    a.jump_max = J
    a.leap = false
    a.decending = false
    a.s_t   = 0
	if (count(actors) < max_actors) then
		--> actor is global
		add(actors, a)
	end
	return a
end


function _update60()
    t += 1
    if freeze and not btnp(4) then return end
    if t % slowdown ~= 0 then return end
    debug.t += 1

    update_btnd()
	foreach(actors, update_actor)
    update_camera()
end


function update_actor(a)
    if(a.kind == 1)update_player(a)

    a.h = a.standing and a.standing_h or a.falling_h
    --debug.h = a.h
    -- x movement 
    collide_side(a)
    -- y movement
    if (a.dy < 0) then
        --debug.dir = 'up'
        collide_up(a)
    else
        --debug.dir = 'down'
        collide_down(a)
    end

    --debug.standing = a.standing

    --moving
    a.x += a.dx
    a.y += a.dy

    debug.dx = a.dx

    --sprite
    update_body(a)

    --friction & gravity
    a.dx *= F
    if abs(a.dx) < MV then
        a.dx = 0
    end
    a.dy += a.ddy

    --snapping
    if(a.dx == 0)a.x = (flr(8*(a.x+a.cx)+.5) - 8*a.cx) * .125
    if(a.dy == 0)a.y =  flr(8 * a.y + .5) * 0.125

    --timers
    a.t += 1

    --debug.f_t = a.f_t

    debug.xy = tostr(a.x)..','..tostr(a.y)
end


function update_player(a)

    --debug.r = a.r
    --input
    if btn(➡️) and not btn(⬅️) then
		a.d = 1
        --if btnd(1) and (a.standing or a.leap) then
        --    a.dx = 1.5 * a.vx
        --    if(a.standing)a.state = 'sprinting'
        --else
            a.r *= I
            a.dx = a.vx * (1-a.r)
            if(a.standing)a.state = 'walking'
        --end
	elseif(btn(⬅️))and not btn(➡️) then
		a.d = -1
        --if  btnd(0) and (a.standing or a.leap) then
        --    a.dx = -1.5 * a.vx
        --    if(a.standing)a.state = 'sprinting'
        --else
            a.r *= I
            a.dx = -a.vx * (1-a.r)
            if(a.standing)a.state = 'walking'
        --end
    else
        a.r = 1
    end

    --debug.abs_dx = abs(a.dx)

    if btn(⬆️) then
        if a.standing then
            --begin jump
            a.dy = -a.vy
            a.jump_t = a.jump_max
            if(a.state == 'sprinting')a.leap = true
        elseif a.state == 'falling' and a.jump_t > 0 then
            a.jump_t -= 1
            a.dy = -a.vy
        end
    else
        a.leap = false
        a.jump_t = 0
    end

    if btn(⬇️) and a.standing then
        a.decending = true
    else
        a.decending = false
    end

    debug.decending = a.decending
    --debug.leap = a.leap
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
        else --> going down
            a.frame = abs(a.dx) > 0 and 51 or 52
        end
    elseif a.state == 'sprinting' then
        a.f_t = flr(a.f_t * 3 + 1.5) / 3 --> three ticks per frame
        a.frame = 49 + flr(a.f_t%4)
        if(a.f_t % 4 == 3)sfx(0) --> tip tap
        a.f_y = a.walking_y[flr(a.f_t%4)+1]
        if abs(a.dx) <= 1.25 * a.vx then
            -- change to walking
            a.sprinting = false
            a.state = 'walking'
        end
    elseif a.state == 'walking' then
        a.f_t = flr(a.f_t * 4 + 1.5) / 4 --> four ticks per frame
        if(a.f_t % 4 == 3)sfx(0) --> tip tap
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
    --debug.frame = a.frame
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
        a.leap = false
        --debug.side = true
    else
        --debug.side = false
    end
end


function collide_up(a, d)
    local y1 = a.y+a.dy-a.h
    if (solid(a.x-a.w*.5+a.dx, y1) or solid(a.x+a.w*.5-E+a.dx, y1)) then
        -- search up for collision point
        while ( not (solid(a.x-a.w*.5+a.dx, a.y-a.h-E) or solid(a.x+a.w*.5-E+a.dx, a.y-a.h-E))) do
            a.y = a.y - E
        end

        a.dy=0
        a.jump_t = 0
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
        --debug.solid_down = true
        --snap down
        while not (solid(xl, a.y+E) or solid(xr, a.y+E)) do
            a.y += E
        end
        a.y = flr(8*a.y+.5)/8

        if(a.state == 'falling') then
            a.state = abs(a.dx) < VX and 'still' or 'walking'
            if(a.dy > 0.2)sfx(0)
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
            if(a.dy > 0.2)sfx(0)
        end
        a.standing=true
        a.decending=false
        a.dy = 0
    else
        a.state = 'falling'
        a.standing = false
        --debug.solid_down = false
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
    local x, dx = update_system(camera_system, player.x)
    if abs(dx) > MV then
        camera_x = x
    end
    camera_x = mid(8, camera_x , WW-8)
    camera_system.y = camera_x
end


function _draw()
    pal(alt_colors,1)
	cls(13)
    camera(8*camera_x-64, 0)
    map()
	pal(alt_colors,1)
    foreach(actors, draw_actor)

    --debug
    camera(0,0)
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