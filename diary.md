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

Added auto_jump boolean. Making manual jumping the default. Feels kinda weird, but It's better when you are trying to reach stuff and not wanting jumping off when you land.

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


## Sam, 31.3.2024

Took a look into the code of jelpi.

## Sam, 1.4.2024

Experimented with new textures.

## Sam, 3.4.2024

Made a gimp file where I fade each color to black and look what pico-8 color it corresponds to. Not implementing it yet since I might change the color palette.

Made the horizontal and vertical acceleration of the umbrella independent and the horizontal acceleration independent of velocity. It feels more 'natural' in a game-control sense, but it's not very true to nature anymore.

The opening of the umbrella is now animated, but I'm not crazy happy about how it looks in game.

New experimental textures added, and with it a new palette. The palette consists mostly of gloomier colors, but I think it has a vibe that could work. The the wall bricks are too in your face / noisy atm, but the ground bricks look nice. *More testing needed*


## Sam, 9.4.2024

Experimented some more with the textures. Simplified them and made room for light gray in the palette. Nevermind – two. I forgot you don't need one dedicated transparency color. Adding a dark strip at the south-east sides of sprites really makes them pop. I like how its looking B). Made a demo with a house.

had to ditch dark brown to make space for black. Would look slightly better with it, but the roofs really need dark maroon that can't be replaced with gray.

I'm thinking that I could remove the umbrella tilting, making the character accelerate by shear willpower. This would make the graphics and animations smoother. I'm also thinking that the game should check if the player has enough room above to deploy the umbrella so it doesn't deploy into ceilings.


## Sam, 10.4.2024

Refined the movement a bit. If the player is going faster than the walking speed when beginning to walk the velocity gradually down to the walking speed.


## Sam, 11.4.2024

Remade the character front end logic so that the umbrella can be put away after landing. I'm happy with the animation. Refined it further and made a new sprite for the character putting down their hand. Fixed a problem with an acceleration spike when landing at high speed and walking in the opposite direction.

TODO:
- make the camera follow the sprite (including offset) and not the hitbox
- add vertical "nudging"


## Sam, 12.4.2024

Added approximate vertical "nudging". The character might move back a little bit but it works alright. Added sfx for the umbrella. Almost what I want but it might get a bit annoying in the long run.

## Sam, 13.4.2024

Refined the vertical "nudging" and it's animation.

## Sam, 14.4.2024

I made the code messy. After making collisions with a sofa I noticed the character moved weirdly, most likely due to the friction being calculated in a different spot. Had to go back to an earlier version to fix it, moving aside the newer broken version. Note to self: Commit when it works.

There is now a movable sofa! It moves physics based, but it could be simplified.

I think the friction still needs fixing.

## Sam, 15.4.2024

It feels like the front end code for the character was too complex, so I'm trying to dumb it down. I'm gonna have to leave it in a visually broken state for now.

## Sam, 21.4.2024

The player code is somewhat cleaner now, but still bloated. I dislike that there is two umbrella timers, one for the drag and one for the sprite.

There is a bug where the sofa starts pushing you if you change direction beside it. I'm thinking of making actor collisions not physics based, so it will get fixed later.

Friction is now applied separate from running, so changing direction feels sluggish.

## Sam, 28.4.24

Added Sidner Olin to the team to give ideas and to help develop concepts.

Right now I'm thinking that the game should be about solving puzzles to get your cat. I'm focusing on making the character movement feel just right, after which I will start working on the game mechanics. The first one being collisions between actors, which should not be too physics based.

I'm realizing that exponential curves could generally be the move. By making umbrella drag exponential instead of quadratic the response feels better and the need for timers is removed. Determining a terminal velocity is also much easier since the drag (friction) is reduced to terminal velocity and how fast you approach it. The approaching starts only when descending faster than the terminal velocity.

I'm going to try to use friction when something slows down exponentially, and drag when the speed reduction is quadratically proportional to the speed.

