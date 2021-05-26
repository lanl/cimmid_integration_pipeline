#!/bin/sh

# Runs human epi model
# Takes 5 arguments
# 1. Path where hydropop model is cloned from git
# 2. Path where config files are stored for the current experiment run
# 3. Name of the hydropop model config file
# 4. Path where hydropop output will be stored for the current experiment run
# 5. Path where hydropop log will be stored for the current experiment run

HYDROPOP_MODEL_PATH=$1
CONFIG_PATH=$2
HYDROPOP_CONFIG_FILENAME=$3
HYDROPOP_MODEL_OUTPUT_PATH=$4
HYDROPOP_LOGS_PATH=$5

# Change to directory where hydropop model is cloned
pushd $HYDROPOP_MODEL_PATH > /dev/null

# Checkout the given branch and get latest commit id
git checkout 1-update_config_file_for_integration --quiet > /dev/null
git pull > /dev/null
echo "$(date): Pulled branch 1-update_config_file_for_integration.."
latest_hydropop_model_commit_id=`git log --format="%H" -n 1`
echo "$(date): Latest commit id is $latest_hydropop_model_commit_id.."

# Set configuration file
cp $HYDROPOP_MODEL_PATH/$HYDROPOP_CONFIG_FILENAME $CONFIG_PATH
sed -i.bak "s|HYDROPOP_MODEL_PATH|$HYDROPOP_MODEL_PATH|g" $CONFIG_PATH/$HYDROPOP_CONFIG_FILENAME
sed -i.bak "s|HYDROPOP_LOGS_PATH|$HYDROPOP_LOGS_PATH|g" $CONFIG_PATH/$HYDROPOP_CONFIG_FILENAME
sed -i.bak "s|HYDROPOP_MODEL_OUTPUT_PATH|$HYDROPOP_MODEL_OUTPUT_PATH|g" $CONFIG_PATH/$HYDROPOP_CONFIG_FILENAME

# Run model
#conda activate /projects/cimmid/miniconda3/envs/hpu
source activate /projects/cimmid/miniconda3/envs/hpu
python e3sm_to_mosq_model_inputs.py --config $CONFIG_PATH/$HYDROPOP_CONFIG_FILENAME > $HYDROPOP_LOGS_PATH/hydropop.out
conda deactivate

# Change back to integration directory
popd $HYDROPOP_MODEL_PATH > /dev/null
