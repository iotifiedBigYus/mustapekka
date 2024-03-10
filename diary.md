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


## Sam, 5.3.24, 1000, version 0.1.3

Made a menu item that changes the jump button between o and up. It felt a bit janky and less is more, so the jump button is now only o. Might bring back up in the future. We most likely will use the x button, so two hands will be needed either way.

## Benjamin, 10.3.2024

Composed a diddy. Since it is my first tima using Pico8 as a DAW, this very well might not even be used in the final product. The cyper-punkiness does not match up to my vision of the game's visual aesthetic - but then again, it might be hard to create this desired soundscape in Pico8.
I will consider introducing other elements to the visuals, which would justify a more electronic soundscape. For now the dream of a Ghibli-inspired game stands, though.

