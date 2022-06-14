"""
    Updates model paramters from global config file to model-specific config file.
    Usage: python update_config_parameters.py GLOBAL_CONFIG_FILE MODEL_CONFIG_FILE MODEL_NAME
    GLOBAL_CONFIG_FILE: Path to global config file (e.g., cimmid_darwin.yaml)
    MODEL_CONFIG_FILE: Path to model-specific config file (e.g., mosq_config.yaml)
    MODEL_NAME: Name of the model (e.g., MOSQUITO_POP_MODEL or EPI_MODEL)
"""

import sys
import yaml
from pathlib import Path


def update_model_config_params_based_on_global_config_params(param_key, global_params, model_params):
    #print('\n')
    #print(global_params)
    #print(model_params)
    #print('-{}, {}, {}'.format(param_key, global_params, model_params))
    if not isinstance(global_params[param_key], dict):
        assert type(global_params[param_key]) == type(model_params[param_key])
        model_params[param_key] = global_params[param_key]
        #print('----m2{}, {}, {}'.format(param_key, global_params, model_params))
        return model_params
    for gb_key, gb_value in global_params[param_key].items():
        #print('--{}, {}, {}'.format(gb_key, global_params[param_key], model_params[param_key]))
        model_params[param_key] = update_model_config_params_based_on_global_config_params(gb_key, global_params[param_key], model_params[param_key])
    #print(model_params)
    return model_params


def update_config_file(global_config_file, model_config_file, model_name):
    """
        Updates model paramters from global config file to model-specific config file.
        Arguments:
        1. GLOBAL_CONFIG_FILE: Path to global config file (e.g., cimmid_darwin.yaml)
        2. MODEL_CONFIG_FILE: Path to model-specific config file (e.g., mosq_config.yaml)
        3. MODEL_NAME: Name of the model (e.g., MOSQUITO_POP_MODEL or EPI_MODEL)
    """

    # Read global and model-specific config files
    global_params = yaml.safe_load(Path(global_config_file).read_text())
    model_params = yaml.safe_load(Path(model_config_file).read_text())

    # Raise an error if unknown model name found.
    if model_name not in ['MOSQUITO_POP_MODEL', 'EPI_MODEL']:
        raise ValueError('ERROR!! Found unknow model name: {}. Following model names are allowed: MOSQUITO_POP_MODEL and EPI_MODEL.'.format(model_name))

    # Read model paramters from global config file
    global_params = global_params[model_name]['CONFIG_FILE_PARAMETERS']

    #print(model_params)
    #print('\n')
    for param_key in global_params.keys():
        assert param_key in model_params.keys()
        model_params = update_model_config_params_based_on_global_config_params(param_key, global_params, model_params)
    #print(model_params)

    # Write updated model parameters
    with open(model_config_file, 'w') as file:
        yaml.dump(model_params, file)


if __name__ == '__main__':
    update_config_file(sys.argv[1], sys.argv[2], sys.argv[3])
