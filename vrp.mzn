% Vehicle Routing Problem Modelling

% given data
string: Name; 
array[int] of int: Demand; % demand of each customer
set of int: C_SIZE = 1..length(Demand) + 1; % sizing of customers + depot location
array[C_SIZE] of float: locX; % X coordinate of the customer + depot 
array[C_SIZE] of float: locY; % Y coordinate of the customer +  depot
int: NumVehicles; % number of vehicles to minimize
set of int: V_SIZE = 1..NumVehicles; % sizing of numVehicles
array[V_SIZE] of int: Capacity; % capacity of each vehicle
% int: weigth = 1000; % the weigth specify the balance betweenb the total distance and the influence of the number of vehicles used

array[C_SIZE,C_SIZE] of var float: distances; % distance using the coordinates

% distance between two points is calculated with the square root of the squared differences between coordinates X and Y of two locations
constraint forall(i,j in C_SIZE)(
                  distances[i,j] = sqrt((pow((locX[j] - locX[i]),2)) + (pow((locY[j] - locY[i]),2))) * 1000
                  );

% Objective function minimize (total distance) + (numVehicles * weigth)
solve satisfy;
