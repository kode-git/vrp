% vehicle Routing Problem Modelling

include "globals.mzn";
include "gecode.mzn";

string: Name; 

% -------- Input Data --------

% Vehicles
int: NumVehicles;
int: VehicleWeigth = 10000;
set of int: Vehicles = 1..NumVehicles;

% Customers
int: NumCustomers = length(Demand);
set of int: Customers = 1..NumCustomers;

% Visits
int: NumVisits = NumCustomers + (2 * NumVehicles);
set of int: Visits = 1..NumCustomers + (2 * NumVehicles);
set of int: StartVisits = NumCustomers + 1..NumCustomers + NumVehicles;
set of int: EndVisits = NumCustomers + NumVehicles + 1..NumCustomers + (2 * NumVehicles);
set of int: StartEndVisits = NumCustomers + 1..NumCustomers + (2 * NumVehicles);

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
constraint forall(i,j in StartEndVisits)(
                   Distance[i,j] = 0);
                   
% Distances between customers and starts or ends visits
constraint forall(i in Customers, j in StartEndVisits)(
                     Distance[i,j] = Distance[j,i] /\ Distance[i,j] = round(sqrt((pow((locX[DepotIndex] - locX[i]),2)) + (pow((locY[DepotIndex] - locY[i]),2))) * 1000));
                     
% -------- Decisions Variables --------
array[Visits] of var Vehicles: vehicle; % if vehicle[i] = j then the vehicle j visited i
array[Visits] of var Visits: succ; % if succ[i] = j then j is the successor of i
array[Visits] of var Visits: prec; % if prec[i] = j then j is the precessor of i (redundant) 
array[Visits] of var Visits: inv; % the inverse routes for each vehicles when the verse of the visited customers is inverted, inv[i] = j is the same of succ[i] = j
array[Vehicles] of var 0..1: isUsed; % define if a vehicle is used or not, for each vehicle i isUsed[i] = 0 if not used or isUsed[i] = 1 if used

% -------- Main Constraints --------
% Hamiltonian constraint
constraint circuit(succ);

% Setting the know decisions

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
            
% Capacity constraint 
constraint forall(j in Vehicles) 
                    (sum(i in Customers where vehicle[i] = j)(Demand[i]) <= Capacity[j]);

% Channelling constraint
constraint forall(i,j in Visits) (succ[i] = j <-> prec[j] = i);

% -------- Objective Function --------
var int: TotalDistance = sum(v in Visits)(Distance[v, succ[v]]); % sum of the distances traveled 
var int: NumVehiclesUsed = sum(v in Vehicles)(isUsed[v]) * VehicleWeigth; % sum the number of vehicles used multiply vehicle weigth used to balance the optimal solution
var int: obj = TotalDistance + NumVehiclesUsed; % objective function is equal to the sum between the total distance and number of vehicles used

% Vehicle constraint
constraint forall(i in Customers)(isUsed[vehicle[i]] = 1);

% ------- Symmetry breaking constraints -----------

% Inverse routing building and symmetry constraint
constraint forall(i in EndVisits)
              (inv[i] = succ[i]);
              
constraint forall(i in StartVisits, j in EndVisits where vehicle[i] = vehicle[j]) 
                (inv[i] = prec[j]);
                
constraint forall(i in Customers where succ[i] <= NumCustomers) 
              (inv[i] = succ[succ[i]]);

constraint forall(i in Customers, j in EndVisits where succ[i] in EndVisits /\ j in EndVisits /\ vehicle[i] = vehicle[j])
              (inv[i] = succ[succ[j]]);

constraint lex_lesseq(succ, inv);
% Vehicle swapping 

% -------- Search --------
solve :: int_search(succ, dom_w_deg, indomain_random) :: restart_luby(250) :: relax_and_reconstruct(succ, 85) minimize obj;
% solve :: int_search(succ, dom_w_deg, indomain_random) :: restart_luby(250) minimize obj;
% solve satisfy;
output["obj=\(obj)\n" ++ "succ=\(succ)\n" ++ "vehicle=\(vehicle)\n" ++ "\(prec)\n" ++ "inv=\(inv)"];