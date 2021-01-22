% vehicle Routing Problem Modelling

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

% -------- Distance Calculations --------
% Distances with the extension of depot in start visits and end visits nodes
array[Visits, Visits] of var int: Distance;

% Distances between two customers
constraint forall(i, j in Customers)(
                  Distance[i,j] = round(sqrt((pow((locX[j] - locX[i]),2)) + (pow((locY[j] - locY[i]),2))) * 1000));

% Distances between starts and ends visits
constraint forall(i,j in StartVisits union EndVisits)(
                   Distance[i,j] = 0);
                                     
% Distances between customers and starts or ends visits
constraint forall(i in Customers, j in StartVisits union EndVisits )(
                     Distance[i,j] = Distance[j,i] /\ Distance[i,j] = round(sqrt((pow((locX[DepotIndex] - locX[i]),2)) + (pow((locY[DepotIndex] - locY[i]),2))) * 1000));
                     
% -------- Decisions Variables --------
array[Visits] of var Vehicles: vehicle; % if vehicle[i] = j then the vehicle j visited i
array[Visits] of var Visits: succ; % if succ[i] = j then j is the successor of i
array[Vehicles] of var 0..1: isUsed; % define if a vehicle is used or not, for each vehicle i isUsed[i] = 0 if not used or isUsed[i] = 1 if used

% -------- Main Constraints --------
% Hamiltonian constraint
constraint circuit(succ) :: domain;
% implied constraints
constraint alldifferent(succ) :: domain;

% Capacity constraint 
constraint forall(j in Vehicles) 
                    (sum(i in Customers where vehicle[i] = j)(Demand[i]) <= Capacity[j]);


% ---- Setting the know decisions -----

% Start visits vehicles
constraint forall(s in StartVisits)(
              vehicle[s] = s - NumCustomers);
     
% End visits vehicles
constraint forall(e in EndVisits)(
              vehicle[e] = (e - NumCustomers - NumVehicles));   
              
% Linking the end visit with the next start visit
constraint forall(se in NumCustomers + NumVehicles + 1.. NumCustomers + (2 * NumVehicles)-1)(
                  succ[se] = se - NumVehicles + 1);

% Linking the last end visit with the first start visit to estabilish the circle
constraint succ[NumCustomers + (2 * NumVehicles)] = NumCustomers + 1;

% Mantain consistency in the subpath of a vehicle
constraint forall (c in Customers)
            (vehicle[succ[c]] = vehicle[c]);
         

% Vehicle constraint
constraint forall(i in Customers)(isUsed[vehicle[i]] = 1);

% Vehicles capacities symmetry breaking
% constraint forall(i,j in 1..NumVehicles where Capacity[i] = Capacity[j] /\ i < j)(isUsed[j] > 0 -> isUsed[i] > 0);


% -------- Objective Function --------
var int: TotalDistance = sum(v in Visits)(Distance[v, succ[v]]); % sum of the distances traveled 
var int: NumVehiclesUsed = sum(v in Vehicles)(isUsed[v]); % sum the number of vehicles used multiply vehicle weigth used to balance the optimal solution
var int: objective = TotalDistance + NumVehiclesUsed * VehicleWeigth; % objective function is equal to the sum between the total distance and number of vehicles used


% -------- Search --------
solve 
% :: seq_search([int_search(vehicle, dom_w_deg, indomain_random, complete),int_search(succ, dom_w_deg, indomain_random)]) :: restart_luby(250)
   :: seq_search([int_search(vehicle, smallest, indomain_min), int_search(succ, dom_w_deg, indomain_random)]) :: restart_luby(300)
%  :: int_search(succ, dom_w_deg, indomain_random) :: restart_luby(350)
            :: relax_and_reconstruct(succ,85)
       minimize objective;


output["Objective = \(objective)\nNumberVehiclesUsed = \(NumVehiclesUsed)\nTotalDistance = \(TotalDistance)m -> \(TotalDistance div 1000)km\n"];



