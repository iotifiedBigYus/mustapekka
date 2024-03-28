--constants (for laura.lua)
--sam westerlund
--13.3.24

-- *-------------------------------*
-- | debug / performance constants |
-- *-------------------------------*

DEBUGGING  = true --show debug info
FREEZE     = false --update the game one frame at a time by pressng player two 🅾️
SLOWDOWN   = 1 --frames per tick
HITBOX     = false
VERSION    = '0.4.2' --version number
MAX_ACTORS = 128 --maximum amount of actors
LEVEL_N    = 1

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
U_DRAG_RESPONSE = 20
U_DDX = 0.5
--UF = 0.1 --umbrella system
--UZ = 1
--UR = 0
--DDX = VX / 6 --sideways acceleration (thrust / friction)
DDXT = 6--8--ticks to accelerate
BOOST = 10 --maximum jump duration (in ticks)
COYOTE = 4 --coyote time (window where you can jump when falling)
E = .01 --epsilon (a small number used when finding edges)
FVX = .04 --sprite recentering speed
MV = .04 --minimum velocity
--MDV = .02 --minimum difference in velocity (for camera)
CAMERA_F = 0.01 --camera dynamics
CAMERA_Z = 0.8
CAMERA_R = 0
CAMERA_MIN_V = 0.32
CAMERA_LOCK_V = 0.32
NUDGES_CENTER = {0,-.125,.125,-.25,.25,-.375,.375}
NUDGES_RIGHT  = {0, .125, .25, .375, 0.5}
NUDGES_LEFT   = {0,-.125,-.25,-.375,-0.5}
AUTO_JUMP    = false

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

PLAY_MUSIC    = false
SFX_STEP      = 63
SFX_JUMP      = 62
MUSIC         = 0
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
