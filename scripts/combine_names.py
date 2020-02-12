"""Creates a sed file which substitutes new names for old from a combination of source files

Run using the following command::

    python combine_names.py output_file.sed EMISSIONS.csv source_file1.csv source_file2.csv

The script extracts the column of ``old`` names from source_file1.csv and
source_file2.csv and concatenates them. It does the same with the column
of ``new`` names from the same files and creates a SED file as an output.

Only those combinations for which the old name appears in the set file is included.

For example, if ``source_file1.csv`` contains the following::

    old,new,name
    DZ,DZA,Algeria
    AO,AGO,Angola

And ``source_file2.csv`` contains::

    old,new,description
    REN,REN,Emission factor that was used to model the RET targets for each country
    CO2,CO2,Emission factor for CO2

The cross product of the two files are generated and mapped to one another::

    s/DZREN/DZAREN/
    s/DZCO2/DZACO2/
    s/AOREN/AGOREN/
    s/AOCO2/AGOCO2/

The set file contains old emission names:

    VALUE
    DZREN
    DZCO2
    AOREN
    AOCO2

This can be run with SED to subtitute names of a file like so::

    sed -f output_file.sed file_to_substitute.txt > destination.txt

"""
import pandas as pd
from itertools import product
from sys import argv
from typing import List, Tuple

from logging import getLogger, basicConfig, DEBUG

basicConfig(filename='example.log', level=DEBUG, filemode='a')
logger = getLogger(__name__)


def get_list(dataframe: pd.DataFrame, column: str) -> List[str]:
    return dataframe[column].to_list()


def combine_codes(*args: List[str]) -> List[str]:
    return ["".join(x) for x in product(*args)]


def read_csvs(*args: List[str]) -> List[pd.DataFrame]:
    dfs = []
    for arg in args[0]:
        logger.info("Reading %s", arg)
        df = pd.read_csv(arg, dtype=str, na_filter=False)
        dfs.append(df)
    return dfs


def create_sed_substitions(dfs: List[pd.DataFrame]) -> Tuple[List[str], List[str]]:

    old = []
    new = []

    for arg in dfs:
        old.append(get_list(arg, 'old'))
        new.append(get_list(arg, 'new'))

    olds = combine_codes(*old)
    news = combine_codes(*new)

    return olds, news


def get_set(filepath: str) -> List:
    df = read_csvs([filepath])
    return get_list(df[0], 'VALUE')


def write_sed(olds: List[str], news: List[str], output_file: str, set_file: str):
    """Writes a SED file substituing elements in ``news`` for elements in ``olds``

    Filters elements in ``olds`` so that only the elements which appear in ``set_file`` are
    included.

    Arguments
    ---------
    olds : List[str]
    news : List[str]
    """
    old_set = get_set(set_file)

    not_present = []
    for element in old_set:
        if element not in olds:
            not_present.append(element)

    if not_present:
        msg = "The following elements from '{}' are not present in the mapping:\n {}"
        logger.warning(msg.format(set_file, "\n".join(not_present)))

    with open(output_file, 'w') as output:
        for old, new in zip(olds, news):
            if old in old_set:
                sed = "s/[[:<:]]{}[[:>:]]/{}/\n".format(old, new)
                output.write(sed)


if __name__ == '__main__':
    output_file = argv[1]
    set_file = argv[2]
    args = argv[3:]
    logger.info(args)

    dfs = read_csvs(args)

    olds, news = create_sed_substitions(dfs)

    write_sed(olds, news, output_file, set_file)
