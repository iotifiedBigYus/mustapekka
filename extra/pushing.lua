-- pushing (outtake)
-- sam westerlund
-- 6.7.2024


function check_pushing(a1, a2)
	local x, y, overlap = get_collision_direction(a1,a2)

	if a1.is_player and a2.is_furniture then
		if aabb(a1,a2) then
			while aabb(a1,a2) do
				a1.x += x * E
				a1.y += y * E
				x, y, overlap = get_collision_direction(a1,a2)
			end
		end

		if aabb_vel(a1,a2) then
			a1.pushing_actor = a2
			a2.pushed_by_actor = a1
		elseif a1.pushing_actor == a2 then
			a1.pushing_actor = nil
			a2.pushed_by_actor = nil
		end
	end

	if a1.is_furniture and a2.is_furniture
	and a1.pushed_by_actor then
		--> a2 is not pushed by player

		if aabb(a1, a2) then
			while overlap >= E do
				a1.x += x * E
				a1.y += y * E
				x, y, overlap = get_collision_direction(a1,a2)
			end
			
			if a1.pushed_by_actor and a1.pushed_by_actor.is_player then
				a1.speed_x = 0
				a1.pushed_by_actor.speed_x = 0
			end
		end
	end
end


function aabb_vel(a1, a2)
	--axis-aligned bounding box collision
	--using strict interior and applying the horizontal velocity of a1
	return (
		a1.x + a1.speed_x - a1.w2 < a2.x + a2.w2 and
		a1.x + a1.speed_x + a1.w2 > a2.x - a2.w2 and
		a1.y - a1.h          < a2.y         and
		a1.y                 > a2.y - a2.h
	)
end


function aabb(a1, a2)
	--axis-aligned bounding box collision
	--using strict interior
	return (
		a1.x - a1.w2 < a2.x + a2.w2 and
		a1.x + a1.w2 > a2.x - a2.w2 and
		a1.y - a1.h  < a2.y         and
		a1.y         > a2.y - a2.h
	)
end


function nudge_pushing(a, nudge_x, nudge_y)
	a.x += nudge_x
	a.y += nudge_y
	for b in all(a.pushing_actors) do
		nudge_pushing(b, nudge_x, nudge_y)
	end
end


function get_collision_direction(a1, a2)
	--source: https://stackoverflow.com/questions/5062833/detecting-the-direction-of-a-collision

	local b = a2.y - (a1.y - a1.h)
	local t = a1.y - (a2.y - a2.h) --> this identifier needs to be local
	local l = a1.x + a1.w2 - (a2.x - a2.w2)
	local r = a2.x + a2.w2 - (a1.x - a1.w2)

	--debug.top = (t < b and t < l and t < r )
	--debug.bottom = (b < t and b < l and b < r)
	--debug.left = (l < r and l < t and l < b)
	--debug.right = (r < l and r < t and r < b )

	if (t < b and t < l and t < r) return  0, -1, t --top collision
	if (b < t and b < l and b < r) return  0,  1, b --bottom collision
	if (l < r and l < t and l < b) return -1,  0, l --left collision
	if (r < l and r < t and r < b) return  1,  0, r --right collision
	return 0, 0, 0
end