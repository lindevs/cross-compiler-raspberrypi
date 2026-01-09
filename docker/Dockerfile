FROM ubuntu

WORKDIR /app

RUN apt-get update && apt-get install -y \
        gperf flex texinfo gawk gfortran bison build-essential unzip wget git libncurses-dev autoconf automake \
        rsync python3 \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/bash"]
