#!/bin/bash

#
# OCP_DIR = Branch name from profile.env
project=$(git rev-parse --show-toplevel)
source ${project}/profile.env

env="env"
ocp_wdir="${GIT_ROOT}/${env}/${OCP_DIR}"

echo "Creating ocp [ ${ocp_wdir} ] dir "
[ ! -d "${ocp_wdir}" ] && mkdir "${ocp_wdir}"
cp -Rf ${GIT_ROOT}/infra/ ${ocp_wdir}/infra/ && mv ${ocp_wdir}/infra/terraform.tfvars.${OCP_DIR} ${ocp_wdir}/infra/terraform.tfvars &&
# copy terraform code to ephermeral ocp_wdir so not to interfere with other branches
#cp install-config.yaml ${OCP_DIR} &&  openshift-install create manifests  --dir ${OCP_DIR}
#sed -i 's/  mastersSchedulable: true/  mastersSchedulable: false/g' ${OCP_DIR}/manifests/cluster-scheduler-02-config.yml
# Template install-config.yaml to use branch name as cluster-id
# Template terraform.tvars to use branch name as cluster-id
cp ${GIT_ROOT}/env/install-config.yaml.${OCP_DIR}  ${ocp_wdir}/install-config.yaml &&  
openshift-install create ignition-configs --dir ${ocp_wdir} &&
rm -f /var/www/html/ignition/bootstrap.ign
cp ${ocp_wdir}/bootstrap.ign /var/www/html/ignition/bootstrap.ign
chmod +r /var/www/html/ignition/bootstrap.ign

echo " sed in worker and control ignition files in tfvars"
# cat each ignition file to var
WORKER_IGNITION=$(cat ${ocp_wdir}/worker.ign)
MASTER_IGNITION=$(cat ${ocp_wdir}/master.ign)
sed -i '/^compute_ignition/!b;n;c'"$WORKER_IGNITION"'' ${ocp_wdir}/infra/terraform.tfvars
sed -i '/^control_plane_ignition/!b;n;c'"$MASTER_IGNITION"'' ${ocp_wdir}/infra/terraform.tfvars
##
echo "bootstrap_complete = "false""
sed 's/bootstrap_complete.*/bootstrap_complete = "false"/' ${ocp_wdir}/infra/terraform.tfvars
cd ${ocp_wdir}/infra; terraform init ${ocp_wdir}/infra &&  terraform apply -auto-approve &&
cd ${GIT_ROOT} ; openshift-install --dir ${ocp_wdir}  wait-for bootstrap-complete &&
sleep 60 && cd ${ocp_wdir}/infra ; terraform apply -auto-approve -var 'bootstrap_complete=true' 

# kick off approve_csr.sh
nohup ${GIT_ROOT}/tools/approve_csr.sh & #> approve_csr 2>&1 & 
cd ${GIT_ROOT} ; openshift-install --dir ${ocp_wdir} wait-for install-complete 
# after install change bootstrap_complete = 'true'
echo "bootstrap_complete = "true""
sed 's/bootstrap_complete.*/bootstrap_complete = "true"/' ${ocp_wdir}/infra/terraform.tfvars
