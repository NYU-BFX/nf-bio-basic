FROM ubuntu:16.04

MAINTAINER Stephen M. Kelly

# ~~~~~ BASIC SETUP ~~~~~ #
RUN apt-get update && \
apt-get install -y wget \
bzip2

# ~~~~~ MINICONDA ~~~~~ #
RUN wget https://repo.continuum.io/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh && \
bash Miniconda3-4.5.4-Linux-x86_64.sh -b -p /conda && \
rm -f Miniconda3-4.5.4-Linux-x86_64.sh
ENV PATH="/conda/bin:${PATH}"
RUN conda config --add channels defaults
RUN conda config --add channels conda-forge
RUN conda config --add channels bioconda
RUN conda install -y -c bioconda fastqc==0.11.7 multiqc=1.5
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
