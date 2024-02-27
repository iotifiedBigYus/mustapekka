--laura
--sam westerlund
--23.2.24

c = {[0]=0,0,128+1,3+128,
	 4+128,128,6,7,
	 8,128+9,10,11,
	 13,128+13,14,128+15}

max_actors = 128
player_x = 4/8
player_y = 8
debug = {t=0}
debugging = true
freeze =  false
slowdown = 1

E = .01 --> epsilon
WW = 16
WH = 16
t = 0

function _init()
    btnd(1)
	actors = {}
    make_player(player_x,player_y,1)

	pal(c,1)
end


function make_player(x, y, d)
    --?? pl.pal
    pl = make_actor(1, x, y, d) --> kind: 1
    pl.walking_y = {0,-.125,-.125,0}
    pl.sprinting = false
    pl.charge = 0
    pl.super  = 0
    pl.score  = 0
    pl.bounce = 0 --> bounce is removed
    pl.delay  = 0
    pl.id     = 0 -- player 1
    pl.pal    = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
    return pl
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
    a.cx    = .4375 --> sprite center x
    a.vx    = .125
    a.vy    = .2
	a.ddy   = .02 -- gravity
	a.d     = d --pickup 1, monster -1 (normalized looking x)
    a.w     = .625
    a.h     = 1
	--a.bounce   = .8
	a.frame = 1
	--a.f0    = 0 --default frame (sprite)
    a.f_t   = 0
    a.f_y   = 0
	a.t		= 0
    a.state = 'still'
	a.standing = false
    a.jump_t = 0
    a.jump_max = 10
    a.leap = false
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
end


function update_actor(a)
    if(a.kind == 1)update_player(a)

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

    debug.standing = a.standing

    --moving
    a.x += a.dx
    a.y += a.dy

    --friction & gravity
    a.dx *= .9
    if abs(a.dx) < .04 then
        a.dx = 0
    end
    a.dy += a.ddy

    --snapping
    if(a.dx == 0)a.x = (flr(8*(a.x+a.cx)+.5) - 8*a.cx) * .125
    if(a.dy == 0)a.y =  flr(8 * a.y + .5) * 0.125

    --timers
    a.t += 1

    debug.f_t = a.f_t

    debug.xy = tostr(a.x)..','..tostr(a.y)
    debug.xy8 = tostr(8*(a.x)%1)..','..tostr(8*(a.y)%1)
    --debug.y = a.y
end


function update_player(a)
    --input
    if btn(➡️) and not btn(⬅️) then
		a.d = 1
        if btnd(1) and (a.standing or a.leap) then
            a.dx = 1.5 * a.vx
            if(a.standing)a.state = 'sprinting'
        else
            a.dx = a.vx
            if(a.standing)a.state = 'walking'
        end
	elseif(btn(⬅️))and not btn(➡️) then
		a.d = -1
        if  btnd(0) and (a.standing or a.leap) then
            a.dx = -1.5 * a.vx
            if(a.standing)a.state = 'sprinting'
        else
            a.dx = -a.vx
            if(a.standing)a.state = 'walking'
        end
    end

    debug.abs_dx = abs(a.dx)

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

    update_body(a)

    debug.leap = a.leap
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
        a.f_t = 0
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
        if abs(a.dx) < .2 and a.f_t%4 == 0 then
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
    debug.frame = a.frame
end


function collide_side(a)
    --> true if touching
    local d = a.dx ~= 0 and sgn(a.dx) or a.d
    local x1 = a.x + a.dx + d * (.5*a.w)
    local xe = d > 0 and 0 or -E --> stay outside edges
    --local xe = d > 0 and -E or 0 --> stay inside edges
    if solid_side(x1+xe,a.y-E) or solid_side(x1+xe,a.y-a.h) then
        -- hit wall
        -- search for contact point
        while not (solid_side(a.x+d*(a.w*.5+E)+xe, a.y-E) or solid_side(a.x+d*(a.w*.5+E)+xe, a.y-a.h)) do
            a.x += sgn(a.dx) * E
        end
        a.x = (flr( 8*(a.x+a.cx)+.5) - 8*a.cx) * .125
        a.dx = 0 --> do this after contact point, so that sgn(0) does not happen
        a.leap = false
        debug.side = true
        -- bounce	
        --if (a.super == 0) then
        --    a.dx = a.dx * -.5
        --end
        --if (a.kind == 3) then
        --    a.d = a.d * -1
        --    a.dx=0
        --end
    else
        debug.side = false
    end
end


function collide_up(a, d)
    local y1 = a.y+a.dy-a.h
    if (solid_bottom(a.x-a.w*.5, y1) or solid_bottom(a.x+a.w*.5-E, y1)) then
        -- search up for collision point
        while ( not (solid_bottom(a.x-a.w*.5, a.y-a.h-E) or solid_bottom(a.x+a.w*.5-E, a.y-a.h-E))) do
            a.y = a.y - E
        end

        a.dy=0
        debug.solid_up = true
        a.jump_t = 0
    else
        debug.solid_up = false

        if a.standing then
            sfx(1)
            a.standing = false
        end
        a.state = 'falling'
    end
end


function collide_down(a)
    if (solid_top(a.x-a.w*.5, a.y+a.dy, a.dy) or solid_top(a.x+a.w*.5-E, a.y+a.dy, a.dy)) then
        debug.solid_down = true
        -- bounce
        --if (a.bounce > 0 and a.dy > .2) then
        --    a.dy = a.dy * -a.bounce
        --else
        --snap down
        a.y = ceil(a.y)
        if(a.state == 'falling') then
            a.state = 'still'
            if(a.dy > 0.2)sfx(2)
        end
            a.standing=true
            a.dy = 0
        --end
        --pop up even if bouncing
        --while(solid(a.x-.2,a.y-.1)) do
        --    a.y -= .01
        --end
        --while(solid(a.x+.5*a.w,a.y-.1)) do
        --    a.y -= .05
        --end   
    else
        a.standing = false
        debug.solid_down = false
    end
end

function solid(x, y)
	if (x < 0 or x >= 128 ) then
        return true
    end
				
	val = mget(x, y)
	return fget(val, 1)
end


function solid_side(x, y)
	if (x < 0 or x >= WW ) then
        return true
    end
				
	val = mget(x, y)
	return fget(val, 1)
end


function solid_top(x, y, dy)
	val = mget(x, y)
    if(fget(val, 1))return true
    if(fget(val, 2) and ceil(y-dy) == flr(y))return true
	return false
end


function solid_bottom(x, y)
	if (x < 0 or x >= 128 ) then
        return true
    end
				
	val = mget(x, y)
	return fget(val, 1)
end


function _draw()
	cls(13)
	map(0,0)
	pal(c,1)
    foreach(actors, draw_actor)

    --debug
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