--collisions
--sam westerlund
--14.4.2024


-- *------------------*
-- | world collisions |
-- *------------------*


function collide_side(a)
	local d = a.speed_x ~= 0 and sgn(a.speed_x) or a.d
	local e = d > 0 and 0 or -E --> stay outside edge
	--local e = d > 0 and -E or 0 --> stay outside edge
	local x1 = a.x + a.speed_x + d * a.w2 + e
	
	if not (solid(x1,a.y-E) or solid(x1,a.y-a.h)) then
		return
	end

	if a.speed_x != 0 then
		local y1 = a.speed_y > 0 and  flr(8*(a.y+a.speed_y))*.125 or ceil(8*(a.y+a.speed_y))*.125
		local y0 = a.speed_y > 0 and ceil(8* a.y      )*.125 or  flr(8* a.y      )*.125
		local step = sgn(a.speed_y)
		for yy = y0, y1, step*.125 do
			if not (solid(x1,yy-E) or solid(x1,yy-a.h)) then
				--> opening
				if (solid(x1,yy-E+step) or solid(x1,yy-a.h+step)) then
					--> opening is a gap
					a.y = yy
					a.speed_y = 0
				end
				return
			end
		end
	end

	--> hit wall
	-- search for contact point
	if(a.k==SPR_BALL)ball.cont = false
	while not (solid(a.x+d*(a.w2+E)+e, a.y-E) or solid(a.x+d*(a.w2+E)+e, a.y-a.h)) do
		a.x += d * E
		if(a.k==SPR_BALL)ball.cont = true
	end

	if a.bounce > 0 and abs(a.speed_x) > a.min_bounce_speed then
		a.speed_x = -a.bounce * a.speed_x
		sfx(a.bounce_sfx)
	else
		a.speed_x = 0
	end
end


function collide_up(a)
	if (a.speed_y > 0) return --> going down

	local y1 = a.y+a.speed_y-a.h
	local xl = snap8(a.x+a.speed_x-a.w2)
	local xr = snap8(a.x+a.speed_x+a.w2)-E

	local nudges
	if a.standing then nudges = {0}
	elseif a.speed_x > 0 then nudges = NUDGES_RIGHT
	elseif a.speed_x < 0 then nudges = NUDGES_LEFT
	else nudges = NUDGES_CENTER end

	for n in all(nudges) do
		if not solid(xl+n, y1) and not solid(xr+n, y1) then
			a.standing = false
			a.t_coyote = 0
			a.x += n
			a.f_x -= n
			return
		end
	end

	--> hit

	-- search up for collision point
	while not solid(xl, a.y-a.h-E) and not solid(xr, a.y-a.h-E) do
		a.y = a.y - E
	end

	if a.bounce > 0 and abs(a.speed_y) > a.min_bounce_speed  then
		a.speed_y = -a.bounce * a.speed_y
		sfx(a.bounce_sfx)
	else
		a.speed_y = 0
	end
end


function collide_down(a)
	if (a.speed_y <= 0) return --> going up

	local y1 = a.y+a.speed_y-E
	local xl = a.x+a.speed_x-a.w2
	local xr = a.x+a.speed_x+a.w2-E

	local hit = false
	if(solid(xl, y1) or solid(xr, y1))then
		--> hit solid
		hit = true
		-- search down for collision point
		while not solid(xl, a.y) and not solid(xr, a.y) do
			a.y = flr(a.y) + 1
		end
	elseif ceil(a.y) == flr(y1) and (platform(xl, y1) or platform(xr, y1)) and not a.descending then
		--> hit platform
		hit = true
		a.descending = false
		a.y = ceil(a.y)
	end

	if hit then
		if a.bounce > 0 and abs(a.speed_y) > a.min_bounce_speed then
			a.speed_y = -a.bounce * a.speed_y
			sfx(a.bounce_sfx)
		else
			a.speed_y = 0
			a.standing = true
		end
	else
		a.standing = false
		--coyote time
		if (not a.t_coyote) return
		a.t_coyote = approach(a.t_coyote)
		if (a.standing) a.t_coyote = COYOTE
	end
