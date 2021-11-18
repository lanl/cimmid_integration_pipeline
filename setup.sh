#!/bin/sh

###################################################################################################
# Needs to be run the first time to set up run environment and experiment.
# Usage: ./setup.sh PATH_TO_MINICONDA_INSTALLATION
# PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3' for Darwin)
###################################################################################################

# load/unload modules
module unload gcc
module load gcc/7.2.0

# Check for correct number of arguments.
if [ "$#" -lt 1 ] || ! [ -d "$1" ] ; then
    echo -e "ERROR!! Incorrect number or type of arguments. See usage information below:\n"
    echo "Usage: ./setup.sh PATH_TO_MINICONDA_INSTALLATION"
    echo -e "PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3' for Darwin)\n"
    exit
fi

# ADD CIMMID miniconda path to PATH.
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
conda deactivate
echo ""

# Git clone ELM
echo "$(date): cloning ELM.."
cd $MODELS_PATH
git clone git@gitlab.lanl.gov:cimmid/earth_system_modeling/ELM_Disease.git
echo "$(date): creating virtual environment for ELM.."
conda create --name elm python=3.6 r-base=3.6 r-essentials=3.6 rpy2 pandas r-ncdf4 mpi4py pyyaml
#conda activate elm
source activate elm
conda install -c conda-forge tzlocal
conda deactivate
echo ""

# Git clone mosquito pop model
echo "$(date): cloning mosquito pop model.."
cd $MODELS_PATH
git clone git@gitlab.lanl.gov:cimmid/earth_system_modeling/mosquito-toy-model.git
echo "$(date): creating virtual environment for mosquito pop model.."
conda create --name mosq-R python=3.8
#conda activate mosq-R
source activate mosq-R
conda install -c conda-forge mamba
conda install -c conda-forge r r-logger
conda install -c conda-forge r r-yaml
conda install -c conda-forge r r-sp
conda install -c conda-forge r r-rgdal
conda deactivate
echo ""

# Git clone human epi model
echo "$(date): cloning human epi model.."
git clone git@gitlab.lanl.gov:cimmid/disease_and_human_modeling/human_epi_models.git
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
