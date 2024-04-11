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
            a.state = 'falling'
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

        a.state = 'falling'
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

	--background
	cls(BG)

	--foreground
	pal(12, 0,0) --> blue drawn as black
    camera(camera_x.pos-63.5, camera_y.pos-63.5)
    color(10)
    print(info_string, info_x, info_y)
    map()

	--actors
    if (HITBOX) foreach(actors, draw_hitbox)
    foreach(actors, draw_actor)

    --pset(camera_x.pos+.5, camera_y.pos+.5,7)

    --debug
    camera(0,0)
    cursor(1,1)
    color(10)
    print('v'..VERSION)
    if DEBUGGING then
        for k,v in pairs(debug) do
            print(k..': '..tostring(v))
        end
    end
end


-- *------------------*
-- | player functions |
-- *------------------*

