<!--
*** Obrigado por estar vendo o nosso README. Se você tiver alguma sugestão
*** que possa melhorá-lo ainda mais dê um fork no repositório e crie uma Pull
*** Request ou abra uma Issue com a tag "sugestão".
*** Obrigado novamente! Agora vamos rodar esse projeto incrível :D
-->

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
  <img alt="logo" src="https://github.com/GersonRS/react-native-template-gersonrsantos-basic/raw/main/assets/logo.png"/>
</p>

<!-- PROJECT LOGO -->

# Engenharia de dados para aprendizado de máquina

Há algum tempo, comecei a procurar maneiras de modernizar meu aprendizado de máquina da minha [disertação de mestrado](https://www.sciencedirect.com/science/article/abs/pii/S0957417422011721#!). Uma das primeiras coisas que eu queria fazer era começar a criar modelos e algoritmos de ML e ter uma maneira de orquestrar sua execução. Podemos pensar em um algoritmo de ML como um aplicativo que obtém alguns dados como entrada, é treinado nesses dados para que possa aprender com eles e, em seguida, pode ser usado para trazer resultados quando novos dados são inseridos nele. O modelo ML é a saída de todo esse processo.

<!-- TABLE OF CONTENTS -->

# Tabela de Conteúdo

- [Tabela de Conteúdo](#tabela-de-conteúdo)
- [Objetivo](#objetivo)
- [Fluxo de versionamento](#fluxo-de-versionamento)
- [Ferramentas](#ferramentas)
- [Como Usar](#como-usar)
  - [Instalação do Cluster](#instalação-do-cluster)
  - [Instalação das Ferramentas](#instalação-das-ferramentas)
  - [Observações](#observações)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Requisitos](#requisitos)
- [Contribuição](#contribuições)
- [Licença](#licença)
- [Contato](#contato)

<!-- ABOUT THE PROJECT -->

# Objetivo

Este repositório fornece uma arquitetura `modern data stack` e um processo de MLOps (operações de machine learning) que usa diversas ferramentas open source, para construir uma plataforma que permita construir, testar e implantar meu modelo de detecção de ondas gravitacionais com o máximo de autonomia possível. Esse processo define uma maneira padronizada de mover modelos e pipelines de machine learning do desenvolvimento para a produção, com opções para incluir processos automatizados e manuais. validação e monitoramento.

# Fluxo de versionamento
Projeto segue regras de versionamento [gitflow](https://www.atlassian.com/br/git/tutorials/comparing-workflows/gitflow-workflow).

# Ferramentas

O repositório inclui um conjunto de ferramentas para orquestração de dados e DataOps. Abaixo segue o que foi utilizado na criação deste projeto:

- [Minikube](https://minikube.sigs.k8s.io/docs/start/) - Ferramenta de código aberto que permite criar um ambiente de teste do Kubernetes em sua máquina local. Com o Minikube, é possível criar e implantar aplicativos em um cluster Kubernetes em sua máquina local.
- [Helm](https://helm.sh/) - Ferramenta de gerenciamento de pacotes de código aberto para o Kubernetes. O Helm permite empacotar aplicativos Kubernetes em um formato padrão chamado de gráfico, que inclui todos os recursos necessários para implantar o aplicativo, incluindo configurações e dependências.
- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) - Ferramenta declarativa que usa a abordagem GitOps para implantar aplicações no Kubernetes. O Argo CD é gratuito, tem código aberto, é um projeto incubado pela CNCF, e possui uma interface web de visualização e gerenciamento dos recursos, mas também pode ser configurado via linha de comando.
- [Spark](https://spark.apache.org/) - O Spark é um framework de processamento de dados distribuído e de código aberto, que permite executar processamento de dados em larga escala, incluindo processamento em batch, streaming, SQL, machine learning e processamento de gráficos. Ele foi projetado para ser executado em clusters de computadores e fornece uma interface de programação fácil de usar para desenvolvedores;
- [Airflow](https://airflow.apache.org/) - O Airflow é uma plataforma de orquestração de fluxo de trabalho de dados de código aberto que permite criar, agendar e monitorar fluxos de trabalho complexos de processamento de dados. Ele usa uma linguagem de definição de fluxo de trabalho baseada em Python e possui uma ampla gama de conectores pré-construídos para trabalhar com diferentes sistemas de armazenamento de dados, bancos de dados e ferramentas de processamento de dados;
- [Reflector](https://github.com/emberstack/kubernetes-reflector) - O Reflector é uma ferramenta de sincronização de estado de código aberto que permite sincronizar recursos Kubernetes em diferentes clusters ou namespaces. Ele usa a abordagem de controlador de reconciliação para monitorar e atualizar automaticamente o estado dos recursos Kubernetes com base em um estado desejado especificado;
- [Minio](https://min.io/) - O Minio é um sistema de armazenamento de objetos de código aberto e de alta performance, compatível com a API Amazon S3. Ele é projetado para ser executado em clusters distribuídos e escaláveis e fornece recursos avançados de segurança e gerenciamento de dados;
- [Postgres](https://www.postgresql.org/) - O Postgres é um sistema de gerenciamento de banco de dados relacional de código aberto, conhecido por sua confiabilidade, escalabilidade e recursos avançados de segurança. Ele é compatível com SQL e é usado em uma ampla gama de aplicativos, desde pequenos sites até grandes empresas e organizações governamentais.

# Como Usar

Para usar esse template, basta criar um novo repositório no GitHub e usar este template como base. O repositório resultante incluirá a estrutura básica do projeto e as ferramentas necessárias para gerenciar seus fluxos de trabalho de dados.

Para começar um novo projeto de Engenharia de Dados com este template, siga as instruções abaixo:

## Instalação do Cluster

O primeiro passo é montar um ambiente com um cluster Kubernetes local para executar a aplicação e o pipeline de dados. Este template usa o cluster de Kubernetes **[minikube](https://minikube.sigs.k8s.io/docs/)**. [Siga este guia de instalação para instalar o Minikube](https://minikube.sigs.k8s.io/docs/start/).

Este template usa o **[helm](https://helm.sh/)** para ajudar a instalar algumas aplicações. [Siga este guia de instalação para instalar o Helm](https://helm.sh/docs/intro/install/).

Execute o seguinte comando para iniciar o Minikube:

```
minikube start
```

Para acessar alguns serviços via loadbalancer no Minikube, é necessário utilizar o [tunelamento do minikube](https://minikube.sigs.k8s.io/docs/handbook/accessing/#example-of-loadbalancer). Para isso, abra uma nova aba no seu terminal e execute o seguinte comando:
```sh
minikube tunnel
```

> Obs: caso não queira usar loadbalancer para acesar suas aplicações, descarte este comando.

## Instalação das ferramentas

Depois do ambiente inicializado será necessario instalar algumas aplicações que serão responsaveis por manter e gerenciar os pipeline de dados.

Estando conectado em no cluster Kubernetes do Minikube local, execute os seguintes comandos para criar todos os namespaces necessarios:

```sh
kubectl create namespace orchestrator
kubectl create namespace database
kubectl create namespace ingestion
kubectl create namespace processing
kubectl create namespace datastore
kubectl create namespace deepstorage
kubectl create namespace cicd
kubectl create namespace app
kubectl create namespace management
kubectl create namespace misc
```

Instale o argocd que será responsavel por manter as aplicações:
```sh
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd --namespace cicd --version 5.27.1
```

Altere o service do argo para loadbalancer:
```sh
# create a load balancer
kubectl patch svc argocd-server -n cicd -p '{"spec": {"type": "LoadBalancer"}}'
```

Em seguida instale o argo cli para fazer a configuração do repositorio:
```sh
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd
```
Em seguida armazene o ip atribiudo para acessar o argo e faça o login no argo, com os seguintes comandos:
```sh
ARGOCD_LB=$(kubectl get services -n cicd -l app.kubernetes.io/name=argocd-server,app.kubernetes.io/instance=argocd -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")

kubectl get secret argocd-initial-admin-secret -n cicd -o jsonpath="{.data.password}" | base64 -d | xargs -t -I {} argocd login $ARGOCD_LB --username admin --password {} --insecure
```
> caso queira ver o password do argo para acessar a interface web, execute este comando: `kubectl get secret argocd-initial-admin-secret -n cicd -o jsonpath="{.data.password}" | base64 -d`

Uma vez feita a autenticação não é necessario adicionar um cluster, pois o argo esta configurado para usar o cluster em que ele esta instalado, ou seja, o cluster local já esta adicionado como **`--in-cluster`**, bastando apenas adicionar o seu repositorio com o seguinte comando:

```sh
argocd repo add git@github.com:GersonRS/big-data-on-k8s.git --ssh-private-key-path ~/.ssh/id_ed25519 --insecure-skip-server-verification
```

> Lembrando que para este comando funcionar é necessario que você tenha uma `chave ssh` configurada para se conectar com o github no seu computador. Caso não tenha, use [este guia](https://docs.github.com/pt/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) para criar uma e [adiciona-la ao github](https://docs.github.com/pt/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

Agora é hora de adicionar as outras ferramentas necesarias para o nosso pipeline de dados. E para isto precisamos criar `secrets` para armazenar senhas e informações censiveis, que  sejam acessiveis pelas aplicações e processos do **`Spark`**, por isso é necessario que eles estejam no namespace onde esta rodando a aplicação e também no namespace processing, onde será executado os processos do `spark`. Então para isto podemos usar o **[Reflactor](https://github.com/EmberStack/kubernetes-reflector)**, que ajudará a replicar os secrets nos namespaces necessários e a manter a segurança dos dados. Além disso, os comandos para instalar as configurações de acesso são importantes para garantir que apenas as pessoas autorizadas possam acessar os recursos do seu cluster, e para isto execute este comando:

```sh
kubectl apply -f manifests/management/reflector.yaml
```

Após o Reflector estar funcionando, execute o comando que cria os secrets nos namespaces necessários:

> Antes de executar os comandos, você pode alterar os secrets dos arquivos localizados na pasta [`secrets/`](/secrets/) se quiser mudar as senhas de acesso aos bancos de dados e ao storage.

```sh
# secrets
kubectl apply -f manifests/misc/secrets.yaml
```

> Caso não queira instalar o Reflactor para automatizar o processo de criar o secret em vários namespaces diferentes, você pode replicar manualmente o secret para outro namespace executando este comando, por exemplo:
`kubectl get secret minio-secrets -n deepstorage -o yaml | sed s/"namespace: deepstorage"/"namespace: processing"/| kubectl apply -n processing -f -`

Uma vez que os secrets estejam configurados, é possível instalar os bancos de dados e o storage do pipeline de dados com o seguinte comando:

```sh
# databases
kubectl apply -f manifests/database/postgres.yaml
# deep storage
kubectl apply -f manifests/deepstorage/minio.yaml
```

Por fim, instale o Spark e o Airflow, juntamente com suas permissões para executar os processos do Spark, executando os seguintes comandos:

```sh
# add & update helm list repos
helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator
helm repo add apache-airflow https://airflow.apache.org/
helm repo update
```

```sh
# processing
kubectl apply -f manifests/processing/spark.yaml
```

Antes de instalar o Airflow, é preciso atender a um requisito: criar um secret contendo sua `chave ssh`, para que o Airflow possa baixar as `DAGs` necessárias por meio do `gitSync`. É possível criar esse secret com o seguinte comando:

> Lembrando que você deve ter a `chave ssh` configurada em sua máquina.

```sh
kubectl create secret generic airflow-ssh-secret --from-file=gitSshKey=$HOME/.ssh/id_ed25519 -n orchestrator
```

```sh
# orchestrator
kubectl apply -f manifests/orchestrator/airflow.yaml
```

Em seguida, instale as configurações de acesso:

```sh
kubectl apply -f manifests/misc/access-control.yaml
```

Para que seja possivel o Ariflow executar de maneira independente os processos spark é preciso que ele tenha uma conexão com o cluster, e para isto é necessario passar essa informação ao Airflow. Para adicionar a conexão com o cluster ao Airflow execute:
```sh
kubectl get pods --no-headers -o custom-columns=":metadata.name" -n orchestrator | grep scheduler | xargs -i sh -c 'kubectl cp images/airflow/connections.json orchestrator/{}:./ -c scheduler | kubectl -n orchestrator exec {} -- airflow connections import connections.json'
```

A partir daqui, você pode personalizar o seu projeto de acordo com as necessidades do seu fluxo de trabalho. Para isso, use o ArgoCD para implantar novas aplicações e fluxos de trabalho em seu cluster.

## Observações

- Certifique-se de ter as ferramentas listadas em [Ferramentas](#ferramentas) instaladas corretamente em seu sistema.
- Para saber mais sobre cada ferramenta, consulte a documentação oficial.
- Certifique-se de testar e validar seus pipelines de dados antes de implantá-los em produção. Isso ajudará a garantir que seus processos estejam funcionando corretamente e que os dados estejam sendo tratados de maneira apropriada.

# Estrutura do Projeto

A estrutura do projeto é a seguinte:

```bash
.
├── access-control
├── dags
├── images
│   ├── spark
│   └── airflow
├── manifests
│   ├── database
│   ├── deepstorage
│   ├── management
│   ├── misc
│   ├── monitoring
│   ├── orchestrator
│   └── processing
└── secrets
```

- **[access-control](/access-control/)** - Diretório contendo todos os arquivos de controle de acesso crb do cluster kubernetes;

- **[dags](/dags/)** - Diretório contendo as DAGs do Airflow, responsáveis por definir fluxos de trabalho de data pipelines;

- **[images](/images/)** - Diretório contendo as imagens personalizadas utilizadas no projeto;

    - **[airflow](/images/airflow/)** - Diretório contendo a imagem do Airflow e suas dependências;

    - **[spark](/images/spark/)** - Diretório contendo a imagem do Spark e suas dependências;

- **[manifests](/manifests/)** - Diretório contendo todos os arquivos de manifesto de aplicação do `Argo` do projeto. O diretório `manifests` é criado para que o código das aplicações possa ser isolado em um diretório e facilmente portado para outros projetos, se necessário;

  - **[database](/manifests/database/)** - Diretório para guardar os arquivos de manifesto das aplicações de banco de dados, por exemplo, a configuração de instalação da aplicação **[postgres](/manifests/database/postgres.yaml)**;

  - **[deepstorage](/manifests/deepstorage/)** - Diretório para guardar os arquivos de manifesto das aplicações de armazenamento, por exemplo, a configuração de instalação da aplicação **[minio](/manifests/deepstorage/minio.yaml)**;

  - **[management](/manifests/management/)** - Diretório para guardar os arquivos de manifesto das aplicações de gerenciamento, por exemplo, a configuração de instalação da aplicação **[reflector](/manifests/management/reflector.yaml)**;

  - **[misc](/manifests/misc/)** - Diretório para guardar os arquivos de manifesto das aplicações em geral, por exemplo, a configuração de instalação dos **[secrets](/manifests/misc/secrets.yaml)** e **[controle de acesso](/manifests/misc/access-control.yaml)**;

  - **[monitoring](/manifests/monitoring/)** - Diretório contendo arquivos de manifesto para configuração do [Prometheus](/manifests/monitoring/kube-prometheus-stack.yaml), responsável pelo monitoramento do cluster Kubernetes;

  - **[orchestrator](/manifests/orchestrator/)** - Diretório contendo arquivos de manifesto para configuração do [Airflow](/manifests/orchestrator/airflow.yaml), responsável pela orquestração de fluxos de trabalho de data pipelines;

  - **[processing](/manifests/processing/)** - Diretório contendo arquivos de manifesto para configuração do [Spark](/manifests/processing/spark.yaml), responsável pelo processamento de dados em larga escala;

- **[secrets](/secrets/)** - Diretório contendo todos os secrets utilizados pelo cluster Kubernetes.

# Requisitos

Para usar este repositório, você precisa ter o Git e o Python instalados em seu sistema. Além disso, para usar o Docker, você precisará instalar o Docker em seu sistema. As instruções para instalar o Docker podem ser encontradas em https://www.docker.com/get-started.

# Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para criar um pull request com melhorias e correções de bugs. As contribuições são o que fazem a comunidade `open source` um lugar incrível para aprender, inspirar e criar. Qualquer contribuição que você fizer será **muito apreciada**.

1. Faça um Fork do projeto
2. Crie uma Branch para sua Feature (`git checkout -b feature/FeatureIncrivel`)
3. Adicione suas mudanças (`git add .`)
4. Comite suas mudanças (`git commit -m 'Adicionando uma Feature incrível!`)
5. Faça o Push da Branch (`git push origin feature/FeatureIncrivel`)
6. Abra um Pull Request

<!-- LICENSE -->


# Suporte

Entre em contato comigo em um dos seguintes lugares!

- Linkedin em [Gerson Santos](https://www.linkedin.com/in/gersonrsantos/)
- Instagram [gersonrsantos](https://www.instagram.com/gersonrsantos/)

---

# Licença

<img alt="License" src="https://img.shields.io/badge/license-MIT-%2304D361?color=rgb(89,101,224)">

Distribuído sob a licença MIT. Veja [LICENSE](LICENSE) para mais informações.

# Contato

Me acompanhe nas minhas redes sociais.

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

---

Feito com ❤️ by **Gerson**
