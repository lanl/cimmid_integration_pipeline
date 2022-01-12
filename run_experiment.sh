#!/bin/sh

############################################################################################
# Runs an experiment (integrarted model). 
# Usage: ./run_experiment.sh -r RUN_NUM -m MODEL_TO_START_FROM MINICONDA_PATH
# -r: Run number (optional)
# -m: Model to start this run from (optional; useful when some of the intial models have succeeded and need to run from the point of failure)
# MINICONDA_PATH: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3' for Darwin)
############################################################################################

# load/unload modules
module unload gcc
module load gcc/7.2.0

HYDROPOP_BRANCH="master"
MOSQUITO_POP_BRANCH="master"
HUMAN_EPI_MODEL_BRANCH="master"

# Print script usage
PRINT_USAGE() {
    echo "Usage: ./run_experiment.sh -r RUN_NUM -m MODEL_TO_START_FROM MINICONDA_PATH"
    echo "-r: Run number (optional; positive integer)"
    echo -e "-m: Model to start this run from (optional; useful when some of the intial models have succeeded and need to run from the point of failure)"
    echo "MINICONDA_PATH: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3' for Darwin)\n"
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
if [ "$#" -lt 1 ] || ! [ -d "$1" ] ; then
    echo -e "ERROR!! MINICONDA_PATH must be specified. See usage information below:\n"
    PRINT_USAGE
    exit
fi

# ADD CIMMID miniconda path to PATH
MINICONDA_PATH=$1
export PATH="$MINICONDA_PATH/bin:$PATH"

# Set paths
# TO DO: When really coupling models, will need to deal with input data paths for all models. Skipping for toy model as they likely do not connect for now. Connecting even trivially may be a good next step. Need to talk to modeling teams. Katy is going to talk to Jon and Jeff about this.
BASE_PATH="$PWD/"
HYDROPOP_MODEL_PATH="$BASE_PATH/models/hydropop/toy_model"
MOSQUITO_POP_MODEL_PATH="$BASE_PATH/models/mosquito-toy-model"
HUMAN_EPI_MODEL_PATH="$BASE_PATH/models/human_epi_models/Epi_SEIR"
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

# Create run directories
sh makedir_if_not_exists.sh $CURRENT_RUN_PATH
sh makedir_if_not_exists.sh $CONFIG_PATH
sh makedir_if_not_exists.sh $OUTPUT_PATH
sh makedir_if_not_exists.sh $HYDROPOP_MODEL_OUTPUT_PATH
sh makedir_if_not_exists.sh $MOSQUITO_POP_MODEL_OUTPUT_PATH
sh makedir_if_not_exists.sh $HUMAN_EPI_MODEL_OUTPUT_PATH
sh makedir_if_not_exists.sh $LOGS_PATH
sh makedir_if_not_exists.sh $HYDROPOP_LOGS_PATH
sh makedir_if_not_exists.sh $MOSQUITO_POP_LOGS_PATH
sh makedir_if_not_exists.sh $HUMAN_EPI_LOGS_PATH

# Set config files
# TO DO: Need to figure out how to set paramter values in config files.

# Run hydropop model
RUN_HYDROPOP_MODEL() {
    echo "$(date): Running hydropop model.."
    sh run_hydropop_model.sh $HYDROPOP_MODEL_PATH $CONFIG_PATH $HYDROPOP_CONFIG_FILENAME $HYDROPOP_MODEL_OUTPUT_PATH $HYDROPOP_LOGS_PATH $HYDROPOP_BRANCH $MINICONDA_PATH &> $HYDROPOP_LOGS_PATH/hydropop.out
    SUCCESS_FLAG=`tail -1 $HYDROPOP_LOGS_PATH/hydropop.out | grep "SUCCESS"`
    if [ "$SUCCESS_FLAG" = "SUCCESS" ]; then
        echo "$(date): Hydropop model completed successfully."
    else
        echo "$(date): ERROR!! hydropop model failed."
        cat $HYDROPOP_LOGS_PATH/hydropop.out | mail -s "CIMMID hydropop model run failed. Run directory is at darwin-fe:$CURRENT_RUN_PATH." nidhip@lanl.gov
        # TO DO: Need to email the relevant team (instead of nidhip) on failure.
        exit
    fi      
}

# Run mosquito pop model
RUN_MOSQUITO_POP_MODEL() {
    echo "$(date): Running mosquito pop model.."
    sh run_mosqito_pop_model.sh $MOSQUITO_POP_MODEL_PATH $CONFIG_PATH $MOSQUITO_POP_CONFIG_FILENAME $MOSQUITO_POP_INPUT_PATH $MOSQUITO_POP_MODEL_OUTPUT_PATH $MOSQUITO_POP_LOGS_PATH $MOSQUITO_POP_BRANCH $MINICONDA_PATH &> $MOSQUITO_POP_LOGS_PATH/mosquito_pop.out
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
    sh run_human_epi_model.sh $HUMAN_EPI_MODEL_PATH $CONFIG_PATH $HUMAN_EPI_CONFIG_FILENAME $HUMAN_EPI_MODEL_OUTPUT_PATH $HUMAN_EPI_LOGS_PATH $HUMAN_EPI_MODEL_BRANCH $MINICONDA_PATH &> $HUMAN_EPI_LOGS_PATH/human_epi.out
    NUM_EPI_MODELS=`cat $HUMAN_EPI_MODEL_PATH/run_human_epi_model.sh | grep "python models_main.py" | wc -l`
    NUM_SUCCESSES=`cat $HUMAN_EPI_LOGS_PATH/* | grep "SUCCESS" | wc -l`
    if [ "$NUM_EPI_MODELS" -eq "$NUM_SUCCESSES" ]; then
        echo "$(date): Human epi model completed successfully."
    else
        echo "$(date): ERROR!! human epi model failed."
        cat $HUMAN_EPI_LOGS_PATH/* | mail -s "CIMMID human epi model run failed. Run directory is at darwin-fe:$CURRENT_RUN_PATH." nidhip@lanl.gov
        # TO DO: Need to email the relevant team (instead of nidhip) on failure.
        exit
    fi
}

# Run experiemnt from the specified model
if [ "$MODEL_TO_START_FROM" = "hydropop" ]; then
    RUN_HYDROPOP_MODEL
    RUN_MOSQUITO_POP_MODEL
    RUN_HUMAN_EPI_MODEL
elif [ "$MODEL_TO_START_FROM" = "mosquito_pop" ]; then
    # Check if previous model was successful. If so start experiment from mosquito pop model. If not, raise an error.
    SUCCESS_FLAG=`tail -1 $HYDROPOP_LOGS_PATH/hydropop.out | grep "SUCCESS"`
    if ! [ "$SUCCESS_FLAG" = "SUCCESS" ]; then
        echo -e "ERROR!! Hydropop model was not successful for run $RUN_NUM. Try starting the run from hydropop model."
        exit
    fi
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
    echo -e "ERROR!! Model to start this run from (option -m) must be hydropop, mosquito_pop, or human_epi."
    exit
fi

