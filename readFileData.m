function [ comm_time light_time] = readFileData(comm_file, light_file)
%readFileData Read in data used by the simulation program
%   This will read in the following data from their respective files:
%       - Light exposure times
%       - Communication windows
%       - Power draws for spacecraft systems

%%
% Read in and convert the lighting data into seconds since 1/1/14 12:00 AM

% Open the lighting data
lighting_data = importdata(light_file,',');

% Create the array for the converted lighting values
light_time = zeros(1,1);

% Compute the seconds of the first point
first_date_sec = compute_seconds('1/1/14 12:00 AM', 'mm/dd/yy HH:MM AM');

% Convert the first column of the array into seconds since 1/1/14 12:00 AM
for i=1:1:length(lighting_data.textdata(:,1))-1
    % Store the seconds since the first value in the array
    light_time(i,1) = compute_seconds(lighting_data.textdata(i+1,1), 'mm/dd/yy HH:MM AM') - first_date_sec;
end

% Convert the second column of the array into seconds since 1/1/14 12:00 AM
for i=1:1:length(light_time)
    % Store the end of the light time in the second column of the array
    light_time(i,2) = light_time(i,1) + lighting_data.data(i);
end

%%
% Read in and convert the communication window data into seconds since 1/1/14 12:00 AM
%

% Open the communications data
comm_data = importdata(comm_file,',');

% Create the array for the converted communications values
comm_time = zeros(1,1);

% Compute the seconds of the first point
first_date_sec = compute_seconds('1/1/2014 0:00', 'mm/dd/yyyy HH:MM');

% Convert the first column of the array into seconds since 1/1/2014 12:00
for i=1:1:length(comm_data.textdata(:,1))-1
    % Store the seconds since the first value in the array
    comm_time(i,1) = compute_seconds(comm_data.textdata(i+1,1), 'mm/dd/yyyy HH:MM') - first_date_sec;
end

% Convert the second column of the array into seconds since 1/1/2014 12:00
for i=1:1:length(comm_time)
    % Store the end of the light time in the second column of the array
    comm_time(i,2) = comm_time(i,1) + comm_data.data(i);
end

% Function end
end

