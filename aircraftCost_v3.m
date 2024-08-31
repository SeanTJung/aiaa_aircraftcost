%% Modified DAPCA IV Cost Model (Raymer Ch.18.4)
clc;
clear;

% Description:
% per unit flyaway cost in 2022 USD assuming a nominal production run of 90, 180, and 270 aircraft over 15 production years.
% Total lifecycle and maintainability costs are to be reduced as much as possible to ensure commercial operability
% Flyaway production cost shall factor in a 10% profit margin per aircraft.

%% Initial values
W_e = 657000; %lbs %empty weight (lb or kg)
%W_e = 298010; %kg
V = 546.7257; %kt %maximum velocity (kt or km/h) %max cruise of M = 0.82 = 1012.536 km/h
Q = 30; %lesser of production quantity OR number to be produced in 5 years
%Q = 30;
%Q = 60;

FTA = 1; %number of flight-test aircraft (typically 2-6)

N_eng = Q * 4; %total production quantity times number of engines per aircraft
T_max = 0; %engine maximum thrust (lb or kN)
M_max = 0; %engine maximum Mach number
T_ti = 0; %temperature of turbine inlet (R or K) 

%W_av = 971.1413; %kg
W_av = 2141; %lbs
C_av = (4000 * W_av) * Q / 1000000000; %avionics cost (range from 5~25% of flyaway cost or $4000~$8000 per pound)

% Wrap rates for labor costs (2012 USD) 
R_E = 115; %Engineering
R_T = 118; %Tooling
R_Q = 108; %Quality control
R_M = 98; %Manufacturing

% Structure Fudge Factor to manufacturing hours
%Al = 1.0;     %Aluminium
%Gh = 1.1~1.8; %Graphite & Epoxy
%Fg = 1.1~1.2; %Fiberglass
%St = 1.5~2.0; %Steel
%Tn = 1.1~1.8; %Titanium

% CPI (from 2012 to 2024)
cpi_avg = (2.1+1.5+1.6+0.1+1.3+2.1+2.4+1.8+1.2+4.7+8+4.1)/12;
cpi_total = cpi_avg * 12/100;

%% Parameters (all in fps (ft,lb,s))
H_E = 4.86 * W_e^0.777 * V^0.894 * Q^0.164; %engineering hours
H_T = 5.99 * W_e^0.777 * V^0.696 * Q^0.263; %tooling hours
H_M = 7.37 * W_e^0.82 * V^0.484 * Q^0.641;  %manufacturing hours (structure fudge factor)
H_Q = 0.076 * H_M; %quality control hours for cargo plane (0.133 * H_M if otherwise)

C_D = (91.3 * W_e^0.630 * V^1.3) / 1000000000; %development support cost 
C_F = (2498 * W_e^0.325 * V^0.822 * FTA^1.21) / 1000000000; %flight test cost
C_MM = (22.1 * W_e^0.921 * V^0.621 * Q^0.799) / 1000000000; %Manufacturing materials cost
%C_eng = 3112 * ((0.043*T_max) + (243.25*M_max) + (0.969*T_ti) - 2228); %Engine production cost
C_eng = 27500000 / 1000000000; %existing engine so we should have cost

%GE90 = 27.5 million USD
%GE9X = 30~40 million USD 

C_E = (H_E * R_E) / 1000000000; %engineering cost
C_T = (H_T * R_T) / 1000000000; %tooling cost
C_M = (H_M * R_M) / 1000000000; %manufacturing cost
C_Q = (H_Q * R_Q) / 1000000000; %quality control cost

%% RDT&E + Flyaway Costs for 90 Aircraft Over 5 Years
RDTE = C_E + C_T + C_M + C_Q + C_D + C_F + C_MM + (C_eng * N_eng) + C_av;
RDTE_2024 = (RDTE * (1 + cpi_total)); %Adjusted for inflation using CPI

