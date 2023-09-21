# Overview
This program is designed for Linux beginners to practice Linux commands.

# Feature
- Learn Linux commands in a **game** format
- This exercise, called **game**, are automatically generated at the start of sh.
- This algorithm for the questions is uniform, but the content of the questions changes dynamically each time the game is started. In other words, **no two questions are ever the same**.
- This practice supports English and Japanese.

# Get started
1. [git clone](https://github.com/jeyeihro/practice-linux.git)
2. `cd practice-linux/src`
3. `bash practice_linux.sh start`

Installation will be done at the same time the game is first started.

Although `practice_linux.sh` is a stand-alone executable sh, it must be invoked in the directory where `practice_linux.sh` is stored.

Bad Example: `bash src/practice_linux.sh start`

**Alternatively**

If you are not familiar with `git`, 

download [practice_linux.sh](https://github.com/jeyeihro/practice-linux/blob/main/src/practice_linux.sh) from the link **Download raw file**, 

place practice_linux.sh anywhere on Linux, 

and run the following in the same directory as practice_linux.sh:

`bash practice_linux.sh start`


# Start game
``
bash practice_linux.sh start
``

A new game will be started

# End game
``
bash practice_linux.sh end
``

When you have solved the game, execute this command. The answer is then automatically evaluated. If any part of the answer is incorrect, the game continues. If all answers are perfect, the game ends and a rank and score are recorded based on the time spent playing the game.

# Options
Several other features are available, such as redisplaying question text, displaying hints, showing previous high scores, and formatting game data.

For more information, please run `bash practice_linux.sh` and check Usage and Options

# Environment
Bash on GNU Linux, which is common in the public domain.

(Maybe, but it doesn't work on macOS, sorry.)

# Roadmap
- Implementation of lap times for scores
- Minor modifications to score-related displays
- Implementation of difficulty level change function



