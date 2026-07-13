# Intermaze

Intermaze is a game based on a puzzle I designed. 
The game has online multiplayer and uses hole punching to start a host server.
The game can also be hosted localy with a keyboard user and a controller user.

## Controls

WASD - Move
Shift - Dash
Space - Open Map
F - Use item at top of pocket
E - Pickup item from top of chest

# How it started

The mock exams for A level computer science are not shortened down. They are 2h30m and everyone finishes in 1h30m leaving an hour to check your work. It does not take this long and often leaves us incredibly bored and the rest of the exam feels like a punishment for picking the subject. It's not like misusing this extra time was affecting our grades either as most of us were getting A's or A*'s. 

So during one of these overly long winded exams I decided to make a game for myself that I could play on paper. I made an algorithm that would turn directions into numbers in their own cells resulting in a sort of encrypted version of the path I took. Then after doing so for long enough that I forgot the path I went on, I would try to decrypt this path. I was playing a bit of Cult of the lamb during these times so I decided to turn this puzzle into a game where each cell on the map had a PvE challenge that you must clear before going to the next room. The combat system is heavily inspired by cult of the lamb. First I made it into a [pygame program](https://github.com/ashley-jclarke/sum-puzzle) without all the game components but I wanted to play it with friends and have fun so I then turned it into a multiplayer game!

# Detailed

<img width="1152" height="648" alt="image" src="https://github.com/user-attachments/assets/75833989-310b-46f2-9e6d-4331542007b5" />
<img width="1152" height="648" alt="image" src="https://github.com/user-attachments/assets/130772a7-4ead-4fd9-92a5-41c557b58c07" />

The aim of the game is to get through the maze back to the priest. The maze does not follow conventional rules though. You're given a map to show you the way but the path is encrypted. You need to work out the path from it.

<img width="1152" height="648" alt="image" src="https://github.com/user-attachments/assets/1bf0c54c-b5ce-45e1-bdd5-4616ec6cc462" />

You must also beat monsters in the maze. 
Only once a room has been cleared can you move to the next room.

<img width="1152" height="648" alt="image" src="https://github.com/user-attachments/assets/f3f9819f-ed76-4825-b6da-46b10f625127" />
<img width="1152" height="648" alt="image" src="https://github.com/user-attachments/assets/b2aa0dfa-ae0a-4050-99f5-4dcadf641644" />

Clearing a room reveals chests that give you temporary power boosts.

Health potion restores your health.
Strength potion boosts the damage you do to enemies.
Speed potion increases your speed.

<img width="1152" height="648" alt="image" src="https://github.com/user-attachments/assets/9abb2c13-f8ff-4149-957d-05f08d46ddd9" />

Clue rooms will show you what the current value your path is. This can be used to check your route or to get a bearings of where you are. They come at a price as they only reveal after you clear all the enemies in a boss room.

<img width="800" height="450" alt="2026-07-1306-54-26-ezgif com-video-to-gif-converter" src="https://github.com/user-attachments/assets/82c4d2a9-b4b7-443e-8d14-b6bb9e6ff040" />

A friend said the puzzle was too hard to follow so I added error checking and the room you're currently in would flash.

<img width="800" height="450" alt="2026-07-1306-54-261-ezgif com-video-to-gif-converter" src="https://github.com/user-attachments/assets/852d1449-71e6-4fae-947f-d2c46139bf4d" />


# The puzzle

If this were your typical labyrinth, going up, left, down and then right would return you to where you originally were. This is not how this maze works. Each room you go to branches to new rooms that are only accessible with the path that you have taken. Their are priests who create mappings of these rooms but they are difficult to read. Why do they make you work out the order of up down left rights? We don't know. They're quite unpredictable and toy with reality in their spare time.

<img width="1152" height="648" alt="image" src="https://github.com/user-attachments/assets/ad3286ed-7a0d-4bce-a9de-af72647006bf" />


You start in a room that is numbered "1". This is the room with the priest in it. The next room will always be numbered "2". This is because going to a room that is adjacent to another on the map increments your score by 1. Your score cannot exceed 9, however, so this score wraps. The answer to this puzzle is a list of directions you must travel in e.g.: Left, Right, Up, Up, Down, Right. These directions must get you to X.

- Your score starts at 1
- If your score is 9 and you go to a new room (one that can be entered without crossing another) your score wraps round to 1

The answer to the image below is Up, Right, Down, Left, Left, Up, Left, Down.

It is likely you could work out moves 1-3 without knowing the gimmick of this map but once you get to room 4, there is no room 5.
So where do you go?

- You cannot land on a square that already has a number

If you were to go left from 4 you would land on room 1. This is not allowed as that would erase the data of room 1. So instead you keep going in that direction until you find an empty position. For each square you land on before reaching that empty position, you add its value to your score. Why? Because the priests are cruel and like to make things complicated. Then once you cross the boundary between a non-empty room and an empty room, you add 1 to your score.

In the example below, from 4 we go left. Going left one position lands us on room 1. This is not allowed so we add 1 (the rooms number) to our score (4) giving us 5. Then we go left again to the empty position. Going from a non-empty position to an empty position increases our score (5) by 1 giving us 6. This makes the empty position room 6.

Then the rest is intuitive as no more non-empty rooms are crossed.

<img width="936" height="526" alt="image" src="https://github.com/user-attachments/assets/e9f5bcc2-714b-45a1-93e1-bf6d233903bf" />

A program I wrote to practice this can be found [here](https://github.com/ashley-jclarke/sum-puzzle). This tool currently uses base 16 which might make it more difficult. This program also has the option to have consecutive oposite directions which the game does not. The game does not implement this as going back through the door you came through will return you to the previous room. This allows players to backtrack if they made a mistake.



# Problems encountered and fixed during development

## Enemy attack positions didn't line up with the animation

I initially used an Area2D to detect the player in the attack zone. This Area2D was centered around the sprite. This was so that the area of attack would be covered for both directions that an enemy sprite can face. This was used at first because only the sprite would rotate using the flip_h attribute. Later on I corrected this by making the Area2D a child of the sprite and then setting its scale.y to -1 if I needed to mirror it. This allowed me to move the Area2D to the area of attack the animation suggests and would keep it feeling accurate in the game.

This fix added more gameplay benefits as it allowed players to dodge attacks made by enemies by dashing behind them. Dodging an attack was possible before but it could not immediately be followed by an attack as the player wouldn't be close enough.

## Maze generation causing game freeze due to generating an infinite loop

The map wraps so going left multiple times will get you to the right side of the map and as you can't go over a position that you have already been on this meant that the generator was stuck in a loop trying to find an empty position along that row/column. To fix this I checked if there was a possible position before appending it to the answer. This fixed the game freezes.

## Undoing a move desynced the player position and the map

Using the normal puzzle rules it is not possible to backtrack purely by going back through the door you came in from. Initially doing this tried to send you past the room you came in from and onto the position above it. To fix this I made it so going back through the door you came in from would pop the move stack. I also then had to make it so that mazes could not generate with a direction followed by its opposite (left cannot be followed by right and up cannot be followed by down vice versa). To fix this I removed the last moves opposite from the move pool when generating the maze.

## Clue rooms didn't line up with the true answer

The map that is shown to the user starts at 1. This is because that is what people are used to. 1 is the first index to non-programmers. Under the hood of the game though, the map starts at 0. The clue rooms took the true value of the room which was 1 off from what the player would expect it to be. This was an easy fix as all I had to do was add 1 to the value before displaying it.

## Explored rooms changed appearance

A room is randomly generated upon entering. Before fixing this, this also meant rooms that were back tracked. To fix this I stored the path of traversed rooms and the id of the room type together. I then changed the room enter code to check if the path was already in this list. If it was then the room would be cleared and the room type would be restored. If not then it would generate a new room. It was possible to serialise this as a each direction in the path is a base 4 number meaning that any path could be turned into a unique integer. This made syncing between players over a network much easier.

## Jittery player movement

Players sent their position to the server and then the server sent those positions to each other player. Enemies were not synced over network as their is no randomness to their AI so as long as each player had the same game state then the AI's would act the same. To fix the jitter I lerped the position of the players.


