#!/bin/bash

set -eu
set -o pipefail

# Load vars
# shellcheck source=weekly-challenge-common.sh
. "$(dirname "$0")/weekly-challenge-common.sh"

WEEKLY_CHUNK="/tmp/weekly-chunk.cs"

expect << EOF
set timeout -1
spawn $CRAWL -name WeeklyChallenge -species random -background viable -extra-opt-last pregen_dungeon=true -extra-opt-last show_more=false -extra-opt-last weapon=viable -seed $RANDOM -dir $SAVE_BASE
expect "Found a staircase leading out of the dungeon."
send "\x13"
EOF

# If we don't wait, editing the save file fails
sleep 5

mv "$SAVE_BASE/WeeklyChallenge.cs" "$WEEKLY_CHALLENGE_PATH"

$CRAWL --edit-save "$WEEKLY_CHALLENGE_PATH" get chr "$WEEKLY_CHUNK"

# Sometimes this part fails and gets the wrong data (like, Jiyva's last name) ???
SPECIES=$(strings "$WEEKLY_CHUNK" | tail -1)
echo "$SPECIES" > "$WEEKLY_CHALLENGE_SPECIES"
BACKGROUND=$(strings "$WEEKLY_CHUNK" | tail -3 | head -1)
echo "$BACKGROUND" > "$WEEKLY_CHALLENGE_BACKGROUND"
