# https://github.com/wkulhanek/gogs-operator
# Create CRD and CluserRole
 oc create -f https://raw.githubusercontent.com/wkulhanek/gogs-operator/master/deploy/crds/gpte_v1alpha1_gogs_crd.yaml
oc create -f https://raw.githubusercontent.com/wkulhanek/gogs-operator/master/deploy/cluster_role.yaml

# Create project for Gogs Operator to live
oc new-project gpte-operators --display-name="GPTE Operators"
oc create -f https://raw.githubusercontent.com/wkulhanek/gogs-operator/master/deploy/service_account.yaml
oc adm policy add-cluster-role-to-user gogs-operator -z system:serviceaccount:gpte-operators:gogs-operator
oc create -f https://raw.githubusercontent.com/wkulhanek/gogs-operator/master/deploy/operator.yaml

# Install CR / GOGS using default CR 4Gi for each PV
oc new-project gogs --display-name="Gogs Server for foo.bar"
oc create -f https://github.com/wkulhanek/gogs-operator/blob/master/deploy/crds/gpte_v1alpha1_gogs_cr.yaml

