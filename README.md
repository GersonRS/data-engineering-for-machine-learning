<!--
*** Obrigado por estar vendo o nosso README. Se você tiver alguma sugestão
*** que possa melhorá-lo ainda mais dê um fork no repositório e crie uma Pull
*** Request ou abra uma Issue com a tag "sugestão".
*** Obrigado novamente! Agora vamos rodar esse projeto incrível :D
-->

# Machine Learning Model Orchestration

<!-- PROJECT SHIELDS -->

[![npm](https://img.shields.io/badge/type-Open%20Project-green?&style=plastic)](https://img.shields.io/badge/type-Open%20Project-green)
[![GitHub last commit](https://img.shields.io/github/last-commit/GersonRS/data-engineering-for-machine-learning?logo=github&style=plastic)](https://github.com/GersonRS/data-engineering-for-machine-learning/commits/master)
[![GitHub Issues](https://img.shields.io/github/issues/gersonrs/data-engineering-for-machine-learning?logo=github&style=plastic)](https://github.com/GersonRS/data-engineering-for-machine-learning/issues)
[![GitHub Language](https://img.shields.io/github/languages/top/gersonrs/data-engineering-for-machine-learning?&logo=github&style=plastic)](https://github.com/GersonRS/data-engineering-for-machine-learning/search?l=python)
[![GitHub Repo-Size](https://img.shields.io/github/repo-size/GersonRS/data-engineering-for-machine-learning?logo=github&style=plastic)](https://img.shields.io/github/repo-size/GersonRS/data-engineering-for-machine-learning)
[![GitHub Contributors](https://img.shields.io/github/contributors/GersonRS/data-engineering-for-machine-learning?logo=github&style=plastic)](https://img.shields.io/github/contributors/GersonRS/data-engineering-for-machine-learning)
[![GitHub Stars](https://img.shields.io/github/stars/GersonRS/data-engineering-for-machine-learning?logo=github&style=plastic)](https://img.shields.io/github/stars/GersonRS/data-engineering-for-machine-learning)
[![NPM](https://img.shields.io/github/license/GersonRS/data-engineering-for-machine-learning?&style=plastic)](LICENSE)
[![Status](https://img.shields.io/badge/status-active-success.svg)](https://img.shields.io/badge/status-active-success.svg)

<p align="center">
  <img alt="logo" src=".github/assets/images/logo.png"/>
</p>

<!-- PROJECT LOGO -->



## Overview
For some time now, I've been exploring ways to modernize my machine learning journey, starting from my [master's dissertation](https://www.sciencedirect.com/science/article/abs/pii/S0957417422011721#!) on gravitational wave detection using neural networks. One of my primary objectives was to create and orchestrate machine learning models and algorithms efficiently.

In the context of this project, think of a machine learning algorithm as an application that takes some data as input, learns from that data during training, and can then make predictions when new data is fed into it. The machine learning model represents the output of this entire process.

## Table of Contents

- [Objective](#objective)
- [Versioning Flow](#versioning-flow)
- [Tools](#tools)
- [Getting Started](#getting-started)
- [Requirements](#requirements)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)
  - [Jupyterhub Login](#jupyterhub-login)
  - [Install libs Python](#install-libs-python)
- [Contributions](#contributions)
- [License](#license)
- [Contact](#contact)
- [Acknowledgments](#acknowledgments)

## Objective
In the realm of machine learning, orchestrating the training and deployment of models can be a complex task. This project aims to streamline and automate the end-to-end machine learning process, encompassing data ingestion, data processing, model training with hyperparameter optimization, experiment tracking, model evaluation, and model deployment in the context of gravitational wave detection using neural networks.


## Versioning Flow
We follow the [Semantic Versioning](https://semver.org/) and [gitflow](https://www.atlassian.com/br/git/tutorials/comparing-workflows/gitflow-workflow) for versioning this project. For the versions available, see the tags on this repository.

## Tools
The following tools are used in this project:

* **Terraform:** Infrastructure-as-Code tool used to automate the setup of the Kubernetes cluster and related resources.

* **Kubernetes (kind)**: A lightweight Kubernetes implementation that allows running Kubernetes clusters inside Docker containers.

* **MetalLB**: A Load Balancer for Kubernetes environments, enabling external access to services in the local environment.

* **ArgoCD**: A GitOps Continuous Delivery tool for Kubernetes, facilitating the management of applications.

* **Traefik**: An Ingress Controller for Kubernetes, routing external traffic to applications within the cluster.

* **Cert-Manager**: A certificate management tool, enabling the use of HTTPS for applications.

* **Keycloak**: An identity management and access control service, securing applications and resources.

* **Minio**: A cloud storage server compatible with Amazon S3, providing object storage for applications.

* **Postgres**: A relational database used to store application data.

* **MLflow**: A Machine Learning lifecycle management platform, simplifying the deployment and tracking of ML models.

* **JupyterHub**: A multi-user Jupyter environment, allowing users to write and share code collaboratively.

* **Airflow**: An open-source platform to programmatically author, schedule, and monitor workflows.

* **Spark**: An open-source, distributed computing system that provides an interface for programming entire clusters with implicit data parallelism and fault tolerance.

* **Ray**: An open-source distributed computing framework that brings the power of Python to distributed computing.

These tools together enable the creation of a complete infrastructure for the development and management of Machine Learning applications in the Kubernetes environment.

## Requirements
To use ML Model Orchestration, you need to have the following prerequisites installed and configured:

1. Terraform:
    * Installation: Visit the [Terraform website](https://www.terraform.io/downloads.html) and follow the instructions for your operating system.
2. Docker:
    * Installation: Install Docker by following the instructions for your operating system from the [Docker website](https://docs.docker.com/get-docker/).
3. Kubernetes CLI (kubectl):
    * Installation: Install `kubectl` by following the instructions for your operating system from the [Kubernetes website](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
4. Helm:
    * Installation: Install Helm by following the instructions for your operating system from the [Helm website](https://helm.sh/docs/intro/install/).

## Getting Started
To get started with the MLflow POC, follow these steps:

1. Clone this repository to your local computer.
    - `git clone https://github.com/GersonRS/data-engineering-for-machine-learning`
2. Change directory to the repository:
    - `cd data-engineering-for-machine-learning`
>Make sure you have Terraform installed on your system, along with other necessary dependencies.
3. Run `terraform init` to initialize Terraform configurations.
* ```sh
  terraform init
  ```
>`This command will download the necessary Terraform plugins and modules.`
4. Run `terraform apply` to start the provisioning process. Wait until the infrastructure is ready for use.
* ```
  terraform apply
  ```
>`Review the changes to be applied and confirm with yes when prompted. Terraform will now set up the Kubernetes cluster and deploy the required resources.`
5. After the Terraform apply is complete, the output will display URLs for accessing the applications. Use the provided URLs to interact with the applications.
6. The Terraform output will also provide the credentials necessary for accessing and managing the applications. Run `terraform output` to get the credentials.
* ```
  terraform output -json
  ```


## Usage
Once the infrastructure is successfully provisioned, you can utilize the installed applications, including MLflow, to track and manage your Machine Learning experiments. Access the applications through the provided URLs and log in using the credentials generated during setup. Follow these steps to utilize the Proof of Concept (PoC):

1. Access the JupyterHub URL: After the infrastructure is provisioned using Terraform, you will receive the JupyterHub URL as an output. Open a web browser and navigate to this URL.

2. Log in to JupyterHub: On the JupyterHub login page, click on "Sign in with Keycloak." Use the credentials provided in the output of the Terraform apply command, as mentioned in step 6 of the previous section.

3. Access Jupyter Notebook: Upon successful login, you will have access to a Jupyter Notebook environment. Locate the "/opt/bitnami/jupyterhub-singleuser" directory within the Jupyter environment.

4. Upload Files: Upload the files from the "code" folder of this repository into the "/opt/bitnami/jupyterhub-singleuser" directory.

5. Execute "main.ipynb": Open the "main.ipynb" Jupyter Notebook file and execute it. This notebook contains the necessary code to initiate the Proof of Concept.

6. Monitor Experiment in MLflow: Upon execution of the notebook, the MLflow experiment will be initiated. To monitor the experiment, access the MLflow URL provided in the output of the Terraform apply command. This URL will allow you to track and analyze the results of the PoC.

Please note that these steps provide a high-level overview of the usage process. Ensure you have met all the requirements mentioned in the "Requirements" section before proceeding with the above steps. Additionally, refer to the provided documentation and comments within the code for any further instructions or configurations.

If you encounter any problems, refer to the [Troubleshooting](#troubleshooting) section for potential solutions to common issues that may arise during the setup and usage of the PoC.


## Project Structure
This project follows a structured directory layout to organize its resources effectively:
```sh
    .
    ├── LICENSE
    ├── locals.tf
    ├── main.tf
    ├── modules
    │   ├── argocd
    │   ├── cert-manager
    │   ├── jupyterhub
    │   ├── keycloak
    │   ├── kind
    │   ├── kube-prometheus-stack
    │   ├── metallb
    │   ├── minio
    │   ├── mlflow
    │   ├── oidc
    │   ├── postgresql
    │   └── traefik
    ├── outputs.tf
    ├── README.md
    ├── s3_buckets.tf
    ├── terraform.tf
    └── variables.tf

    15 directories, 83 files
```

* [**LICENSE**](LICENSE) - License file of the project.
* [**locals.tf**](locals.tf) - Terraform locals file.
* [**main.tf**](main.tf) - Main Terraform configuration file.
* [**modules**](modules/) - Directory containing all the Terraform modules used in the project.
  * [**argocd**](modules/argocd/) - Directory for configuring ArgoCD application.
  * [**cert-manager**](modules/cert-manager/) - Directory for managing certificates using Cert Manager.
  * [**jupyterhub**](modules/jupyterhub/) - Directory for setting up JupyterHub application.
  * [**keycloak**](modules/keycloak/) - Directory for installing and configuring Keycloak.
  * [**kind**](modules/kind/) - Directory for creating a Kubernetes cluster using Kind.
  * [**metallb**](modules/metallb/) - Directory for setting up MetalLB, a load balancer for Kubernetes.
  * [**minio**](modules/minio/) - Directory for deploying and configuring Minio for object storage.
  * [**mlflow**](modules/mlflow/) - Directory for setting up MLflow, a machine learning lifecycle management platform.
  * [**oidc**](modules/oidc/) - Directory for OpenID Connect (OIDC) configuration.
  * [**postgresql**](modules/postgresql/) - Directory for deploying and configuring PostgreSQL database.
  * [**traefik**](modules/traefik/) - Directory for setting up Traefik, an ingress controller for Kubernetes.
* [**outputs.tf**](outputs.tf) - Terraform outputs file.
* [**README.md**](README.md) - Project's README file, containing important information and guidelines.
* [**s3_buckets.tf**](s3_buckets.tf) - Terraform configuration for creating S3 buckets.
* [**terraform.tf**](terraform.tf) - Terraform configuration file for initializing the project.
* [**variables.tf**](variables.tf) - Terraform variables file, containing input variables for the project.

## Troubleshooting
### Jupyterhub Login:

If you encounter a login error, specifically an error 500, while attempting to access JupyterHub, follow these steps to resolve the issue:

1. Access MinIO Storage: In case of a login error, navigate to the MinIO Storage using the provided MinIO URL available in the Terraform output.

2. Single Sign-On (SSO) Login: Log in to MinIO using the Single Sign-On (SSO) credentials. This will establish a session that will allow you to successfully log in to other components.

3. Return to JupyterHub: After successfully logging in to MinIO, return to the JupyterHub login page.

4. Refresh the Page: Refresh the JupyterHub page. This will complete the login process, and you should now have access to the Jupyter Notebook environment.

This troubleshooting procedure is specifically designed to address login errors that result in an error 500 when accessing JupyterHub. By logging in to MinIO using SSO and refreshing the JupyterHub page, you can resolve the issue and continue with the usage of the Proof of Concept.

If you continue to experience login issues or encounter other technical difficulties, please refer to the provided documentation, check for any additional error messages, and ensure that you have followed all the prerequisites and setup instructions accurately.

### Install libs Python

Sometimes, during the installation of Python libraries in Jupyter Notebook, you may encounter an issue where the kernel does not recognize the appropriate environment. To resolve this problem, follow these steps:

1. Select the Correct Kernel:

When working with Jupyter Notebook, ensure that you are using the correct kernel corresponding to the specific Python environment you intend to use. To do this, follow these steps:

  * a. Click on the "Kernel" option in the Jupyter Notebook toolbar.

  * b. Choose the "Change Kernel" option.

  * c. A dropdown menu will appear showing available kernels. Click on the option that corresponds to the name of the notebook you are working on, such as "main.ipynb" for the "main.ipynb" notebook.

  * d. The notebook will now use the selected kernel, ensuring that the required Python libraries are properly recognized and utilized.

By selecting the appropriate kernel, you can ensure that the Python libraries required for your specific notebook are correctly installed and utilized, mitigating any potential issues related to library compatibility or recognition.

If you encounter any other issues or difficulties while using the Proof of Concept, refer to this "Troubleshooting" section for solutions to common problems. If the problem persists or if you experience unique challenges, consider consulting the provided documentation or seeking assistance from the community.



## Contributions
Contributions are welcome! Feel free to create a pull request with improvements, bug fixes, or new features. Contributions are what make the open source community an amazing place to learn, inspire, and create. Any contribution you make will be greatly appreciated.

To contribute to the project, follow the steps below:

1. Fork the project.
2. Create a branch for your contribution (git checkout -b feature-mycontribution).
3. Make the desired changes to the code.
4. Commit your changes (git commit -m 'MyContribution: Adding new feature').
5. Push the branch to your Fork repository (git push origin feature-mycontribution).
6. Open a Pull Request on the main branch of the original project. Describe the changes and wait for the community's review and discussion.

We truly value your interest in contributing to the MLflow-Kube project. Together, we can make it even better!

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact
For any inquiries or questions, please contact:

<p align="center">

 <a href="https://twitter.com/gersonrs3" target="_blank" >
     <img alt="Twitter" src="https://img.shields.io/badge/-Twitter-9cf?logo=Twitter&logoColor=white"></a>

  <a href="https://instagram.com/gersonrsantos" target="_blank" >
    <img alt="Instagram" src="https://img.shields.io/badge/-Instagram-ff2b8e?logo=Instagram&logoColor=white"></a>

  <a href="https://www.linkedin.com/in/gersonrsantos/" target="_blank" >
    <img alt="Linkedin" src="https://img.shields.io/badge/-Linkedin-blue?logo=Linkedin&logoColor=white"></a>

  <a href="https://t.me/gersonrsantos" target="_blank" >
    <img alt="Telegram" src="https://img.shields.io/badge/-Telegram-blue?logo=Telegram&logoColor=white"></a>

  <a href="mailto:gersonrodriguessantos8@gmail.com" target="_blank" >
    <img alt="Email" src="https://img.shields.io/badge/-Email-c14438?logo=Gmail&logoColor=white"></a>

</p>


## Acknowledgments
We appreciate your interest in using ML Model Orchestration on Kubernetes. We hope this configuration simplifies the management of your Machine Learning experiments on Kubernetes! 🚀📊
