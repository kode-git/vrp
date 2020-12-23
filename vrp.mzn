% vehicle Routing Problem Modelling

include "globals.mzn";
include "gecode.mzn";

string: Name; 

% Input Data

% Customers
int: NumCustomers = length(Demand);
set of int: Customers = 1..NumCustomers; % set of customers
array[int] of int: Demand; % each customer has a demand

% Locations
set of int: Locations = 1..NumCustomers + 1; % set of ustomers and depot locations
array[Locations] of float: locX;
array[Locations] of float: locY;

% Locations Distances

array[Locations, Locations] of int: Distances = array2d(Locations, Locations,[round(sqrt((pow((locX[j] - locX[i]),2)) + (pow((locY[j] - locY[i]),2))) * 1000) | i,j in Locations]);

% TO-DO: Extends Distance from Locations to (Locations - 1) + ( 2 * NumVehicles) and set the last 2 * NumVehicles to depot location for locY_Extended and locY_Extended

% Vehicles
int: NumVehicles; % number of vehicles
set of int: Vehicles = 1..NumVehicles; % set of vehicles

% Capacity
array[Vehicles] of int: Capacity; % set of vehicles capacities

% Visits

% Visits bound include the sequences customers, 
% start visits, end visits where the start and end 
% visits are sequence of NumRoutes elements.
int: NumVisits = NumCustomers + (2 * NumVehicles);  % number of total visits of the combined route
set of int: Visits = 1..NumVisits; % set of visits

% start visits and end visits 
int: startS = NumCustomers + 1;
int: endS = startS + NumRoutes - 1;
set of int: StartVisits = startS..endS; % bound of start visits

int: startE = endS + 1;
int: endE = startE + NumRoutes - 1;
set of int: EndVisits = startE..endE; % bound of end visits



% Routes
int: NumRoutes = NumVehicles; % number of routes
set of int: Routes = 1..NumRoutes; % 0 is arbitrary routes

% Decisions Variables
array[Visits] of var Routes: routeOf; % the visit i belongs in the routeOf[i]
array[Visits] of var Visits: succ; % for each i,j in Visits if i is the successor of j then succ(i) = j
array[Visits] of var Visits: prec; % for each i,j in Visits if i is the previous of j then prec(i) = j

% Constraints
% Alldifferent constraint
constraint alldifferent(succ); % all values of the succ array are different from each other

% Constraint the element of succ to define 
% a circuit where succ[i] = j means that j 
% is the successor of i
constraint circuit(succ); 

% Symmetry Breaking
constraint forall(i,j in StartVisits where i < j)(routeOf[i] < routeOf[j]);
constraint forall(i,j in EndVisits where i < j)(routeOf[i] < routeOf[j]);
% constraint forall(i in StartVisits, j in EndVisits where i = (j + NumRoutes))(routeOf[i] = routeOf[j]);

% Combined constraint
constraint forall(i in StartVisits)(exists(j in Customers)(succ[i] = j));
constraint forall(i in EndVisits)(exists(j in StartVisits)(succ[i] = j));
constraint forall(i in Customers)(
                 forall(j in StartVisits)(
                     succ[i] != j));

% Capacity constraint 
constraint forall(j in Vehicles) 
                    (sum(i in Customers where (j = routeOf[i] /\ i in Customers))(Demand[i]) <= Capacity[j]);


% Implied constraint
constraint forall(i, j in Visits) (succ[i] = j <-> prec[j] = i);

% Objective function
% var int: obj;


%constraint obj =  sum(j in Vehicles) (sum(i in Visits where j = routeOf[i] /\ i in Customers)(Distances[i, succ[i]]));

% succ = array1d(1..9, [8, 7, 9, 1, 3, 2, 4, 5, 6]);

% Objective function minimize (total distance)
% solve minimize obj;
solve satisfy;


