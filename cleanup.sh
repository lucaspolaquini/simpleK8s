# Deletes the resources created in the lab

# Delete Services
kubectl delete services nginx-demo nginx-blue nginx-green --ignore-not-found

# Delete Deployments
kubectl delete deployments nginx-blue nginx-green nginx-canary --ignore-not-found

# Delete ConfigMaps
kubectl delete configmap nginx-v1-config nginx-v2-config --ignore-not-found
