# Nextflow Bioinformatics Basic Workflow

A basic bioinformatics data analysis workflow for testing of Nextflow and demonstrating functionality and configurations.

# Usage

Clone this repo:

```
git clone https://github.com/stevekm/nf-bio-basic.git
cd nf-bio-basic
```

Run the workflow

```
make run
```
* NOTE: This default configuration runs with Docker in the local session.

## Conda

The workflow can be run with conda instead of Docker. A fresh installation of conda will be created in the current directory, and the included `env.yml` file will be used to create a cona env to run the workflow with.

```
make run-conda
```

*HPC Compatibility:* NYU Big Purple, NYU phoenix

## Singularity

The workflow can be run with Singularity instead of Docker. 

### Build Singularity Container

The Singularity container can be built on macOS by using Vagrant. If you dont have Vagrant on your Mac, install it with these commands:

```
brew cask install virtualbox
brew cask install vagrant # https://releases.hashicorp.com/vagrant/2.0.1/vagrant_2.0.1_x86_64.dmg
brew cask install vagrant-manager
```
The container can then be built with the following command:
```
make singularity-container
```
You will have to manually transfer the output container file `singularity-vm/image/nf-bio-basic.simg` to your system where you intend to run the workflow (e.g. HPC cluster).

### Run with Singularity

Once the Singularity container file is transfered to or created on your system, you can run the workflow with Singularity in the local session by using the following command:

```
make run-singularity
```

* NOTE: This configuration call system module `singularity/2.5.2`, which is required for NYU Big Purple HPC compatibility. Remove this from `nextflow.config` to adjust if needed.

*HPC Compatibility:* NYU Big Purple

## Extra `run` Configuration

Extra parameters can be passed to the Nextflow run command via the `EP` argument;

```
make run EP='-resume'
```

### HPC Schedulers

To submit jobs with an HPC scheduler, use one of the following commands:

- `make run-conda-slurm` (NYU Big Purple)
- `make run-singularity-slurm` (NYU Big Purple)
- `make run-conda-sge` (NYU phoenix)

# Software
- bash
- Java 8 or later (for Nextflow)
- Python
- Docker (optional)
- bzip2 (for conda)
- standard GNU tools
- Vagrant (optional)
