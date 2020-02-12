# Rename all emissions, fuels, technologies and tradelinks

otoole validate datapackage datapackage.json --config validate.yaml

EMISSION_SED_FILE=emission.sed
FUEL_SED_FILE=fuel.sed
TECH_SED_FILE=tech.sed
TRADE_SED_FILE=trade.sed

cp data/TECHNOLOGY.csv data/TECHNOLOGY_old.csv

# Create a temporary folder
mkdir -p tmp/data

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
python combine_names.py $EMISSION_SED_FILE data/EMISSION.csv countrycode.csv emissionfactor.csv
# Find files with EMISSION commodities
EMISSION_FILES=`grep "EMISSION" data/*.csv -lr`
substitute "$EMISSION_FILES data/EMISSION.csv" $EMISSION_SED_FILE

# Fuels
python combine_names.py $FUEL_SED_FILE data/FUEL.csv countrycode.csv fuelcode.csv
# Find the files with FUEL commodities
FUEL_FILES=`grep "FUEL" data/*.csv -lr`
substitute "$FUEL_FILES data/FUEL.csv" $FUEL_SED_FILE

# Technologies
python combine_names.py $TECH_SED_FILE data/TECHNOLOGY_old.csv countrycode.csv techcodes.csv
# Find the files with technologies
TECH_FILES=`grep "TECHNOLOGY" data/*.csv -lr`
substitute "$TECH_FILES data/TECHNOLOGY.csv" $TECH_SED_FILE

# Trade links
python combine_names.py $TRADE_SED_FILE data/TECHNOLOGY_old.csv countrycode.csv tradecode.csv countrycode.csv tradesuffix.csv
# Find the files with trade links
TRADE_FILES=`grep "TECHNOLOGY" data/*.csv -lr`
substitute "$TRADE_FILES data/TECHNOLOGY.csv" $TRADE_SED_FILE

# Clean up
rm -r tmp
# rm -r *.sed
rm -r data/TECHNOLOGY_old.csv

otoole validate datapackage datapackage.json  --config validate.yaml

. run.sh