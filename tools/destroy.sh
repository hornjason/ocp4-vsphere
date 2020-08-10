#!/bin/bash
# OCP_DIR = Branch name from profile.env
source ${GIT_ROOT}/profile.env

terraform destroy -force
rm -rf  ${OCP_DIR}
