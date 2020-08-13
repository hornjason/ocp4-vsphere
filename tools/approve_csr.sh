#!/bin/bash

function check {

  # keep checking for CSRs until something 
  until [ $(oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}'|wc -l) -ge 1 ]
  do
    sleep 10
  done
  
 echo "Found CSRs" 
 approve
}

function approve {
  echo "Approving CSRs"
  oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs oc adm certificate approve
  sleep 10
}

for num in {1..10};
do
  if [[ $num -le 10 ]];
  then
    echo "Try # $num"
    num=$((num+1))
    check
  fi
done
