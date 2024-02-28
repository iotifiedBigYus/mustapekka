pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--laura
--sam westerlund
--23.2.24

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

    print('v0.1.1')
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


--btnd (double press activated button)
--sam westerlund
--23.2.24

btnd_state = {
    0,0,0,0,0,0
}
btnd_timer = {
    0,0,0,0,0,0
}
btnd_delay = 10


function update_btnd()
    for n = 1,6 do
        local s = btnd_state[n]
        if btn(n-1) then
            if s == 0 then
                btnd_state[n] = 1
                btnd_timer[n] = btnd_delay
            elseif s == 1 then
                btnd_timer[n] -= 1
                if btnd_timer[n] == 0 then
                    btnd_state[n] = 2
                end
            elseif s == 3 then
                btnd_state[n] = 4
            end
        else
            if s == 2 then
                btnd_state[n] = 0
            elseif s == 1 then
                btnd_state[n] = 3
            elseif s == 3 then
                btnd_timer[n] -= 1
                if btnd_timer[n] == 0 then
                    btnd_state[n] = 0
                end
            elseif s == 4 then
                btnd_timer[n] = 0
                btnd_state[n] = 0
            end
        end
    end
end

function btnd(i)
    return btnd_state[i+1] == 4
end


--system (integrator)
--sam westerlund
--12.2.2024

--source: https://www.youtube.com/watch?v=KPoeNZZ6H4s&t=428s
--makes things move with momentum. Makes things bouncy, slow to react, or vibrate.

function new_system(f, z, r, x0)
	--f (frequency): natural frequency

	--z (damping): how the system comes to settle at the target
	--damping = 0: system is undamped, never settles
	--0<damping<1: system is underdamped.
	--damping = 1: critical damping
	--damping >= 1: system does not vibrate

	--r (response): inital response of the system
	--response = 0: system takes time to accelerate
	--response > 0: reacts immediately
	--response > 1: system will overshoot
	--response < 0: system will anitcipate
	--response = 2 is typical for mechanical systems

	local sys = {}

	--compute constants
	local a = 0.5/3.1415/f --> angular period
	sys.k1 = 2*z*a
	sys.k2 = a*a
	sys.k3 = r*z*a

	--init variables
	sys.x = x0 or 0
	sys.y = x0 or 0
	sys.dy = 0
	
	return sys
end


function update_system(sys, x)
	local dx = x - sys.x
	sys.x = x
    sys.y += sys.dy
    sys.dy += (x + sys.k3 * dx - sys.y - sys.k1 * sys.dy) / sys.k2

	return sys.y, sys.dy
end



