Mattermost on Kubernetes
=======

You can use these manifests as a starting point to run Mattermost on Kubernetes.

If you already have a Kubernetes cluster you can skip this first step.

### Start local Kubernetes cluster

To get started we can use [minikube](https://github.com/kubernetes/minikube/) to run a local kubernetes cluster.

Download and install minikube and any dependancies for your operating system (see minikube readme). You will also need to install [kubectl](http://kubernetes.io/docs/user-guide/prereqs/).

Start the minikube VM and Kubernetes API server

```
minikube start
```

### Start a Postgres database

#### WARNING: The database is not backup up and will lose all data if the pod is restarted. Consider using a [persistent volume](http://kubernetes.io/docs/user-guide/persistent-volumes/) for storing pgdata

This will run a postgres deployment with default values for database name, username, and password.

```
kubectl run postgres --image=postgres:9 \
  --env="POSTGRES_PASSWORD=mmuser_password" \
  --env="POSTGRES_DB=mattermost" \
  --env="POSTGRES_USER=mmuser"
```
Expose the postgres database as a service named "db"
```
kubectl expose deployment postgres \
  --name=db \
  --port 5432 \
  --target-port 5432
```

### Run Mattermost container

The Mattermost application is split into three manifests.

First, create the secret which will set the environment varibles for the main application container. If you changed the values for the Postgres container you will also need to set the values in mattermost.secret.yaml using the [manual steps for creating a secret](http://kubernetes.io/docs/user-guide/secrets/#creating-a-secret-manually).
```
kubectl create -f mattermost.secret.yaml
```
Next create the Mattermost deployment (main application) with
```
kubectl create -f mattermost.deployment.yaml
```
You should check that the pod started successfully with 
```
kubectl get po -l app=mattermost
NAME                              READY     STATUS    RESTARTS   AGE
mattermost-app-1605216003-fvnz1   1/1       Running   0          44m
```

Finally, you can expose the application with a service so you can easily access the application from a web browser. The example service is using a `type: NodePort` which means it will be exposed on a random high port on your cluster nodes (or minikube VM if you're using minikube). If you are running your Kubernetes cluster in AWS or GCE you should change the type to loadBalancer.
```
kubectl create -f mattermost.svc.yaml
```
Now you can get your VM's IP address with 
```
minikube ip
192.168.99.100
```
and the exposed port for the application with
```
kubectl describe svc mattermost
Name:                   mattermost
Namespace:              default
Labels:                 <none>
Selector:               app=mattermost,tier=app
Type:                   NodePort
IP:                     10.0.0.194
Port:                   http    80/TCP
NodePort:               http    32283/TCP
Endpoints:              172.17.0.4:8000
Session Affinity:       None
No events.
```
Make sure the Endpoints shows an IP address. This should correlate to the pod IP started by the deployment.

Now browse to your node IP and exposed NodePort in your browser to view the application or test it with curl

```
curl -L http://192.168.99.100:32283
```

### Optional steps

 * If you want your data to be persistent you will need to make persistent volumes for Mattermost and Postgres. This requires adding a [securityContext](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#discussion) to the deployment to set `runAsUser: 2000`, `runAsGroup: 2000` and `fsGroup: 2000`.
 * If you want to change advanced settings for the mattermost container you can make a [configMap](http://blog.kubernetes.io/2016/04/configuration-management-with-containers.html) for the /mattermost/config/config.json file
 * If you want the application exposed on port 80 you can either specify the port in the service manifest or use an [ingress controller](http://kubernetes.io/docs/user-guide/ingress/#ingress-controllers) and an ingress map for the mattermost service. A sample ingress map would be
```
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: mattermost
spec:
  rules:
  - host: mattermost
    http:
      paths:
      - backend:
          serviceName: mattermost
          servicePort: 80
```
