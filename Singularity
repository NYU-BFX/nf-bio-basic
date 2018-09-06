BootStrap: docker
OSVersion: xenial
MirrorURL: http://us.archive.ubuntu.com/ubuntu/
From: ubuntu:16.04

%post
    # ~~~~~ BASIC SETUP ~~~~~ #
    apt-get update && \
    apt-get install -y wget \
    bzip2

    # ~~~~~ MINICONDA ~~~~~ #
    wget https://repo.continuum.io/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh && \
    bash Miniconda3-4.5.4-Linux-x86_64.sh -b -p /conda && \
    rm -f Miniconda3-4.5.4-Linux-x86_64.sh
    conda config --add channels defaults
    conda config --add channels conda-forge
    conda config --add channels bioconda

    # ~~~~~ MULTIQC ~~~~~ #
    conda install -y -c bioconda fastqc==0.11.5 multiqc=1.5

%environment
    export PATH="/conda/bin:${PATH}"
    export LC_ALL="C.UTF-8"
    export LANG="C.UTF-8"
