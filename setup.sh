#!/bin/sh

###################################################################################################
# Needs to be run the first time to set up run environment and experiment.
# Usage: ./setup.sh PATH_TO_MINICONDA_INSTALLATION CONFIG_FILE
# PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3' for Darwin)
# CONFIG_FILE: Config file (e.g., cimmid_old.yaml)
###################################################################################################

# load/unload modules
module load gcc

# Check for correct number of arguments.
if [ "$#" -lt 2 ] || ! [ -d "$1" ] || ! [ -f "$2" ]; then
    echo -e "ERROR!! Incorrect number or type of arguments. See usage information below:\n"
    echo "Usage: sh setup_yellow.sh PATH_TO_MINICONDA_INSTALLATION CONFIG_FILE"
    echo "PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3')"
    echo -e "CONFIG_FILE: Config file (e.g., cimmid_old.yaml)\n"
    exit
fi

# ADD CIMMID miniconda path to PATH.
MINICONDA_PATH=$1
export PATH="$MINICONDA_PATH/bin:$PATH"
conda config --prepend envs_dirs "$MINICONDA_PATH/envs"
# Create virtual environment for integration
conda create --name integration python=3.8
#conda activate integration
source activate integration
conda install -c conda-forge shyaml

# Set base path
BASE_PATH="$PWD"

# Get config file
CONFIG_FILE=$2
CONFIG_FILE="$BASE_PATH/$2"
HYDROPOP_REPO=`cat $CONFIG_FILE | shyaml get-value HYDROPOP_MODEL.REPO`
MOSQUITO_POP_REPO=`cat $CONFIG_FILE | shyaml get-value MOSQUITO_POP_MODEL.REPO`
EPI_MODEL_REPO=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL.REPO`
conda deactivate

# Make directory where models will be cloned from Gitlab
echo "$(date): Making models directory.."
MODELS_PATH="$BASE_PATH/models"
sh makedir_if_not_exists.sh $MODELS_PATH
echo ""

# Git clone hydropop model
echo "$(date): cloning hydropop model.."
cd $MODELS_PATH
git clone $HYDROPOP_REPO
HYDROPO_DIR=`echo $HYDROPOP_REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
cd $HYDROPO_DIR
git config pull.rebase false
echo "$(date): creating virtual environment for hydropop model.."
conda create --name hpu python=3.8
#conda activate hpu
source activate hpu
conda install -c conda-forge mamba
mamba install -c jschwenk -c conda-forge rivgraph=0.4 yaml
conda deactivate
echo ""

# Git clone mosquito pop model
echo "$(date): cloning mosquito pop model.."
cd $MODELS_PATH
git clone $MOSQUITO_POP_REPO
MOSQUITO_POP_DIR=`echo $MOSQUITO_POP_REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
cd $MOSQUITO_POP_DIR
echo "$(date): creating virtual environment for mosquito pop model.."
conda create --name mosq-R python=3.8
#conda activate mosq-R
source activate mosq-R
conda install -c conda-forge mamba
conda install -c conda-forge r r-logger
conda install -c conda-forge r r-yaml
conda install -c conda-forge r r-sp
conda install -c conda-forge r r-tidyverse
conda deactivate
echo ""

# Git clone human epi model
echo "$(date): cloning human epi model.."
cd $MODELS_PATH
git clone $EPI_MODEL_REPO
EPI_DIR=`echo $EPI_MODEL_REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
cd $EPI_DIR
git config pull.rebase false
echo "$(date): creating virtual environment for human epi model.."
conda create --name human-epi-env python=3.8.3
#conda activate human-epi-env
source activate human-epi-env
conda install --channel conda-forge numpy pyyaml pandas scipy pyarrow matplotlib sphinx
cd $BASE_PATH
conda deactivate
echo ""

# Create experiments and run directories
echo "$(date): creating experiment directories.."
EXPERIMENTS_PATH="$BASE_PATH/experiments"
RUNS_PATH="$EXPERIMENTS_PATH/runs"
sh makedir_if_not_exists.sh $EXPERIMENTS_PATH
sh makedir_if_not_exists.sh $RUNS_PATH
echo "Done setting up."
