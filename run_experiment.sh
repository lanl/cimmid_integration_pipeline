#!/bin/sh

############################################################################################
# Runs an experiment (integrarted model). 
# Usage: ./run_experiment.sh -r RUN_NUM -m MODEL_TO_START_FROM MINICONDA_PATH CONFIG_FILE
# -r: Run number (optional)
# -m: Model to start this run from (optional; useful when some of the intial models have succeeded and need to run from the point of failure)
# MINICONDA_PATH: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3' for Darwin)
# CONFIG_FILE: Config file (e.g., cimmid_darwin.yaml)
############################################################################################

# load/unload modules
module load gcc

# Print script usage
PRINT_USAGE() {
    echo "Usage: ./run_experiment.sh -r RUN_NUM -m MODEL_TO_START_FROM MINICONDA_PATH CONFIG_FILE"
    echo "-r: Run number (optional; positive integer)"
    echo -e "-m: Model to start this run from (optional; useful when some of the intial models have succeeded and need to run from the point of failure)"
    echo -e "MINICONDA_PATH: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3' for Darwin)"
    echo "CONFIG_FILE: Config file (e.g., cimmid_darwin.yaml)\n"
}

# Get run number from command line arguments if specified
while getopts "r:m:" opt
do
    case $opt in
        (r) RUN_NUM=$OPTARG
            ;;
        (m) MODEL_TO_START_FROM=$OPTARG
            ;;
    esac
done
shift $(( OPTIND - 1 ))

# If Model to start this run from is not provided, start form begining.
if [ -z "$MODEL_TO_START_FROM" ]; then
    MODEL_TO_START_FROM='mosquito_pop'
fi
# Check if model to start this run from is correct.
if ! [ "$MODEL_TO_START_FROM" = "mosquito_pop" ] && ! [ "$MODEL_TO_START_FROM" = "human_epi" ]; then
    echo -e "ERROR!! Model to start this run from (option -m) must be mosquito_pop or human_epi."
    exit
fi

# Check for correct number of arguments.
if [ "$#" -lt 2 ] || ! [ -d "$1" ] || ! [ -f "$2" ]; then
    echo -e "ERROR!! Incorrect number or type of arguments. See usage information below:\n"
    PRINT_USAGE
    exit
fi

# ADD CIMMID miniconda path to PATH
MINICONDA_PATH=$1
export PATH="$MINICONDA_PATH/bin:$PATH"
conda config --prepend envs_dirs "$MINICONDA_PATH/envs"
#conda activate integration
source activate integration

# Get config file
CONFIG_FILE=$2

# Set base path
BASE_PATH="$PWD"
CONFIG_FILE="$BASE_PATH/$CONFIG_FILE"

# Read paths from config file
MOSQUITO_POP_DIR=`cat $CONFIG_FILE | shyaml get-value MOSQUITO_POP_MODEL.REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
EPI_DIR=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL.REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`

MOSQUITO_POP_BRANCH=`cat $CONFIG_FILE | shyaml get-value MOSQUITO_POP_MODEL.BRANCH`
EPI_MODEL_BRANCH=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL.BRANCH`

EPI_MODEL_DIR=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL.MODEL_DIR`

MOSQUITO_POP_CONFIG_FILENAME=`cat $CONFIG_FILE | shyaml get-value MOSQUITO_POP_MODEL.CONFIG_FILENAME`
EPI_CONFIG_FILENAME=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL.CONFIG_FILENAME`

MOSQUITO_POP_OUTPUT_DIRNAME=`cat $CONFIG_FILE | shyaml get-value MOSQUITO_POP_MODEL.OUTPUT_DIRNAME`
EPI_OUTPUT_DIRNAME=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL.OUTPUT_DIRNAME`

