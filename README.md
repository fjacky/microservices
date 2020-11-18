# Udagram Image Filtering Application

Udagram is a simple cloud application developed alongside the Udacity Cloud Engineering Nanodegree. It allows users to register and log into a web client, post photos to the feed, and process photos using an image filtering microservice.


### Prerequisite
1. The depends on the Node Package Manager (NPM). You will need to download and install Node from [https://nodejs.com/en/download](https://nodejs.org/en/download/). This will allow you to be able to run `npm` commands.
2. Environment variables will need to be set. These environment variables include database connection details that should not be hard-coded into the application code.

#### Environment Script
A file named `set_env.sh` can be used to configure these variables on your local development environment. The values in this script are also used in the deployment script.

### Database
Create a PostgreSQL database either locally or on AWS RDS. Set the config values for environment variables prefixed with `POSTGRES_` in `set_env.sh`.

### S3
Create an AWS S3 bucket. Set the config values for environment variables prefixed with `AWS_` in `set_env.sh`.

### Docker Images
Travis-CI has been setup to generate and push Docker images of all the microservices (`reverse-proxy`, `udagram-frontend`, `udagram-feed-service`, `udagram-user-service`, all located in their respective directories) on each push to GitHub (see .travis.yml in the root directory for the configuration).

### EKS Deployment
The deployment script in `deploy/cleanDeployment.sh can be used to cleanly deploy to a configured AWS EKS cluster (note, that it deletes all previous deployments, configmaps and secrets). For this to work, the AWS-cli must be configured with an AWS account which may modify the configured services (Database, S3, EKS cluster and its node group). The deployment will set up a reverse proxy which is located in front of all other services. It will route requests to port 80 to the frontend, and port 8080 to the udagram-user-service or udagram-feed-service depending on the path.

### Local Testing

#### Frontend App
* To download all the package dependencies, run the command from the directory `udagram-frontend/`:
    ```bash
    npm install .
    ```
* Install Ionic Framework's Command Line tools for us to build and run the application:
    ```bash
    npm install -g ionic
    ```
* Prepare your application by compiling them into static files.
    ```bash
    ionic build
    ```
* Run the application locally using files created from the `ionic build` command.
    ```bash
    ionic serve
    ```
* You can visit `http://localhost:8100` in your web browser to verify that the application is running. You should see a web interface.

### Backend APIs (udagram-user-service and udagram-feed-service)
* To download all the package dependencies, run the command from the respective directory `udagram-user-service/` or `udagram-feed-service`:
    ```bash
    npm install .
    ```
* To run the application locally, run:
    ```bash
    npm run dev
    ```
The corresponding API should now be available on port 8080. Please note, that both services run on this port, and therefore cannot be run in parallel in this way. If they are required in parallel, use the Dockerfiles in the folders to generate the docker images, and use port mappings when running them. For manual system testing it is recommended to deploy to EKS.
