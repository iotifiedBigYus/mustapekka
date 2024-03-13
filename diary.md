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

Checklist when creating a new version because I noticed I need one:
- Update the version number
- Capture new label image (ctrl-7)
- "save .png"


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

<<<<<<< HEAD
## Sam, 12.3.2024, version 0.2.0

Made the umbrella tilt discrete with the positions left, center, and right. Thinking that this will make controlling and drawing the character easier.

I added air resistance and it works as it should, but it yields weird results when I make the umbrella drag proportional to velocity squared. Direct proportionality it is. I got the umbrella (not yet drawn) implemented into the game. _Call me chef the way my code is starting to look like spaghetti._ It isn't _that_ bad at the moment but it needs some cleaning at some point.

My thinking was correct. The umbrella is now being drawn. It looks pretty janky in slow motion but at 60 fps its alright. Might make a system that shifts the position of the umbrella. Also noticed that the rotations of the umbrella use the same amount of pixels (except the handle, but that can be covered up with the hand of the player). This means that it could be rotated using three shears. _How exciting._ It will stay snappy for the moment being.

I also realized I've been using semantic versioning wrong.

Bugs
- Visual: The character jitters when the camera follows them at approx the same speed.
- Double jump using the umbrella.
- Two landing sounds when coming from a platform down to a platform directly below.

TODO
- make the camera "lock on to" the player when their velocities are similar so that the jittering does not occur
=======
## Benjamin 13.3.2024

Made a proto level. Colour codes: yellow = chasing dog; blue = window; red = spikes; brown = honing (bird?); green = cat.
UPDATE: Done messed up. Problems with Github - overwrote Sam's demo. After a long reverting session the two should be separate and navigable. This problem should not arise in the future, as long as I remember to edit a duplicated file, and not the original.
