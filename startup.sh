terraform apply -auto-approve &&
openshift-install --dir ocp-4.2  wait-for bootstrap-complete &&
terraform apply -auto-approve -var 'bootstrap_complete=true' &&
openshift-install --dir ocp-4.2 wait-for install-complete
