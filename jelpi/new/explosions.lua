function bang_puff(mx,my,sp)

	local aa=rnd(1)
	for i=0,5 do
	
		local dx=cos(aa+i/6)/4
		local dy=sin(aa+i/6)/4
		local s=make_sparkle(
			sp,mx + dx, my + dy) 
		s.dx = dx
		s.dy = dy
		s.max_t=10
	end
	
end

function atomize_sprite(s,mx,my,col)
	local sx=(s%16)*8
	local sy=flr(s/16)*8
	local w=0.04
	
	for y=0,7 do
		for x=0,7 do
			if (sget(sx+x,sy+y)>0) then
				local q=make_sparkle(0, mx+x/8, my+y/8)
				q.dx=(x-3.5)/32 +rnd(w)-rnd(w)
				q.dy=(y-7)/32   +rnd(w)-rnd(w)
				q.max_t=20+rnd(20)
				q.t=rnd(10)
				q.spin=0.05+rnd(0.1)
				if (rnd(2)<1) q.spin*=-1
				q.ddy=0.01
				q.col=col or sget(sx+x,sy+y)
			end
		end
	end
end
