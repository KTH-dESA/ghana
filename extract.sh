mkdir -p ../Ghana/data

for file in "$@"
do
	echo $file
	head -n 1 $file > ../Ghana/$file
	grep -e ',GH\|^GH' $file >> ../Ghana/$file
done

# Copy only fuels and technologies of Ghana
for file in data/FUEL.csv data/TECHNOLOGY.csv data/STORAGE.csv data/EMISSION.csv
do
	grep -e '^GH' $file >> ../Ghana/$file
done

# Copy all sets
for file in data/REGION.csv data/TIMESLICE.csv data/YEAR.csv data/SEASON.csv data/MODE_OF_OPERATION.csv data/DAYTYPE.csv data/DAILYTIMEBRACKET.csv data/YearSplit.csv
do
	cp  $file ../Ghana/$file
done
