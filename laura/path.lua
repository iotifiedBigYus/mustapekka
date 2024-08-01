--path
--sam westerlund
--19.8.2024

--sources:
--lazydevs, making a rouge-like ep. 19
--https://www.youtube.com/watch?v=zA1uMY5f4Js
--Atrejo, (devlog 2.5) how to PLATFORMER AI and pathfinding
--https://www.youtube.com/watch?v=RPB6LplBQK8


function make_path_node(list, matrix, x,y,on_ground,col)
	local node = {
		x=x, y=y, neighbors={}, on_ground = on_ground,
		col=col, target_direction = {}, height = 0
	}
	add(list, node)
	matrix[y][x] = node

	return node
end


function make_path_graph()
	local nodes = {}
	local matrix = {}
	local floating = {}
	
	-- make nodes on ground
	for y = world_y, world_y+world_h-1 do
		matrix[y] = {}
		for x = world_x, world_x+world_w-1 do
			if not solid(x,y) and (solid(x,y+1) or platform(x,y+1)) then
				local node = make_path_node(nodes, matrix, x,y,true,11)
				if (platform(x,y+1)) add(floating, node)
			end
		end
	end

	-- add floating nodes
	for node in all(nodes) do
		local x,y = node.x, node.y

		for dx = -1,1,2 do
			x2 = x+dx
			local node2 = matrix[y][x2]
			if node.on_ground and not node2 and not solid(x2,y) then
				node2 = make_path_node(nodes, matrix, x2,y,false,9)
				add(floating, node2)
			end
		end
	end

	-- connect neighbors
	for left in all(nodes) do
		local x,y = left.x, left.y

		local right = matrix[y][x+1]
		if right and (left.on_ground or right.on_ground) then
			if inverted then
				left .neighbors[1] = right
				right.neighbors[2] = left
			else
				left .neighbors[2] = right
				right.neighbors[1] = left
			end
		end
	end

	-- connect floating nodes down and add heights
	for node in all(floating) do
		local x, y = node.x, node.y

		local height = 0
		repeat
			height += 1
			local below = matrix[y+height][x]
		until below and below.on_ground
		
		for dy = 1,height do
			local above = matrix[y+dy-1][x]
			local below = matrix[y+dy][x]
			if not below then
				below = make_path_node(nodes, matrix, x, y+dy, false, 8)
			end
			
			above.neighbors[4] = below
			below.neighbors[3] = above

			above.height = height-dy+1
		end

		-- platforms
		if node.on_ground then
			node.height = 0
		end
	end

	path_nodes = nodes
	path_node_matrix = matrix
end


function update_direction_map(target, chaser)
	local x0 = flr(target.x)
	local y0 = flr(target.y - target.h2)

	-- find the node the actor is on or one underneath
	local target_node = path_node_matrix[y0][x0]
	while not target_node do
		y0 += 1
		target_node = path_node_matrix[y0][x0]
	end

	-- skip if same position
	if x0 == target.path_x[chaser.k] and y0 == target.path_y[chaser.k] then
		return
	end

	-- reset directions
	for node in all(path_nodes) do
		node.direction = nil
		node.target_direction[a] = nil
	end

	target.path_x[chaser.k] = x0
	target.path_y[chaser.k] = y0
end


function update_path_from(a, jump_height, fall_height)
	jump_height = jump_height or 1/0
	fall_height = fall_height or 1/0
	local x0 = flr(a.x)
	local y0 = flr(a.y - a.h2)

	-- find the node the actor is on or one underneath
	local target_node = path_node_matrix[y0][x0]
	while not target_node do
		y0 += 1
		target_node = path_node_matrix[y0][x0]
	end

	-- reset directions
	for node in all(path_nodes) do
		node.direction = nil
		node.target_direction[a] = nil
	end

	-- expand from actor
	local check_nodes = {target_node}
	local new_check_nodes = {}
	local flip_direction = {2,1,4,3}
	repeat
		for node in all(check_nodes) do
		local dir = node.target_direction[a]
		for i = 1,4 do
		local neigh = node.neighbors[i]
		if neigh and not neigh.target_direction[a] then
			local direct = false
			
			if i == 3 then
				-- expansion upwards, approach by falling
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
				neigh.target_direction[a] = flip_direction[i]
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
	local y0 = flr(a.y - a.h2)
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
		--print("'", node.x*8, node.y*8, node.col)
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