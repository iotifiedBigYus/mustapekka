--path
--sam westerlund
--19.8.2024

--source: lazydevs, making a rouge-like ep. 19
--https://www.youtube.com/watch?v=zA1uMY5f4Js


function blank_map(val)
	x0 = flr(player.x)
	y0 = flr(player.y-player.h*.5)

	local m = {}
	for y = max(world_y, y0-UPDATE_LEFT), min(world_y+world_h-1, y0+UPDATE_RIGHT) do
		m[y] = {}
		for x = max(world_x, x0-UPDATE_UP), min(world_x+world_w-1, x0+UPDATE_DOWN) do
			m[y][x] = val
		end
	end

	return m
end


function draw_map(m)
	for y = max(world_y, y0-UPDATE_LEFT), min(world_y+world_h-1, y0+UPDATE_RIGHT) do
		for x = max(world_x, x0-UPDATE_UP), min(world_x+world_w-1, x0+UPDATE_DOWN) do
			print(m[y][x],x*8,y*8,8)
		end
	end
end