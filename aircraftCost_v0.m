%% Modified DAPCA IV Cost Model (Raymer Ch.18.4)
% Description:
% per unit flyaway cost in 2022 USD assuming a nominal production run of 90, 180, and 270 aircraft over 15 production years.
% Total lifecycle and maintainability costs are to be reduced as much as possible to ensure commercial operability
% Flyaway production cost shall factor in a 10% profit margin per aircraft.

%% Initial values
W_e = 632870; %lbs %empty weight (lb or kg)
%W_e = 298010; %kg
V = 546.7257; %kt %maximum velocity (kt or km/h) %max cruise of M = 0.82 = 1012.536 km/h
Q = 90; %lesser of production quantity OR number to be produced in 5 years (Q is either 30, 60, 90)

FTA = 2; %number of flight-test aircraft (typically 2-6)
%Check this value ^ from standards/certification

N_eng = Q * 4; %total production quantity times number of engines per aircraft
T_max = 0; %engine maximum thrust (lb or kN)
M_max = 0; %engine maximum Mach number
T_ti = 0; %temperature of turbine inlet (R or K) 

%W_av = 971.1413; %kg
W_av = 2141; %lbs
C_av = (4000 * W_av) * Q; %avionics cost (range from 5~25% of flyaway cost or $4000~$8000 per pound)

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
%cpi_avg = (2.1+1.5+1.6+0.1+1.3+2.1+2.4+1.8+1.2+4.7+8+4.1)/12;
%cpi_total = cpi_avg * 12/100;
%cpi_total = 0;

% CPI (from 2012 to 2022)
cpi_avg = (2.1+1.5+1.6+0.1+1.3+2.1+2.4+1.8+1.2+4.7)/10;
cpi_total = cpi_avg * 10/100;


%% Parameters (all in fps (ft,lb,s))
H_E = 4.86 * W_e^0.777 * V^0.894 * Q^0.164; %engineering hours
H_T = 5.99 * W_e^0.777 * V^0.696 * Q^0.263; %tooling hours
H_M = 7.37 * W_e^0.82 * V^0.484 * Q^0.641;  %manufacturing hours (structure fudge factor)
H_Q = 0.076 * H_M; %quality control hours for cargo plane (0.133 * H_M if otherwise)

C_D = (91.3 * W_e^0.630 * V^1.3); %development support cost 
C_F = (2498 * W_e^0.325 * V^0.822 * FTA^1.21); %flight test cost
C_MM = (22.1 * W_e^0.921 * V^0.621 * Q^0.799); %Manufacturing materials cost
C_eng = 27500000; %existing engine so we should have cost
%C_eng = 3112 * ((0.043*T_max) + (243.25*M_max) + (0.969*T_ti) - 2228); %Engine production cost

%GE90 = 27.5 million USD
%GE9X = 30~40 million USD 

C_E = (H_E * R_E); %engineering cost
C_T = (H_T * R_T); %tooling cost
C_M = (H_M * R_M); %manufacturing cost
C_Q = (H_Q * R_Q); %quality control cost

%% RDT&E + Flyaway Costs for 30, 60, 90 Aircraft Over 5 Years
RDTE = C_E + C_T + C_M + C_Q + C_D + C_F + C_MM + (C_eng * N_eng) + C_av;
RDTE_2024 = (RDTE * (1 + cpi_total)); %Adjusted for inflation using CPI

% Cost per aircraft (first 5 years)
ac_cost_5 = RDTE_2024 / Q; 
ac_cost_5m = ac_cost_5 * 1.1; % 10% profit margin

%DAPCA doesnt include cost for interiors: $3500 per passenger for jet trans­port, $1700 for regional transports, or $850 for general aviation aircraft (2012 USD)
%hours and cost estimates increased by 20% for modern designs (pg 698)
%Investment factor for customers: 1.1~1.4 
%Initial spares: 10~15% of aircraft unit price

%% Operating Costs (Raymer Ch.18.5.1)
% Choose typical mission profile (Mach number formula: M = u / c)
missionA = 2500; % in nm (430,000lbs)
missionB = 5000; % in nm (295,000lbs)
missionC = 8000; % in nm (0lb)
mach_cruise = 0.80;
sound_speed = 661.47; %standard speed of sound in kt
ground_speed = mach_cruise * sound_speed; % mph 

mission_duration = 0; %total mission duration in hours
durationA = missionA / ground_speed; %hours for mission A
durationB = missionB / ground_speed; %hours for mission B
durationC = missionC / ground_speed; %hours for mission C 

SFC_GE90 = 0.325; %lb/lbf-hr (lbs of fuel per lb thrust per hour)
SFC_GE9X = 0.325 * 1.1; % 10% increase of GE90
Max_thrust = 134300; %lbf 
cruise_thrust = Max_thrust * 0.80; % 80% max thrust during cruise? 
fuel_burn_rate = SFC_GE9X * cruise_thrust; %fuel burn rate during cruise (lb/hr)

fuel_burnedA = fuel_burn_rate * durationA;
fuel_burnedB = fuel_burn_rate * durationB;
fuel_burnedC = fuel_burn_rate * durationC;

MT = 2204.62; %1 metric ton = 2204.62 lbs
avg_FH = 1100; %average yearly flight hours per aircraft (700~1400 for military transport) 
fuel_burned_year = fuel_burn_rate * avg_FH; %yearly fuel usage (lbs)
fuel_price = 697.6; % 2024 USD in United States (per Metric Ton)
% https://simpleflying.com/military-aircraft-fuel-guide/
% https://jet-a1-fuel.com/fuel-price/jp-8
fuel_price_lb = fuel_price / MT;

