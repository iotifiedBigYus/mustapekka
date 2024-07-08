--actors
--3.4.2024


function init_actor_data()
	actor_data = {
	[SPR_PLAYER] = init_player_data(),
	[SPR_DOG] = init_dog_data(),
	--[[
	[SPR_SOFA] = {
		w2 = 1,
		h  = 1,
		mass = 2,
		friction = 0.05,
		is_furniture = true,
		draw = draw_sofa
	}, --]]
	[SPR_BALL] = init_ball_data(),
	[SPR_CAT] = init_cat_data()
	}
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
	a.speed_x       = 0
	a.speed_y       = 0
	a.accel_y      = .02 -- gravity
	a.drag     = .02 --air drag
	a.friction = .9 -- exponential deacceleration
	a.traction = true
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

	add(actors, a)

	debug.actors_n = count(actors)

	return a
end


function delete_actor(a)
	del(actors, a)

	debug.actors_n = count(actors)
end



function spawn_actor(k,x,y,d)
	return make_actor(k,x,y,d)
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
	if(a.speed_x == 0)a.x = snap8(a.x,a.cx)
	if(a.speed_y == 0)a.y = snap8(a.y,0)

	--friction
	if a.standing and a.traction then
		a.speed_x *= a.friction
		if (abs(a.speed_x) < MIN_SPEED) a.speed_x = 0
	end

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
