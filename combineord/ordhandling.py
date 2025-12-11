import pandas as pd

# Handling + merging ELT files

def merge_melt(gpqt, melt):
    _melt = melt[['SummaryId', 'EventId', 'MeanLoss', 'SDLoss', 'MaxLoss']]
    merged = gpqt.merge(_melt, on='EventId', how='left')

    return merged

def read_melt(path):
    return pd.read_csv(path)


def read_qelt(path):
    return pd.read_csv(path).rename(columns={"Loss": "QuantileLoss",
                                             "Quantile": "LTQuantile"})


def read_selt(path):
    # Remove negative sampleids
    return pd.read_csv(path).query('SampleId > 0').rename(columns={"Loss": "SampleLoss"}).reset_index(drop=True)
