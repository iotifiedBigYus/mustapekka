--a star pathfinding
--sam westerlund
--16.7.2024

-- ======================================================================
-- Copyright (c) 2012 RapidFire Studio Limited 
-- All Rights Reserved. 
-- http://www.rapidfirestudio.com

-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:

-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- ======================================================================

function generate_nodes()
	local nodes = {}

	for xx = world_x, world_x+world_w-1 do
		for yy = world_y, world_y+world_h-1 do
			if not solid(xx,yy) then
				local node = {}
				node.x = xx
				node.y = yy
				node.is_walkable = solid(xx,yy +1) or platform(xx, yy+1)
				node.is_descendable = platform(xx, yy+1)
				add(nodes, node)
			end
		end
	end

	return nodes
end


function find_node(nodes,x,y)
	local x1, y1 = flr(x), ceil(y-1)
	debug.p_x = x1
	debug.p_y = y1
	local nodes_x = {}
	local min_y = world_y + world_h
	local min_node = nil
	for node in all(nodes) do
		if node.x == x1 and node.is_walkable and node.y >= y1 and node.y < min_y then
			min_node = node
			min_y = node.y
		end
	end

	debug.node_x = min_node.x
	debug.node_y = min_node.y
	return min_node
end



----------------------------------------------------------------
-- local variables
----------------------------------------------------------------

local INF = 1/0
local cachedPaths = nil

----------------------------------------------------------------
-- local functions
----------------------------------------------------------------

function dist ( x1, y1, x2, y2 )
	
	return sqrt ( ( x2 - x1)^2 + ( y2 - y1 )^2 )
end

function dist_between ( nodeA, nodeB )

	return dist ( nodeA.x, nodeA.y, nodeB.x, nodeB.y )
end

function heuristic_cost_estimate ( nodeA, nodeB )

	return dist ( nodeA.x, nodeA.y, nodeB.x, nodeB.y )
end

function is_valid_node ( node, neighbor )
	return true
end


function lowest_f_score ( set, f_score )

	local lowest, bestNode = INF, nil
	for node in all( set ) do
		local score = f_score [ node ]
		if score < lowest then
			lowest, bestNode = score, node
		end
	end
	return bestNode
end

function neighbor_nodes ( theNode, nodes )

	local neighbors = {}
	for node in all( nodes ) do
		if theNode ~= node and is_valid_node ( theNode, node ) then
			add( neighbors, node )
		end
	end
	return neighbors
end

function not_in ( set, theNode )

	for _, node in ipairs ( set ) do
		if node == theNode then return false end
	end
	return true
end

function remove_node ( set, theNode )

	for i, node in ipairs ( set ) do
		if node == theNode then 
			set [ i ] = set [ #set ]
			set [ #set ] = nil
			break
		end
	end	
end

function unwind_path ( flat_path, map, current_node )

	if map [ current_node ] then
		add( flat_path, map [ current_node ], 1 ) 
		return unwind_path ( flat_path, map, map [ current_node ] )
	else
		return flat_path
	end
end

----------------------------------------------------------------
-- pathfinding functions
----------------------------------------------------------------

function a_star ( start, goal, nodes, valid_node_func )

	local closedset = {}
	local openset = { start }
	local came_from = {}

	if valid_node_func then is_valid_node = valid_node_func end

	local g_score, f_score = {}, {}
	g_score [ start ] = 0
	f_score [ start ] = g_score [ start ] + heuristic_cost_estimate ( start, goal )

	steps = 0
	while #openset > 0 do
	
		local current = lowest_f_score ( openset, f_score )
		if current == goal then
			local path = unwind_path ( {}, came_from, goal )
			add( path, goal )
			return path
		end

		remove_node ( openset, current )		
		add( closedset, current )
		
		local neighbors = neighbor_nodes ( current, nodes )
		for neighbor in all( neighbors ) do 
			if not_in ( closedset, neighbor ) then
			
				local tentative_g_score = g_score [ current ] + dist_between ( current, neighbor )
				 
				if not_in ( openset, neighbor ) or tentative_g_score < g_score [ neighbor ] then 
					came_from 	[ neighbor ] = current
					g_score 	[ neighbor ] = tentative_g_score
					f_score 	[ neighbor ] = g_score [ neighbor ] + heuristic_cost_estimate ( neighbor, goal )
					if not_in ( openset, neighbor ) then
						add( openset, neighbor )
					end
				end
			end
			steps += 1
		end

		if steps > 100 then return nil end
	end
	return nil -- no valid path
end

----------------------------------------------------------------
-- exposed functions
----------------------------------------------------------------

function clear_cached_paths ()

	cachedPaths = nil
end

function distance ( x1, y1, x2, y2 )
	
	return dist ( x1, y1, x2, y2 )
end

function path ( start, goal, nodes, ignore_cache, valid_node_func )

	if not cachedPaths then cachedPaths = {} end
	if not cachedPaths [ start ] then
		cachedPaths [ start ] = {}
	elseif cachedPaths [ start ] [ goal ] and not ignore_cache then
		return cachedPaths [ start ] [ goal ]
	end

      local resPath = a_star ( start, goal, nodes, valid_node_func )
      if not cachedPaths [ start ] [ goal ] and not ignore_cache then
              cachedPaths [ start ] [ goal ] = resPath
      end

	return resPath
end