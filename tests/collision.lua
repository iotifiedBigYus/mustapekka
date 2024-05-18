--collision test
--sam westerlund
--18.5.24

function _init()
	a1 = {}
	a1.x  = 64
	a1.y  = 100
	a1.w2 = 20
	a1.h  = 40
	a2 = {}
	a2.x  = 64
	a2.y  = 100
	a2.w2 = 20
	a2.h  = 40

	speed = 1
end

function _update60()
	if ( btn(0) )a1.x -= speed
	if ( btn(1) )a1.x += speed
	if ( btn(2) )a1.y -= speed
	if ( btn(3) )a1.y += speed
end


function get_collision_overlap(a1, a2)
	--source: https://stackoverflow.com/questions/5062833/detecting-the-direction-of-a-collision

	local b = a2.y - (a1.y - a1.h)
	local t = a1.y - (a2.y - a2.h) --> this identifier needs to be local
	local l = a1.x + a1.w2 - (a2.x - a2.w2)
	local r = a2.x + a2.w2 - (a1.x - a1.w2)

	--debug.top = (t < b and t < l and t < r )
	--debug.bottom = (b < t and b < l and b < r)
	--debug.left = (l < r and l < t and l < b)
	--debug.right = (r < l and r < t and r < b )

	if (t < b and t < l and t < r) return  0, t --top collision
	if (b < t and b < l and b < r) return  0,-b --bottom collision
	if (l < r and l < t and l < b) return  l, 0 --left collision
	if (r < l and r < t and r < b) return -r, 0 --right collision
	return 0, 0
end


function _draw()
	cls()
	x, y = get_collision_overlap(a1, a2)
	?x
	?y
	color(8)
	draw_square(a1)
	color(10)
	draw_square(a2)
end


function draw_square(a)
	rect(a.x - a.w2, a.y - a.h, a.x + a.w2, a.y)
end