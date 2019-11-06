# Changing storage folder location
By default OpenShift will create a /etc/kubernetes/cloud.txt file with credentials for vSphere and a folder location of 'cluster.id'
This is not always desired,  these steps show how to change the machineConfig for each machineConfgPool with a custom
/etc/kubernetes/cloud.txt

Create new cloud.txt with new folder location for Storage provisioning
```
cat <<EOF>cloud.txt
[Global]
secret-name      = vsphere-creds
secret-namespace = kube-system
insecure-flag    = 1

[Workspace]
server            = vcenter.foo.bar
datacenter        = DC1
default-datastore = QNAP-VMDATA
folder            = ocp-test/test

[VirtualCenter "vceneter.foo.bar"]
datacenters = DC1
EOF```

* Base64 encode it 
cat cloud.txt|base64 | tr -d '\n'

* example
'''
NEW=$( base64 cloud.txt| tr -d '\n' )
for i in worker master; do
cat <<EOF> machine_configs_${i}-cloud-vsphere.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: ${i}
  name: 10-${i}-cloud-vsphere
spec:
  config:
    ignition:
      version: 2.2.0
    storage:
      files:
      - contents:
          source: "data:text/plain;charset=utf-8;base64,${NEW}"
        filesystem: root
        mode: 0420
        path: /etc/kubernetes/cloud.conf
EOF
done
'''
oc create -f  machine_configs_worker-cloud-vsphere.yaml
oc create -f  machine_configs_master-cloud-vsphere.yaml

oc get mcp
