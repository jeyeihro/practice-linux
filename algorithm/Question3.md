# TL; DR
Although this is the algorithm that underlies this program, 

it is not particularly important for most people to know. 

It is, in a manner of speaking, my **memorandum**, so busy people should not read it.

# Overview
In question 3, how dynamic directories and files are provided by the contestant is shown below.

# 1st step
First, imagine a diagram of the file structure before and after the change. So, like this:

before)
```
dir1
  |-subdir1
  |  |-file1
  |  |-file2
  |
  |-subdir2
  |  |-file3
  |  |-file4
  |
  |-subdir3
     |-file5
     |-file6

dir2
  |-subdir4
  |  |-subsubdir1
  |  |  |-file7
  |  |
  |  |-subsubdir2
  |     |-file8
  |
  |-subdir5
  |  |-subsubdir3
  |  |  |-file9
  |  |
  |  |-subsubdir4
  |     |-file10
  |
  |-subdir6
     |-subsubdir5
     |  |-file11
     |
     |-subsubdir6
        |-file12
```

after)
```
dir1
  |-subdir1
  |  |-file1(Deleted)
  |  |-file2
  |
  |-subdir2
  |  |-file3(Deleted)
  |  |-file4
  |
  |-subdir3(Deleted)
     |-file5(Deleted)
     |-file6(Deleted)

dir2
  |-subdir4
  |  |-subsubdir1
  |  |  |-file7(Deleted)
  |  |  |-file1(Created)
  |  |
  |  |-subsubdir2
  |     |-file13(Renamed)
  |
  |-subdir5
  |  |-subsubdir7(Renamed)
  |  |  |-file9
  |  |
  |  |-subsubdir4
  |     |-file10
  |     |-file7(Created)
  |
  |-subdir6
     |-subsubdir5(Deleted)
     |  |-file11(Deleted)
     |
     |-subsubdir6
        |-file12
        |-subsubdir3(Created)
           |-file9(Created)

dir3(Created)
  |-subdir3(Created)
     |-file5(Created)
     |-file6(Created)
     |-file14(Created)
```

`Before the change` refers to the "as-is" file structure that the questioner, that means me, has prepared, and `after the change` refers to the "desired figure (i.e., the desired answer)" for the respondent of this game.

Strictly speaking, the transitions in the above diagram are only the results, but only the inputs and outputs of the questioner's simulated operations on the files and directories shown below:

- Copying files to a different directory

    Copy file1 to subsubdir1

- Move a file to another directory

    Move file7 to subsubsubdir4

- Copy a directory

    Copy subsubsubdir3 under subsubdir6

- Rename the directory

    Rename dir2/subdir5/subsubdir3 to subsubdir7

- Rename the file

    Rename file8 to file13

- Delete the file	

    Delete dir1/subdir1/file1
    Delete dir1/subdir2/file3

- Create directory

    Create dir3	

- Move a directory

    Move subdir3 under dir3

- Delete the directory

    Delete the entire subsubdir5

- Create an empty file

    Create file14	

- Change the permissions of the directory

    Change the permission of only subsubdir4 directory to 711

- Change permissions of all directories under the directory

    Change the permission to 700 for everything under subsubsubdir6 directory

- Copy the files

    (Assign the name ".bak" to the file. Keep the timestamp)

    Backup dir3/subdir3/file5 with .bak and keep timestamps

- Modify the contents of the file

    Edit file5

(The above mentioned questions are draft versions and may differ from the current behavior implemented in practice_linux.sh)

# 2nd step

The rest is very simple and primitive.

As you can see from `after the change`, there are 16 unique directories and 14 files, respectively.

This means that there are 30 unique, non-duplicate values for resources as concepts.

All that remains is to have these 30 unique values randomly generated each time a game is started.

When actually programming, all I have to do is look at the diagram before and after the change and define the same variable names, and bind `unique values` to them.

In this way, I can say that the variable names are as shown in the diagram, however, the value of the variable will be random each time.

# 3rd step

Random strings were generated using openssl, which is preinstalled on any decent Linux machine.
Lowercase letters a-z were used and the number of digits was set to 4. (No deep meaning here. It's just a feeling, really.)

Once I have 30 random, non-duplicate strings, all that remains is to dump them into the array.

Then, just like a stack and a queue, the stacked items are consumed one by one. The difference from the stack/queue mechanism is that it doesn't matter the order. It's just as long as it's random.

Specifically, I made it like this:

```
stock(){
    while [ ${#random_strings[@]} -lt 30 ]; do
        local random_string=$(openssl rand -base64 100 | tr -dc 'a-z' | head -c 4)
        if [ -z "${already_generated[$random_string]}" ]; then
            already_generated[$random_string]=1
            random_strings+=($random_string)
        fi
    done
    echo "${random_strings[@]}" > "$temp_file"
}

pop(){
    read -ra random_strings < "$temp_file"
    if [ ${#random_strings[@]} -gt 0 ]; then
        echo "${random_strings[0]}"
        echo "${random_strings[@]:1}" > "$temp_file"
    else
        echo "Error: No more strings left!"
        exit 1
    fi
}
```

Oops, you think there might be a more efficient way to do it? 

That makes my ears burn.

I've been working on this project for a while now, partly to relieve stress, partly out of a desire to just write a program without the constraints of the world.

If you have any complaints, please feel free to send me a pull request. Thank you in advance.

Also, the spelling of stack as stock instead of stack is intentional. It's just a groove, so don't worry about the details.

# 4th step
A minor problem was uncovered here.

There was a possibility that the logs directory used in Question 1 could overlap with these random strings.

This is a very rare possibility, but I could not ignore it.

In the logic I tentatively created in the 3rd step, the basic concept was to "pop from the `top` and delete what has been popped". So this was changed.

I defined the string "logs" as a unique reserved word, and then changed the pop method. Specifically, "pop from the `end` and delete what has been popped".

The final code was as follows:

```
stock(){
    # logs is a reserved word
    already_generated["logs"]=1
    random_strings+="logs"

    # modified (30 -> 31)
    while [ ${#random_strings[@]} -lt 31 ]; do
        local random_string=$(openssl rand -base64 100 | tr -dc 'a-z' | head -c 4)
        if [ -z "${already_generated[$random_string]}" ]; then
            already_generated[$random_string]=1
            random_strings+=($random_string)
        fi
    done
    echo "${random_strings[@]}" > "$temp_file"
}

pop(){
    read -ra random_strings < "$temp_file"
    if [ ${#random_strings[@]} -gt 0 ]; then
        # modified (top -> end)
        echo "${random_strings[-1]}"
        # modified (top -> end)
        echo "${random_strings[@]:0:${#random_strings[@]}-1}" > "$temp_file"
    else
        echo "Error: No more strings left!"
        exit 1
    fi
}
```