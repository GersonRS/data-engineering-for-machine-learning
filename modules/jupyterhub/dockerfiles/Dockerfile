FROM bitnami/jupyter-base-notebook:latest
USER root
RUN apt-get install git-all -y
RUN conda install --quiet --yes \
    'mlflow' \
    'seaborn' \
    'pandas' \
    'boto3' \
    'atom-ml[full]' \
    'scikit-learn' \
    'ipywidgets' \
    'lightgbm' \
    'optuna' \
    'matplotlib-base' \
    'scipy' && \
    conda clean --all -f -y
USER 1001
