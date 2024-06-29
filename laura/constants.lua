--constants (for laura.lua)
--sam westerlund
--13.3.24

-- *-------------------------------*
-- | debug / performance constants |
-- *-------------------------------*

DEBUGGING  = true--show debug info
FREEZE     = false --update the game one frame at a time by pressng player two 🅾️
SLOWDOWN   = 1 --frames per tick
HITBOX     = false
SIGTHLINES = true
VERSION    = '0.5.0' --version number
MAX_ACTORS = 128 --maximum amount of actors
LEVEL_N    = 4

-- *------------------------------*
-- | physics / physical constants |
-- *------------------------------*

SOFA_X = 13
SOFA_Y = 13
SOFA2_X = 18
SOFA2_Y = 13
DOG_X = 8
DOG_Y = 13
DOG_SIGHT_HEIGHT = 3
DOG_SIGHT_DIST = 20
DOG_TARGET_TIME = 20
DOG_SIGHT_SLOPE = 2

U_DRAG_X = 0.05 --umbrella sideways air drag
U_DRAG_Y = 1.2 --umbrella drag (when going down)
U_OPEN_FRAMES = 6
U_DDX = 0.005
RUN_MAX = 8
DDXT = 6--8--ticks to accelerate
JUMP_MAX = 5 --maximum jump duration (in ticks)
COYOTE = 4 --coyote time (window where you can jump when falling)
JUMP_GRACE = 4
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
AUTO_JUMP     = false

-- *---------------*
-- | color palette |
-- *---------------*

local c2 = {}
c2[0]  = 0
c2[1]  = 128+5
c2[2]  = 128+2
c2[3]  = 128+3
c2[4]  = 128+4
c2[5]  = 5
c2[6]  = 128+6
c2[7]  = 6

c2[8]  = 128+8
c2[9]  = 128+9
c2[10] = 10
c2[11] = 3
c2[12] = 13 
c2[13] = 128+13
c2[14] = 4
c2[15] = 15+128
ALT_COLORS = c2
BG = 12 --background color

-- *--------*
-- | sounds |
-- *--------*

PLAY_MUSIC    = not DEBUGGING
SFX_STEP      = 63
SFX_JUMP      = nil--62
SFX_UMBRELLA_UP = 61
SFX_UMBRELLA_DOWN = 62
SFX_BARK      = 60
MUSIC         = 0
MUSIC_FADE_IN = 1000
FALL_SFX_V    = 0.1

-- *---------*
-- | sprites |
-- *---------*
 
BACKGROUND_X = 0
BACKGROUND_Y = 48
BACKGROUND_W = 20
BACKGROUND_H = 20

SPR_PLAYER          = 64
SPR_WALKING        = 80--65
SPR_U_STILL        = 66 --> u as in umbrella
SPR_U_WALKING      = 96

FRAME_WALK      = 16
FRAME_UMBR_WALK = 32

SPR_SOFA = 68

SPR_DOG = 100
