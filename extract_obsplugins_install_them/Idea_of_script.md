# Why was this script created?

Since I switched from Windows to Linux as a daily driver, I encounterd that OBS-Studio plugins on the Linu side are a bit diffrent to windows.

There are .deb files, tar.gz files and they need to be extracted and in some way converted.
Instead of doing this manaully, since I use a couple plugins and also like to update them, I thought let us try to get this "automated"

Since I had some experience with pwsh (Powershell) on Windows, learning shell scripts on linux is logicall.

## Features

- Takes current directory as $base_dir for working directory
- Unzips first all zip files in $base_dir (Stage 1)
- Untars tar.gz files in $base_dir (Stage 2)
- Search .tar.gz archives inside subfolders from Stage 2, extract them to base_dir, and clean up directories (Stage 3)
- Renaming of the folders to cut of numbers of the name via Regex (Stage 4)
- Looking in subfolders for .deb files and extracting them in a format ready to be used for obs-plugins folder (Stage 5)
- Moving all plugins in $base_dir into $dest_dir so obs-plugins folder location 

## Future impprovments

1) Make $base_dir and $dest_dir optional script arguments
2) The current script directory a fall back for $base_dir
3) Script shall detect where OBS Studio is installed e.g. as Flatpak, native or other methode


# Code Explanation

will follow soon