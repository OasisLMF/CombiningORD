import argparse
import pandas as pd
from pathlib import Path
import numpy as np

rng = np.random.default_rng(seed=1234)

# %% Load the exposure file

def main(location_path, n_splits, output_path, subset_location=None):
    output_path = Path(output_path)
    loc_df = pd.read_csv(location_path)
    fname = Path(location_path).name

    idx_arr = np.arange(len(loc_df))
    rng.shuffle(idx_arr)

    if subset_location is not None and subset_location < len(idx_arr):
        print(f'Using subset of indices: {subset_location} / {len(idx_arr)}')
        idx_arr = idx_arr[:subset_location]
    split_idx_arrays = np.array_split(idx_arr, n_splits)

    for i, _idx_arr in enumerate(split_idx_arrays):
        print(f'Running split: {i}')
        _output_path = output_path / f'{i+1}/{fname}'
        _output_path.parent.mkdir(parents=True, exist_ok=True)
        loc_df.iloc[_idx_arr].to_csv(_output_path, index=False)
        print(f'   Saved output to: {_output_path}')

parser = argparse.ArgumentParser(
            prog='PrepareTestLoc',
            description='Prepare test location file.'
        )

parser.add_argument('-l', '--location-path')
parser.add_argument('-n', '--n-splits', type=int)
parser.add_argument('-o', '--output-path')
parser.add_argument('-s', '--subset-location', type=int, help='Use a subset of the location file. -s 100 will use 100 locations from the location file',
                    default=None)

kwargs = vars(parser.parse_args())

print('input args: ')
print(kwargs)

main(**kwargs)