end


function is_outside(x,y)
	return x < world_x or x >= world_x+world_w or y < world_y or y >= world_y+world_h
end


function solid(x, y)
	if (is_outside(x,y)) return true
				
	local val = mget(x, y)
	return fget(val, 1)
end


function platform(x,y)
	local val = mget(x, y)
	return fget(val, 2)
end


-- *------------------*
-- | actor collisions |
-- *------------------*


function collisions()
	for i=1,#actors do
		for j=i+1,#actors do
			collide(actors[i],actors[j])
		end
	end
end


function collide(a1, a2)
	if (not a1 or not a2 or a1==a2) return

	if aabb(a1, a2) then
		collide_event(a1, a2)
		collide_event(a2, a1)
	end
end


function collide_event(a1, a2)
	local x, y, overlap = get_collision_direction(a1,a2)

	if a1.is_player and a2.is_cat then
		finish_level()
	end

	--[[
	if y < 0 and overlap >= 0 and a2.standing then
		while aabb(a1,a2) do
			a1.y += y * E
		end
		a1.y = snap8(a1.y)

		a1.standing = true
		a1.speed_y = 0
	end
	--]]

	if a1.is_player and a2.is_furniture then
	
	end

	if a1.is_furniture and a2.is_furniture then
		
	end

	--[[
	if (a1.is_monster and
		a1.can_bump and
		a2.is_monster) then
		local d=sgn(a1.x-a2.x)
		if (a1.d!=d) then
			a1.speed_x=0
			a1.d=d
		end
	end
	
	-- bouncy mushroom
	if (a2.k==82) then
		if (a1.speed_y > 0 and 
		not a1.standing) then
			a1.speed_y=-1.1
			a2.active_t=6
			sfx(18)
		end
	end

	if(a1.is_player) then
		if(a2.is_pickup) then

			if (a2.k==64) then
				a1.super = 30*4
				--sfx(17)
				a1.speed_x = a1.speed_x * 2
				--a1.speed_y = a1.speed_y-0.1
				-- a1.standing = false
				sfx(13)
			end

			-- watermelon
			if (a2.k==80) then
				a1.score+=5
				sfx(9)
			end

			-- end level
			if (a2.k==65) then
				finished_t=1
				bang_puff(a2.x,a2.y-0.5,108)
				del(actor,pl[1])
				del(actor,pl[2])
				music(-1,500)
				sfx(24)
			end

			-- glitch mushroom
			if (a2.k==84) then
				glitch_mushroom = true
				sfx(29)
			end

			-- gem
			if (a2.k==67) then
				a1.score = a1.score + 1

				-- total gems between players
				gems+=1

			end

			-- bridge builder
			if (a2.k==99) then
				local x,y=flr(a2.x)+.5,flr(a2.y+0.5)
				for xx=-1,1 do
				if (mget(x+xx,y)==0) then
					local a=make_actor(53,x+xx,y+1)
					a.speed_x=xx/2
				end
				end
			end

			a2.life=0

			s=make_sparkle(85,a2.x,a2.y-.5)
			s.frames=3
			s.max_t=15
			sfx(9)
		end

		-- charge or dupe monster

		if(a2.is_monster) then -- monster

			if(
					(a1.dash > 0 or 
						a1.y < a2.y-a2.h/2)
					and a2.can_bump
				) then
				
				-- slow down player
				a1.speed_x *= 0.7
				a1.speed_y *= -0.7
				
				if (btn(🅾️,a1.id))a1.speed_y -= .5
				
				monster_hit(a2)
				
			else
				-- player death
				a1.life=0

			end
		end

	end
	--]]
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


--[[

function aabb_gravity(a1, a2)
	--axis-aligned bounding box collision
	--using strict interior and gravity
	return (
		a1.x - a1.w2         < a2.x + a2.w2 and
		a1.x + a1.w2         > a2.x - a2.w2 and
		a1.y + a1.accel_y - a1.h < a2.y         and
		a1.y + a1.accel_y        > a2.y - a2.h
	)
end
]]