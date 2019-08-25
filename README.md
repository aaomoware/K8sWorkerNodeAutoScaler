### Steps To Deploy

Deploy EKS
```hcl
cd cluster
terraform init --upgrade=true
terraform plan -var cidr_blocks_remote=`curl -s ifconfig.co`/32 -var-file=key/public_key.tf
terraform apply --auto-approve -var cidr_blocks_remote=`curl -s ifconfig.co`/32 -var-file=key/public_key.tf
```

Generate kubectl config file
```hcl
aws eks --region eu-west-1 update-kubeconfig --name nike
```

IAM Role authentication; enables worker nodes join the EKS cluster
```hcl
kubectl apply -f aws-auth-cm.yaml
```

Deploy metric server
```hcl
cd ../metrics
kubectl create -f .
cd ../
```

Deploy autoscaler
```hcl
kubectl apply -f cluster_autoscaler.yml
sleep 10;
```

Create an nginx pod and service
```hcl
kubectl run nginx --image nginx --requests "cpu=100m,memory=512Mi" --limits "cpu=100m,memory=512Mi" --replicas=1
kubectl expose deploy nginx --port 80 --type=NodePort
```

Horizontal autoscaling deploymet
```hcl
kubectl apply -f hpa.yml
```

Destroy EKS
```hcl
terraform destroy --force -var cidr_blocks_remote=`curl -s ifconfig.co`/32 -var-file=key/public_key.tf
```

#### Docs
* https://learn.hashicorp.com/terraform/aws/eks-intro
* https://github.com/kubernetes-incubator/metrics-server
* https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough
* https://github.com/feiskyer/kubernetes-handbook/blob/master/examples/hpa.yaml
