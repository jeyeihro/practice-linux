# Overview
This program is designed for Linux beginners to practice Linux commands.

(Japanese Only)

# Feature
- Learn Linux commands in a **game** format
- The exercise, called **game**, are automatically generated at the start of sh.
- The algorithm for the questions is uniform, but the content of the questions changes dynamically each time the game is started. In other words, **no two questions are ever the same**.
- All messages in the game are in **Japanese**. Not in the near future, but something will be done about it soon.
.

# Get started
1. [git clone](https://github.com/jeyeihro/practice-linux.git)
2. `cd practice-linux/src`
3. `bash practice_linux.sh start`

Installation will be done at the same time the game is first started.

Although `practice_linux.sh` is a stand-alone executable sh, it must be invoked in the directory where `practice_linux.sh` is stored.

Bad Example: `bash src/practice_linux.sh start`

# Start of game
``
bash practice_linux.sh start
``

A new game will be started

# End of game
``
bash practice_linux.sh end
``

When you have solved the game, execute this command. The answer is then automatically evaluated. If any part of the answer is incorrect, the game continues. If all answers are perfect, the game ends and a rank and score are recorded based on the time spent playing the game.

# Other
Several other features are available, such as redisplaying question text, displaying hints, showing previous high scores, and formatting game data.

For more information, please run `bash practice_linux.sh` and check Usage and Options

# Environment
Bash on GNU Linux, which is common in the public domain.

(Maybe, but it doesn't work on macOS, sorry.)

# Roadmap
- English Support