MOSQUITO_POP_LOG_DIRNAME=`cat $CONFIG_FILE | shyaml get-value MOSQUITO_POP_MODEL.LOG_DIRNAME`
EPI_LOG_DIRNAME=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL.LOG_DIRNAME`

conda deactivate

# Set paths
MODELS_PATH="$BASE_PATH/models"
MOSQUITO_POP_MODEL_PATH="$MODELS_PATH/$MOSQUITO_POP_DIR"
HUMAN_EPI_MODEL_PATH="$MODELS_PATH/$EPI_DIR/$EPI_MODEL_DIR"
EXPERIMENTS_PATH="$BASE_PATH/experiments"
RUNS_PATH="$EXPERIMENTS_PATH/runs"
if [ "$RUN_NUM" == "" ]; then
    RUN_NUM=$(python get_run_num.py $RUNS_PATH 2>&1)
fi

# Check if run number is integer
#if ! [ "$RUN_NUM" =~ ^[0-9]+$ ] ; then
if ! [ "$RUN_NUM" -ge 0 ] ; then
    echo -e "ERROR!! RUN_NUM has to be a positive integer. See usage information below:\n"
    PRINT_USAGE
    exit
fi

# Set current run specific paths
CURRENT_RUN_PATH="$RUNS_PATH/r$RUN_NUM"
CONFIG_PATH=$CURRENT_RUN_PATH/config
OUTPUT_PATH=$CURRENT_RUN_PATH/output
MOSQUITO_POP_MODEL_OUTPUT_PATH="$OUTPUT_PATH/$MOSQUITO_POP_OUTPUT_DIRNAME"
HUMAN_EPI_MODEL_OUTPUT_PATH="$OUTPUT_PATH/$EPI_OUTPUT_DIRNAME"
LOGS_PATH=$CURRENT_RUN_PATH/logs
MOSQUITO_POP_LOGS_PATH="$LOGS_PATH/$MOSQUITO_POP_LOG_DIRNAME"
HUMAN_EPI_LOGS_PATH="$LOGS_PATH/$EPI_LOG_DIRNAME"

# TO DO: Fix this while linking models
MOSQUITO_POP_INPUT_PATH="$MOSQUITO_POP_MODEL_PATH/input"
HUMAN_EPI_INPUT_PATH=$MOSQUITO_POP_MODEL_OUTPUT_PATH

# Create run directories
sh makedir_if_not_exists.sh $CURRENT_RUN_PATH
sh makedir_if_not_exists.sh $CONFIG_PATH
sh makedir_if_not_exists.sh $OUTPUT_PATH
sh makedir_if_not_exists.sh $MOSQUITO_POP_MODEL_OUTPUT_PATH
sh makedir_if_not_exists.sh $HUMAN_EPI_MODEL_OUTPUT_PATH
sh makedir_if_not_exists.sh $LOGS_PATH
sh makedir_if_not_exists.sh $MOSQUITO_POP_LOGS_PATH
sh makedir_if_not_exists.sh $HUMAN_EPI_LOGS_PATH

# Set config files
# TO DO: Need to figure out how to set paramter values in config files.

# Run mosquito pop model
RUN_MOSQUITO_POP_MODEL() {
    echo "$(date): Running mosquito pop model.."
    sh run_mosqito_pop_model.sh $MOSQUITO_POP_MODEL_PATH $CONFIG_PATH $MOSQUITO_POP_CONFIG_FILENAME $MOSQUITO_POP_INPUT_PATH $MOSQUITO_POP_MODEL_OUTPUT_PATH $MOSQUITO_POP_LOGS_PATH $MOSQUITO_POP_BRANCH $MINICONDA_PATH $CONFIG_FILE &> $MOSQUITO_POP_LOGS_PATH/mosquito_pop.out
    SUCCESS_FLAG=`tail -1 $MOSQUITO_POP_LOGS_PATH/mosquito_pop.out | grep "SUCCESS"`
    if ! [ -z "$SUCCESS_FLAG" ]; then
        echo "$(date): Mosquito pop model completed successfully."
    else
        echo "$(date): ERROR!! Mosquito pop model failed."
        cat $MOSQUITO_POP_LOGS_PATH/mosquito_pop.out | mail -s "CIMMID mosquito pop model run failed. Run directory is at darwin-fe:$CURRENT_RUN_PATH." nidhip@lanl.gov
        # TO DO: Need to email the relevant team (instead of nidhip) on failure.
        exit
    fi
}

# Run Run human epi model
RUN_HUMAN_EPI_MODEL() {
    echo "$(date): Running human epi model.."
    sh run_human_epi_model.sh $HUMAN_EPI_MODEL_PATH $CONFIG_PATH $EPI_CONFIG_FILENAME $HUMAN_EPI_INPUT_PATH $HUMAN_EPI_MODEL_OUTPUT_PATH $HUMAN_EPI_LOGS_PATH $EPI_MODEL_BRANCH $MINICONDA_PATH $CONFIG_FILE &> $HUMAN_EPI_LOGS_PATH/human_epi.out
    SUCCESS_FLAG=`cat $HUMAN_EPI_LOGS_PATH/human_epi.out | grep "ALL HPU RUNS SUCCESSFUL"`
    if ! [ -z "$SUCCESS_FLAG" ]; then
        echo "$(date): Human epi model completed successfully."
    else
        echo "$(date): ERROR!! human epi model failed."
        cat $HUMAN_EPI_LOGS_PATH/human_epi.out | mail -s "CIMMID human epi model run failed. Run directory is at darwin-fe:$CURRENT_RUN_PATH." nidhip@lanl.gov
        # TO DO: Need to email the relevant team (instead of nidhip) on failure.
        exit
    fi
}

# Run experiemnt from the specified model
if [ "$MODEL_TO_START_FROM" = "mosquito_pop" ]; then
    RUN_MOSQUITO_POP_MODEL
    RUN_HUMAN_EPI_MODEL
elif [ "$MODEL_TO_START_FROM" = "human_epi" ]; then
    # Check if previous model was successful. If so start experiment from human epi model. If not, raise an error.
    SUCCESS_FLAG=`tail -1 $MOSQUITO_POP_LOGS_PATH/mosquito_pop.out | grep "SUCCESS"`
    if [ -z "$SUCCESS_FLAG" ]; then
        echo -e "ERROR!! mosquito pop model was not successful for run $RUN_NUM. Try starting the run from mosquito pop model."
        exit
    fi
    RUN_HUMAN_EPI_MODEL
else
    echo -e "ERROR!! Model to start this run from (option -m) must be mosquito_pop or human_epi."
    exit
fi

