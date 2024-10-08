--unstuck
--8.10.24
--sam westerlund

function _init()
	a = {
		x = 8,
		y = 8,
		w2 = 3/8,
		h = 6/8
	}

	speed = 0.1/32
	scale = 8

	actors = {a}

	debug = {}
end


function _update60()
	if btn(0) then a.x -= speed*scale end
	if btn(1) then a.x += speed*scale end
	if btn(2) then a.y -= speed*scale end
	if btn(3) then a.y += speed*scale end

	update_status(a)

	debug.ax = a.x
end


function update_status(a)
	update_corners(a)


	local xl, xc, xr = a.x - a.w2, a.x,          a.x + a.w2
	local yt, yc, yb = a.y - a.h,  a.y - a.h*.5, a.y
	local w2 = a.w2
	local h2 = a.h / 2

	dir_x, dir_y = 0, 0


	ax_ = xl % 1
	ay_ = yt % 1

	x_ = (xc + .5) % 1 - .5
	y_ = (yc + .5) % 1 - .5


	scootch = function(x, d)
		return d * ( flr(d * x + w2) + w2 ) 
	end

	scootch_diff = function(x, d)
		return scootch(x,d) - x * d * d
	end


	push_x, push_y = 0,0

	push_x_t = scootch_diff(xc, corner_a - corner_b)
	push_x_b = scootch_diff(xc, corner_c - corner_d)
	push_y_l = scootch_diff(yc, corner_a - corner_c)
	push_y_r = scootch_diff(yc, corner_b - corner_d)

	local sum = corner_a + corner_b + corner_c + corner_d

	if sum == 1 then
		-- a / b / c / d
		local x = push_x_t + push_x_b
		local y = push_y_l + push_y_r
		local bool = x * x < y * y and 1 or 0
		debug.bool = bool
		dir_x = x * bool
		dir_y = y * (1 - bool)


	elseif sum == 2 then
		if push_x_t * push_x_b > 0 then
			-- ac / bd
			dir_x = push_x_t
		elseif push_y_l * push_y_r > 0 then
			-- ab / cd
			dir_y = push_y_l
		elseif corner_a - corner_b > 0 then
			-- ad
			local a = push_x_t - push_y_r
			local b = push_x_b - push_y_l
			if a * a < b * b then
				dir_x = push_x_t
				dir_y = push_y_r
			else
				dir_x = push_x_b
				dir_y = push_y_l
			end
		elseif corner_a - corner_b < 0 then
			-- ad
			local a = push_x_t + push_y_l
			local b = push_x_b + push_y_r
			if a * a < b * b then
				dir_x = push_x_t
				dir_y = push_y_l
			else
				dir_x = push_x_b
				dir_y = push_y_r
			end
		end
		--]]
	elseif sum == 3 then
		dir_x = push_x_t + push_x_b
		dir_y = push_y_l + push_y_r
	end
end


function update_corners(a)
	local xl, xc, xr = a.x - a.w2, a.x,          a.x + a.w2
	local yt, yc, yb = a.y - a.h,  a.y - a.h*.5, a.y

	corner_a = solid(xl, yt) and 1 or 0
	corner_b = solid(xr, yt) and 1 or 0
	corner_c = solid(xl, yb) and 1 or 0
	corner_d = solid(xr, yb) and 1 or 0
end

function solid(x,y)
	return fget(mget(x,y),0)
end


function _draw()
	cls()
	draw_ghost(a)
	map()
	foreach(actors, draw_actor)

	draw_status()

	--debug
	for k,v in pairs(debug) do
		print(tostr(k)..": "..tostr(v))
	end
end

function draw_ghost(a)
	color(10)
	rect_scale(a.x-a.w2+dir_x,a.y-a.h+dir_y,a.x+a.w2+dir_x,a.y+dir_y)
	color()
end

function draw_status()
	local x, y, w, h = 10, 100, 16, 16
	color(10)
	rect(x,y,x+w,y+h)
	color()


	mark_corner = function(x,y)
		circfill(x,y,2)
	end

	draw_direction = function(x0,y0,dx,dy)
		line(x0, y0, x0+dx, y0+dy)
	end

	if corner_a == 1 then mark_corner(x,y) end
	if corner_b == 1 then mark_corner(x+w,y) end
	if corner_c == 1 then mark_corner(x,y+h) end
	if corner_d == 1 then mark_corner(x+w,y+h) end

	--move direction
	draw_direction(x + w/2,y + h/2,dir_x*w,dir_y*w)

	y -= 2*h

	--top
	draw_direction(x + w/2, y,       push_x_t*w, 0)
	draw_direction(x + w/2, y + h,   push_x_b*w, 0)
	draw_direction(x,       y + h/2, 0,            push_y_l*w)
	draw_direction(x + h,   y + h/2, 0,            push_y_r*w)
end

function draw_debug()
	--debug
	for k,v in pairs(debug) do
		print(tostr(k)..": "..tostr(v))
	end
end

function draw_actor(a)
	rect_scale(a.x-a.w2,a.y-a.h,a.x+a.w2,a.y)
end

function rect_scale(x1, y1, x2, y2)
	rect(pos_scale(x1),pos_scale(y1),pos_scale(x2),pos_scale(y2)) 
end

function pos_scale(v)
	return v*scale
end