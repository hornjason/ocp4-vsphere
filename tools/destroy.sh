#!/bin/bash
# OCP_DIR = Branch name from profile.env
source $(git rev-parse --show-toplevel)/profile.env

cd ${OCP_ENV}/infra ; terraform destroy -force  &&
rm -rf  ${OCP_ENV}
