%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CySat power drain simulation
% This script will calculate the power drain experienced by the satelite
% over a given amount of time by determining which systems are running at
% what time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
clc;

ORBIT = 1;

switch(ORBIT)
    case 1
        % NASA Default Mission Orbit (325km x 51.6deg)
        ORBIT_DATA_LOCATION = '../OrbitData/325_DefaultOrbit/';
    case 2
        % 325x1500 km orbit
        ORBIT_DATA_LOCATION = '../OrbitData/325x1500/';
    case 4
        % 620km Sunsynchronous
        ORBIT_DATA_LOCATION = '../OrbitData/620_SunSync/';
end

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
FOOTPRINT_SIZE = 1609; 

% Simulation start point (change the date string)
start_point = compute_seconds('1/1/14 12:00 AM', 'mm/dd/yy HH:MM AM');

% Compute when the data points start
first_date_sec = compute_seconds('1/1/14 12:00 AM', 'mm/dd/yy HH:MM AM');
global start_second;
       start_second = start_point - first_date_sec;

% Interpret the orbit data files into usable data
fprintf('Reading in data...');
[downlink_time light_time] = readFileData([ORBIT_DATA_LOCATION 'coverage.csv'],[ORBIT_DATA_LOCATION 'lighting.csv']);
fprintf('Complete\n');

% Compute the power draws for the various systems
fprintf('Computing Power Draws...');
[power_draws beacon_interval beacon_duration] = PowerCalculations(ORBIT, 1);
fprintf('Complete\n\n');

fprintf('Using the orbit data located in %s.\n',ORBIT_DATA_LOCATION);
fprintf('Using a simulation length of %f seconds.\n',SIMULATION_DURATION);
fprintf('Using a step size of %f seconds.\n',STEP_SIZE);
fprintf('Using a footprint size of %f kilometers.\n',FOOTPRINT_SIZE);
fprintf('Using a beacon interval of %f minutes.\n',beacon_interval);
fprintf('Using a beacon length of %f seconds.\n',beacon_duration);
fprintf('Using an initial Battery Capacity of %f Whr\n\n',STARTING_BATTERY_CAPACITY);

% Calculate the timings for the payload
fprintf('Calculate payload timing...');
payload_time = computePayloadTimes(FOOTPRINT_SIZE);
fprintf('Complete\n');

% Calculate the timings for the beacon system
fprintf('Calculate beacon timing...');
beacon_time = computeBeaconTimes(beacon_interval, beacon_duration);
fprintf('Complete\n');

% Compute the power draw at the interval
fprintf('Computing power drains...');
[time_codes power_drawn charging_power battery_level] = power_drain(downlink_time, beacon_time, light_time, payload_time, power_draws);
fprintf('\nComplete\n');

% Interpret the calculated data, save it to a file, and export the graph
fprintf('Analyzing the data...');
analyzeData(time_codes, power_drawn, charging_power, battery_level, ORBIT_DATA_LOCATION, ORBIT);
fprintf('Complete\n');