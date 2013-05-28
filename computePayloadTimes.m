function [ payload_times ] = computePayloadTimes( footprint_size )
%COMPUTEPAYLOADTIMES Compute the payload trigger times
%

global start_second;
global STEP_SIZE;
global SIMULATION_DURATION;

% Initialize the returned array
payload_times = zeros(2,2);

% The speed the satellite is travelling at
speed = 7.7; % 7.7 km/s

% Compute the time between payload activations
time_between_collections = footprint_size*(1/speed) - 3;

% The first data collection point
payload_times(1,1) = time_between_collections;
payload_times(1,2) = payload_times(1,1) + 3;

i=2;
% Compute the rest of the data collection point
while (payload_times(i-1,2) < start_second+SIMULATION_DURATION)
    payload_times(i,1) = payload_times(i-1,2) + time_between_collections;
    payload_times(i,2) = payload_times(i,1) + 3;
    i = i+1;
end

% End of the function
end