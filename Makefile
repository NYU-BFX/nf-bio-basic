SHELL:=/bin/bash
UNAME:=$(shell uname)
none:

# ~~~~~ SETUP PIPELINE ~~~~~ #
./nextflow:
	curl -fsSL get.nextflow.io | bash

install: ./nextflow

update: ./nextflow
	./nextflow self-update


# ~~~~~ SETUP CONDA ~~~~~ #
ifeq ($(UNAME), Darwin)
CONDASH:=Miniconda3-4.5.4-MacOSX-x86_64.sh
endif

ifeq ($(UNAME), Linux)
CONDASH:=Miniconda3-4.5.4-Linux-x86_64.sh
endif
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
TIMESTAMP=$(shell date +%s)
clean-conda:
	[ -d conda ] && mv conda ".conda.old.${TIMESTAMP}" && rm -rf ".conda.old.${TIMESTAMP}" &

# ~~~~~ SETUP DOCKER ~~~~~ #
check-Docker:
	docker --version > /dev/null 2>&1 || { echo "ERROR: 'docker' not found, is it running?" && exit 1 ; }
docker: check-Docker
	docker build -t stevekm/nf-bio-basic .
docker-test: docker
	docker run --rm -ti stevekm/nf-bio-basic bash


# ~~~~~ CREATE SINGULARITY IMAGE ON MAC USING VAGRANT ~~~~~ #
# # Requires Vagrant install:
# brew cask install virtualbox
# brew cask install vagrant # https://releases.hashicorp.com/vagrant/2.0.1/vagrant_2.0.1_x86_64.dmg
# brew cask install vagrant-manager
# #
# set up directories and files for Vagrant
vagrant-installed:
	type vagrant >/dev/null 2>&1 || { echo >&2 "Vagrant required but not found. Aborting."; exit 1; }

# singularity-vm:
# 	mkdir -p singularity-vm
#
# singularity-vm/Vagrantfile: singularity-vm
# 	if [ ! -f singularity-vm/Vagrantfile ]; then \
# 	cd singularity-vm && \
# 	vagrant init singularityware/singularity-2.4 && \
# 	sed -i '' 's|  # config.vm.synced_folder "../data", "/vagrant_data"|  config.vm.synced_folder "image", "/image"|' Vagrantfile ; \
# 	fi
#
# singularity-vm/image: singularity-vm
# 	mkdir -p singularity-vm/image

singularity-vm/image/Singularity: 
	/bin/cp -v Singularity singularity-vm/image/Singularity

# Create the Singularity container file
singularity-vm/image/nf-bio-basic.simg: singularity-vm/image/Singularity
	cd singularity-vm && \
	vagrant up && \
	vagrant ssh -c 'cd /image && sudo singularity build nf-bio-basic.simg Singularity'

singularity-container: singularity-vm/image/nf-bio-basic.simg

singularity-vm/image/multiqc.txt: singularity-vm/image/nf-bio-basic.simg
	cd singularity-vm && \
	vagrant up && \
	vagrant ssh -c 'cd /image && singularity exec nf-bio-basic.simg multiqc --version > multiqc.txt'

singularity-test: singularity-vm/image/multiqc.txt
	cat singularity-vm/image/multiqc.txt



# ~~~~~ RUN PIPELINE ~~~~~ #
# $ make run EP='-profile sge -resume'
# default run use Docker, executes locally
run: install
	./nextflow run main.nf $(EP)

run-conda: install conda
	if [ "$$( module > /dev/null 2>&1; echo $$?)" -eq 0 ]; then module unload python ; fi ; \
	unset PYTHONHOME; unset PYTHONPATH; source "$(CONDA_ACTIVATE)" && \
	./nextflow run main.nf -profile conda $(EP)

# conda needs to be in PATH for parent Nextflow process !!
run-conda-slurm: install conda
	if [ "$$( module > /dev/null 2>&1; echo $$?)" -eq 0 ]; then module unload python ; fi ; \
	unset PYTHONHOME; unset PYTHONPATH; source "$(CONDA_ACTIVATE)" && \
	./nextflow run main.nf -profile slurmConda $(EP)

run-conda-sge: install conda
	if [ "$$( module > /dev/null 2>&1; echo $$?)" -eq 0 ]; then module unload python ; fi ; \
	unset PYTHONHOME; unset PYTHONPATH; source "$(CONDA_ACTIVATE)" && \
	./nextflow run main.nf -profile sgeConda $(EP)

SINGULARITYIMG:=singularity-vm/image/nf-bio-basic.simg
run-singularity-slurm: install
	./nextflow run main.nf -profile singularity,slurm $(EP)

run-singularity: install
	./nextflow run main.nf -profile singularity $(EP)


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

