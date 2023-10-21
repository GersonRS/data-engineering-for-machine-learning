# The examples Docker image adds dependencies needed to run the examples

FROM rayproject/ray-ml:2.6.3-py38-cpu

USER $RAY_UID
# Needed to run Tune example with a 'plot' call - which does not actually render a plot, but throws an error.
RUN apt-get update && apt-get install -y zlib1g-dev libgl1-mesa-dev libgtk2.0-dev && apt-get clean
RUN pip install --no-cache-dir -U pip \
    atom-ml[full] \
    modin[all]
