% Define the range of production numbers
Q_range = 20:150;

% Initialize arrays to store production numbers and unit costs
production_numbers = zeros(size(Q_range));
unit_costs = zeros(size(Q_range));
total_program_costs = zeros(size(Q_range));

% Loop through each production number
for i = 1:length(Q_range)
    % Get the current production number
    Q2 = Q_range(i);
    W_e = 657000; %lbs %empty weight (lb or kg)
    %W_e = 298010; %kg
    V = 546.7257; %kt %maximum velocity (kt or km/h) %max cruise of M = 0.82 = 1012.536 km/h

    FTA = 2; %number of flight-test aircraft (typically 2-6)
    %Check this value ^ from standards/certification

    N_eng = Q2 * 4; %total production quantity times number of engines per aircraft
    T_max = 0; %engine maximum thrust (lb or kN)
    M_max = 0; %engine maximum Mach number
    T_ti = 0; %temperature of turbine inlet (R or K) 

    %W_av = 971.1413; %kg
    W_av = 2141; %lbs
    C_av = (4000 * W_av) * Q2; %avionics cost (range from 5~25% of flyaway cost or $4000~$8000 per pound)

    % Wrap rates for labor costs (2012 USD) 
    R_E = 115; %Engineering
    R_T = 118; %Tooling
    R_Q = 108; %Quality control
    R_M = 98; %Manufacturing

    % CPI (from 2012 to 2022)
    cpi_avg = (2.1+1.5+1.6+0.1+1.3+2.1+2.4+1.8+1.2+4.7)/10;
    cpi_total = cpi_avg * 10/100;


    %% Parameters (all in fps (ft,lb,s))
    H_E = 4.86 * W_e^0.777 * V^0.894 * Q2^0.164; %engineering hours
    H_T = 5.99 * W_e^0.777 * V^0.696 * Q2^0.263; %tooling hours
    H_M = 7.37 * W_e^0.82 * V^0.484 * Q2^0.641;  %manufacturing hours (structure fudge factor)
    H_Q = 0.076 * H_M; %quality control hours for cargo plane (0.133 * H_M if otherwise)

    C_D = (91.3 * W_e^0.630 * V^1.3); %development support cost 
    C_F = (2498 * W_e^0.325 * V^0.822 * FTA^1.21); %flight test cost
    C_MM = (22.1 * W_e^0.921 * V^0.621 * Q2^0.799); %Manufacturing materials cost
    C_eng = 27500000; %existing engine so we should have cost

    C_E = (H_E * R_E); %engineering cost
    C_T = (H_T * R_T); %tooling cost
    C_M = (H_M * R_M); %manufacturing cost
    C_Q = (H_Q * R_Q); %quality control cost

    %% RDT&E + Flyaway Costs for 30, 60, 90 Aircraft Over 5 Years
    RDTE = C_E + C_T + C_M + C_Q + C_D + C_F + C_MM + (C_eng * N_eng) + C_av;
    RDTE_2024 = (RDTE * (1 + cpi_total)); %Adjusted for inflation using CPI

    ac_cost_5 = RDTE_2024 / Q2; 
    ac_cost_5m = ac_cost_5 * 1.1; % 10% profit margin
    RDTE_LC1 = RDTE_2024;
    RDTE_LC2 = RDTE_2024 * (2^((log(0.75) * log(2) / log(2))));
    RDTE_LC3 = RDTE_2024 * (2^((log(0.75) * log(3) / log(2))));

    %% RDT&E + Flyaway Costs for 90, 180, 270 Aircraft Over 15 Years (Q*3)
    RDTE_2024_LC = RDTE_LC1 + RDTE_LC2 + RDTE_LC3;
    ac_cost_15 = RDTE_2024_LC / (Q2*3); 
    ac_cost_15m = ac_cost_15 * 1.1;

    % Calculate the unit cost using the ac_cost variable
    unit_cost = ac_cost_15 / 100000000;
    total_program_cost = RDTE_2024_LC / 1000000000;
    % Store the production number and unit cost in the arrays
    production_numbers(i) = Q2 * 3;
    unit_costs(i) = unit_cost;
    total_program_costs(i) = total_program_cost;

end

% Plot the production numbers against the unit costs
subplot(1,2,1)
plot(production_numbers, unit_costs);
xlabel('Number of Aircraft Produced in 15 Years (units)', 'FontSize',14);
ylabel('Unit Cost in $100 Million USD (2022)', 'FontSize',14);
title('Unit Cost Variation with Production Quantity', 'FontSize',16);
[~, idx] = min(abs(production_numbers - 180));
% Mark the point on the plot
hold on;
plot(production_numbers(idx), unit_costs(idx), 'ro'); % Mark the point in red color
% Add a label to the marked point
set(gcf, 'color', 'w');
yticks(0:1:100); % Set ticks at intervals of 10 from 0 to 100
set(gca, 'FontSize', 12); % Set font size to 12 for tick labels
text(production_numbers(idx), unit_costs(idx), ['RFP Production Point', '; Cost = ', sprintf('%.1f',(unit_costs(idx)))], 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize',12);
hold off;

subplot(1, 2, 2); % Select the second subplot
plot(production_numbers, total_program_costs);
xlabel('Number of Aircraft Produced in 15 Years (units)', 'FontSize',14);
ylabel('Program Cost in $1 Billion USD (2022)', 'FontSize', 14); % Set font size to 14 for y-axis label
title('Program Cost Variation with Production Quantity', 'FontSize', 16); % Set font size to 16 for title
hold on;
plot(production_numbers(idx), total_program_costs(idx), 'ro'); % Mark the point in red color
text(production_numbers(idx), total_program_costs(idx), ['RFP Production Point', '; Cost =', sprintf('%.0f',(total_program_costs(idx)))], 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', 'FontSize', 12); 
set(gca, 'color', 'w');
yticks('auto'); % Let MATLAB automatically determine the number of ticks
set(gca, 'FontSize', 12); % Set font size to 12 for tick labels
hold off;