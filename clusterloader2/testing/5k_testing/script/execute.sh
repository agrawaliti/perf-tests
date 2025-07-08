#!/bin/bash

# Check if all three parameters are provided
if [ $# -lt 3 ]; then
  echo "Usage: $0 <namespace_count> <node_count> <replica_count>"
  echo "Example: $0 25 5000 20"
  exit 1
fi

# Resolve this script's directory, supporting symlinks
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

# The base directory is one level up from script/
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Paths relative to BASE_DIR
SCALE_OVERRIDES="${BASE_DIR}/scale-overrides.yaml"
LOGS_BASE="${BASE_DIR}/logs"
TESTCONFIG="${BASE_DIR}/5k-test.yaml"

# Get parameters
NAMESPACE_COUNT=$1
NODE_COUNT=$2
REPLICA_COUNT=$3

# Generate timestamp in YYYYMMDD-HHMMSS format
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

mkdir -p "$LOGS_BASE"

LOG_FILENAME="logs-${TIMESTAMP}-${NAMESPACE_COUNT}ns-${NODE_COUNT}nodes-${REPLICA_COUNT}replica.txt"
LOG_PATH="${LOGS_BASE}/${LOG_FILENAME}"
REPORT_DIR="${LOGS_BASE}/${LOG_FILENAME%.txt}"
mkdir -p "$REPORT_DIR"

# Optionally dynamically find clusterloader binary if it's co-located, otherwise fallback
# You can change this line if your clusterloader binary is elsewhere
CLUSTERLOADER_PATH="${CLUSTERLOADER_PATH:-${BASE_DIR}/../../../../clusterloader2/clusterloader}"

# Print information before executing
echo "Starting test with:"
echo "- Namespaces: ${NAMESPACE_COUNT}"
echo "- Nodes: ${NODE_COUNT}"
echo "- Replicas per deployment: ${REPLICA_COUNT}"
echo "- Log file: ${LOG_PATH}"
echo "- Report directory: ${REPORT_DIR}"
echo "- Test config: ${TESTCONFIG}"
echo "- Scale overrides: ${SCALE_OVERRIDES}"
echo "- Timestamp: ${TIMESTAMP}"

# Write overrides file
cat > "$SCALE_OVERRIDES" << EOF
CL2_NAMESPACES: $NAMESPACE_COUNT
CL2_NODES: $NODE_COUNT
CL2_REPLICAS_PER_DEPLOYMENT: $REPLICA_COUNT
CL2_POD_STARTUP_LATENCY_THRESHOLD: "90s"
CL2_NAMESPACE_PREFIX: "podscale"
EOF

"$CLUSTERLOADER_PATH" --provider=aks --kubeconfig=~/.kube/config \
 --testconfig="$TESTCONFIG" --v=5 \
 --enable-prometheus-server=True \
 --prometheus-storage-class-provisioner=disk.csi.azure.com \
 --prometheus-pvc-storage-class=default \
 --report-dir="${REPORT_DIR}" \
 --testoverrides="$SCALE_OVERRIDES" \
 2>&1 | tee "${LOG_PATH}"

echo "Test completed. Log saved to: ${LOG_PATH}"
echo "Report saved to: ${REPORT_DIR}"

sh cleanup_report_dir.sh "$REPORT_DIR"