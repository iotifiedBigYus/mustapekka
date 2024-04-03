--camera functions
--3.4.2024

function make_camera()
    camera_x = make_camera_axis(8*player.x, 8*(world_x+8), 8*(world_x+world_w-8))
    camera_y = make_camera_axis(8*player.y, 8*(world_y+8), 8*(world_y+world_h-8))

	--debug.maxy = 8*(world_y+world_h-8)
	--debug.miny = 8*(world_y+8)
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

	if (c.bounded) c.pos = mid(min, c.pos, max)
	
	return c
end


function update_camera()
    update_camera_axis(camera_x, 8*(player.x-sgn(player.d)*player.cx))
    update_camera_axis(camera_y, 8*player.y)
end


function update_camera_axis(c, p)
	local target_vel = p - c.target_pos
	c.target_pos = p

	if abs(c.vel) > CAMERA_MIN_V and abs(c.vel - target_vel) < CAMERA_LOCK_V then
	--if abs(c.vel - target_vel) < CAMERA_LOCK_V then
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