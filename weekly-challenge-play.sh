#!/bin/bash

set -eux
set -o pipefail

NAME=$2
TEMP_CHUNK_PATH="/tmp/chunk.cs"

# Load vars
# shellcheck source=weekly-challenge-common.sh
. "$(dirname "$0")/weekly-challenge-common.sh"

# If they are already in the scores file, don't continue
#if grep -q ":name=$NAME:" "$SAVE_BASE/scores" ; then
#    echo "You've already played!"
#    exit 0
#fi

# If their save file doesn't exist, create it
if [[ -f "$SAVE_BASE/$NAME.cs" ]] ; then
  echo "User already has a save" >&2
else
  echo "Starting template game" >&2
  # Start a game as the target user
  expect << EOF
set timeout -1
spawn $CRAWL -name $NAME -species "$(cat "$WEEKLY_CHALLENGE_SPECIES")" -background "$(cat "$WEEKLY_CHALLENGE_BACKGROUND")" -extra-opt-last show_more=false -extra-opt-last weapon=viable -dir "$SAVE_BASE"
expect "Found a staircase leading out of the dungeon."
send "\x13"
EOF

  # If we don't wait, editing the save file fails
  echo "Sleeping 5 secs" >&2
  sleep 5

  # Extract their chr chunk
  $CRAWL --edit-save "$SAVE_BASE/$NAME.cs" get chr $TEMP_CHUNK_PATH
  # Now copy the weekly challenge to their save path
  cp "$WEEKLY_CHALLENGE_PATH" "$SAVE_BASE/$NAME.cs"
  # And replace the chr chunk
  $CRAWL --edit-save "$SAVE_BASE/$NAME.cs" put chr $TEMP_CHUNK_PATH
fi

# Start the game
exec $CRAWL "$@"
