#!/bin/bash
# Installer
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-install-linux.tar.gz
tar -xvzf openshift-install-linux.tar.gz -C /usr/local/bin/
chmod +x /usr/local/bin/openshift-installer

# Client
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz
tar -xvzf openshift-client-linux.tar.gz -C /usr/local/bin/
chmod +x /usr/local/bin/{oc,kubectl}
