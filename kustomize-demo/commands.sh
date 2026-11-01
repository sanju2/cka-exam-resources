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