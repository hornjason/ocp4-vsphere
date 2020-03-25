#!/bin/bash

#
OCP_DIR="ocp-43"

echo "Creating ocp dir "
[ ! -d "${OCP_DIR}" ] && mkdir ${OCP_DIR} 
#cp install-config.yaml ${OCP_DIR} &&  openshift-install create manifests  --dir ${OCP_DIR}
#sed -i 's/  mastersSchedulable: true/  mastersSchedulable: false/g' ${OCP_DIR}/manifests/cluster-scheduler-02-config.yml
#exit
cp install-config.yaml ${OCP_DIR} &&  
openshift-install create ignition-configs --dir ${OCP_DIR}
rm -f /var/www/html/ignition/bootstrap.ign
cp ${OCP_DIR}/bootstrap.ign /var/www/html/ignition/bootstrap.ign
chmod +r /var/www/html/ignition/bootstrap.ign

echo " sed in worker and control ignition files in tfvars"
# cat each ignition file to var
WORKER_IGNITION=$(cat ${OCP_DIR}/worker.ign)
MASTER_IGNITION=$(cat ${OCP_DIR}/master.ign)
sed -i '/^compute_ignition/!b;n;c'"$WORKER_IGNITION"'' terraform.tfvars
sed -i '/^control_plane_ignition/!b;n;c'"$MASTER_IGNITION"'' terraform.tfvars
##
echo "bootstrap_complete = "false""
sed 's/bootstrap_complete.*/bootstrap_complete = "false"/' terraform.tfvars
terraform apply -auto-approve &&
openshift-install --dir ${OCP_DIR}  wait-for bootstrap-complete &&
sleep 60 && terraform apply -auto-approve -var 'bootstrap_complete=true' &&
openshift-install --dir ${OCP_DIR} wait-for install-complete
# after install change bootstrap_complete = 'true'
echo "bootstrap_complete = "true""
sed 's/bootstrap_complete.*/bootstrap_complete = "true"/' terraform.tfvars
