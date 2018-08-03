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
NOTE: The default configuration runs with Docker.

## Conda

The workflow can be run with conda instead of Docker. A fresh installation of conda will be created in the current directory, and the included `env.yml` file will be used to create a cona env to run the workflow with.

```
make run-conda
```

NOTE: The conda version can be changed upon first install with the `CONDASH` argument;

```
make run-conda CONDASH=Miniconda3-4.5.4-Linux-x86_64.sh
```

## Extra `run` Configuration

Extra parameters can be passed to the Nextflow run command via the `EP` argument;

```
make run EP='-resume'
```

# Software
- bash
- Java 8 or later (for Nextflow)
- Python
- Docker (optional)
- bzip2 (for conda)
- standard GNU tools
