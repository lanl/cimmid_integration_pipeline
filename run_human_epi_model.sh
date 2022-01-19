#!/bin/sh

############################################################################################
# Runs human epi model
# USAGE: ./run_human_epi_model.sh HUMAN_EPI_MODEL_PATH CONFIG_PATH HUMAN_EPI_CONFIG_FILENAME HUMAN_EPI_MODEL_OUTPUT_PATH HUMAN_EPI_LOGS_PATH HUMAN_EPI_MODEL_BRANCH MINICONDA_PATH
# HUMAN_EPI_MODEL_PATH: Path where human epi model is cloned from git
# CONFIG_PATH: Path where config files are stored for the current experiment run
# HUMAN_EPI_CONFIG_FILENAME: Name of the human epi model config file
# HUMAN_EPI_MODEL_OUTPUT_PATH: Path where human epi output will be stored for the current experiment run
# HUMAN_EPI_LOGS_PATH: Path where human epi log will be stored for the current experiment run
# HUMAN_EPI_MODEL_BRANCH: Human epi model branch to use
# MINICONDA_PATH: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3' for Darwin)
############################################################################################

echo $1
echo $2
echo $3
echo $4
echo $5
echo $6
echo $7

if [ "$#" -lt 7 ] || ! [ -d "$1" ] || ! [ -d "$2" ] || ! [ -f "$1/config/$3" ] || ! [ -d "$4" ] || ! [ -d "$5" ] || ! [ -d "$7" ] ; then
    echo -e "ERROR!! Incorrect number or type of arguments. See usage information below:\n"
    echo "USAGE: ./run_human_epi_model.sh HUMAN_EPI_MODEL_PATH CONFIG_PATH HUMAN_EPI_CONFIG_FILENAME HUMAN_EPI_MODEL_OUTPUT_PATH HUMAN_EPI_LOGS_PATH MINICONDA_PATH"
    echo "HUMAN_EPI_MODEL_PATH: Path where human epi model is cloned from git"
    echo "CONFIG_PATH: Path where config files are stored for the current experiment run"
    echo "HUMAN_EPI_CONFIG_FILENAME: Name of the human epi model config file"
    echo "HUMAN_EPI_MODEL_OUTPUT_PATH: Path where human epi output will be stored for the current experiment run"
    echo "HUMAN_EPI_LOGS_PATH: Path where human epi log will be stored for the current experiment run"
    echo "HUMAN_EPI_MODEL_BRANCH: Human epi model branch to use"
    echo -e "MINICONDA_PATH: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3' for Darwin)\n"
    exit
fi

HUMAN_EPI_MODEL_PATH=$1
CONFIG_PATH=$2
HUMAN_EPI_CONFIG_FILENAME=$3
HUMAN_EPI_MODEL_OUTPUT_PATH=$4
HUMAN_EPI_LOGS_PATH=$5
HUMAN_EPI_MODEL_BRANCH=$6
MINICONDA_PATH=$7

# Change to directory where human epi model is cloned
pushd $HUMAN_EPI_MODEL_PATH > /dev/null

# Checkout the given branch and get latest commit id
git checkout $HUMAN_EPI_MODEL_BRANCH --quiet > /dev/null
git pull > /dev/null
echo "$(date): Pulled branch $HUMAN_EPI_MODEL_BRANCH.."
latest_human_epi_model_commit_id=`git log --format="%H" -n 1`
echo "$(date): Latest commit id is $latest_human_epi_model_commit_id.."

# Set configuration file
cp $HUMAN_EPI_MODEL_PATH/config/$HUMAN_EPI_CONFIG_FILENAME $CONFIG_PATH
sed -i.bak "s|HUMAN_EPI_MODEL_PATH|$HUMAN_EPI_MODEL_PATH|g" $CONFIG_PATH/$HUMAN_EPI_CONFIG_FILENAME
sed -i.bak "s|HUMAN_EPI_LOGS_PATH|$HUMAN_EPI_LOGS_PATH|g" $CONFIG_PATH/$HUMAN_EPI_CONFIG_FILENAME
sed -i.bak "s|HUMAN_EPI_MODEL_OUTPUT_PATH|$HUMAN_EPI_MODEL_OUTPUT_PATH|g" $CONFIG_PATH/$HUMAN_EPI_CONFIG_FILENAME

# Run model
#conda activate "$MINICONDA_PATH/envs/human-epi-env"
source activate "$MINICONDA_PATH/envs/human-epi-env"
logfiles=`shopt -s nullglob dotglob; echo $HUMAN_EPI_LOGS_PATH/*`
if [ "$logfiles" != "" ]; then
    rm $HUMAN_EPI_LOGS_PATH/*
fi
sh run_human_epi_model.sh $CONFIG_PATH/$HUMAN_EPI_CONFIG_FILENAME 0 > $HUMAN_EPI_LOGS_PATH/human_epi.out
conda deactivate

# Change back to integration directory
popd > /dev/null
