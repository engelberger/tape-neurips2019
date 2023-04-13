# Build stage image to install python
FROM nvidia/cuda:10.0-cudnn7-runtime as builder

ENV DEBIAN_FRONTEND=noninteractive



RUN rm /etc/apt/sources.list.d/cuda.list
RUN rm /etc/apt/sources.list.d/nvidia-ml.list
RUN apt-get update && apt-get install -y wget
RUN   apt-key del 7fa2af80
ADD   https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb .
RUN   dpkg -i cuda-keyring_1.0-1_all.deb

#RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
#RUN mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
#RUN apt-key add --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
#RUN add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
#RUN apt-get update
#RUN apt-get -y install cuda




RUN apt-get update -y && apt-get install -y --no-install-recommends wget
# Prerequisites: https://github.com/pyenv/pyenv/wiki/common-build-problems#prerequisites
RUN apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python-openssl git
RUN apt-get clean

# Install Pyenv
RUN git clone https://github.com/pyenv/pyenv /opt/pyenv

ENV PYENV_ROOT=/opt/pyenv \
    PATH=${PYENV_ROOT}/bin:${PATH}

# Install Python 3.6.8
RUN /opt/pyenv/bin/pyenv install 3.6.8 \
    && /opt/pyenv/versions/3.6.8/bin/python -m pip install --upgrade pip setuptools wheel

# Runtime image
FROM nvidia/cuda:10.0-cudnn7-runtime

RUN rm /etc/apt/sources.list.d/cuda.list
RUN rm /etc/apt/sources.list.d/nvidia-ml.list
RUN apt-get update && apt-get install -y wget
RUN   apt-key del 7fa2af80
ADD   https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb .
RUN   dpkg -i cuda-keyring_1.0-1_all.deb

COPY --from=builder /opt/pyenv/versions/ /opt/pyenv/versions

ENV DEBIAN_FRONTEND=noninteractive

ENV PATH=/opt/pyenv/versions/3.6.8/bin:${PATH} \
    LD_LIBRARY_PATH=/opt/pyenv/versions/$python_version/lib

RUN apt-get update && apt-get install -y gcc g++ git && apt-get clean

RUN git clone -b 2023 https://github.com/engelberger/tape-neurips2019.git /tape-neurips2019



#COPY setup.py .
#COPY tape ./tape
WORKDIR /tape-neurips2019/
# Install dependencies
RUN /opt/pyenv/versions/3.6.8/bin/python -m pip install https://github.com/codecov/codecov-python/archive/refs/tags/v2.1.12.tar.gz
RUN /opt/pyenv/versions/3.6.8/bin/python -m pip install --no-cache-dir -e .