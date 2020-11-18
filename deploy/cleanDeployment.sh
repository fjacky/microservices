## Script to clean up previous deployments and deploy application into existing cluster
## Ensure that the environment variables are set in PROJECTROOT/set_env.sh (only $URL is ignored)

# set working dir to script dir
cd "${0%/*}"

# source environment variables from PROJECTROOT/set_env.sh
# Note, that $URL is only used for local development and will be ignored during this EKS deployment
. ../set_env.sh

# retrieve current cluster config
aws eks --region $(echo $AWS_REGION) update-kubeconfig --name $(echo $AWS_EKS_CLUSTER)

# clean up previous deployments
kubectl delete all --all
kubectl delete configmap --all
kubectl delete secret --all

# create secrets 
kubectl create secret generic aws-credentials \
  --from-file=$HOME/.aws/credentials
kubectl create secret generic postgres-credentials --from-literal=username=$(echo $POSTGRES_USERNAME) --from-literal=password=$(echo $POSTGRES_PASSWORD)

# deploy reverse proxy
kubectl apply -f reverseProxyDeployment.yaml
kubectl apply -f reverseProxyService.yaml

# sleep five second, then retrieve the endpoint url of the reverse proxy.
sleep 5
UDAGRAM_HOST=$(kubectl get service -o custom-columns=HOST:.status.loadBalancer.ingress[0].hostname reverseproxy-svc | tail -n 1)

# apply the retrieved endpoint url and relevant environment variables to env-configmap template and deploy resulting configmap to aws
cat env-configmap-template.yaml | \
  awk '{gsub(/{AWS_BUCKET}/,"'$AWS_BUCKET'")}1' | \
  awk '{gsub(/{AWS_PROFILE}/,"'$AWS_PROFILE'")}1' | \
  awk '{gsub(/{AWS_REGION}/,"'$AWS_REGION'")}1' | \
  awk '{gsub(/{JWT_SECRET}/,"'$JWT_SECRET'")}1' | \
  awk '{gsub(/{POSTGRES_HOST}/,"'$POSTGRES_HOST'")}1' | \
  awk '{gsub(/{POSTGRES_DATABASE}/,"'$POSTGRES_DATABASE'")}1' | \
  awk '{gsub(/{URL}/,"'$UDAGRAM_HOST'")}1' | \
  kubectl apply -f -

# deploy frontend and the micro services
kubectl apply -f frontendDeployment.yaml
kubectl apply -f frontendService.yaml
kubectl apply -f userServiceDeployment.yaml
kubectl apply -f userServiceService.yaml
kubectl apply -f feedServiceDeployment.yaml
kubectl apply -f feedServiceService.yaml

# add auto scaling to feed service
kubectl autoscale deployment feed-service --cpu-percent=50 --min=1 --max=2

# cleanup
echo "\n\nDone! The site can be reached at $UDAGRAM_HOST"
unset UDAGRAM_HOST