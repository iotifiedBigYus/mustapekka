function draw_sparkle(s)

	--spinning
	if (s.k == 0) then
		local sx=s.x*8
		local sy=s.y*8
		
		line(sx,sy,
				sx+cos(s.t*s.spin)*1.4,
				sy+sin(s.t*s.spin)*1.4,
				s.col)
				
		return
	end
	
	if (s.col and s.col > 0) then
		for i=1,15 do
			pal(i,s.col)
		end
	end

	local fr=s.frames * s.t/s.max_t
	fr=s.k+mid(0,fr,s.frames-1)
	spr(fr, s.x*8-4, s.y*8-4)

	pal()
end

function draw_actor(a)

	local fr=a.k + a.frame

	-- rainbow colour when dashing
	if (a.dash>0) for i=2,15 do pal(i,7+((a.t/2) % 8)) end
	
	local sx=a.x*8-4
	local sy=a.y*8-8
	
	-- sprite flag 3 (green):
	-- draw one pixel up
	if (fget(fr,3)) sy-=1

	-- draw the sprite
	spr(fr, sx,sy,1,1,a.d<0)

	-- sprite flag 2 (yellow):
	-- repeat top line
	-- (for mimo's ears!)
	
	if (fget(fr,2)) then
		pal(14,7)
		spr(fr,sx,sy-1,1,1/8,
						a.d<0)
	end
	
	pal()
end

function draw_tail(a)

	draw_actor(a)
	
	local sx=a.x*8
	local sy=a.y*8-2
	local d=-a.d
	sx += d*3
	if (a.d>0) sx-=1
	
	for i=0,4,2 do
		pset(sx+i*d*1,
		  sy + cos(i/16-time())*
		  (1+i)*abs(a.dx)*4,7)
	end
	
end


function apply_paint()
	if (tt==nil) tt=0
	tt=tt+0.25
	srand(flr(tt))
	local nn=rnd(128)
	local xx=0
	local yy=nn&127
	for i=1,1000*13,13 do
		nn+=i
		nn*=33
		xx=nn&127
		local col=pget(xx,yy)
		rectfill(xx,yy,xx+1,yy+1,col)
		line(xx-1,yy-1,xx+2,yy+2,col)
		nn+=i
		nn*=57
		yy=nn&127
		rectfill(xx-1,yy-1,xx,yy,pget(xx,yy))
			
	end
end

-- draw the world at sx,sy
-- with a view size: vw,vh
function draw_world(
		sx,sy,vw,vh,cam_x,cam_y)

	-- reduce jitter
	cam_x=flr(cam_x) 
	cam_y=flr(cam_y)
	
	if (level>=4) cam_y = 0
	
	clip(sx,sy,vw,vh)
	cam_x -= sx
	
	local ldat=theme_dat[level]
	if (not ldat) ldat={}
	
	-- sky
	camera (cam_x/4, cam_y/4)
	
	-- sample palette colour
	local colx=120+level
	
	-- sky gradient
	if (ldat.sky) then
		for y=cam_y,127 do
			col=ldat.sky[
				flr(mid(1,#ldat.sky,
					(y+(y%4)*6) / 16))]
				
			line(0,y,511,y,col)
		end
	end
	
	-- elements
	
	
	for pass=0,1 do
	camera()
	
	for el in all(ldat.bgels) do
	
	if (pass==0 and el.xyz[3]>1) or
	   (pass==1 and el.xyz[3]<=1)
	then
	
		pal()
		if (el.cols) then
		for i=1,#el.cols, 2 do
			if (el.cols[i+1]==-1) then
				palt(el.cols[i],true)
			else
				pal(el.cols[i],el.cols[i+1])
			end
		end
		end
		
		local s=el.src
		local pixw=s[3] * 8
		local pixh=s[4] * 8
		local sx=el.xyz[1]
		if (el.dx) then
			sx += el.dx*t()
		end
		local sy=el.xyz[2]
		
		sx = (sx-cam_x)/el.xyz[3]
		sy = (sy-cam_y)/el.xyz[3]
		
		repeat
			map(s[1],s[2],sx,sy,s[3],s[4])
			if (el.fill_up) then
				rectfill(sx,-1,sx+pixw-1,sy-1,el.fill_up)
			end
			if (el.fill_down) then
				rectfill(sx,sy+pixh,sx+pixw-1,128,el.fill_down)
			end
			sx+=pixw
		
		until sx >= 128 or not el.xyz[4] 
	
	end
	end
	pal()
	
		if (pass==0) then
			draw_z1(cam_x,cam_y)
		end
	end
	

	
	clip()
	
end
	

-- map and actors
function draw_z1(cam_x,cam_y)
	
	camera (cam_x,cam_y)
	pal(12,0)	-- 12 is transp
	map (0,0,0,0,128,64,0)
	pal()
	foreach(sparkle, draw_sparkle)
	for a in all(actor) do
		pal()
		if (a.hit_t>0 and a.t%4 < 2) then
			for i=1,15 do
				pal(i,8+(a.t/4)%4)
			end
		end
		a:draw() -- same as a.draw(a)
	end
	-- forground map
	map (0,0,0,0,128,64,1)
end