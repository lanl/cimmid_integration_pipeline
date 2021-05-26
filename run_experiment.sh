#!/bin/sh

# load/unload modules
module unload gcc
module load gcc/7.2.0

# ADD CIMMID miniconda path to PATH
export PATH="/projects/cimmid/miniconda3/bin:$PATH"

# TO DO: Need to figure out a way to get run number. If given as an argument, runs for the current number and if not given, gets the next run number based on experiments directory.
RUN_NUM=0

# Set paths
# TO DO: When really coupling models, will need to deal with input data paths for all models. Skipping for toy model as they likely do not connect for now. Connecting even trivially may be a good next step. Need to talk to modeling teams. Katy is going to talk to Jon and Jeff about this.
BASE_PATH="/projects/cimmid/users/nidhip/integration/toy_model"
HYDROPOP_MODEL_PATH="$BASE_PATH/hydropop/toy_model"
HUMAN_EPI_MODEL_PATH="$BASE_PATH/dengue_model/Epi_SEIR"
EXPERIMENTS_PATH="$BASE_PATH/experiments"
RUNS_PATH="$EXPERIMENTS_PATH/runs"
CURRENT_RUN_PATH="$RUNS_PATH/r$RUN_NUM"
CONFIG_PATH=$CURRENT_RUN_PATH/config
OUTPUT_PATH=$CURRENT_RUN_PATH/output
HYDROPOP_MODEL_OUTPUT_PATH=$OUTPUT_PATH/HPU_forcing_data
HUMAN_EPI_MODEL_OUTPUT_PATH=$OUTPUT_PATH/human_model_output
LOGS_PATH=$CURRENT_RUN_PATH/logs
HYDROPOP_LOGS_PATH=$LOGS_PATH/hydropop
HUMAN_EPI_LOGS_PATH=$LOGS_PATH/human_epi

# Config file names
HYDROPOP_CONFIG_FILENAME='hp_config_darwin.yaml'
HUMAN_EPI_CONFIG_FILENAME='human_epi_config.yaml'

# Create run directories
# TO DO: If starting experiment from begining need to remove CURRENT_RUN_PATH. If redoing experiemnt from a certqain step, need to keep exisitng directory. 
mkdir $CURRENT_RUN_PATH
mkdir $CONFIG_PATH
mkdir $OUTPUT_PATH
mkdir $HYDROPOP_MODEL_OUTPUT_PATH
mkdir $HUMAN_EPI_MODEL_OUTPUT_PATH
mkdir $LOGS_PATH
mkdir $HYDROPOP_LOGS_PATH
mkdir $HUMAN_EPI_LOGS_PATH

# Set config files
# TO DO: Need to figure out how to set paramter values in config files.

##### Run hydropop model
echo "$(date): Running hydropop model.."
sh run_hydropop_model.sh $HYDROPOP_MODEL_PATH $CONFIG_PATH $HYDROPOP_CONFIG_FILENAME $HYDROPOP_MODEL_OUTPUT_PATH $HYDROPOP_LOGS_PATH
SUCCESS_FLAG=`tail -1 $HYDROPOP_LOGS_PATH/hydropop.out | grep "SUCCESS"`
if [ "$SUCCESS_FLAG" = "SUCCESS" ]; then
    echo "$(date): Hydropop model completed successfully."
else
    echo "$(date): ERROR!! hydropop model failed."
    cat $HYDROPOP_LOGS_PATH/hydropop.out | mail -s "CIMMID hydropop model run failed. Run directory is at darwin-fe:$CURRENT_RUN_PATH." nidhip@lanl.gov
    # TO DO: Need to email the relevant team (instead of nidhip) on failure.
fi

##### Run human epi model
echo "$(date): Running human epi model.."
sh run_human_epi_model.sh $HUMAN_EPI_MODEL_PATH $CONFIG_PATH $HUMAN_EPI_CONFIG_FILENAME $HUMAN_EPI_MODEL_OUTPUT_PATH $HUMAN_EPI_LOGS_PATH
NUM_EPI_MODELS=`cat $HUMAN_EPI_MODEL_PATH/run_human_epi_model.sh | grep "python models_main.py" | wc -l`
NUM_SUCCESSES=`cat $HUMAN_EPI_LOGS_PATH/* | grep "SUCCESS" | wc -l`
if [ "$NUM_EPI_MODELS" -eq "$NUM_SUCCESSES" ]; then
    echo "$(date): human epi model completed successfully."
else
    echo "$(date): ERROR!! human epi model failed."
    cat $HUMAN_EPI_LOGS_PATH/* | mail -s "CIMMID human epi model run failed. Run directory is at darwin-fe:$CURRENT_RUN_PATH." nidhip@lanl.gov
    # TO DO: Need to email the relevant team (instead of nidhip) on failure.
fi
