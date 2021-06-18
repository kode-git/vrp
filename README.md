# How to run the VRP model
<p>
        <img src="https://img.shields.io/static/v1?label=build&message=passing&color=%3CCOLOR%3E" alt="alternatetext">
	<img src="https://img.shields.io/badge/state-closed-red" alt="alternatetext">
	<img src="https://img.shields.io/badge/version-1.0%20-blue" alt="alternatetext">
  <img src="https://img.shields.io/badge/solver-Gecode Solver 6.3.0-yellow" alt="alternatetext">
  <img src="https://img.shields.io/badge/language-Minizinc 2.5.1-white" alt="alternatetext">
</p>

## Features

Project based on the analyses and report of results during the research of the optimal solution in the Vehicle Routing Problem using Constraint Programming approach and Minizinc tool. It was used to Constraint Programming exam at Alma Mater Studiorum - DISI Course

## Step to run
- Open Project file vrp.mzp in the main directory
- Set Gecode 6.3.0+ as solver
- Go to "Show configuration editor" > Options > Enable Time limit with value 300
- Click on Run and choose data file

## Coding in Minizinc

I used Minizinc IDE and language following official documentation on https://www.minizinc.org basing on Constraint Programming Approach which data.dzn and scripts are in different files and loaded in runtime. 

We used global constraints to improve the computational time efficiency for a better propagation. The following snippet of code represents the input data structure used inside the project. For more info about the scripts, check vrp.mzn.

```
include "globals.mzn";
include "gecode.mzn";


string: Name; 

% -------- Input Data --------

% Vehicles
int: NumVehicles;
int: VehicleWeigth = 100000;
set of int: Vehicles = 1..NumVehicles;

% Customers
int: NumCustomers = length(Demand);
set of int: Customers = 1..NumCustomers;

% Visits
int: NumVisits = NumCustomers + (2 * NumVehicles);
set of int: Visits = 1..NumCustomers + (2 * NumVehicles);
set of int: StartVisits = NumCustomers + 1..NumCustomers + NumVehicles;
set of int: EndVisits = NumCustomers + NumVehicles + 1..NumCustomers + (2 * NumVehicles);


% Depot Location Index
int: DepotIndex = NumCustomers + 1;

% Locations
set of int: Locations = 1..NumCustomers + 1; 

% Customers + Depot Coordinates
array[Locations] of float: locX;
array[Locations] of float: locY;

% Demand
array[int] of int: Demand;

% Capacity
array[Vehicles] of int: Capacity;
```


## Author
- Mario Sessa (@kode-git)

## License

&copy; Apache License Version 2.0, January 2004
