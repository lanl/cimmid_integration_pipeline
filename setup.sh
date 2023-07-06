#!/bin/sh

###################################################################################################
# Needs to be run the first time to set up run environment and experiment.
# Usage: ./setup.sh PATH_TO_MINICONDA_INSTALLATION CONFIG_FILE
# PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/usr/projects/cimmid/miniconda3' for Chicoma)
# CONFIG_FILE: Config file (e.g., cimmid_chicoma.yaml)
###################################################################################################

conda init bash
source ~/.bashrc

# load/unload modules

# Check for correct number of arguments.
if [ "$#" -lt 2 ] || ! [ -d "$1" ] || ! [ -f "$2" ]; then
    echo -e "ERROR!! Incorrect number or type of arguments. See usage information below:\n"
    echo "Usage: sh setup_yellow.sh PATH_TO_MINICONDA_INSTALLATION CONFIG_FILE"
    echo "PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/usr/projects/cimmid/miniconda3')"
    echo -e "CONFIG_FILE: Config file (e.g., cimmid_chicoma.yaml)\n"
    exit
fi

# ADD CIMMID miniconda path to PATH.
MINICONDA_PATH=$1
export PATH="$MINICONDA_PATH/bin:$PATH"
conda config --prepend envs_dirs "$MINICONDA_PATH/envs"
# Create virtual environment for integration
conda create --name integration python=3.8
conda activate integration
conda install -c conda-forge shyaml

# Set base path
BASE_PATH="$PWD"

# Get config file
CONFIG_FILE=$2
CONFIG_FILE="$BASE_PATH/$2"
EXPERIMENTS_BASE_PATH=`cat $CONFIG_FILE | shyaml get-value EXPERIMENTS_BASE_PATH`
MOSQUITO_POP_REPO=`cat $CONFIG_FILE | shyaml get-value MOSQUITO_POP_MODEL.REPO`
EPI_MODEL_REPO=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL.REPO`
EPI_SEIR_MODEL_DIR=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL.MODEL_DIR`
conda deactivate

# Make directory where models will be cloned from Gitlab
echo "$(date): Making models directory.."
MODELS_PATH="$BASE_PATH/models"
sh makedir_if_not_exists.sh $MODELS_PATH
echo ""

# Git clone mosquito pop model
echo "$(date): cloning mosquito pop model.."
cd $MODELS_PATH
git clone $MOSQUITO_POP_REPO
MOSQUITO_POP_DIR=`echo $MOSQUITO_POP_REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
cd $MOSQUITO_POP_DIR
git config pull.rebase false
echo "$(date): creating virtual environment for mosquito pop model.."
conda create --name mosq-R python=3.9
conda activate mosq-R
conda install -c conda-forge mamba
conda install -c conda-forge r r-logger
conda install -c conda-forge r r-yaml
conda install -c conda-forge r r-sp
conda install -c conda-forge r r-rgdal
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
cd $EPI_SEIR_MODEL_DIR
echo "$(date): creating virtual environment for human epi model.."
conda env create -f conda_environment/environment.yml
#conda create --name human-epi-env python=3.9
#conda activate human-epi-env
#conda install --channel conda-forge numpy pyyaml pandas scipy pyarrow matplotlib sphinx pytest lmfit statsmodels
#conda install --channel conda-forge numpy
#conda install --channel conda-forge pyyaml
#conda install --channel conda-forge pandas
#conda install --channel conda-forge scipy
#conda install --channel conda-forge pyarrow
#conda install --channel conda-forge matplotlib
#conda install --channel conda-forge sphinx
#conda install --channel conda-forge pytest
#conda install --channel conda-forge lmfit
cd $BASE_PATH
conda deactivate
echo ""

# Create experiments and run directories
echo "$(date): creating experiment directories.."
EXPERIMENTS_PATH="$EXPERIMENTS_BASE_PATH/experiments"
RUNS_PATH="$EXPERIMENTS_PATH/runs"
sh makedir_if_not_exists.sh $EXPERIMENTS_PATH
sh makedir_if_not_exists.sh $RUNS_PATH
#chgrp -R cimmid $EXPERIMENTS_PATH
#chmod -R g+rwx $EXPERIMENTS_PATH
echo "Done setting up."
