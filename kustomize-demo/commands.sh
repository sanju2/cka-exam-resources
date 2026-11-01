kustomize build k8s/ ## build kutomize configs

kustomize build k8s/ | kubectl apply -f - ## apply kutomize
kubectl apply -k k8s/

# delete
kustomize build k8s/ | kubectl delete -f - ## delete kutomize
kubectl delete -k k8s/