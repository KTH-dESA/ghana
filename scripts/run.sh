# Run the Ghana OSeMOSYS model using 1. GLPK, 2. CBC, 3. Gurobi

otoole convert datapackage datafile datapackage.json ghana.txt
# 1. GLPK
glpsol -m osemosys_short.txt -d ghana.txt

# 2. CBC
# glpsol -m osemosys_short.txt -d ghana.txt --wlp ghana.lp --check
# cbc ghana.lp barr -solu ghana.sol

# 3. Gurobi
# glpsol -m osemosys_short.txt -d ghana.txt --wlp ghana.lp --check
# gurobi_cl NumericFocus=1 ResultFile=ghana.sol ResultFile=ghana.ilp LogFile=ghana.log ghana.lp