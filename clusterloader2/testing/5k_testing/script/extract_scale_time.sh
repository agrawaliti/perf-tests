#!/bin/bash
# filepath: extract_scale_times.sh

if [ $# -ne 2 ]; then
    echo "Usage: $0 <log_file> <output_directory>"
    exit 1
fi

LOG_FILE="$1"
OUTDIR="$2"

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' not found!"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTDIR"

# Extract scale-up time (step 05) - force text mode with -a
SCALE_UP_TIME=$(grep -a -B5 'step: 05.*create objects.*ended' "$LOG_FILE" | grep -a "maxDuration=" | tail -1 | sed 's/.*maxDuration=\([^,]*\).*/\1/')

# Extract scale-down time (step 08) - force text mode with -a  
SCALE_DOWN_TIME=$(grep -a -B5 'step: 08.*delete objects.*ended' "$LOG_FILE" | grep -a "maxDuration=" | tail -1 | sed 's/.*maxDuration=\([^,]*\).*/\1/')

# Create scale_time file in the specified output directory
SCALE_TIME_FILE="$OUTDIR/scale_time"
cat > "$SCALE_TIME_FILE" <<EOF
Scale-Up: ${SCALE_UP_TIME:-"NOT FOUND"}
Scale-Down: ${SCALE_DOWN_TIME:-"NOT FOUND"}
EOF

echo "Scale times extracted:"
echo "- Scale-Up: ${SCALE_UP_TIME:-"NOT FOUND"}"
echo "- Scale-Down: ${SCALE_DOWN_TIME:-"NOT FOUND"}"
echo "- Scale time file: ${SCALE_TIME_FILE}"