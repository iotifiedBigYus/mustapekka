--constants (for laura.lua)
--sam westerlund
--13.3.24

-- *--------------------*
-- | "nature" constants |
-- *--------------------*

--horizontal speed
VX = .125
--jump speed
VY = 0.2 --> when pressing fast (~5 ticks) you jump exactly one block
--gravitational acceleration
G = .02
--exponential acceleration
EI = 0.5
--exponential deacceleration
EF = 0.9
--air drag
C = .02
--umbrella drag
UC = .7
--umbrella system
UF = 0.1
UZ = 1
UR = 0
--sideways acceleration (thrust / friction)
--DDX = VX / 4
--maximum jump duration (in ticks)
J = 11
--epsilon (a small number)
E = .01
--world upper left corner x,y; width; height
WX = 0
WY = 0
WW = 77
WH = 38
--minimum velocity
MV = .04

-- *-----------------*
-- | other constants |
-- *-----------------*

--version number
version = 'v0.2.0'
--maximum amount of actors
max_actors = 128
--show debug info
debugging = false
--update the game one frame at a time by pressng ⬆️
freeze =  false
--frames per tick
slowdown = 1
--camera dynamics
camera_f = 0.01
camera_z = 1
camera_r = 0
--auto jump
auto_jump = false
--music
play_music = false

-- *---------------*
-- | color palette |
-- *---------------*

local c = {}
c[0]  = 0
c[1]  = 0
c[2]  = 2+128
c[3]  = 3+128
c[4]  = 4+128
c[5]  = 0+128
c[9]  = 9+128
c[11] = 3
c[12] = 13
c[13] = 13+128
c[15] = 15+128
alt_colors = c

--background color
BG = 13

-- *----------------*
-- | initial values |
-- *----------------*

player_x = 8
player_y = 16

-- *--------*
-- | sounds |
-- *--------*

SFX_STEP = 63
SFX_JUMP = 62
MUSIC = 0
MUSIC_FADE_IN = 1000

-- *---------*
-- | sprites |
-- *---------*

SPR_STILL = 1
SPR_WALKING = 2
SPR_GLIDING = 7 --> center