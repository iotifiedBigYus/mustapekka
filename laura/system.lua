--system (integrator)
--sam westerlund
--12.2.2024

--source: https://www.youtube.com/watch?v=KPoeNZZ6H4s&t=428s
--makes things move with momentum. Makes things bouncy, slow to react, or vibrate.

function new_system(f, z, r, a0)
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
	local p = 0.5/3.1415/f --> angular period
	sys.k1 = 2*z*p
	sys.k2 = p*p
	sys.k3 = r*z*p

	--init variables
	sys.a = a0 or 0
	sys.b = a0 or 0
	sys.db = 0
	
	return sys
end


function update_system(sys, a)
	local da = a - sys.a
	sys.a = a
    sys.b += sys.db
    sys.db += (a + sys.k3 * da - sys.b - sys.k1 * sys.db) / sys.k2

	return sys.b, sys.db
end