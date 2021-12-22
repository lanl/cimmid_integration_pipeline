#!/bin/sh

############################################################################################
# Runs hydropop model.
# USAGE: ./run_hydropop_model.sh HYDROPOP_MODEL_PATH CONFIG_PATH HYDROPOP_CONFIG_FILENAME HYDROPOP_MODEL_OUTPUT_PATH HYDROPOP_LOGS_PATH HYDROPOP_BRANCH MINICONDA_PATH 
# HYDROPOP_MODEL_PATH: Path where hydropop model is cloned from git
# CONFIG_PATH: Path where config files are stored for the current experiment run
# HYDROPOP_CONFIG_FILENAME: Name of the hydropop model config file
# HYDROPOP_MODEL_OUTPUT_PATH: Path where hydropop output will be stored for the current experiment run
# HYDROPOP_LOGS_PATH: Path where hydropop log will be stored for the current experiment run
# HYDROPOP_BRANCH: Hydropop model branch to use
# MINICONDA_PATH: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3' for Darwin)
############################################################################################

if [ "$#" -lt 7 ] || ! [ -d "$1" ] || ! [ -d "$2" ] || ! [ -f "$1/$3" ] || ! [ -d "$4" ] || ! [ -d "$5" ] || ! [ -d "$7" ] ; then
    echo -e "ERROR!! Incorrect number or type of arguments. See usage information below:\n"
    echo "USAGE: ./run_hydropop_model.sh HYDROPOP_MODEL_PATH CONFIG_PATH HYDROPOP_CONFIG_FILENAME HYDROPOP_MODEL_OUTPUT_PATH HYDROPOP_LOGS_PATH MINICONDA_PATH"
    echo "HYDROPOP_MODEL_PATH: Path where hydropop model is cloned from git"
    echo "CONFIG_PATH: Path where config files are stored for the current experiment run"
    echo "HYDROPOP_CONFIG_FILENAME: Name of the hydropop model config file"
    echo "HYDROPOP_MODEL_OUTPUT_PATH: Path where hydropop output will be stored for the current experiment run"
    echo "HYDROPOP_LOGS_PATH: Path where hydropop log will be stored for the current experiment run"
    echo "HYDROPOP_BRANCH: Hydropop model branch to use"
    echo -e "MINICONDA_PATH: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3' for Darwin)\n"
    exit
fi

HYDROPOP_MODEL_PATH=$1
CONFIG_PATH=$2
HYDROPOP_CONFIG_FILENAME=$3
HYDROPOP_MODEL_OUTPUT_PATH=$4
HYDROPOP_LOGS_PATH=$5
HYDROPOP_BRANCH=$6
MINICONDA_PATH=$7

# Change to directory where hydropop model is cloned
pushd $HYDROPOP_MODEL_PATH > /dev/null

# Checkout the given branch and get latest commit id
git checkout $HYDROPOP_BRANCH --quiet > /dev/null
git pull > /dev/null
echo "$(date): Pulled branch $HYDROPOP_BRANCH.."
latest_hydropop_model_commit_id=`git log --format="%H" -n 1`
echo "$(date): Latest commit id is $latest_hydropop_model_commit_id.."

# Set configuration file
cp $HYDROPOP_MODEL_PATH/$HYDROPOP_CONFIG_FILENAME $CONFIG_PATH
sed -i.bak "s|HYDROPOP_MODEL_PATH|$HYDROPOP_MODEL_PATH|g" $CONFIG_PATH/$HYDROPOP_CONFIG_FILENAME
sed -i.bak "s|HYDROPOP_LOGS_PATH|$HYDROPOP_LOGS_PATH|g" $CONFIG_PATH/$HYDROPOP_CONFIG_FILENAME
sed -i.bak "s|HYDROPOP_MODEL_OUTPUT_PATH|$HYDROPOP_MODEL_OUTPUT_PATH|g" $CONFIG_PATH/$HYDROPOP_CONFIG_FILENAME

# Run model
conda activate "$MINICONDA_PATH/envs/hpu"
#source activate "$MINICONDA_PATH/envs/hpu"
python e3sm_to_mosq_model_inputs.py --config $CONFIG_PATH/$HYDROPOP_CONFIG_FILENAME
conda deactivate

# Change back to integration directory
popd $HYDROPOP_MODEL_PATH > /dev/null
