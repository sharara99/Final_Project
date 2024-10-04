# Kubernetes Part

This cluster demonstrates a Kubernetes deployment of a Django web application with a MySQL database using a StatefulSet and various Kubernetes resources. The setup includes a multi-container environment orchestrated by Kubernetes, with services, StatefulSets, and deployments managed under the `proj` namespace.

## Prerequisites

Before deploying the application, ensure that you have the following prerequisites installed and configured:

- Kubernetes cluster (Minikube, AWS EKS, etc.)
- kubectl CLI installed and configured
- Docker images for MySQL and Django

## Project Structure

The project consists of the following main components:
- **Django Web Application**: A Python-based web app framework.
- **MySQL Database**: A relational database for storing app data, running in a StatefulSet.

## Kubernetes Resources

The project includes the following Kubernetes resources:

### 1. **Namespace**

All resources are deployed under the `proj` namespace.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: proj
```

### 2. **MySQL StatefulSet**

MySQL is deployed as a StatefulSet to manage persistent data, with a corresponding `PersistentVolumeClaim` for data storage.

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysqldb
  namespace: proj
spec:
  serviceName: mysqldb
  replicas: 1
  selector:
    matchLabels:
      app: mysqldb
  template:
    metadata:
      labels:
        app: mysqldb
    spec:
      containers:
      - name: mysqldb
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: rootpassword
        - name: MYSQL_DATABASE
          value: django_db
        - name: MYSQL_USER
          value: django_user
        - name: MYSQL_PASSWORD
          value: djangopassword
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-persistent-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

### 3. **MySQL Service**

The MySQL service is configured as a `ClusterIP` for internal communication between Django and MySQL.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysqldb
  namespace: proj
spec:
  ports:
    - port: 3306
  selector:
    app: mysqldb
  type: ClusterIP
```

### 4. **Django Deployment**

Django is deployed with an environment configuration to interact with the MySQL service. The deployment uses a replica set and relies on the MySQL StatefulSet for database services.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: django
  namespace: proj
spec:
  replicas: 4
  selector:
    matchLabels:
      app: django
  template:
    metadata:
      labels:
        app: django
    spec:
      containers:
      - name: django
        image: elshwaihi/iattend-jen
        env:
        - name: DEBUG
          value: "1"
        - name: DB_NAME
          value: "django_db"
        - name: DB_USER
          value: "django_user"
        - name: DB_PASSWORD
          value: "djangopassword"
        - name: DB_HOST
          value: "mysqldb"
        - name: DB_PORT
          value: "3306"
        ports:
        - containerPort: 8000
```

### 5. **Django Service**

The Django application is exposed via a `NodePort` service to allow access from outside the cluster.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: django
  namespace: proj
spec:
  type: NodePort
  ports:
    - port: 8000
      targetPort: 8000
      nodePort: 32635
  selector:
    app: django
```

## Steps to Deploy the Project

1. **Clone the Repository**

   Clone the repository containing the Kubernetes YAML files and the Django project.

   ```bash
   git clone <repository-url>
   cd <project-directory>/k8s

   ```

2. **Create Namespace**

   Apply the namespace manifest to create the `proj` namespace:

   ```bash
   kubectl apply -f proj-namespace.yaml
   ```

3. **Deploy MySQL StatefulSet and Service**

   Deploy the MySQL database using a StatefulSet and expose it using a service.

   ```bash
   kubectl apply -f musql-pvc.yaml
   kubectl apply -f mysql-statefulset.yaml
   kubectl apply -f mysql-service.yaml
   ```

4. **Deploy Django App**

   Deploy the Django app as a Kubernetes deployment and expose it using a NodePort service.

   ```bash
   kubectl apply -f django-deployment.yaml
   kubectl apply -f django-service.yaml
   ```

5. **Check Pod and Service Status**

   Verify that the pods and services are running correctly in the `proj` namespace:

   ```bash
   kubectl get all -n proj
   ```

### 6. Access the Django Application

- **In a Regular Kubernetes Cluster**:

    Get the NodePort service information:

    ```bash
    kubectl get services -n proj
    ```

    Access the Django app using the external IP and NodePort.

    ```bash
    http://<external-ip>:<node-port>
    ```

- **In Minikube**:

    If you're using Minikube, you can access the service through Minikube's IP using the following command:

    ```bash
    minikube service django -n proj
    ```

    This will automatically open your browser and direct you to the Django application's NodePort URL.

7. **Create Django Superuser**

   Once the application is running, you need to create a superuser for accessing the Django admin panel. First, connect to the Django pod:

   ```bash
   kubectl exec -it <django-pod-name> -n proj -- bash
   ```

   Then, run the following commands inside the container to create a superuser:

   ```bash
   python manage.py migrate
   python manage.py createsuperuser
   ```

   Follow the prompts to create the superuser.

## Diagram

Below is a visual diagram of the architecture (created using D2):

```
  +-------------------------+
  |       Client            |
  +-------------------------+
             |
             |
  +-------------------------+
  |    NodePort (32635)      |
  +-------------------------+
             |
             v
  +-------------------------+      +----------------------+
  |  Django Deployment       |<---->| MySQL StatefulSet     |
  +-------------------------+      +----------------------+
  | Django Service (8000)    |      | MySQL Service (3306)  |
  +-------------------------+      +----------------------+
```

## Conclusion

This README outlines the steps to set up a Django app with a MySQL database on Kubernetes. By following these instructions, you can deploy a containerized Django application using Kubernetes resources like StatefulSets, Deployments, and Services under the `proj` namespace.

