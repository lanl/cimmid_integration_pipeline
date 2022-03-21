!/bin/sh

###################################################################################################
# Currently, CIMMID code lives on gitlab.lanl.gov (yellow network) which is not accessible from turquoise network (e.g., Badger) where ELM is setup to run. So need to create bare DropZone repos on turquoise cluster. This script needs to be run once before running any experiemnts on turquoise network.

# Usage: sh setup_turuoise_2.sh PATH_TO_MINICONDA_INSTALLATION CONFIG_FILE
# PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/turquoise/usr/projects/cimmid/miniconda3')
# CONFIG_FILE: Config file (e.g., cimmid.yaml)

# TO DO: Update above path to a path in project directory instead of in my home directory
###################################################################################################

# load/unload modules
#source /etc/profile.d/z01-modules.lanl.sh 
#source /etc/profile.d/00-modulepath.csh
# TO DO: For some reason, following command works on command line but not through script (says "module: command not found").
#module unload gcc
#module load gcc/7.4.0

# Check for correct number of arguments.
if [ "$#" -lt 2 ] || ! [ -d "$1" ] || ! [ -f "$2" ]; then
    echo -e "ERROR!! Incorrect number or type of arguments. See usage information below:\n"
    echo "Usage: sh setup_turuoise_2.sh PATH_TO_MINICONDA_INSTALLATION CONFIG_FILE"
    echo "PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/turquoise/users/nidhip/miniconda3')"
    echo -e "CONFIG_FILE: Config file (e..g, cimmid.yaml)\n"
    exit
fi

# ADD CIMMID miniconda path to PATH.
MINICONDA_PATH=$1
export PATH="$MINICONDA_PATH/bin:$PATH"
conda config --prepend envs_dirs "$MINICONDA_PATH/envs"
#conda activate integration
source activate integration

# Get config file
CONFIG_FILE=$2
PROJECT_ROOT=`cat $CONFIG_FILE | shyaml get-value TURQUOISE_NET.PROJECT_ROOT`
CONFIG_FILE="$PROJECT_ROOT/$2"

# Read paths from config file
BARE_DROPZONE_REPO_PATH=`cat $CONFIG_FILE | shyaml get-value TURQUOISE_NET.BARE_DROPZONE_REPO_PATH`
BARE_DROPZONE_REPO_PATH="$PROJECT_ROOT/$BARE_DROPZONE_REPO_PATH"
INTEGRATION_DIR=`cat $CONFIG_FILE | shyaml get-value INTEGRATION_MODEL.REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
HYDROPO_DIR=`cat $CONFIG_FILE | shyaml get-value HYDROPOP_MODEL.REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
MOSQUITO_POP_DIR=`cat $CONFIG_FILE | shyaml get-value MOSQUITO_POP_MODEL.REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
EPI_DIR=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL.REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`

conda deactivate

# Git clone interation model
echo "$(date): cloning integration model.."
git clone "$BARE_DROPZONE_REPO_PATH/$INTEGRATION_DIR"
INTEGRATION_PATH="$PROJECT_ROOT/$INTEGRATION_DIR"

# Make directory where models will be cloned from Gitlab
cd $INTEGRATION_PATH
echo "$(date): Making models directory.."
MODELS_PATH="$INTEGRATION_PATH/models"
sh makedir_if_not_exists.sh $MODELS_PATH
echo ""

# Git clone hydropop model
echo "$(date): cloning hydropop model.."
cd $MODELS_PATH
git clone "$BARE_DROPZONE_REPO_PATH/$HYDROPO_DIR"
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
git clone "$BARE_DROPZONE_REPO_PATH/$MOSQUITO_POP_DIR"
echo "$(date): creating virtual environment for mosquito pop model.."
conda create --name mosq-R python=3.8
#conda activate mosq-R
source activate mosq-R
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
git clone "$BARE_DROPZONE_REPO_PATH/$EPI_DIR"
echo "$(date): creating virtual environment for human epi model.."
conda create --name human-epi-env python=3.9
#conda activate human-epi-env
source activate human-epi-env
conda install --channel conda-forge numpy pyyaml pandas scipy pyarrow matplotlib sphinx pytest lmfit
conda deactivate
echo ""

# Create experiments and run directories
cd $INTEGRATION_PATH
echo "$(date): creating experiment directories.."
EXPERIMENTS_PATH="$INTEGRATION_PATH/experiments"
RUNS_PATH="$EXPERIMENTS_PATH/runs"
sh makedir_if_not_exists.sh $EXPERIMENTS_PATH
sh makedir_if_not_exists.sh $RUNS_PATH
echo "Done setting up."
