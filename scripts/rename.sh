# Rename all emissions, fuels, technologies and tradelinks

otoole validate datapackage datapackage.json --config validate.yaml

# Create a temporary folder
mkdir -p tmp/data

EMISSION_SED_FILE=tmp/emission.sed
FUEL_SED_FILE=tmp/fuel.sed
TECH_SED_FILE=tmp/tech.sed
TRADE_SED_FILE=tmp/trade.sed

# Define the substitute function
substitute () {
for file in $1
do
    sed -f $2 $file > tmp/$file
    cp tmp/$file $file
    rm -r tmp/$file
done
}

# Emissions
python scripts/combine_names.py $EMISSION_SED_FILE data/EMISSION.csv rename/countrycode.csv rename/emissionfactor.csv
# Find files with EMISSION commodities
EMISSION_FILES=`grep "EMISSION" data/*.csv -lr`
substitute "$EMISSION_FILES data/EMISSION.csv" $EMISSION_SED_FILE

# Fuels
python scripts/combine_names.py $FUEL_SED_FILE data/FUEL.csv rename/countrycode.csv rename/fuelcode.csv
# Find the files with FUEL commodities
FUEL_FILES=`grep "FUEL" data/*.csv -lr`
substitute "$FUEL_FILES data/FUEL.csv" $FUEL_SED_FILE

# Technologies
python scripts/combine_names.py $TECH_SED_FILE data/TECHNOLOGY.csv rename/countrycode.csv rename/techcodes.csv
# Find the files with technologies
TECH_FILES=`grep "TECHNOLOGY" data/*.csv -lr`
substitute "$TECH_FILES data/TECHNOLOGY.csv" $TECH_SED_FILE

# Trade links
python scripts/combine_names.py $TRADE_SED_FILE data/TECHNOLOGY.csv rename/countrycode.csv rename/tradecode.csv rename/countrycode.csv rename/tradesuffix.csv
# Find the files with trade links
TRADE_FILES=`grep "TECHNOLOGY" data/*.csv -lr`
substitute "$TRADE_FILES data/TECHNOLOGY.csv" $TRADE_SED_FILE

# Clean up
rm -r tmp

otoole validate datapackage datapackage.json  --config validate.yaml

. scripts/run.sh