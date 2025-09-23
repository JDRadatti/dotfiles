#!/bin/bash

# Set the destination directory.

DEST_DIR=$HOME

# Array of files and directories to ignore.
declare -a IGNORE_LIST=(
  "."
  ".."
  ".git"
  "README.md"
  "setup.sh"
)

# Check if a file/directory should be ignored
is_ignored() {
  local target="$1"
  for ignore_item in "${IGNORE_LIST[@]}"; do
    if [ "$target" = "$ignore_item" ]; then
      return 0
    fi
  done
  return 1
}

# Create the destination directory if it doesn't exist
if [ ! -d "$DEST_DIR" ]; then
  mkdir -p "$DEST_DIR"
  if [ $? -ne 0 ]; then
    echo "Error: Could not create destination directory '$DEST_DIR'" >&2
    exit 1
  fi
fi

# Loop through all files and directories in the current directory
for item in .[!.]* *; do
  # Check if the item should be ignored
  if is_ignored "$item"; then
    continue
  fi
  # Create the symlink in the destination directory
  ln -s "$PWD/$item" "$DEST_DIR/$item"
done

echo "Symlinks created in '$DEST_DIR'"
exit 0

