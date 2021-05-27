#!/bin/sh

###################################################################################################
# Needs to run the first time setting up run environment and experiment.
# Usage: ./setup.sh PATH_TO_MINICONDA_INSTALLATION (e.g., '/projects/cimmid/miniconda3' for Darwin)
###################################################################################################

# load/unload modules
module unload gcc
module load gcc/7.2.0

# ADD CIMMID miniconda path to PATH.
# TO DO: miniconda is already installed on Darwin. It will need to be installed on other clusters. Check with Jon about installation.
MINICONDA_PATH=$1
export PATH="$MINICONDA_PATH/bin:$PATH"
conda config --prepend envs_dirs "$MINICONDA_PATH/envs"

# Set base path
BASE_PATH="$PWD"

# Make directory where models will be cloned from Gitlab
echo "$(date): Making models directory.."
MODELS_PATH="$BASE_PATH/models"
sh makedir_if_not_exists.sh $MODELS_PATH
echo ""

# Git clone hydropop model
echo "$(date): cloning hydropop model.."
cd $MODELS_PATH
git clone git@gitlab.lanl.gov:cimmid/hydropop.git
echo "$(date): creating virtual environment for hydropop model.."
conda create --name hpu python=3.8
#conda activate hpu
source activate hpu
conda install -c conda-forge mamba
mamba install -c jschwenk -c conda-forge rivgraph=0.4 yaml
echo ""

# Git clone human epi model
echo "$(date): cloning human epi model.."
git clone git@gitlab.lanl.gov:cimmid/disease_and_human_modeling/dengue_model.git
echo "$(date): creating virtual environment for human epi model.."
conda create --name human-epi-env python=3.8.3
#conda activate human-epi-env
source activate human-epi-env
conda install --channel conda-forge numpy pyyaml pandas scipy pyarrow matplotlib sphinx
cd $BASE_PATH
echo ""

# Create experiments and run directories
echo "$(date): creating experiment directories.."
EXPERIMENTS_PATH="$BASE_PATH/experiments"
RUNS_PATH="$EXPERIMENTS_PATH/runs"
sh makedir_if_not_exists.sh $EXPERIMENTS_PATH
sh makedir_if_not_exists.sh $RUNS_PATH
