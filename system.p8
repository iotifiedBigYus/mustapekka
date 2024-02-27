pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--integrator
--sam westerlund
--12.2.2024

function new_sys(f, d, r, x, y)
	--frequency: natural frequency

	--damping: how the system comes to settle at the target
	--damping = 0: system is undamped, never settles
	--0<damping<1: system is underdamped.
	--damping = 1: critical damping
	--damping >= 1: system does not vibrate

	--response: inital response of the system
	--response = 0: system takes time to accelerate
	--response > 0: reacts immediately
	--response > 1: system will overshoot
	--response < 0: system will anitcipate
	--response = 2 is typical for mechanical systems

	local sys = {}

	--compute constants
	local pi = 3.1415
	local a_p = 0.5/pi/f --> angular period
	sys.k1 = 2*d*a_p
	sys.k2 = a_p*a_p
	sys.k3 = r*d*a_p

	--init variables
	int.l_x = p_x or 0
	int.l_y = p_y or 0
	int.x = 0
	int.y = 0
	int.dx = 0
	int.dy = 0
	int.ddx = 0
	int.ddy = 0
	
	return int
end


function update_int(int, x, y)
	local l_dx = x - int.l_x
	local l_dy = y - int.l_y
	
	int.l_x = x
	int.l_y = y
end


function c:update(dt, nextleaderposition, nextleadervelocity)
	assert(dt, 'integrator: no dt given')
	assert(nextleaderposition, 'integrator: no leaderposition given')

	if nextleadervelocity then
		self.leadervelocity = nextleadervelocity 
	else
		self.leadervelocity = (nextleaderposition - self.leaderposition) / dt
	end

	if followervelocity then
		self.followervelocity = followervelocity
	end

	self.leaderposition = nextleaderposition
	--local k2stable = self.k2
	--local k2stable = math.max(self.k2, 1.1 * dt * dt * 0.25 + dt * self.k1 * 0.5) --> for eigenvalues too large
	local k2stable = math.max(self.k2, dt * dt * 0.5 + dt * self.k1 * 0.5, dt * self.k1) --> for eigenvalues too large or small
	self.followerposition = self.followerposition + (dt * self.followervelocity)
	self.followeracceleration = (self.leaderposition + (self.k3 * self.leadervelocity) - self.followerposition - (self.k1 * self.followervelocity)) / k2stable
	self.followervelocity = self.followervelocity + (dt * self.followeracceleration)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
