# diary

## Sam, 12.2.24, 1400-1530

Started to make files and listed some ideas. Reimplemented a second-order-dynamic-system integrator. Might refactor it later. Due to the pixel density of p8 it does not look good when the follower is close to the leader, but orbiting looks nice.

## Sam, 27.2.24, 2200

Have not been writing here. I've taken a look at the jelpi code and created a character. The character can walk run and jump, but the movement is not done yet. For the running/sprinting I've created a btnd function that activates when a button is double pressed.

Things to be fixed:
- Initial acceleration when running. It feels annoying that you can't move just a little bit.
- Making sprinting stop when colliding or letting go while jumping, and having to activate it again afterwards.
- Bug: When jumping up into an opening just under the ceiling, you can get inside the floor of the opening when hitting the ceiling.
- Collision when trying to jump into a hole in a wall.


## Sam, 28.2.24, 1600, version 0.1.1

Published the first version to BBS. A bit scary tbh having my code visible to the public.

Changes made:
- Added initial acceleration.
- Made the player have a smaller hit-box when in the air so it's easier to jump into openings.
- Decided to remove sprinting, at least for the time being
- Made platform collisions better. Now the player can go down them.


## Sam, 2.3.24, 2000, version 0.1.2

Noticed that jumping on mobile is much easier if it's mapped to O. Added that alternative.

## Sam, 5.3.24, 1800, version 0.1.3

Made a menu item that changes the jump button between o and up. It felt a bit janky and less is more, so the jump button is now only o. Might bring back up in the future. The x button will most likely be in use, so two hands will be needed either way.

To make it easier to position one self I added linear acceleration, and changed where friction is added because of it. Tried linear de-acceleration but did not like it at all. In the end I changed the acceleration back to asymptotic. Positioning is not the best because of the fast movement response, but for the moment being it's alright.

Tried making the jump button in a way where you have to press it again every time you jump, but did not like it.

Made the map larger, and added vertical scroll.

## Benjamin, 10.3.2024

Composed a diddy. Since it is my first time using Pico8 as a DAW, this very well might not even be used in the final product. The cyper-punkiness does not match up to my vision of the game's visual aesthetic - but then again, it might be hard to create this desired soundscape in Pico8.
I will consider introducing other elements to the visuals, which would justify a more electronic soundscape. For now the dream of a Ghibli-inspired game stands, though.

## Sam, 10.3.2024

Added auto_jump boolean. Making manual jumping the default. Feelis kinda weird, but It's better when you are trying to reach stuff and not wanting jumping off when you land.

Added Benji's new diddy to the game with the ability to turn on and off the music in the menu.

## Benjamin 11.3.2024

This is horrible. My music should not turn off - although, this I admit: so far it has been kind of bland. That all changes with this second song, an absolute banger, not tried and yet true. Summa summarum: I made a second song today. UPDATE: additional mastering completed.

## Sam, 11.3.2024

Made an umbrella demo. Feels very nice. Will add terminal velocity to the game, but only when you're not standing, I think.

## Sam, 12.3.2024, version 0.2.0

Made the umbrella tilt discrete with the positions left, center, and right. Thinking that this will make controlling and drawing the character easier.

I added air resistance and it works as it should, but it yields weird results when I make the umbrella drag proportional to velocity squared. Direct proportionality it is. I got the umbrella (not yet drawn) implemented into the game. _Call me chef the way my code is starting to look like spaghetti._ It isn't _that_ bad at the moment but it needs some cleaning at some point.

My thinking was correct. The umbrella is now being drawn. It looks pretty janky in slow motion but at 60 fps its alright. Might make a system that shifts the position of the umbrella. Also noticed that the rotations of the umbrella use the same amount of pixels (except the handle, but that can be covered up with the hand of the player). This means that it could be rotated using three shears. _How exciting._ It will stay snappy for the moment being.

I also realized I've been using semantic versioning wrong.

Bugs
- Visual: The character jitters when the camera follows them at approx the same speed.
- Double jump using the umbrella.
- Two landing sounds when coming from a platform down to a platform directly below.

TODO:
- make the camera "lock on to" the player when their velocities are similar so that the jittering does not occur

## Benjamin, 13.3.2024

Made a proto level. Colour codes:
- yellow = chasing dog
- blue = window
- red = spikes
- brown = honing (bird?)
- green = cat
(
EDIT - Sam
- gray = ground
- pink = solid wall
- dark red = background wall 1
- dark green = background wall 2
)
UPDATE: Done messed up. Problems with Github - overwrote Sam's demo. After a long reverting session the two should be separate and navigable. This problem should not arise in the future, as long as I remember to edit a duplicated file, and not the original.

## Sam, 13.3.2024

Thats how it goes in the world of game dev. I don't know how git branches work, so this method will do for now.

I created a separate file for constants called "constants.lua". Some so called constants were not even constant. They are moved to laura.lua. The code of laura.p8 now includes: constants.lua, laura.lua, and system.lua.

