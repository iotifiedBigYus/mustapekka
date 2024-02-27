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