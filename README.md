# Combining ORD Demo

> [!WARNING]
> This is a demo repository that is now deprecated. The combine tool is now part of [ODS Tools](https://github.com/OasisLMF/ODS_Tools) and further details of this tool can be found [here](https://github.com/OasisLMF/ODS_Tools/tree/main/ods_tools/combine).

This folder contains the scripts necessary to run a demo of the method described in
*Combining_results_in_ORD_v1.1.pdf*.

## Installation + Usage

Run `pip install -r requirements.txt`.

To view the notebooks run `jupyter lab`

Project dependencies are specified in `requirements.in` and `pip-tools` is used
to specify the `requirements.txt`.

## PiWindExample

The `PiWindExample/` contains the exposure files used in this demo. Run
`install.sh` to setup the PiWind model.

The `full/` directory contains the full test exposure set for PiWind and the
`split/` exposure set is the full exposure set split in two randomly. We run
the combining_ord procedure on the 10 location version of the exposure set.

## Notebooks

The `notebooks/` folder contains the demos for combining ORD files.

> Note this directory was prepared using `jupytext` and so the notebooks `{filename}.ipynb`
> are paired with a python script file `{filename}.py`.

There are two notebooks in this directory.

1) `CombineORD.ipynb` - Performs the full procedure for combining the results from the
`split/` exposure set.
    - Example outputs from running using `MELT`, `QELT` and `SELT` are stored in the `outputs/combined_ord-{m, q, s}elt` directories respectively.
2. `OutputComparison.ipynb` - Compare the output of `CombineORD.ipynb` with the
    output from running PiWind on the `full/` exposure set.
