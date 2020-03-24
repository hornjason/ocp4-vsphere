# Registry
oc patch sc thin --patch '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class": "false"}}}'
oc create -f registry-pv.yml
oc patch configs.imageregistry.operator.openshift.io cluster --type merge --patch '{"spec":{"storage":{"pvc":{"claim":""}}}}'
#expose
 oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge

# google oauth
oc create secret generic google-secret --from-literal=clientSecret=MtRy4FaGF_aEog63YJy6zwVk -n openshift-config
oc apply -f google-oauth.yml
oc adm policy add-cluster-role-to-user cluster-admin jhorn@redhat.com

# change sc back to default
oc patch sc thin --patch '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class": "true"}}}'

# custom kubeletconfig
# add label to mcp worker
oc label mcp worker customkubelet=true
oc create -f custom-kubelet-config.yml
