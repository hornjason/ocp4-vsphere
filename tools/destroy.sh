#!/bin/bash
# OCP_DIR = Branch name from profile.env
source $(git rev-parse --show-toplevel)/profile.env

cd ${GIT_ROOT}/infra && terraform destroy -force  &&
rm -rf  ${GIT_ROOT}/env/${OCP_DIR}
