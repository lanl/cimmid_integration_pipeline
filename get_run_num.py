import os
import sys
import glob

def get_run_number(exp_dir):
    """
        Gets next run number based on run directories in `exp_dir`.
    """

    # Get all directories starting with 'r' from `exp_dir`
    run_dirs = glob.glob(os.path.join(exp_dir, 'r*', ''))

    run_nums = list()
    for run_dir in run_dirs:
        run_nums.append(int(run_dir.replace(exp_dir, '')[2:-1]))
    run_nums.sort()
    
    print(run_nums[-1] + 1)

if __name__ == '__main__':
    get_run_number(sys.argv[1])

