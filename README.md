# Toy Integration Model

TO DO: Add `setup.sh` that needs to be run first time we run experiment from a new directory/server to create required directories, set up virtual environment, git clone code/models, etc.

To run an experiment, run following:

    ./run_experiment.sh -r RUN_NUM -m MODEL_TO_START_FROM

    -r: Run number (optional)
    -m: Model to start this run from (optional; useful when some of the intial models have succeeded and need to run from the point of failure)
