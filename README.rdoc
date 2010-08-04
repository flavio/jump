Jump, a bookmarking system for the bash shell.
==============================================

Introduction
------------

Jump is a tool that allows you to quickly change directories in the bash
shell using bookmarks. Thanks to Jump, you won't have to type those long
paths anymore. 
Jump was inspired by go-tool by ActiveState
(<http://code.google.com/p/go-tool/>).

Usage
-----

Say you often work in a directory with a path like
`/Users/giuseppe/Work/Projects/MyProject`. With Jump you can add a bookmark
to it:

    $ jump add myproject

From now on you can jump to your project just by typing:

    $ jump to myproject

You can even append subfolders to the bookmark name!

    $ jump to myproject/src/
    
You can take a look at all your bookmarks with the `list` command:

    $ jump list

To delete a bookmark you don't need anymore, use the `delete` command:

    $ jump delete myproject

Don't remember a command? Just type:

    $ jump help

Installation
------------

I'm not shipping compiled binaries at the moment, so you'll have to compile
Jump from the sources. That's not hard though:

    $ gcc -o jump-bin jump.c
    $ sudo cp jump-bin /usr/bin

In order to be able to change directories, Jump needs a shell driver you'll
have to add to your bash configuration file (e.g. `~/.bash_profile`):

    function jump {
        if [ "$1" == "to" ] && [ "$2" != "" ]; then 
            cd $(jump-bin $*)
        else
            jump-bin $*
        fi
    }

If you prefer a shorter command to type even less, just rename the function
with a shorter name (e.g. `function j {...}`).

&copy; 2010 Giuseppe Capizzi (<g.capizzi@gmail.com>)