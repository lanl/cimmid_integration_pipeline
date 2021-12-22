#!/bin/sh

############################################################################################
# Runs mosquito pop model.
# USAGE: ./run_mosquito pop_model.sh MOSQUITO_POP_MODEL_PATH CONFIG_PATH MOSQUITO_POP_CONFIG_FILENAME MOSQUITO_POP_OUTPUT_PATH MOSQUITO_POP_LOGS_PATH MOSQUITO_POP_BRANCH MINICONDA_PATH 
# MOSQUITO_POP_MODEL_PATH: Path where mosquito pop model is cloned from git
# CONFIG_PATH: Path where config files are stored for the current experiment run
# MOSQUITO_POP_CONFIG_FILENAME: Name of the mosquito pop model config file
# MOSQUITO_POP_INPUT_PATH: PAth where input for mosqito pop model is stored
# MOSQUITO_POP_OUTPUT_PATH: Path where mosquito pop output will be stored for the current experiment run
# MOSQUITO_POP_LOGS_PATH: Path where mosquito pop log will be stored for the current experiment run
# MOSQUITO_POP_BRANCH: Mosquito pop model branch to use
# MINICONDA_PATH: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3' for Darwin)
############################################################################################

if [ "$#" -lt 8 ] || ! [ -d "$1" ] || ! [ -d "$2" ] || ! [ -f "$1/$3" ] || ! [ -d "$4" ] || ! [ -d "$5" ] || ! [ -d "$6" ] || ! [ -d "$8" ] ; then
    echo -e "ERROR!! Incorrect number or type of arguments. See usage information below:\n"
    echo "USAGE: ./run_mosquito_pop_model.sh MOSQUITO_POP_MODEL_PATH CONFIG_PATH MOSQUITO_POP_CONFIG_FILENAME MOSQUITO_POP_OUTPUT_PATH MOSQUITO_POP_LOGS_PATH MINICONDA_PATH"
    echo "MOSQUITO_POP_MODEL_PATH: Path where mosquito pop model is cloned from git"
    echo "CONFIG_PATH: Path where config files are stored for the current experiment run"
    echo "MOSQUITO_POP_CONFIG_FILENAME: Name of the mosquito pop model config file"
    echo "MOSQUITO_POP_INPUT_PATH: PAth where input for mosqito pop model is stored"
    echo "MOSQUITO_POP_OUTPUT_PATH: Path where mosquito pop output will be stored for the current experiment run"
    echo "MOSQUITO_POP_LOGS_PATH: Path where mosquito pop log will be stored for the current experiment run"
    echo "MOSQUITO_POP_BRANCH: Mosquito pop model branch to use"
    echo -e "MINICONDA_PATH: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3' for Darwin)\n"
    exit
fi

MOSQUITO_POP_MODEL_PATH=$1
CONFIG_PATH=$2
MOSQUITO_POP_CONFIG_FILENAME=$3
MOSQUITO_POP_INPUT_PATH=$4
MOSQUITO_POP_OUTPUT_PATH=$5
MOSQUITO_POP_LOGS_PATH=$6
MOSQUITO_POP_BRANCH=$7
MINICONDA_PATH=$8

# Change to directory where mosquito pop model is cloned
pushd $MOSQUITO_POP_MODEL_PATH > /dev/null

# Checkout the given branch and get latest commit id
git checkout $MOSQUITO_POP_BRANCH --quiet > /dev/null
git pull > /dev/null
echo "$(date): Pulled branch $MOSQUITO_POP_BRANCH.."
latest_mosquito_pop_model_commit_id=`git log --format="%H" -n 1`
echo "$(date): Latest commit id is $latest_mosquito_pop_model_commit_id.."

# Set configuration file
cp $MOSQUITO_POP_MODEL_PATH/$MOSQUITO_POP_CONFIG_FILENAME $CONFIG_PATH
sed -i.bak "s|MOSQUITO_POP_INPUT_PATH|$MOSQUITO_POP_INPUT_PATH|g" $CONFIG_PATH/$MOSQUITO_POP_CONFIG_FILENAME
sed -i.bak "s|MOSQUITO_POP_LOGS_PATH|$MOSQUITO_POP_LOGS_PATH|g" $CONFIG_PATH/$MOSQUITO_POP_CONFIG_FILENAME
sed -i.bak "s|MOSQUITO_POP_OUTPUT_PATH|$MOSQUITO_POP_OUTPUT_PATH|g" $CONFIG_PATH/$MOSQUITO_POP_CONFIG_FILENAME

# Run model
conda activate "$MINICONDA_PATH/envs/mosq-R"
#source activate "$MINICONDA_PATH/envs/mosq-R"
sh run_mosq_toy.sh $CONFIG_PATH/$MOSQUITO_POP_CONFIG_FILENAME
conda deactivate

# Change back to integration directory
popd $MOSQUITO_POP_MODEL_PATH > /dev/null
