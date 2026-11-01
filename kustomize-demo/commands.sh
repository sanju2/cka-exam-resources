# Usefull commands
kubectl kustomize base	## Build base
kubectl kustomize overlays/dev	## Preview DEV
kubectl apply -k overlays/dev	## Deploy DEV
kubectl diff -k overlays/dev	## Preview cluster changes
kubectl get -k overlays/dev	## View resources
kubectl delete -k overlays/dev	## Delete DEV resources

kustomize build k8s/ ## build kutomize configs

kustomize build k8s/ | kubectl apply -f - ## apply kutomize
kubectl apply -k k8s/

# delete
kustomize build k8s/ | kubectl delete -f - ## delete kutomize
kubectl delete -k k8s/

# patches command - Change replicas using patches

# overlays/qa/replica-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
spec:
  replicas: 3

# config map
configMapGenerator:
  - name: nginx-config
    literals:
      - APP_ENV=development
      - APP_NAME=KustomizeDemo