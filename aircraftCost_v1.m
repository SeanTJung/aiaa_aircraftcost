%% Modified DAPCA IV Cost Model (Raymer Ch.18.4)

%% Initial values
W_e = 0; %empty weight (lb or kg)
V = 0; %maximum velocity (kt or km/h)   %max cruise of M = 0.82
Q = 0; %lesser of production quantity OR number to be produced in 5 years
FTA = 0; %number of flight-test aircraft (typically 2-6)
N_eng = 0; %total production quantity times number of engines per aircraft
T_max = 0; %engine maximum thrust (lb or kN)
M_max = 0; %engine maximum Mach number
T_ti = 0; %temperature of turbine inlet (R or K) 
C_av = 0; %avionics cost

% Wrap rates for labor costs (2012 USD) 
R_E = 115; %Engineering
R_T = 118; %Tooling
R_Q = 108; %Quality control
R_M = 98; %Manufacturing

%% Parameters (all in fps (ft,lb,s))
H_E = 4.86 * W_e^0.777 * V^0.894 * Q^0.164; %engineering hours
H_T = 5.99 * W_e^0.777 * V^0.696 * Q^0.263; %tooling hours
H_M = 7.37 * W_e^0.82 * V^0.484 * Q^0.641;  %manufacturing hours
H_Q = 0.076 * H_M; %quality control hours for cargo plane (0.133 * H_M if otherwise)

C_D = 91.3 * W_e^0.630 * V^1.3; %development support cost 
C_F = 2498 * W_e^0.325 * V^0.822 * FTA^1.21; %flight test cost
C_M = 22.1 * W_e^0.921 * V^0.621 * Q^0.799; %Manufacturing materials cost
C_eng = 3112 * ((0.043*T_max) + (243.25*M_max) + (0.969*T_ti) - 2228); %Engine production cost

C_E = H_E * R_E; %engineering cost
C_T = H_T * R_T; %tooling cost
C_M = H_M * R_M; %manufacturing cost
C_Q = H_Q * R_Q; %quality control cost

RDTE = C_E + C_T + C_M + C_Q + C_D + C_F + C_M + (C_eng * N_eng) + C_av;

%Adjust for inflation, inflation factor using CPI
%Avionics range from 5~25% of flyaway cost or $4000~$8000 per pound
%DAPCA doesnt include cost for interiors: $3500 per passenger for jet trans­port, $1700 for regional transports, or $850 for general aviation aircraft (2012 USD)
%hours and cost estimates increased by 20% for modern designs (pg 698)
%Investment factor for customers: 1.1~1.4 
%Initial spares: 10~15% of aircraft unit price

%% Operating Costs (Raymer Ch.18.5.1)
% Choose typical mission profile
mission_duration = 0; %total mission duration in hours
fuel_burned = 0; %total fuel burned during mission
avg_fuel = fuel_burned / mission_duration; %average fuel burned per hour
avg_FH = 0; %average yearly flight hours per aircraft
fuel_year = avg_fuel * avg_FH; %yearly fuel usage
fuel_price = 0; %set by petroleum vendors, adjusted to inflation

fuel_cost = fuel_year * fuel_price; %fuel cost per year per aircraft (inflated USD)
%Oil costs average less than half a percent of total fuel costs and can be
%ignored.

%Crew salaries (RFP: crew of 4, consisting of pilot, copilot and two loadmasters)
how_many = 0; %number of aircrafts
crew_num = 4; %number of crew members per aircraft
crew_price = 0; %average cost per crew member (obtained from military sources)
crew_ratio = 1.5; %ratio of aircrews per aircraft (1.5 if FH < 1200 / 2.5 if FH < 2400 / 3.5 if FH > 2400)
FH = 1050; %flight hours per year per aircraft (700~1400 for military transport)

% I need to come back to this (pg 701)
% number of aircraft * crew members per aircraft * crew ratio
crew_cost = crew_price * crew_num * crew_ratio * FH; %crew salaries per year (2012 USD) 

%% Maintenance Costs (Raymer 18.5.3)
MMH_FH = 24; %MMH per flight hour per year (20~30 for military transport), 24 is max as stated as RFP
MMH_Y = MMH_FH * FH; %MMH per year

Maintenance_cost = MMH_Y * R_M; %maintenance labor cost per year (2012 USD)

%% Depreciation and Insurance (Raymer 18.5.4)
% Depreciation considered operating cost for commercial aircraft, Raymer
% doesnt say anything about military so maybe look into this (or disregard)
total_cost = 0; 
eng_cost = 0;
airframe_cost = total_cost - eng_cost; 
depreciation_period = 0; %number of years used for depreciation
resale_value = 0; %as percentage

insurance = 0; %1~3% to cost of operations for commercial aircraft 