## Sam, 29.4.24

Kinda stuck with the movement, so I took a loot at the celeste 2 running and implemented it in the game. They use linear acceleration and it feels alright. It has a very sudden stop so the walking animation might continue a little too long.

I took the input code from celeste 2 with global input variables.

## Sam, 14.5.24

Made the linear player acceleration a little smaller. Tried making the gliding linear and added a menu item to toggle between the two gliding modes.

## Sam, 16.5.24

Less is more. Made the horizontal umbrella movement linear and the jump height the same height each jump. I also made the jump only two blocks high. The couch is still buggy.

## Sam, 18.5.24

Cleaned up the code somewhat. Have been trying to get pushing to work. I could make the player the only accelerating thing in the game, but it feels restricting, so I'm making every actor push the same way. I'm wondering if the game should be more about moving stuff around than moving oneself.

At some point my warning bells went off, but I was too stubborn. A universal pushing mechanic turned out to be a technical rabbit hole into which I dug myself deeper and deeper. I got myself out in the end but not without a fight with my inner perfectionist. The pushing of sofas now work without any noticeable bugs (limited testing) but you can only move one thing at a time. Pushing two sofas stops the player movement.

I did do some sprites of the character pushing things to the side, but I don't think they'll be used.

## Sam, 3.6.24

Added a function that fades the player to black. It might be used when going up stairs. Also added a dog with running a animation. It looks kinda goody but it will do.

I'm pretty unsure of what the game is going to play, but the umbrella mechanic might have to go. Its either going to be some kind of a puzzle game, or a game with enemies (like dogs and parrots - pets) that hinder the player. The core idea is still to get to your missing cat.

## Sam, 5.6.24

Added eye sight using digital differential analysis (DDA). Taking inspiration from games like Robbery Bob, the dog will react when it sees the player. 

## Sam, 6.6.24

The dog now runs towards the player if it sees it. I took a bark sound effect made by Gruber from the pico8 game secret santa.

TODO:
- the dog should not notice the player if the slope of the sight line is big.


## Sam, 22.6.24

Made a mountain in the background and added slope to the dog target code.

## Sam, 29.6.24

Sidner is now on the team. We tweaked the dog enemy and Sidner started making a level. A possible direction for the game is to have the dog appear in every level and making the levels increasingly clever / harder. To outwit the dog the player would find gadgets.

## Sam, 30.6.24

While working on bounce during collision I found an interesting thing. The bounce is quantized using the ratio of the speed after collision compared to the speed before (coefficient of restitution). When a thing hits the ground it is snapped to the ground and given an upwards velocity timed by bounce. When a thing is dropped, the jump height should decrease exponentially, but it instead approaches a set height and speed during takeoff. Here are the values I found.

| bounce | approaches speed  |
|--------|-------------------|
| 1      |            0.2691 |
| 0.95   |            0.1843 |
| 0.9    |            0.1052 |
| 0.85   |            0.0757 |
| 0.8    |            0.0556 |
| 0.75   |            0.0458 |
| 0.7    |            0.047  |
| 0.65   |            0.0363 |
| 0.6    |            0.0375 |
| 0.55   |            0.0258 |
| 0.5    |            0.0267 |
| 0.45   |            0.0276 |
| 0.4    |            0.0143 |
| 0.35   |            0.0148 |
| 0.3    |            0.0154 |
| 0.25   |            0.016  |
| 0.2    |            0.0166 |
| 0.15   |            0.0174 |
| 0.1    |            0.0182 |
| 0.05   |            0.02   |
| 0      |            0.02   |

The wonkiness is most likely due to air resistance. 0.02 is the gravitational acceleration.

I never learn. I once again got myself into a technical rabbit hole. My thought was that using integration you could get the exact position and velocity after a bounce. I did the math and implemented it in code, but it does not line up, so I'm going to skip it and go with the _stop and flip speed_ approach.

