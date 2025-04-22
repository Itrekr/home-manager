#!/usr/bin/env sh

LOGFILE="$HOME/Mimisbrunnr/Documents/Emacs/wordcount"
TODAY=$(date +%Y-%m-%d)

if [[ -f "$LOGFILE" ]]; then
    COUNT=$(grep "^$TODAY" "$LOGFILE" | awk '{ sum += $3 } END { print sum + 0 }')
else
    COUNT=0
fi

echo "📝 $COUNT woorden"
