# Why using a Linux nativ binary in wine env

This came to my mind during the use of a programm (Streamer.bot) where I used a shoutout C# script.
But I had to use a external binary for it.
An it was, since Streamer.Bot is run through wine, a windows binary.

# The Solution

Instead of installing the dependencies for example phyton, we can use a trick.
Symbolic links!
Sound strange but it works, as long as you made the .sh (which could also an .exe in wine prefix) script executbale.
Well a simpler way is to just create an .sh script that you call .exe inside of wine prefix.

But the symbolic link has some quirks to it
You can target directories with your Linux user rights without making them accessible for the wine envoriment.
In my case I just need the programm to do it's thing and then post the string into OBS (which is Linux nativ anyways)

A symbolic link would look this
```
ln -s /path/to/yourscipt.sh /path/to/wine/prefix/drive_c/some/path/yourscipt.exe
```