Inserted the laura proto map and sprites into laura. The map feels really good, but the movement needs some tweaking. Small steps are hard not to overshoot and strafing makes gliding much faster. The latter might be more a feature more than a bug, but we need to think about it. All-in-all I think we need to make the basic movement a bit slower. Experimentation is needed.

Tried to make the camera lock on to the player in a good way, but the locking is way to snappy, and it does not even fix the glide jittering. Will get back to it another time.

TODO:
- more precise movement

## Sam, 14.3.2024, version 0.3.0

All right. Went back to linear acceleration. I does not feel like the greatest thing ever but I think it is good enough, and I might just be used to the previous movement. **Never mind.** After writing this I realized quadratic curves existed and used that. 6 ticks to full speed. Man, what a difference. Quadratic is definitely the way to go.

The umbrella now stays straight when you deploy it whilst pressing one of the directional keys. You have to press one of them again to tilt it.

Added coyote time after watching a video by The Shaggy Dev, making it possible to jump some ticks after walking off an edge. Will also add 'push-off' so that you don't have to align yourself up perfectly to jump into spaces above you.
(Video: *[5 tips for better platformer controls](https://www.youtube.com/watch?v=Bsy8pknHc0M&t=181s)*)

TODO:
- add push-off

## Sam, 17.3.2024

I've experimented with colors. Found seven colors that look good behind the charater, those being greens, grays, purples, and a dark brown thats a little on the edge of looking good. The darker red might also work, but thats the new color of the umbrella. The rest of the colors are too bright, too dark, or clash with the sprite.

The chosen colors are easy on the eyes, but the purples and the grays are functionally very similar. We might want to only use two of the four colors to leave room for other colors. The purples have more color than the grays, but the grays work better with the greens. _Tough Choice._

Changes:
- The umbrella is darker (might be changed back)
- Made an orange cat sprite that I'm pretty pleased with.
- Made pink walls light gray and dark purple walls dark gray

There is now some slack when jumping into a space. Collision is checked up to two pixels from the current position and the character is teleported sideways to match the gap. This might need to be reworked so that the character is given sideways momentum instead of teleportation, staying outside walls so that the physics don't break.

## Sam, 18.3.2024, version 0.4.0

Made the push off better by offsetting the player sprite after push-off and re-centering the sprite smoothly. There is no push-off if your jumping with a block directly over you and it checks in what direction you are going to not hinder you from jumping into a hole in a wall by pushing you away.

Experimented with the umbrella by making the drag stronger, tilting it less, and making the y-component of the drag vector constant. Not yet satisfied but there is potential.

Added a lying german shepherd here and there.

## Sam, 19.3.2024

TODO:
- add push-off when descending

## Sam, 20.3.2024, version 0.4.1

From this day onward I am calling 'push-off' nudging, which now also occurs when descending from standstill. I have been spelling descending wrong in my code this whole time.

My friend noted that the umbrella deaccelerates the player too fast, and I agree. We will need to deviate from physics to come up with a smoother drag model.

Tried to fix the glide jittering. Got closer but it only works sometimes.

Changes:
- Made the start of the player acceleration constant as the minimum velocity until the quadratic curves becomes larger.
- Cleaned up the camera code so that smart following can be implemented easier and removed system.lua
- Created levels.lua where Benjamin can define the borders of levels 

## Benjamin, 20.3.2024

"You know, I feel like I am going crazy. I swear, I close the door every night. My cat sits on my bed as I sleep. But then, I wake up; the doors stands agape and my cat has ran away.
Am I going crazy? Or is some unknowable, grotesque being snatching my cat with its' slimy fingers each night, waiting for me to have fallen asleep before peeking in - its' eye must be bigger than my whole body?"

We had a meeting:
	- Spikes as static enemies are derivative, so we had to change our way of thinking. Nothing, that can naturally be found in homes, can be considered life-threathening.
	- We settled on the following aesthetic: a setting reminiscent of suburban Japan; weird anatomical limbs sticking out of the walls as static enemies (lovecraftian entities).
	- We settled on which colours fit with the character design.
	- We made up a plan for movig forward and settled the date of the next meeting.
	- Also, levels should be shorter than the first draft, and each should have its' own gist.


## Sam, 25.3.2024, version 0.4.2

After many tries I've gotten rid of the gliding jitter. The problem was that the sprite gets sub-pixel shifted when drawn due to it being only seven pixels wide, but the camera did not shift the target. I hope I don't have to touch the camera axis code anymore.


## Sam, 25.3.2024, version 0.4.2

Made Benji's map 32 blocks high and added a secret room under the first building.

Tried cleaning up the umbrella physics, still a bit messy. It now activates slowly (20 ticks to full power).


## Sam, 27.3.2024, version 0.4.2

TODO:
- color fade ins and outs
- inventory
- checkpoints
- keys to doors
- particle system
- damage system
- wiener dog
- clean up sprite code
- make camera simpler
- level system