NOTE : update execute.sh CLUSTERLOADER_PATH and kubeconfig path - Update it to your system path [TO DO remove hardcode]

run `go build -o clusterloader cmd/clusterloader.go` in clusterloader 2 folder to build the library 
run `cd testing/5k_testing/scripts`
run `sh execute.sh <<no of namespaces>> <<no of nodes>> <<no of replica per deployment>>` to run the test 