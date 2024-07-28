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
		col=col, target_direction = {}, height = 0
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
			x2, y2 = x+dx[i], y -- +dy[i]
			local node2 = path_node_matrix[y2][x2]
			if not node2 and not solid(x2,y2) and node.on_ground then
			--elseif node.on_ground and not solid(x2,y2) then
				node2 = make_path_node(x2,y2,false,9)
				add(floating_path_nodes, node2)
			end
		end
	end

	-- connect neighbors
	for node1 in all(path_nodes) do
		local x,y = node1.x, node1.y

		local node2 = path_node_matrix[y][x+1]
		if node2 and (node1.on_ground or node2.on_ground) then
			node1.neighbors[2] = node2
			node2.neighbors[1] = node1
		end
	end

	-- connect floating nodes down
	for node1 in all(floating_path_nodes) do
		local checking = true
		while checking and not is_outside(x2,y2) do
			local x2,y2 = node1.x,node1.y+1
			local node2 = path_node_matrix[y2][x2]

			if node2 then
				checking = false
			else
				node2 = make_path_node(x2,y2, false, 8)
			end

			node1.neighbors[4] = node2
			node2.neighbors[3] = node1

			node1 = node2
		end
	end
	--]]

	-- add heights
	for node in all(path_nodes) do
		if not node.on_ground then
			local height = 0
			local node1 = node
			repeat
				height += 1
				node1 = node1.neighbors[4]
			until not node1 or node1.on_ground

			node.height = height
		end
	end
end


function update_path(target, jump_height, fall_height)
	jump_height = jump_height or 1/0
	fall_height = fall_height or 1/0
	local x0 = flr(target.x)
	local y0 = flr(target.y - 0.5* target.h)

	-- find the node the target is on or one underneath
	local target_node = path_node_matrix[y0][x0]
	while not target_node do
		y0 += 1
		target_node = path_node_matrix[y0][x0]
	end

	-- reset directions
	for node in all(path_nodes) do
		node.direction = nil
		node.target_direction[target] = nil
	end

	-- expand from target
	local check_nodes = {target_node}
	local new_check_nodes = {}
	local flip_direction = {2,1,4,3}
	repeat
		for node in all(check_nodes) do
		local dir = node.target_direction[target]
		for i = 1,4 do
		local neigh = node.neighbors[i]
		if neigh and not neigh.target_direction[target] then
			local direct = false
			
			if i == 3 then
				-- expansion downwards, approach by jumping
				if dir != 3 then
					direct = neigh.height < fall_height
				end
			elseif i == 4 then
				-- expansion downwards, approach by jumping
				if dir != 4 then
					direct = neigh.height < jump_height
				end
			else
				direct = true
			end

			if direct then
				neigh.target_direction[target] = flip_direction[i]
				add(new_check_nodes, neigh)
			end
		end
		end
		end
		check_nodes = new_check_nodes
		new_check_nodes = {}
	until #check_nodes == 0
end


function get_path_direction(a, target)
	local x0 = flr(a.x)
	local y0 = flr(a.y - 0.5* a.h)
	local node = path_node_matrix[y0][x0]
	if node then
		return node.target_direction[target]
	end
end


function draw_path_nodes()
	for node in all(path_nodes) do
		for i = 1,4 do
			local neigh = node.neighbors[i]
			if neigh then
				local dx = neigh.x-node.x
				local dy = neigh.y-node.y
				line(node.x*8+4,node.y*8+4, node.x*8+dx*4+4, node.y*8+dy*4+4, node.col)
			end
		end
	end

	for node in all(path_nodes) do
		pset(node.x*8+4, node.y*8+4, node.col)
		--print("'", node.x*8, node.y*8, node.col)
	end
end


function draw_path_heights()
	for node in all(path_nodes) do
		print(node.height, node.x*8, node.y*8, 7)
		--if node.on_ground then pset(node.x*8+6, node.y*8,7) end
	end
end


function draw_path_directions(target)

	local direction_x = {-1,1,0,0}
	local direction_y = {0,0,-1,1}

	for node in all(path_nodes) do
		local x = node.x*8+4
		local y = node.y*8+4
		local dir = node.target_direction[target]
		if dir then
			local dx = direction_x[dir]
			local dy = direction_y[dir]
			circ(x+dx*2,y+dy*2, 1, 7)
			line(x+dx*3,y+dy*3,x-dx*3, y-dy*3,7)
		else
			circ(x,y, 0, 7)
		end
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