#!/bin/bash

function check {

  # keep checking for CSRs until something 
  until [ $(oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}'|wc -l) -gt 1 ]
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

check
check
