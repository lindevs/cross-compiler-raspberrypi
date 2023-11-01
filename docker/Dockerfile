FROM ubuntu

WORKDIR /rpi-cross

RUN apt-get update \
    && apt-get install -y \
        gperf flex texinfo gawk gfortran bison build-essential unzip wget git libncurses-dev autoconf automake \
        rsync python3 \
    && git clone https://github.com/lindevs/cross-compiler-raspberrypi.git . \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]
