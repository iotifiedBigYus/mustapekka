--ball
--sam westerlund
--29.6.2024

function init_ball_data()
	local a = {}

	a

	return a
end


function spawn_ball(x,y,dx,dy)
	local a = make_actor(SPR_BALL, x, y, 1)

	a.dx = dx
	a.dy = dy
	
	return a
end