## Sam, 2.7.24

The player now throws tennis balls instead of gliding with the umbrella. The dog prefers to chase the balls, but a ball has a limited life time so it eventually goes after the player.

There was a bug when climbing onto a 2m block. The player would get a boost due to the game nudging the player onto the edge. The game now only nudges if there is a 1m opening and it will stop vertical speed when nudging.


## Sam, 4.7.24

Started on some forest graphics.


## Sam, 7.7.24

Implemented a forest background with parallax.

## Sam, 8.7.24

The cat is now an actor that triggers an iris out and loads the next level. Cleaned up the code by removing remnants of umbrella and pushing code and creating a util.lua file. Started on a state machine, but as of now there is only a 'play' state.

TODO:
- make the dog chase the player if it can't see any balls.

## Sam, 17.7.24

Got the a star algorithm to work with the dog pathfinding, but it gets really slow when it does not find a path. Might tweak it so that it searches only for the next best move, not the whole path. Before that I need the dog to jump and look good doing so.

The game now remembers what cells it has cleared and resets before he next level is initialized.

Tried making the camera follow the player exactly, but it didn't feel as nice as the current movement.

## Sam, 19.7.24

Changed the trees in the background to a darker red color so that the foreground can use dark green.

Made a new walking animation for the dog that looks good while jumping. I think I nailed it.

Started on a new pathfinding algorithm that generates a graph of paths.

TODO:
- fix bug where player leaves ground while jumping under a block

## Sam, 26.7.24

Worked on the pathfinding. The idea is based on Atrejo's algorithm, but the logic regarding reach by jumping is still not done.

## Sam, 28.7.24

I now got the pathfinding to work as I imagined, except for some problems. It needs to be optimized, the dog can get stuck jumping on the edge between coordinates, and the dog should try to get as close to the player as possible even though they can't reach them. Besides that I'm happy that I got it somewhat working.

## Sam, 1.8.24

Tried to optimize the pathfinding by making the graph account for the jumping and falling heights of the dog. It got real confusing and I scrapped the idea. I'm having a hard time structuring the pathfinding in a logical way. The pathfinding should work like this:

1. When a dog finds a target it starts chasing it by getting a direction from a direction map
2. The direction map tied to the target is updated
3. If there is no direction that leads to the target, the dog should pathfind to the point that is closest to the target


## Sam, 2.8.24

Got the dog to go as close to the player as possible even if it can't reach them. The pathfinding has yet to be optimized but it is on its way. There is a bug where the dog descends platforms it shouldn't.

## Sam, 4.8.24

Some cleanup, and some more work on the pathfinding. Solid blocks might create some problems.

## Sam, 12.8.24

Made the dog continue strafing until it reaches inside the next cell, this way it wont stop walking when it emerges from under a solid block, expecting to jump.

When saving the .p8 it warned of being too large. Will have to do some cleanup.

## Sam, 1.9.24

The balls stick to the wall when throwing them to the right beside one. Tried some debugging but haven't found the reason yet. I suspect that the collision detection does not work as intended.


## Sam, 4.9.24

Ignored the dog and the ball for now and started working on fall damage and hp. I'm thinking that I don't want a health bar, but rather communicate health by making the player flash red. Fall damage does not feel consequential atm, so it needs tweaking and some sfx to go with it. The level now restarts when you die.


## Sam, 8.10.24

The falldamage kinde sucked so I sacked it. I Noticed the ball got stuck inside the wall when thrown next to it, so I spent some time engineering an "unstuck" function that finds the closest point in the immidiate neighbors that is not stuck. I ended up not using it because you could just not make it spawn inside the wall.

After that I noticed that the ball does not bounce on a platform if it at the level of your feet. Fixed it.

I changed how gravity and jumping works. Gravity gets smaller when jumping but returns to normal after getting to the apex or letting go. Tinkered with different gravities, but I like the 0.02 I've been using so far.
