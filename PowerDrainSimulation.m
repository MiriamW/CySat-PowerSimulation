%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CySat power drain simulation
% This script will calculate the power drain experienced by the satelite
% over a given amount of time by determining which systems are running at
% what time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
clc;


%% Global Variables used in the entire script
% Step size of the simulation - in seconds (how much time between data points)
global STEP_SIZE;
       STEP_SIZE = 1;

% Duration of simulation in seconds
global SIMULATION_DURATION;
       SIMULATION_DURATION = 60*60*24;  % one day
       
global BATTERY_CAPACITY;
       BATTERY_CAPACITY = 20; % 20 Whr - Full Battery

global STARTING_BATTERY_CAPACITY;
       STARTING_BATTERY_CAPACITY = 20;   % Full battery
%       STARTING_BATTERY_CAPACITY = 0;    % Empty battery
       
% Number of data points present in the simulation
global DATA_POINTS;
       DATA_POINTS = ceil(SIMULATION_DURATION/STEP_SIZE);
       
% Footprint size in kilometers (the distance between payload activations)
global FOOTPRINT_SIZE;
       FOOTPRINT_SIZE = 1609;
       
% The speed the satellite is travelling at
global SATELLITE_SPEED;       
       SATELLITE_SPEED = 7.7; % 7.7 km/s


%% Miscellaneous variables used in other places throughout the script

% Array containing the power output of each side
%
% Column 1 = Wattage per cell
% Column 2 = Cells per side
% Column 3 = Total wattage of side
solarArray = [2.017, 1;     % Side 1 (Left of diagnostics panel when viewed)
              0.737, 6;     % Side 2 (Diagnostics Port)
              2.017, 1;     % Side 3 (Right of diagnostics panel when viewed)
              2.017, 1;     % Side 4 (Opposite Diagnostics Port)
              0.737, 6;     % Side 5 (Top)
              2.017, 1];    % Side 6 (Bottom)
solarArray(:,3) = solarArray(:,1).*solarArray(:,2);

% Angular position of the center of the diagnostic panel of the satellite
% Assume the satellite is sitting with top up and a right-handed coordinate
% system has been superimposed over it.
%
% Column 1 = Position in the XY Plane
% Column 2 = Position in the XZ Plane
angularPosition = [0, 0];

% The speed at which the panel is rotating (same column order as above)
angularSpeed = [0, 0];


%% Construct the orbit data information
fprintf('Gathering Orbit Data...');
% Prompt the user for the location of the orbit data
%orbitData.path = uigetdir(pwd ,'Select Orbit Data Location');
orbitData.path = '/home/imcinerney/Dropbox/CySAT/Simulations/OrbitData/325_DefaultOrbit';

% Create the file paths to the data files
orbitData.coveragePath = [orbitData.path '/coverage.csv'];
orbitData.lightingPath = [orbitData.path '/lighting.csv'];
orbitData.informationPath = [orbitData.path '/OrbitData.txt'];

% Interpret the coverage and lighting times files into usable data
[orbitData.downlinkTimes, orbitData.lightTimes] = readFileData(orbitData.coveragePath,orbitData.lightingPath);

% Interpret the orbit data file
orbitFactsFile = fopen(orbitData.informationPath);
line = fgets(orbitFactsFile);
while ischar(line)
    if ((line(1) == '#') || (line(1) == 13) || (line(1) == 10))
        % ignore the line because it is either a comment or a blank line
    else
        data = textscan(line, '%s = %q');
        switch(cell2mat(data{1}))
            case 'name'
                orbitData.name = cell2mat(data{2});
            case 'semiAxis'
                orbitData.semiAxis = str2double(data{2});
            case 'period'
                orbitData.period = str2double(data{2});
            case 'lightTime'
                orbitData.lightTime = str2double(data{2});
            case 'lightPercentage'
                orbitData.lightPercentage = str2double(data{2});
            case 'coverageTime'
                orbitData.coverageTime = str2double(data{2});
            otherwise
                error('Unknown orbit information identifier!');
        end
    end
    line = fgets(orbitFactsFile);
end
fclose(orbitFactsFile);

orbitData.darkTime = orbitData.period - orbitData.lightTime;
fprintf('Complete\n');


%% Construct the timing structure (to say how often things run)
% First 
      

%% Compute the power draws for the various systems
fprintf('Computing Power Draws...');
[powerDraws timing] = PowerCalculations(orbitData, 1);
fprintf('Complete\n\n');


%% Display simulation parameters to the user
fprintf('Using the orbit data located in %s.\n',ORBIT_DATA_LOCATION);
fprintf('Using a simulation length of %f seconds.\n',SIMULATION_DURATION);
fprintf('Using a step size of %f seconds.\n',STEP_SIZE);
fprintf('Using a footprint size of %f kilometers.\n',FOOTPRINT_SIZE);
fprintf('Using a beacon interval of %f minutes.\n',beacon_interval);
fprintf('Using a beacon length of %f seconds.\n',beacon_duration);
fprintf('Using an initial Battery Capacity of %f Whr\n\n',STARTING_BATTERY_CAPACITY);


%%
% Simulation start point (change the date string)
startPoint = compute_seconds('1/1/14 12:00 AM', 'mm/dd/yy HH:MM AM');

% Compute when the data points start
firstDateSec = compute_seconds('1/1/14 12:00 AM', 'mm/dd/yy HH:MM AM');
global start_second;
       start_second = startPoint - firstDateSec;

% Calculate the timings for the payload
fprintf('Calculate payload timing...');
payloadTime = computePayloadTimes(FOOTPRINT_SIZE);
fprintf('Complete\n');

% Calculate the timings for the beacon system
fprintf('Calculate beacon timing...');
beaconTime = computeBeaconTimes(beaconInterval, beaconDuration);
fprintf('Complete\n');

% Compute the power draw at the interval
fprintf('Computing power drains...');
[timeCodes powerDrawn chargingPower batteryLevel] = power_drain(downlinkTime, beaconTime, lightTime, payloadTime, powerDraws);
fprintf('\nComplete\n');

% Interpret the calculated data, save it to a file, and export the graph
fprintf('Analyzing the data...');
analyzeData(time_codes, power_drawn, charging_power, battery_level, orbitData);
fprintf('Complete\n');