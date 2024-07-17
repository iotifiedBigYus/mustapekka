-- utilities
-- sam westerlund
-- 8.7.2024


function find_sprites(spr, single)
	local coords = {}

	for x = world_x, world_x+world_w-1 do
		for y = world_y, world_y+world_h-1 do
			if mget(x,y) == spr then
				if (single) return x, y
				add(coords, {x, y})
			end
		end
	end
	
	if (single) return 0, 0
	return coords
end


function clear_cell(x, y)
	add(cleared_cells, {x,y,mget(x,y)})
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


function reset_cells()
	for c in all(cleared_cells) do
		mset(unpack(c))
	end

	cleared_cells = {}
end


function pos8(x)
	return .5 + 8*x
end


function snap8(val, shift)
	shift = shift or 0
	return flr(8*(val+shift)+.5) * .125 - shift
end


function approach(x, target, max_delta)
	target = target or 0
	max_delta = max_delta or 1
	return x < target and min(x + max_delta, target) or max(x - max_delta, target)
end


function dda(x1, y1, x2, y2)
	--digital differential analysis
	--source: youtu.be/NbSee-XM7WA?si=SdPCtOXWTj_hdpCn
	local map_x = flr(x1)
	local map_y = flr(y1)
	local dx = x2 - x1
	local dy = y2 - y1
	local sx = sqrt(1 + dy / dx * dy / dx)
	local sy = sqrt(1 + dx / dy * dx / dy)
	local step_x = sgn(dx)
	local step_y = sgn(dy)
	local ray_x = dx < 0 and (x1 - map_x) * sx or (map_x + 1 - x1) * sx
	local ray_y = dy < 0 and (y1 - map_y) * sy or (map_y + 1 - y1) * sy
	local dist = 0
	local len = sqrt(dx * dx + dy * dy)
	local found = false

	while not found and dist < len do
		if sx != 0 and (sy == 0 or ray_x < ray_y) then
			map_x += step_x
			dist = ray_x
			ray_x += sx
		else
			map_y += step_y
			dist = ray_y
			ray_y += sy
		end

		if solid(map_x, map_y) then
			found = true
		end
	end
	
	local blocked = found and dist < len
	local bx = blocked and x1 + dist / len * dx or x2
	local by = blocked and y1 + dist / len * dy or y2

	return blocked, min(dist, len), bx, by, step_x
end