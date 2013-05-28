function [ beacon_times ] = computeBeaconTimes( beacon_interval, beacon_duration )
%COMPUTEBEACONTIMES Compute the times the beacon is on
% The first column of the returned matrix is the start time for the beacon
% The second column of the returned matrix is the stop time for the beacon
% 

global start_second;
global SIMULATION_DURATION;

beacon_interval = beacon_interval*60;

% Initialize the returned array
beacon_times = zeros(2,2);

% The first data collection point
beacon_times(1,1) = beacon_interval;
beacon_times(1,2) = beacon_times(1,1) + beacon_duration;

i=2;
% Compute the rest of the data collection point
while (beacon_times(i-1,2) < start_second+SIMULATION_DURATION)
    beacon_times(i,1) = beacon_times(i-1,2) + beacon_interval;
    beacon_times(i,2) = beacon_times(i,1) + beacon_duration;
    i = i+1;
end

% End of the function
end

