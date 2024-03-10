--button test
--sam westerlund
--28.2.24

W = 128
H = 128

function _init()
    restart()
end

function restart()
    t = {0,0,0,0}
    d = {{},{},{},{}}
    maximum = {0,0,0,0}
    state = 'running'
end

function _update60()
    if state == 'restarting' then
        if btnp(❎) then
            restart()
        elseif btnp(🅾️) then
            state = 'running'
        end
    else
        if btnp(🅾️) then
            state = 'restarting'
        end
        update()
    end
end


function update()
    for i =1,4 do
        if btn(i-1) then
            t[i] += 1
        elseif t[i] > 0 then
            if t[i] > maximum[i] then
                maximum[i] = t[i]
            end
            add(d[i],t[i])
            t[i] = 0
        end
    end
end

function _draw()
    cls()
    if state == 'restarting' then
        print('do you want to restart?')
        print('❎ yes, 🅾️ no')
    else
        for i = 1,4 do
            print('button '..i)
            for j = 1,count(d[i]) do
                print(d[i][j])
            end
            --y = i*H/4
            --l = count(d[i])
            --l1 = max(l-128)
            --dx = W / (l - l1 +1)
            --color(7+i)
            --for j=l1+1,l do
            --    dy = d[i][j] / maximum[i] * H/4
            --    rectfill(y, (j-1)*dx, y-dy, j*dx)
            --end
        end
    end
end