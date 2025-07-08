#!/bin/bash

# Check if all three parameters are provided
if [ $# -lt 3 ]; then
  echo "Usage: $0 <namespace_count> <node_count> <replica_count>"
  echo "Example: $0 25 5000 20"
  exit 1
fi

# Get parameters
NAMESPACE_COUNT=$1
NODE_COUNT=$2
REPLICA_COUNT=$3

# Generate timestamp in YYYYMMDD-HHMMSS format
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Base logs directory
LOGS_BASE="/home/itiagrawal/Projects/Cilium/perf-tests/clusterloader2/testing/5k_testing/logs"
mkdir -p "$LOGS_BASE"

# Create the log filename with timestamp + parameters
LOG_FILENAME="logs-${TIMESTAMP}-${NAMESPACE_COUNT}ns-${NODE_COUNT}nodes-${REPLICA_COUNT}replica.txt"
LOG_PATH="${LOGS_BASE}/${LOG_FILENAME}"

# Create a matching report directory (strip .txt)
REPORT_DIR="${LOGS_BASE}/${LOG_FILENAME%.txt}"
mkdir -p "$REPORT_DIR"

# Set the correct path to clusterloader
CLUSTERLOADER_PATH="/home/itiagrawal/Projects/Cilium/perf-tests/clusterloader2/clusterloader"

# Print information before executing
echo "Starting test with:"
echo "- Namespaces: ${NAMESPACE_COUNT}"
echo "- Nodes: ${NODE_COUNT}"
echo "- Replicas per deployment: ${REPLICA_COUNT}"
echo "- Log file: ${LOG_PATH}"
echo "- Report directory: ${REPORT_DIR}"
echo "- Timestamp: ${TIMESTAMP}"

# Execute the clusterloader command with the correct path
"$CLUSTERLOADER_PATH" --provider=aks --kubeconfig=/home/itiagrawal/.kube/config \
 --testconfig=/home/itiagrawal/Projects/Cilium/cl2/perf-tests/clusterloader2/testing/5k_testing/5k-test.yaml --v=5 \
 --enable-prometheus-server=True \
 --prometheus-storage-class-provisioner=disk.csi.azure.com \
 --prometheus-pvc-storage-class=default \
 --report-dir="${REPORT_DIR}" \
 --testoverrides=/home/itiagrawal/Projects/Cilium/cl2/perf-tests/clusterloader2/testing/5k_testing/scale-overrides.yaml \
 2>&1 | tee "${LOG_PATH}"

echo "Test completed. Log saved to: ${LOG_PATH}"
echo "Report saved to: ${REPORT_DIR}"