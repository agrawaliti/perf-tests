#!/bin/sh

# Usage: ./cleanup_report_dir.sh /path/to/report-dir

REPORT_DIR="$1"

if [ -z "$REPORT_DIR" ] || [ ! -d "$REPORT_DIR" ]; then
  echo "Usage: $0 <report-dir>"
  echo "The provided path must be a directory."
  exit 1
fi

cd "$REPORT_DIR" || exit 1

# Find and delete files that do NOT start with the allowed prefixes
find . -type f ! \( \
  -name 'APIResponsivenessPrometheus*' -o \
  -name 'InClusterNetworkLatency*' -o \
  -name 'PodStartupLatency_PodStartupLatency*' \
\) -exec rm -v {} +

echo "Cleanup complete. Only APIResponsivenessPrometheus*, InClusterNetworkLatency*, and PodStartupLatency_PodStartupLatency* files remain."