#!/bin/bash

#
# OCP_DIR = Branch name from profile.env
env="env"
project=$(git rev-parse --show-toplevel)
ocp_wdir="${project}/${env}/${OCP_DIR}"

echo "Creating ocp [ ${ocp_wdir} ] dir "
[ ! -d "${ocp_wdir}" ] && mkdir "${env_path}/${OCP_DIR}"
#cp install-config.yaml ${OCP_DIR} &&  openshift-install create manifests  --dir ${OCP_DIR}
#sed -i 's/  mastersSchedulable: true/  mastersSchedulable: false/g' ${OCP_DIR}/manifests/cluster-scheduler-02-config.yml
#exit
cp install-config.yaml ${ocp_wdir} &&  
openshift-install create ignition-configs --dir ${ocp_wdir}
rm -f /var/www/html/ignition/bootstrap.ign
cp ${ocp_wdir}/bootstrap.ign /var/www/html/ignition/bootstrap.ign
chmod +r /var/www/html/ignition/bootstrap.ign

echo " sed in worker and control ignition files in tfvars"
# cat each ignition file to var
WORKER_IGNITION=$(cat ${ocp_wdir}/worker.ign)
MASTER_IGNITION=$(cat ${ocp_wdir}/master.ign)
sed -i '/^compute_ignition/!b;n;c'"$WORKER_IGNITION"'' ${project}/infra/terraform.tfvars
sed -i '/^control_plane_ignition/!b;n;c'"$MASTER_IGNITION"'' ${project}/infra/terraform.tfvars
##
echo "bootstrap_complete = "false""
sed 's/bootstrap_complete.*/bootstrap_complete = "false"/' ${project}/infra/terraform.tfvars
exit
cd ${project}/infra ; terraform apply -auto-approve &&
cd ${project} ; openshift-install --dir ${ocp_wdir}  wait-for bootstrap-complete &&
sleep 60 && cd ${project}/infra ; terraform apply -auto-approve -var 'bootstrap_complete=true' &&
cd ${project} ; openshift-install --dir ${ocp_wdir} wait-for install-complete
# after install change bootstrap_complete = 'true'
echo "bootstrap_complete = "true""
sed 's/bootstrap_complete.*/bootstrap_complete = "true"/' ${project}/infra/terraform.tfvars
