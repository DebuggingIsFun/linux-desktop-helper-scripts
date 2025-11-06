#!/bin/bash

base_dir="$(pwd)"

# Step 1: Extract all .zip files
echo "Extracting all .zip files..."
for zipfile in *.zip; do
    if [ -e "$zipfile" ]; then
        echo "Processing: $zipfile"
        top_level_dirs=$(unzip -l "$zipfile" | awk '{print $4}' | grep '/$' | awk -F/ '{print $1}' | uniq)

        if [ -n "$top_level_dirs" ]; then
            echo "Archive $zipfile already contains folders, extracting as-is..."
            unzip -o "$zipfile"
        else
            target_dir="${zipfile%.zip}"
            echo "No folder detected. Extracting $zipfile into $target_dir/"
            mkdir -p "$target_dir"
            unzip -o "$zipfile" -d "$target_dir"
        fi
    fi
done

# Step 2: Extract all .tar.gz files in the base directory
echo "Extracting all .tar.gz files in the base directory..."
for tarfile in "$base_dir"/*.tar.gz; do
    tar -xzf "$tarfile"
done


# Step 3: Look inside newly created folders for .tar.gz files, extract to base_dir, and delete source folders
echo "Looking for additional .tar.gz files inside subfolders..."
find . -mindepth 2 -type f -name "*.tar.gz" | while read -r inner_tar; do
    source_dir="$(dirname "$inner_tar")"
    echo "Found nested archive: $inner_tar"
    echo "Extracting $inner_tar into $base_dir"
    tar -xzf "$inner_tar" -C "$base_dir"
    echo "Removing source folder: $source_dir"
    rm -rf "$source_dir"
    echo "Removing all folders containing 'ubuntu' in their names..."
    find . -type d -name "*ubuntu*" -exec rm -rf {} +
done

echo "Extraction complete!"

# Step 4 Reanming Folder into Name for OBS-Studio Plugins Folder
echo "Renaming Folders that match Regex ^(.+)-[0-9]"
for dir in "$base_dir"/*/; do
    dir=${dir%/} # Remove trailing slash
    folder=$(basename "$dir")
    
    # Check if folder matches regex ^(.+)-[0-9]
    if [[ "$folder" =~ ^(.+)-[0-9] ]]; then
        base_name="${BASH_REMATCH[1]}"
        # Rename if target name doesn't exist
        if [ ! -e "$base_dir/$base_name" ]; then
            echo "Renaming folder '$folder' to '$base_name'"
            mv "$base_dir/$folder" "$base_dir/$base_name"
        else
            echo "Skipping rename, '$base_name' already exists"
        fi
    fi
done

# Step 5: Find and process .deb packages
echo "Searching for .deb packages..."
find "$base_dir" -type f -name "*.deb" | while read -r deb_file; do
    deb_dir="$(dirname "$deb_file")"
    echo "Processing .deb file found in: $deb_dir"

    (
        cd "$deb_dir" || exit 1
        ar x *.deb

        tar -xf data.tar.* 2>/dev/null

        mkdir -p "$deb_dir/bin/64bit"
        mkdir -p "$deb_dir/data"

        if [ -d "$deb_dir/usr" ]; then
            find "$deb_dir/usr" -type f -name "*.so" -exec mv {} "$deb_dir/bin/64bit/" \;
            find "$deb_dir/usr/share" -type d -name "obs-plugins" | while read -r obs_dir; do
                cp -r "$obs_dir/"* "$deb_dir/data/"
            done

            find "$deb_dir" -maxdepth 1 -type f -exec rm -f {} +
            rm -rf "$deb_dir/usr"
        fi
    )
done

echo "All extractions (including .deb) complete!"

# Step 6: Move all folders inside base_dir into $base_dir/test
echo "Moving all folders from $base_dir into $base_dir/test..."
dest_dir="$base_dir/test"
mkdir -p "$dest_dir" # use if you need to create it or are not sure if it exists 

shopt -s dotglob  # include hidden folders
for dir in "$base_dir"/*/; do
    # Skip the destination directory itself
    if [ "$dir" != "$dest_dir/" ]; then
        folder_name=$(basename "$dir")
        echo "Moving $folder_name into $dest_dir"
        mv -f "$dir" "$dest_dir/"
    fi
done

echo "All folders have been moved successfully to $dest_dir!"