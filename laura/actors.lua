--actors
--3.4.2024


function init_actor_data()
	actor_data = {
		[SPR_PLAYER] = init_player_data(),
		[SPR_DOG] = init_dog_data(),
		[SPR_BALL] = init_ball_data(),
		[SPR_CAT] = init_cat_data()
	}
end


function point(x,y)
	local a = {}
	a.x = x
	a.y = y
	a.w2 = 0
	a.h = 0
	a.h2 = 0
	return a
end


function make_actor(k,x,y,d)
	if (count(actors) >= MAX_ACTORS) then
		return {}
	end

	local a = {}
	a.k = k --> sprite id of actor
	a.standing = true
	a.frame = 0
	a.t_frame = 0
	a.t = 0
	--motion
	a.x        = x
	a.y        = y
	a.speed_x  = 0
	a.speed_y  = 0
	a.accel_y  = .02 -- gravity
	a.drag     = .02 --air drag
	a.friction = .9 -- exponential deacceleration
	a.d        = d or -1 --(looking direction)
	a.mass     = 1
	a.bounce   = 0
	a.min_bounce_speed = 1
	--sprite
	a.cx  = 0
	a.w2  = .5
	a.h   = 1
	a.f_x = 0
	a.fade = 1
	--methods
	a.update        = function() end
	a.update_sprite = function() end
	a.draw          = function() end
	a.clear         = clear_cell

	for attr,v in pairs(actor_data[k]) do
		a[attr]=v
	end

	--half height
	a.h2 = a.h * .5

	add(actors, a)

	debug.actors_n = count(actors)

	return a
end


function get_situation_acceleration(a)
	-- acceleration
	if abs(a.speed_x) > a.walk_speed and a.d == sgn(a.speed_x) then
		return .2 --> going too fast (probably wont happen)
	elseif a.standing then
		return 1 --> on ground
	elseif a.strafing_x != 0 then
		return .8 --> strafing while airborn
	end
	return .4 --> airborn
end


function delete_actor(a)
	del(actors, a)

	debug.actors_n = count(actors)
end


function get_center_floored(a)
	return flr(a.x), flr(a.y - a.h2)
end


function update_spawning(x0, y0)
	x0=flr(x0)
	y0=flr(y0)

	for y = max(world_y, y0-UPDATE_LEFT), min(world_y+world_h-1, y0+UPDATE_RIGHT) do
		for x = max(world_x, x0-UPDATE_UP), min(world_x+world_w-1, x0+UPDATE_DOWN) do
			local val = mget(x, y)
			
			if (fget(val, 0)) then    
				spawn_actor(val, x+.5, y+1)
				clear_cell(x, y)
			end
		end
	end
end


function spawn_actor(k,x,y,d)
	return make_actor(k,x,y,d)
end


function despawn_actors()
	if not spawned_actors then
		spawned_actors = {}
		return
	end

	for a in all(spawned_actors) do
		mset(unpack(a))
	end
end

function update_actor(a)
	collide_side(a)
	collide_up(a)
	collide_down(a)

	--jumping
	if(a.speed_y < 0) a.jumped = true

	--moving
	a.x += a.speed_x
	a.y += a.speed_y

	--snapping
	if a.speed_x == 0 and a.speed_y == 0 then
		a.x = snap8(a.x,a.cx)
		a.y = snap8(a.y)
	end
	--if(a.speed_y == 0)a.y = snap8(a.y,0)
	
	--gravity
	a.speed_y += a.accel_y

	--air resistance
	a.speed_y -= sgn(a.speed_y) * a.speed_y * a.speed_y * a.drag

	--timers
	a.t += 1
end

--[[

actor position is center bottom
.   _______
.  |       |
.  | (x,y) |
.  |___.___|

.    O       O       O       O    
. --@@@-- --@@@-- --@@@-- --@@@-- 
.   @@@\    @@@\   _@@@    _@@@  
.   |      /           \      |   

--]]


function draw_hitbox(a)
	rect(
		8*snap8(a.x-a.w2),
		8*snap8(a.y-a.h),
		8*(snap8(a.x+a.w2)-E),
		8*(snap8(a.y)-E),
		8
	)  
end


--[[
function spawn_sofa(x,y)
	return make_actor(SPR_SOFA,x,y,1)
end

function draw_sofa(a)
	local x = pos8(a.x-1)
	local y = pos8(a.y-1)

	spr(a.k, x,   y)
	spr(a.k, x+8, y,1,1,true)
end
--]]
