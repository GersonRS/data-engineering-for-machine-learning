FROM bitnami/jupyter-base-notebook:latest

# Fix: https://github.com/hadolint/hadolint/wiki/DL4006
# Fix: https://github.com/koalaman/shellcheck/wiki/SC3014
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install all OS dependencies for Server that starts
# but lacks all features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --yes && \
    # - apt-get upgrade is run to patch known vulnerabilities in apt-get packages as
    #   the ubuntu base image is rebuilt too seldom sometimes (less than once a month)
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    # - bzip2 is necessary to extract the micromamba executable.
    bzip2 \
    ca-certificates \
    locales \
    sudo \
    # - tini is installed as a helpful container entrypoint that reaps zombie
    #   processes and such of the actual executable we want to start, see
    #   https://github.com/krallin/tini#why-tini for details.
    tini \
    wget \
    git && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    fonts-dejavu \
    gfortran \
    curl \
    gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN conda update -n base conda
RUN conda install -n base conda-libmamba-solver && \
    conda config --set solver libmamba

RUN conda install --quiet --yes \
    'mlflow' \
    'pandas' \
    'boto3' \
    'ipywidgets' \
    'lightgbm' \
    'tensorflow' \
    'matplotlib-base' \
    'scipy' \
    'h5py' \
    'ipympl'\
    'protobuf' \
    'pytables' \
    'scikit-image' \
    'scikit-learn' \
    'seaborn' \
    'sqlalchemy' \
    'statsmodels' \
    'sympy' && \
    conda clean --all -f -y
RUN conda install -c conda-forge jupyterlab-git
RUN pip install -U ray[all]
RUN pip install -U optuna ipywidgets modin[all]
RUN pip install jupyterlab-pullrequests
RUN pip install evidently
RUN pip install -U atom-ml[ray]
RUN pip install deltalake

RUN apt-get update && apt-get install -y \
    software-properties-common \
    npm
RUN npm install npm@latest -g && \
    npm install n -g && \
    n latest

RUN jupyter lab build

# Spark dependencies
# Default values can be overridden at build time
# (ARGS are in lower case to distinguish them from ENV)
ARG spark_version="3.4.1"
ARG hadoop_version="3"
ARG scala_version
ARG spark_checksum="5a21295b4c3d1d3f8fc85375c711c7c23e3eeb3ec9ea91778f149d8d321e3905e2f44cf19c69a28df693cffd536f7316706c78932e7e148d224424150f18b2c5"
ARG openjdk_version="17"

ENV APACHE_SPARK_VERSION="${spark_version}" \
    HADOOP_VERSION="${hadoop_version}"

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    "openjdk-${openjdk_version}-jre-headless" \
    ca-certificates-java && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Spark installation
WORKDIR /tmp

# You need to use https://archive.apache.org/dist/ website if you want to download old Spark versions
# But it seems to be slower, that's why we use recommended site for download
RUN if [ -z "${scala_version}" ]; then \
    curl --progress-bar --location --output "spark.tgz" \
    "https://dlcdn.apache.org/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz"; \
    else \
    curl --progress-bar --location --output "spark.tgz" \
    "https://dlcdn.apache.org/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}-scala${scala_version}.tgz"; \
    fi && \
    echo "${spark_checksum} *spark.tgz" | sha512sum -c - && \
    tar xzf "spark.tgz" -C /usr/local --owner root --group root --no-same-owner && \
    rm "spark.tgz"

# Configure Spark
ENV SPARK_HOME=/usr/local/spark
ENV SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info" \
    PATH="${PATH}:${SPARK_HOME}/bin"

RUN if [ -z "${scala_version}" ]; then \
    ln -s "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}" "${SPARK_HOME}"; \
    else \
    ln -s "spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}-scala${scala_version}" "${SPARK_HOME}"; \
    fi && \
    # Add a link in the before_notebook hook in order to source automatically PYTHONPATH && \
    mkdir -p /usr/local/bin/before-notebook.d && \
    ln -s "${SPARK_HOME}/sbin/spark-config.sh" /usr/local/bin/before-notebook.d/spark-config.sh

# Configure IPython system-wide
COPY ipython_kernel_config.py "/etc/ipython/"
RUN chmod 777 "/etc/ipython/"

# Install pyarrow
# Temporarily pin pandas to version 1.5.3, see: https://github.com/jupyter/docker-stacks/issues/1924
RUN conda install --yes \
    'pandas>=1.5.3,<2.0.0' \
    'pyarrow' && \
    conda clean --all -f -y

RUN pip install pyspark
RUN conda install -c conda-forge findspark

EXPOSE 4040

USER 1001

WORKDIR $HOME
