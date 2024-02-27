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
