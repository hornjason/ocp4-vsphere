DIR=ocp-43
terraform apply -auto-approve &&
openshift-install --dir ${DIR} wait-for bootstrap-complete &&
#terraform apply -auto-approve -var 'bootstrap_complete=true' &&
openshift-install --dir ${DIR} wait-for install-complete
# after install change bootstrap_complete = 'true'
