function [ ] = analyzeData( time_codes, power_drawn, charging_power, battery_level, file_folder, orbit )
%ANALYZEDATA Analyze the data given and export the results
%   Detailed explanation goes here

global SIMULATION_DURATION;
global STARTING_BATTERY_CAPACITY;

% Turn off the warning saying the directory already exists (it is useless to us)
warning('off','MATLAB:MKDIR:DirectoryExists');
% Make the output folder for the data analysis files
mkdir(file_folder,'output');    

% % Export the results to a file
% file = fopen([file_folder 'output/' num2str(SIMULATION_DURATION/3600) '-instantaneous_power_draw.csv'],'w');
% fprintf(file,'Time Code (seconds), Power Drawn (watts)\n');
% for i=1:1:length(time_codes)
%     fprintf(file,'%f,%f\n',time_codes(i),power_drawn(i));
% end
% fclose(file);

% Determine the length of time codes
lngth = size(time_codes,1);

time_codes = time_codes - time_codes(1);

% Plot the data
graph1 = figure;

subplot(3,1,1);
plot(time_codes/3600,power_drawn);
title('Power drawn over time');
% xlabel('Time since simulation start (Hours)');
ylabel('Power draw (Watts)');

subplot(3,1,2);
plot(time_codes/3600,charging_power);
title('Charging Power over time');
% xlabel('Time since simulation start (Hours)');
ylabel('Charging Power (Watts)');

subplot(3,1,3);
plot(time_codes/3600,battery_level((1:lngth),1));
title('Battery Level over time');
xlabel('Time since simulation start (Hours)');
ylabel('Battery Status (Whr)');

title_text = '';
switch(orbit)
    case 1
        title_text = 'NASA Default Orbit';
    case 2
        title_text = '325x1500 with 80\circ Inclination Orbit';
    case 4
        title_text = '620 Sunsynchronous Orbit';
end

[ax4,h3]=suplabel(title_text ,'t');
set(h3,'FontSize',20)

% Save the graph as files
%saveas(graph1,[file_folder 'output/' num2str(SIMULATION_DURATION/3600) '-' num2str(STARTING_BATTERY_CAPACITY) '-instantaneous_power_draw.fig'],'fig');    % Output it so MATLAB can open it again
saveas(graph1,[file_folder 'output/' num2str(SIMULATION_DURATION/3600) '-' num2str(STARTING_BATTERY_CAPACITY) '-instantaneous_power_draw.png'],'png');    % Output it as an image for other programs

%export_data(1,:) = time_codes;
%export_data(2,:) = power_drawn;
%export_data(3,:) = battery_level(1:lngth);

%save([file_folder 'output/' num2str(SIMULATION_DURATION/3600) '-instantaneous_power_draw.mat'],'export_data');
end

