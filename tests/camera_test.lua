--camera test
--sam westerlund
--25.3.24

function _init()
	CAMERA_F = 0.01 --camera dynamics
	CAMERA_Z = 1
	CAMERA_R = 0

	CAMERA_MIN_V = 0.32
	CAMERA_LOCK_V = 0.25

	SLOWDOWN = 1

	x = 64
	camera_x = make_camera_axis(x)
	tx = 0
	t = 0
	n = 400

	debug = {}
end

function _update60()
	t += 1
	t %= SLOWDOWN
	debug.t = t
	debug.work = t==0
	if t>0 then return end

	tx+=1
	--x += 1.78* flr(-sin(tx/n)+.5)
	x += 1.78* -sin(tx/n)
	update_camera_axis(camera_x, x)
end

function _draw()
	cls()

	--camera_x.pos = x
	--camera(flr(camera_x.pos +.5) - 64)
	camera(camera_x.pos +.5 - 64)
	--camera(x - 64.5)
	map()
	print(x)
	pset(x+.5, 64, 7)
	spr(1, x+.5, 64)

	camera(-1,-1)
	for k,v in pairs(debug) do
		print(k..': '..tostr(v))
	end
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

function update_camera_axis(c, p)
	local target_vel = p - c.target_pos
	c.target_pos = p

	if abs(target_vel) > CAMERA_MIN_V
	and abs(c.vel - target_vel) < CAMERA_LOCK_V then
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