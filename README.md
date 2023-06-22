# Toy Integration Model

## How to run?

When running integrated model (or experiment) first time from a new directory (or cluster), install miniconda (see instructions at https://docs.conda.io/projects/conda/en/latest/user-guide/install/linux.html) and then, run following to create required directories, set up virtual environment, git clone code/models, etc.

    ./setup.sh PATH_TO_MINICONDA_INSTALLATION

    PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3' for Darwin)

To run an experiment, run following:

    ./run_experiment.sh -r RUN_NUM -m MODEL_TO_START_FROM PATH_TO_MINICONDA_INSTALLATION

    -r: Run number (optional)
    -m: Model to start this run from (optional; useful when some of the intial models have succeeded and need to run from the point of failure)
    PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3' for Darwin)
