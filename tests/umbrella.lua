--umbrella test
--sam westerlund
--11.3.2024


-- gravity
G = .02
-- drag coefficient
C = 0--.01
-- umbrella drag coefficient
UC = .2
-- angle change
DA = 0.01
-- max angle
MA = 0.125
-- umbrella radius
UR = 2
-- dot radius (in pixels)
DR = 2

function _init()
    x,y = 8,8
    dx,dy = 0,0
    cx,cy = 0,0
    a = 0
end


function _update60()
    x += dx
    y += dy

    umbrella=btn(5)

    if(x >= 16)x-=16
    if(x <   0)x+=16
    if(y >= 16)y-=16
    if(y <   0)y+=16

    dy += G
    dy -= sgn(dy) * C * dy * dy
    dx -= sgn(dx) * C * dx * dx

    --umbrella
    ux,uy = sin(a),-cos(a)
    if umbrella then
        a = 0
        if(btn(⬅️))a = MA--a=min(0.25, a+DA)
        if(btn(➡️))a = -MA--a=max(-0.25, a-DA)

        vsq = dx * dx + dy + dy
        d = -(dx * ux + dy * uy) * UC * vsq

        dx += d * ux
        dy += d * uy
    end
end


function _draw()
    cls()
    ?ux
    ?uy
    if umbrella then
        line(
            .5+8*(x+UR*sin(a+.125)),
            .5+8*(y-UR*cos(a+.125)),
            .5+8*(x+UR*sin(a-.125)),
            .5+8*(y-UR*cos(a-.125)),
            8
        )
    end
    color(7)
    circfill(.5+x*8,.5+y*8,DR)
end