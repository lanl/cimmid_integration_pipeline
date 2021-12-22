#!/bin/sh
  
############################################################################################
# Runs an experiment (integrarted model). 
# Usage: ./run_experiment.sh -r RUN_NUM -m MODEL_TO_START_FROM MINICONDA_PATH CONFIG_FILE
# -r: Run number (optional; positive integer)
# -m: Model to start this run from (optional; useful when some of the intial models have succeeded and need to run from the point of failure)
# MINICONDA_PATH: Path where miniconda3 is installed (e.g., '/turquoise/users/nidhip/miniconda3')
# CONFIG_FILE: Config file (e.g., cimmid.yaml)

# TO DO: Update above path to a path in project directory instead of in my home directory
############################################################################################

module load gcc

# Print script usage
PRINT_USAGE() {
    echo "Usage: ./run_experiment.sh -r RUN_NUM -m MODEL_TO_START_FROM MINICONDA_PATH CONFIG_FILE"
    echo "-r: Run number (optional; positive integer)"
    echo "-m: Model to start this run from (optional; useful when some of the intial models have succeeded and need to run from the point of failure)"
    echo "MINICONDA_PATH: Path where miniconda3 is installed (e.g., '/turquoise/users/nidhip/miniconda3')"
    echo -e "CONFIG_FILE: Config file (e.g., cimmid.yaml)\n"
    exit
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
    MODEL_TO_START_FROM='hydropop'
fi
# Check if model to start this run from is correct.
if ! [ "$MODEL_TO_START_FROM" = "hydropop" ] && ! [ "$MODEL_TO_START_FROM" = "mosquito_pop" ] && ! [ "$MODEL_TO_START_FROM" = "human_epi" ]; then
    echo -e "ERROR!! Model to start this run from (option -m) must be hydropop, mosquito_pop, or human_epi."
    exit
fi

# Check for correct number of arguments.
if [ "$#" -lt 2 ] || ! [ -d "$1" ] || ! [ -f "$2" ]; then
    echo -e "ERROR!! Incorrect number or type of arguments. See usage information below:\n"
    PRINT_USAGE
    exit
fi

# ADD CIMMID miniconda path to PATH.
MINICONDA_PATH=$1
export PATH="$MINICONDA_PATH/bin:$PATH"
conda config --prepend envs_dirs "$MINICONDA_PATH/envs"
conda activate integration

# Get config file
CONFIG_FILE=$2
PROJECT_ROOT=`cat $CONFIG_FILE | shyaml get-value TURQUOISE_NET.PROJECT_ROOT`
CONFIG_FILE="$PROJECT_ROOT/$2"

# Read paths from config file
INTEGRATION_DIR=`cat $CONFIG_FILE | shyaml get-value INTEGRATION_MODEL.REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
HYDROPO_DIR=`cat $CONFIG_FILE | shyaml get-value HYDROPOP_MODEL.REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
MOSQUITO_POP_DIR=`cat $CONFIG_FILE | shyaml get-value MOSQUITO_POP_MODEL.REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
EPI_DIR=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL.REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
INTEGRATION_BRANCH=`cat $CONFIG_FILE | shyaml get-value INTEGRATION_MODEL.BRANCH`
HYDROPO_BRANCH=`cat $CONFIG_FILE | shyaml get-value HYDROPOP_MODEL.BRANCH`
MOSQUITO_POP_BRANCH=`cat $CONFIG_FILE | shyaml get-value MOSQUITO_POP_MODEL.BRANCH`
EPI_MODEL_BRANCH=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL.BRANCH`
conda deactivate

# Set paths
INTEGRATION_PATH="$PROJECT_ROOT/$INTEGRATION_DIR"
MODELS_PATH="$INTEGRATION_PATH/models"
HYDROPOP_MODEL_PATH="$MODELS_PATH/$HYDROPO_DIR"
MOSQUITO_POP_MODEL_PATH="$MODELS_PATH/$MOSQUITO_POP_DIR"
HUMAN_EPI_MODEL_PATH="$MODELS_PATH/$EPI_DIR"
EXPERIMENTS_PATH="$INTEGRATION_PATH/experiments"
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
HYDROPOP_MODEL_OUTPUT_PATH=$OUTPUT_PATH/HPU_forcing_data
MOSQUITO_POP_MODEL_OUTPUT_PATH=$OUTPUT_PATH/mosquito_pop_output
HUMAN_EPI_MODEL_OUTPUT_PATH=$OUTPUT_PATH/human_model_output
LOGS_PATH=$CURRENT_RUN_PATH/logs
HYDROPOP_LOGS_PATH=$LOGS_PATH/hydropop
MOSQUITO_POP_LOGS_PATH=$LOGS_PATH/mosquito_pop
HUMAN_EPI_LOGS_PATH=$LOGS_PATH/human_epi

MOSQUITO_POP_INPUT_PATH="$MOSQUITO_POP_MODEL_PATH/input"

# Config file names
HYDROPOP_CONFIG_FILENAME='hp_config_darwin.yaml'
MOSQUITO_POP_CONFIG_FILENAME='mosq_config.yaml'
HUMAN_EPI_CONFIG_FILENAME='human_epi_config.yaml'
