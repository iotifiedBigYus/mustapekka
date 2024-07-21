--path
--sam westerlund
--19.8.2024

--sources:
--lazydevs, making a rouge-like ep. 19
--https://www.youtube.com/watch?v=zA1uMY5f4Js
--Atrejo, (devlog 2.5) how to PLATFORMER AI and pathfinding
--https://www.youtube.com/watch?v=RPB6LplBQK8


function make_path_node(x,y,on_ground,col)
	local node = {
		x=x, y=y, neighbors={}, on_ground = on_ground,
		col=col, direction = nil
	}
	add(path_nodes, node)
	path_node_matrix[y][x] = node

	return node
end


function init_path_nodes()

	path_nodes = {}
	path_node_matrix = {}
	local floating_path_nodes = {}
	
	-- make nodes on ground
	for y = world_y, world_y+world_h-1 do
		path_node_matrix[y] = {}
		for x = world_x, world_x+world_w-1 do
			--path_node_matrix[y][x] = nil
			if not solid(x,y) and (solid(x,y+1) or platform(x,y+1)) then
				local node = make_path_node(x,y,true,11)
				if (platform(x,y+1)) add(floating_path_nodes, node)
			end
		end
	end

	local dx = {-1,1,0,0}
	local dy = {0,0,-1,1}

	-- add floating nodes
	for node in all(path_nodes) do
		local x,y = node.x, node.y

		for i = 1,2 do
			x2, y2 = x+dx[i], y+dy[i]
			local node2 = path_node_matrix[y2][x2]
			if not node2 and node.on_ground and not solid(x2,y2) then
			--elseif node.on_ground and not solid(x2,y2) then
				node2 = make_path_node(x2,y2,false,9)
				add(floating_path_nodes, node2)
			end
		end
	end

	-- connect neighbors
	for node in all(path_nodes) do
		local x,y = node.x, node.y

		local node2 = path_node_matrix[y][x+1]
		if node2 then
			node.neighbors[2] = node2
			node2.neighbors[1] = node
		end
	end

	-- connect floating nodes down
	for node in all(floating_path_nodes) do
		local x2,y2 = node.x, node.y+1
		local checking = true
		while checking and not is_outside(x2,y2) do
			local node2 = path_node_matrix[y2][x2]
			if node2 then
				checking = false
			else
				node2 = make_path_node(x2,y2, false, 8)
			end

			node.neighbors[4] = node2
			node2.neighbors[3] = node

			y2 += 1
		end
	end
	--]]
end


function update_path(target_x, target_y)
	local x0 = flr(target_x)
	local y0 = flr(target_y)

	local target_node = path_node_matrix[y0][x0]
	while not target_node do
		y0 += 1
		target_node = path_node_matrix[y0][x0]
	end

	check_nodes = {target_node}

	i = 0
	for _,n in ipairs(target_node.neighbors) do
		i += 1
	end
	debug.neigh = i
end


function draw_path_nodes()
	for node in all(path_nodes) do
		for neigh in all(node.neighbors) do
			local dx = neigh.x-node.x
			local dy = neigh.y-node.y
			line(node.x*8,node.y*8, node.x*8+dx*4, node.y*8+dy*4, node.col)
		end
	end

	for node in all(path_nodes) do
		pset(node.x*8, node.y*8, node.col)
		--print("'", node.x*8, node.y*8, node.col)
	end
end


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