% Cost per aircraft (first 5 years)
ac_cost_5 = RDTE_2024 / Q; 
ac_cost_market_5 = ac_cost_5 * 1.1; % 10% profit margin

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
fuel_price = 0; %set by petroleum vendors, adjust to inflation
fuel_cost = fuel_year * fuel_price; %fuel cost per year per aircraft (inflated USD)
%Oil costs average less than half a percent of total fuel costs and can be ignored

%Crew salaries (RFP: crew of 4, consisting of pilot, copilot and two loadmasters)
how_many = 0; %number of aircrafts
crew_num = 4; %number of crew members per aircraft
crew_price = 0; %average cost per crew member (obtained from military sources)
crew_ratio = 1.5; %ratio of aircrews per aircraft (1.5 if FH < 1200 / 2.5 if FH < 2400 / 3.5 if FH > 2400)
FH = 1400; %flight hours per year per aircraft (700~1400 for military transport)

% I need to come back to this (pg 701)
% number of aircraft * crew members per aircraft * crew ratio
crew_cost = crew_price * crew_num * crew_ratio * FH; %crew salaries per year (2012 USD) 
crew_cost_2024 = crew_cost * cpi_total; %(2024 USD)

%% Maintenance Costs (Raymer 18.5.3)
MMH_FH = 24; %MMH per flight hour per year (20~30 for military transport), 24 is max as stated as RFP
MMH_Y = MMH_FH * FH; %MMH per year
Maintenance_cost = MMH_Y * R_M; %maintenance labor cost per year (2012 USD)
Maintenance_cost_2024 = (Maintenance_cost * cpi_total); %(2024 USD) 

%% Landing Fees & Certification? 

%% Depreciation and Insurance (Raymer 18.5.4)
% Depreciation considered operating cost for commercial aircraft, Raymer
% doesnt say anything about military so maybe look into this (or disregard)
total_cost = 0; 
eng_cost = 0;
airframe_cost = total_cost - eng_cost; 
depreciation_period = 0; %number of years used for depreciation
resale_value = 0; %as percentage

insurance = 0; %1~3% to cost of operations for commercial aircraft 

%% Learning Curve
% 85% learning curve = 15% decreased labor (hours) cost as quantity doubles
% page 694
RDTE_LC1 = RDTE_2024;
RDTE_LC2 = RDTE_2024 * (2^((log(0.85) * log(2) / log(2))));
RDTE_LC3 = RDTE_2024 * (2^((log(0.85) * log(3) / log(2))));

%% RDT&E + Flyaway Costs for 270 Aircraft Over 15 Years
RDTE_2024_LC = RDTE_LC1 + RDTE_LC2 + RDTE_LC3;
ac_cost_15 = RDTE_2024_LC / 270; 
ac_cost_market_15 = ac_cost_15 * 1.1;


%% OUTPUT
fprintf('ALL IN BILLION USD (2024) \n')
fprintf('Total CPI from 2012 to 2024: %.4f \n\n', cpi_total)
fprintf('Engineering cost: %.4f \n', C_E);
fprintf('Tooling cost: %.4f \n', C_T)
fprintf('Manufacturing cost: %.4f \n', C_M)
fprintf('Quality control cost: %.4f \n', C_Q)
fprintf('Development support cost: %.4f \n', C_D)
fprintf('Flight test cost: %.4f \n', C_F)
fprintf('Manufacturing Materials cost: %.4f \n', C_MM)
fprintf('Engine production cost: %.4f \n', C_eng * N_eng)
fprintf('Avionics cost: %.4f \n', C_av)
fprintf('Interior cost: \n\n')

fprintf('RDTE + Flyaway cost for %.0f aircraft in 5 years: %.4f \n', Q, RDTE_2024)
fprintf('RDTE + Flyaway cost for %.0f aircraft in 15 years: %.4f \n', Q * 3, RDTE_2024_LC)

fprintf('Aircraft cost (nominal production of %.0f): %.4f \n\n', Q * 3, ac_cost_15);

fprintf('Fuel cost: \n')
fprintf('Crew cost: \n')
fprintf('Maintenance cost: \n')
fprintf('Landing fees: \n')




