function draw_finished(tt)

	if (tt < 15) return
	tt -= 15

	local str="★ stage clear ★  "
	
	print(str,64-#str*2,31,14)
	print(str,64-#str*2,30,7)
	
	-- gems
	local n = total_gems
	
	for i=1,15 do pal(i,13) end
	for pass=0,1 do
			
				for i=0,n-1 do
					t2=tt-(i*4+15)
					q=i<gems and t2>=0
					if (pass == 0 or q) then
						local y=50-pass
						if (q) then
								y+=sin(t2/8)*4/(t2/2)
								if (not gem_sfx[i]) sfx(25)
								gem_sfx[i]=true
						end
						
						spr(67,64-n*4+i*8,y)
						
					end
				end
	
		pal()
	end
	
	if (tt > 45) then
		print("❎ continue",42,91,12)
		print("❎ continue",42,90,7)
	end
	
end