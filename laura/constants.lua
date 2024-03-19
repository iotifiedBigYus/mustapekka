--constants (for laura.lua)
--sam westerlund
--13.3.24

-- *-----------------*
-- | debug constants |
-- *-----------------*

DEBUGGING = false --show debug info
FREEZE = false --update the game one frame at a time by pressng player two 🅾️
SLOWDOWN = 1 --frames per tick
HITBOX = false

-- *------------------------------*
-- | physics / physical constants |
-- *------------------------------*

VX = .125 -- horizontal speed
VY = 0.2 -- jump speed > when pressing fast (~5 ticks) you jump exactly one block
G = .02 -- gravitational acceleration
--EI = 0.6 -- inverse exponential acceleration
--EA = 1.1 -- exponential acceleration
EF = 0.9 -- exponential deacceleration
DRAG = .02 --air drag
U_DRAG = 1.2 --umbrella drag (only downwards)
U_TILT = 0.08
--UF = 0.1 --umbrella system
--UZ = 1
--UR = 0
--DDX = VX / 6 --sideways acceleration (thrust / friction)
DDXT = 6--8--ticks to accelerate
BOOST = 10 --maximum jump duration (in ticks)
COYOTE = 4 --coyote time (window where you can jump when falling)
E = .01 --epsilon (a small number used when finding edges)
FVX = .04 --spirte recentering speed
WX = 0 --world upper left corner x,y; width; height
WY = 0
WW = 77
WH = 38
MV = .04 --minimum velocity
--MDV = .02 --minimum difference in velocity (for camera)
CAMERA_F = 0.01 --camera dynamics
CAMERA_Z = 1
CAMERA_R = 0
--PLAYER_X = 4
--PLAYER_Y = 20

-- *-----------------*
-- | other constants |
-- *-----------------*

VERSION = '0.4.0' --version number
AUTO_JUMP = false
PLAY_MUSIC = true
MAX_ACTORS = 128 --maximum amount of actors

-- *---------------*
-- | color palette |
-- *---------------*

local c = {}
c[0]  = 0
c[1]  = 0
c[2]  = 4+128
c[3]  = 3+128
c[4]  = 4
c[5]  = 5+128
c[6]  = 6+128
c[8]  = 8+128
c[9]  = 9+128
c[11] = 3
c[12] = 13
c[13] = 5
c[14] = 13+128
c[15] = 15+128
ALT_COLORS = c
BG = 12 --background color

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
SPR_UMBRELLA_L_X = 72
SPR_UMBRELLA_L_Y = 2
SPR_UMBRELLA_C_X = 76
SPR_UMBRELLA_C_Y = 1
SPR_UMBRELLA_R_X = 82
SPR_UMBRELLA_R_Y = 2
