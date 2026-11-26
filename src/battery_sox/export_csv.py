"""Conversion of NASA battery .mat files to CSV files.

It reads the four cells (B0005, B0006, B0007, B0018) from data/raw/
and writes one CSV per database table (cells, cycles, discharge_samples, impedance)
to data/processed/, ready to load into MySQL.

Usage
-----
Run from the project root:
python src/battery_sox/export_csv.py"""

from datetime import datetime
from pathlib import Path

import pandas as pd
from scipy.io import loadmat


# Path & dataset settings
PROJECT_ROOT = Path(__file__).resolve().parents[2]
RAW_DIR = PROJECT_ROOT / "data" / "raw"
PROCESSED_DIR = PROJECT_ROOT / "data" / "processed"
CELL_IDS = ["B0005", "B0006", "B0007", "B0018"]
RATED_CAPACITY_AH = 2.0


def load_cycles(cell_id : str) -> list[dict]:
    """load cycles from a cell id
    parameters
    ----------
    cell_id : str
    name of the cell

    returns
    -------
    list[dict]
    one dictionary per cycle with the keys
    type, ambient_temperature, time and data."""
    mat_path = RAW_DIR / f"{cell_id}.mat"
    mat = loadmat(mat_path, simplify_cells=True)
    return mat[cell_id]["cycle"]


def matlab_datevec_to_datetime(datevec: list[float]) -> datetime:
    """convert a MATLAB date vector to a datetime.
    parameters
    ----------
    datevec : list[float]
    [year, month, day, hour, minute, seconds].

    returns
    -------
    datetime
    the same instant as a python datetime object.
    """
    year, month, day, hour, minute, seconds = datevec
    seconds = float(seconds)
    whole_seconds = int(seconds)
    microseconds = round((seconds - whole_seconds) * 1_000_000)
    return datetime(int(year), int(month), int(day), int(hour), int(minute), whole_seconds, microseconds)


def build_tables() -> dict[str, pd.DataFrame]:
    """Dcitionary mapping - each table to its dataframe.

    returns
    -------
    dict[str, pd.DataFrame]"""

    cell_rows = []
    cycle_rows = []
    cycle_id = 0

    for cell_id in CELL_IDS:
        cell_rows.append({
            "cell_id": cell_id,
            "rated_capacity_ah": RATED_CAPACITY_AH,
        })
        cycles = load_cycles(cell_id)

        for cycle_number, cycle in enumerate(cycles, start=1):
            cycle_id += 1
            is_discharge = cycle["type"] == "discharge"
            capacity = cycle["data"]["Capacity"] if is_discharge else None

            cycle_rows.append({
                "cycle_id": cycle_id,
                "cell_id": cell_id,
                "cycle_number": cycle_number,
                "cycle_type": cycle["type"],
                "ambient_temp_c": cycle["ambient_temperature"],
                "start_time": matlab_datevec_to_datetime(cycle["time"]),
                "capacity_ah": capacity,
            })

    return {
        "cells": pd.DataFrame(cell_rows),
        "cycles": pd.DataFrame(cycle_rows),
    }





