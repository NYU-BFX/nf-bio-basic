SHELL:=/bin/bash
none:

# ~~~~~ SETUP PIPELINE ~~~~~ #
./nextflow:
	curl -fsSL get.nextflow.io | bash

install: ./nextflow

update: ./nextflow
	./nextflow self-update


# ~~~~~ SETUP CONDA ~~~~~ #
CONDASH:=Miniconda3-4.5.4-Linux-x86_64.sh
# CONDASH:=Miniconda3-4.5.4-MacOSX-x86_64.sh
# CONDASH:=Miniconda3-4.5.4-Linux-ppc64le.sh
CONDAURL:=https://repo.continuum.io/miniconda/$(CONDASH)
CONDADIR:=$(shell python -c 'import os; print(os.path.realpath("conda"))')
CONDA_ACTIVATE:=$(CONDADIR)/bin/activate
conda:
	wget "$(CONDAURL)" && \
	bash "$(CONDASH)" -b -p conda && \
	rm -f "$(CONDASH)" && \
	unset PYTHONHOME; unset PYTHONPATH && \
	source "$(CONDA_ACTIVATE)" && \
	conda config --add channels defaults && \
	conda config --add channels bioconda

# NOTE: methods of getting local conda into PATH;
# unset PYTHONHOME; unset PYTHONPATH; export PATH=$(CONDADIR)/bin:$$PATH; \
# unset PYTHONHOME; unset PYTHONPATH; source "$(CONDA_ACTIVATE)" && \

# ~~~~~ SETUP DOCKER ~~~~~ #
check-Docker:
	docker --version > /dev/null 2>&1 || { echo "ERROR: 'docker' not found, is it running?" && exit 1 ; }
docker: check-Docker
	docker build -t stevekm/nf-bio-basic .
docker-test: docker
	docker run --rm -ti stevekm/nf-bio-basic bash


# ~~~~~ RUN PIPELINE ~~~~~ #
# $ make run EP='-profile sge -resume'
run: install
	./nextflow run main.nf $(EP)

run-conda: install conda
	if [ "$$( module > /dev/null 2>&1; echo $$?)" -eq 0 ]; then module unload python ; fi ; \
	unset PYTHONHOME; unset PYTHONPATH; source "$(CONDA_ACTIVATE)" && \
	./nextflow run main.nf -profile conda $(EP)

run-conda-slurm:
	if [ "$$( module > /dev/null 2>&1; echo $$?)" -eq 0 ]; then module unload python ; fi ; \
	unset PYTHONHOME; unset PYTHONPATH; source "$(CONDA_ACTIVATE)" && \
	./nextflow run main.nf -profile slurmConda $(EP)

run-conda-sge:
	if [ "$$( module > /dev/null 2>&1; echo $$?)" -eq 0 ]; then module unload python ; fi ; \
	unset PYTHONHOME; unset PYTHONPATH; source "$(CONDA_ACTIVATE)" && \
	./nextflow run main.nf -profile conda,sge $(EP)

# ~~~~~ CLEANUP ~~~~~ #
clean-traces:
	rm -f trace*.txt.*

clean-logs:
	rm -f .nextflow.log.*

clean-reports:
	rm -f *.html.*

clean-flowcharts:
	rm -f *.dot.*

clean-output:
	[ -d output ] && mv output oldoutput && rm -rf oldoutput &

clean-work:
	[ -d work ] && mv work oldwork && rm -rf oldwork &

# deletes files from previous runs of the pipeline, keeps current results
clean: clean-logs clean-traces clean-reports clean-flowcharts

# deletes all pipeline output
clean-all: clean clean-output clean-work
	[ -d .nextflow ] && mv .nextflow .nextflowold && rm -rf .nextflowold &
	rm -f .nextflow.log
	rm -f *.png
	rm -f trace*.txt*
	rm -f *.html*

TIMESTAMP=$(shell date +%s)
clean-conda:
	[ -d conda ] && mv conda ".conda.old.${TIMESTAMP}" && rm -rf ".conda.old.${TIMESTAMP}" &