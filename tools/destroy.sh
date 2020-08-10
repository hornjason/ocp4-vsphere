#!/bin/bash
DIR="ocp-42"
terraform destroy -force
rm -rf  ${DIR}
