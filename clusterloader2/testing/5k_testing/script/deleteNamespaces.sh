#!/bin/bash
# kubectl delete namespaces probes net-policy-test monitoring
kubectl delete namespaces cluster-loader monitoring probes
for i in $(seq 1 100)
do
  kubectl delete namespace podscale-$i &
done

wait