fuel_cost_year = fuel_burned_year * fuel_price_lb; %fuel cost per year per aircraft (inflated USD)
fuel_cost_FH = fuel_cost_year / avg_FH; %assuming FH = 1400, not specified to a mission. 

%Oil costs average less than half a percent of total fuel costs and can be ignored

%Crew salaries (RFP: crew of 4, consisting of pilot, copilot and two loadmasters)
%The Federal Aviation Regulations (FARs) limit pilots to 36 flight hours per week, 100 hours in 28 days, and 1,000 hours in a year.
crew_pilot = 80; %hourly wage (THESE ARE GUESSES)
crew_copilot = 65;
crew_load = 30;

crew_price = (crew_pilot + crew_copilot + (2 * crew_load)) * 1.2; %cost of full crew (4) per hour (20% increase for benefits) 
crew_ratio = 1.5; %ratio of aircrews per aircraft (1.5 if FH < 1200 / 2.5 if FH < 2400 / 3.5 if FH > 2400)
FH = 1100; %flight hours per year per aircraft (700~1400 for military transport)

% I need to come back to this (pg 701)
crew_cost_year = crew_price * crew_ratio * FH; %crew salaries per year
crew_cost_FH = crew_price * crew_ratio; %crew salaries per year
%crew_cost_2024 = crew_cost * (1+ cpi_total); %(2024 USD if wage in 2012)

%% Maintenance Costs (Raymer 18.5.3)
MMH_FH = 20; %MMH per flight hour per year (20~30 for military transport), 24 is max as stated as RFP
MMH_Y = MMH_FH * FH; %MMH per year
maintenance_cost = MMH_Y * R_M; %maintenance labor cost per year (2012 USD)
maintenance_cost_2024 = (maintenance_cost * (1 + cpi_total)); %(2024 USD) 

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
% 75% learning curve = 25% decreased labor (hours) cost as quantity doubles
% page 694
RDTE_LC1 = RDTE_2024;
RDTE_LC2 = RDTE_2024 * (2^((log(0.75) * log(2) / log(2))));
RDTE_LC3 = RDTE_2024 * (2^((log(0.75) * log(3) / log(2))));

%% RDT&E + Flyaway Costs for 90, 180, 270 Aircraft Over 15 Years (Q*3)
RDTE_2024_LC = RDTE_LC1 + RDTE_LC2 + RDTE_LC3;
ac_cost_15 = RDTE_2024_LC / (Q*3); 
ac_cost_15m = ac_cost_15 * 1.1;

%% Break-Even
profit5 = ac_cost_5 * 1.1;
profit15 = ac_cost_15 * 1.1;
breakeven5 = RDTE_2024 / profit5;
breakeven15 = RDTE_2024_LC / profit15;

%% OUTPUT
fprintf('Total CPI from 2012 to 2024 inflation factor: %.4f \n\n', 1 + cpi_total)
fprintf('ALL IN BILLION USD (2024) \n')
fprintf('Engineering cost: %.4f \n', (C_E  * (1 + cpi_total))/1000000000);
fprintf('Tooling cost: %.4f \n', (C_T * (1 + cpi_total))/1000000000)
fprintf('Manufacturing cost: %.4f \n', (C_M  * (1 + cpi_total))/1000000000)
fprintf('Quality control cost: %.4f \n', (C_Q * (1 + cpi_total))/1000000000)
fprintf('Development support cost: %.4f \n', (C_D * (1 + cpi_total))/1000000000)
fprintf('Flight test cost: %.4f \n', (C_F * (1 + cpi_total))/1000000000)
fprintf('Manufacturing Materials cost: %.4f \n', (C_MM * (1 + cpi_total))/1000000000)
fprintf('Engine production cost: %.4f \n', (C_eng * N_eng  * (1 + cpi_total))/1000000000)
fprintf('Avionics cost: %.4f \n', (C_av * (1 + cpi_total))/1000000000)
fprintf('Interior cost: \n\n')

fprintf('RDTE + Flyaway cost for %.0f aircraft in 5 years: %.1f billion USD\n', Q, RDTE_2024/1000000000)
fprintf('RDTE + Flyaway cost for %.0f aircraft in 15 years: %.1f billion USD \n\n', Q * 3, RDTE_2024_LC/1000000000)
fprintf('Aircraft cost (nominal production of %.0f in 5 years): %.2f billion USD \n', Q, ac_cost_5/1000000000);
fprintf('Aircraft cost (nominal production of %.0f in 15 years): %.2f million USD \n\n', Q * 3, ac_cost_15/1000000);
fprintf('Operating Costs:\n')
fprintf('Fuel cost (per aircraft per year): %.2f million USD\n', fuel_cost_year/1000000)
fprintf('Fuel cost (per aircraft per FH): %.0f USD\n', fuel_cost_FH)
fprintf('Crew cost (per year): %.0f USD\n', crew_cost_year)
fprintf('Crew cost (per FH): %.0f USD\n', crew_cost_FH)
fprintf('Maintenance cost (per year): %.2f million USD\n', maintenance_cost_2024/1000000)
fprintf('Maintenance cost (per FH): %.0f USD\n\n', maintenance_cost_2024/FH)
fprintf('Landing fees: No landing fees for military (but might look into for niche market)\n\n')

fprintf('Number of aircrafts for Break-even (5 years): %.1f units\n', breakeven5)
fprintf('Number of aircrafts for Break-even (15 years): %.1f units\n', breakeven15)



