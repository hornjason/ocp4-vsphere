#!/bin/bash
# OCP_DIR = Branch name from profile.env
source ${project}/profile.env

terraform destroy -force
rm -rf  ${OCP_DIR}