__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbb4444444444444444111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbb4444444444444444100005110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4bbb44bb4b4bbb444444444444444454100051510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44b444b4444bb4444444444444444444100515010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
444444444444b4444444444445544444105150010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444445544444151500010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444115000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333332222222222222222111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333332222222222222222122225110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
23332233232333222222222222222212122251510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22322232222332222222222222222222122515210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222232222222222221122222125152210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222221122222151522210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222115222210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222222222222222222222222222111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00551000005510000055100000551000005510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
005ff000005ff000005ff000005ff000005ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
051ff100051ff100051ff100051ff100051ff1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaa000faaaaaf0faaaaaf000aaa00000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaa0000aaa00000aaa000faaaaaf0faaaaaf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0faaaf0000aaaf0000aaaf0000aaa00000aaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00f0f00000f0090000f0090009f0f00009f0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00909000009000000900000000000900000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
6t6t666ttttt66tttttt66tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt
6t6t6t6tttttt6ttttttt6tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt
6t6t6t6tttttt6ttttttt6tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt
666t6t6tttttt6ttttttt6tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt
t6tt666tt6tt666tt6tt666ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt
tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt
tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt
tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt
tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt3333333333333333
tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt3333333333333333
ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttk3k333kkk333kk33
ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttkkk33kkkkk3kkk3k
ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttkkkk3kkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt00000000ttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt0ttttg00ttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt0tttg0g0ttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt0ttg0gt0ttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt0tg0gtt0ttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt0g0gttt0ttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt00gtttt0ttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttt00000000ttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkk
tttttttt0000000000000000tttttttttttttttt3333333333333333tttttttttttttttttttttttttttttttttttttttt3333333333333333kkkkkkkkkkkkkkkk
tttttttt0ttttg000ttttg00tttttttttttttttt3333333333333333tttttttttttttttttttttttttttttttttttttttt3333333333333333kkkkkkkkkkkkkkkk
tttttttt0tttg0g00tttg0g0ttttttttttttttttk333kk33k333kk33ttttttttttttttttttttttttttttttttttttttttk333kk33k3k333kkkkkkkkkkkkkkkkgk
tttttttt0ttg0gt00ttg0gt0ttttttttttttttttkk3kkk3kkk3kkk3kttttttttttttttttttttttttttttttttttttttttkk3kkk3kkkk33kkkkkkkkkkkkkkkkkkk
tttttttt0tg0gtt00tg0gtt0ttttttttttttttttkkkkkkkkkkkkkkkkttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkk3kkkkkkkkkkkkggkkkkk
tttttttt0g0gttt00g0gttt0ttttttttttttttttkkkkkkkkkkkkkkkkttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkggkkkkk
tttttttt00gtttt000gtttt0ttttttttttttttttkkkkkkkkkkkkkkkkttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttt0000000000000000ttttttttttttttttkkkkkkkkkkkkkkkkttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttthhhhhh0hhhhhhhhhttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttth00hhhhhhhhhhhhhttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttth00hhhhhhhhhhhhhttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttttttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkktttttttgg0ttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkgktttttttgvvttttttttttttttttttttttttttttttkkkkkkkkkkkkkkgkkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkttttttg0vv0tttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttkkkkkkkkkggkkkkktttttvaaaaavttttttttttttttttttttttttttttkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttkkkkkkkkkggkkkkktttttttaaattttttttttttttttttttttttttttttkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkktttttttaaavtttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkktttttttvttptttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttt0000000000000000tttttttttttttttthhhhhhhhhhhhhhhhtttttttptttttttttttttttttttttttt33333333kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttt0ttttg000ttttg00tttttttttttttttthhhhhhhhhhhhhhhhtttttttttttttttttttttttttttttttt33333333kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttt0tttg0g00tttg0g0tttttttttttttttthhhhhh0hhhhhhhhhttttttttttttttttttttttttttttttttk3k333kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttt0ttg0gt00ttg0gt0tttttttttttttttthhhhhhhhhhhhhhhhttttttttttttttttttttttttttttttttkkk33kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttt0tg0gtt00tg0gtt0tttttttttttttttth00hhhhhhhhhhhhhttttttttttttttttttttttttttttttttkkkk3kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttt0g0gttt00g0gttt0tttttttttttttttth00hhhhhhhhhhhhhttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttt00gtttt000gtttt0tttttttttttttttthhhhhhhhhhhhhhhhttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
tttttttt0000000000000000tttttttttttttttthhhhhhhhhhhhhhhhttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
ttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkktttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
ttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkktttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
ttttttttttttttttttttttttttttttttttttttttkkkkkkgkkkkkkkkktttttttttttttttttttttttttttttttthhhhhhhhhhhhhh0hhhhhhhhhhhhhhhhhhhhhhhhh
ttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkktttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
ttttttttttttttttttttttttttttttttttttttttkggkkkkkkkkkkkkktttttttttttttttttttttttttttttttthhhhhhhhh00hhhhhhhhhhhhhhhhhhhhhhhhhhhhh
ttttttttttttttttttttttttttttttttttttttttkggkkkkkkkkkkkkktttttttttttttttttttttttttttttttthhhhhhhhh00hhhhhhhhhhhhhhhhhhhhhhhhhhhhh
ttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkktttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
ttttttttttttttttttttttttttttttttttttttttkkkkkkkkkkkkkkkktttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
tttttttttttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhtttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
tttttttttttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhtttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
tttttttttttttttttttttttttttttttttttttttthhhhhhhhhhhhhh0htttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhhhhhhhhhhhhhhh0hhhhhhhhh
tttttttttttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhtttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
tttttttttttttttttttttttttttttttttttttttthhhhhhhhh00hhhhhtttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhhhhhhhhhh00hhhhhhhhhhhhh
tttttttttttttttttttttttttttttttttttttttthhhhhhhhh00hhhhhtttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhhhhhhhhhh00hhhhhhhhhhhhh
tttttttttttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhtttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
tttttttttttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhtttttttttttttttttttttttttttttttthhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
333333333333333333333333333333333333333333333333333333333333333333333333000000003333333333333333kkkkkkkk00000000kkkkkkkkkkkkkkkk
3333333333333333333333333333333333333333333333333333333333333333333333330hhhhg003333333333333333kkkkkkkk0hhhhg00kkkkkkkkkkkkkkkk
k333kk33k3k333kkk333kk33k333kk33k3k333kkk333kk33k3k333kkk3k333kkk333kk330hhhg0g0k3k333kkk333kk33kkkkkkkk0hhhg0g0kkkkkkkkkkkkkkkk
kk3kkk3kkkk33kkkkk3kkk3kkk3kkk3kkkk33kkkkk3kkk3kkkk33kkkkkk33kkkkk3kkk3k0hhg0gh0kkk33kkkkk3kkk3kkkkkkkkk0hhg0gh0kkkkkkkkkkkkkkkk
kkkkkkkkkkkk3kkkkkkkkkkkkkkkkkkkkkkk3kkkkkkkkkkkkkkk3kkkkkkk3kkkkkkkkkkk0hg0ghh0kkkk3kkkkkkkkkkkkkkkkkkk0hg0ghh0kkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk0g0ghhh0kkkkkkkkkkkkkkkkkkkkkkkk0g0ghhh0kkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk00ghhhh0kkkkkkkkkkkkkkkkkkkkkkkk00ghhhh0kkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk00000000kkkkkkkkkkkkkkkkkkkkkkkk00000000kkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkkkkkkgk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkggkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkggkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkgkkkkkkkgkkkkkkkkkkkkkkkkkkkkkkkgkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhh0hhhhhhhhhhhhhhh0hhhhhhhhhhhhhhhhhkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhkkkkkkkkkkkkkkkk
kkkkkkkkkggkkkkkkggkkkkkkkkkkkkkkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkkkkkkkkkkh00hhhhhhhhhhhhhh00hhhhhhhhhhhhhhhhhhhhhkkkkkkkkkkkkkkkk
kkkkkkkkkggkkkkkkggkkkkkkkkkkkkkkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkkkkkkkkkkh00hhhhhhhhhhhhhh00hhhhhhhhhhhhhhhhhhhhhkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhh
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhh
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkgkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhhhhhhh0hhhhhhh0h
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhh
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhh00hhhhhh00hhhhh
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhh00hhhhhh00hhhhh
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhh
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkhhhhhhhhhhhhhhhhhhhhhhhh
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkgkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkgkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkgkkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkgkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkgkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkggkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk
kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk

__gff__
0000000000000000000000000000000002020202040000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000111024241111000000000000000014140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000001400000000121223221213000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000121222221312100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0014140000101000000000001011121324241212120000000014140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000232200000000001212121223221212121100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000121300000000001213121222231212131200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0014140000232200000000111212121224241212121214000000000014140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000131200000000222322222222222222232200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000222300000000222222232222222223222200000000000000000014000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011101011101111102411101224121224122412121010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212122212121222121322122212131212222021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213131212131212122322232222121223222213121212222223211110241011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121312121222232322121212121213222322221312221213000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121312121213121212121213121222222223222222222222222223221312000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212131212121212121212131212121212131212121213121213121212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
910200000065000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
910100001a0501a0501a0501b0501c0501e05021150261502e1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200000065000655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
