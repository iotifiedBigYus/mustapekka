--btnd (double press activated button)
--sam westerlund
--23.2.24

btnd_state = {
    0,0,0,0,0,0
}
btnd_timer = {
    0,0,0,0,0,0
}
btnd_delay = 10


function update_btnd()
    for n = 1,6 do
        local s = btnd_state[n]
        if btn(n-1) then
            if s == 0 then
                btnd_state[n] = 1
                btnd_timer[n] = btnd_delay
            elseif s == 1 then
                btnd_timer[n] -= 1
                if btnd_timer[n] == 0 then
                    btnd_state[n] = 2
                end
            elseif s == 3 then
                btnd_state[n] = 4
            end
        else
            if s == 2 then
                btnd_state[n] = 0
            elseif s == 1 then
                btnd_state[n] = 3
            elseif s == 3 then
                btnd_timer[n] -= 1
                if btnd_timer[n] == 0 then
                    btnd_state[n] = 0
                end
            elseif s == 4 then
                btnd_timer[n] = 0
                btnd_state[n] = 0
            end
        end
    end
end

function btnd(i)
    return btnd_state[i+1] == 4
end