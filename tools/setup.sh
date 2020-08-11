#!/bin/bash

#
# OCP_DIR = Branch name from profile.env
project=$(git rev-parse --show-toplevel)
source ${project}/profile.env

env="env"
ocp_wdir="${GIT_ROOT}/${env}/${OCP_DIR}"

echo "Creating ocp [ ${ocp_wdir} ] dir "
[ ! -d "${ocp_wdir}" ] && mkdir "${ocp_wdir}"
#cp install-config.yaml ${OCP_DIR} &&  openshift-install create manifests  --dir ${OCP_DIR}
#sed -i 's/  mastersSchedulable: true/  mastersSchedulable: false/g' ${OCP_DIR}/manifests/cluster-scheduler-02-config.yml
# Template install-config.yaml to use branch name as cluster-id
# Template terraform.tvars to use branch name as cluster-id
cp ${GIT_ROOT}/env/install-config.yaml ${ocp_wdir} &&  
openshift-install create ignition-configs --dir ${ocp_wdir}
rm -f /var/www/html/ignition/bootstrap.ign
cp ${ocp_wdir}/bootstrap.ign /var/www/html/ignition/bootstrap.ign
chmod +r /var/www/html/ignition/bootstrap.ign

echo " sed in worker and control ignition files in tfvars"
# cat each ignition file to var
WORKER_IGNITION=$(cat ${ocp_wdir}/worker.ign)
MASTER_IGNITION=$(cat ${ocp_wdir}/master.ign)
sed -i '/^compute_ignition/!b;n;c'"$WORKER_IGNITION"'' ${GIT_ROOT}/infra/terraform.tfvars
sed -i '/^control_plane_ignition/!b;n;c'"$MASTER_IGNITION"'' ${GIT_ROOT}/infra/terraform.tfvars
##
echo "bootstrap_complete = "false""
sed 's/bootstrap_complete.*/bootstrap_complete = "false"/' ${GIT_ROOT}/infra/terraform.tfvars
cd ${GIT_ROOT}/infra ; terraform init ${GIT_ROOT}/infra &&  terraform apply -auto-approve &&

cd ${GIT_ROOT} ; openshift-install --dir ${ocp_wdir}  wait-for bootstrap-complete &&
sleep 60 && cd ${GIT_ROOT}/infra ; terraform apply -auto-approve -var 'bootstrap_complete=true' &&
cd ${GIT_ROOT} ; openshift-install --dir ${ocp_wdir} wait-for install-complete
# after install change bootstrap_complete = 'true'
echo "bootstrap_complete = "true""
sed 's/bootstrap_complete.*/bootstrap_complete = "true"/' ${GIT_ROOT}/infra/terraform.tfvars
