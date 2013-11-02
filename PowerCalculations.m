function [power_draws com_beacon_interval com_beacon_length] = PowerCalculations(orbit, display)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Orbit Information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch(orbit)
    case 1
        orbit_name = 'Orbit 1';
        orbit_period = 90; % Minutes
        orbit_light_time = 49; % Minutes
        orbit_coverage_time = 10; % Minutes
    case 2
        orbit_name = 'Orbit 2';
        orbit_period = 103; % Minutes
        orbit_light_time = 66; % Minutes
        orbit_coverage_time = 23; % Minutes
    case 4
        orbit_name = 'Orbit 4';
        orbit_period = 97; % Minutes
        orbit_light_time = 97; % Minutes
        orbit_coverage_time = 13; % Minutes
end

orbit_rad_runs = floor(orbit_period/(209/60));  % Minutes
orbit_dark_time = orbit_period - orbit_light_time; % Minutes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Electrical Characteristics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Motherboard Characteristics
mb_Vcc = 5.5;
mb_Ityp = 500E-6;
mb_Isleep = 5E-6;
mb_runtime = 1; % Full hour

% PPM Characteristics
ppm_Vcc = 3.3;
ppm_Ityp = 20E-3;
ppm_Isleep = 100E-9;    % 100 nanoWatts
ppm_runtime = 1; % Full hour

% Communications Characteristics
com_downlink_Vcc = 7.06;
com_downlink_Vtyp = 3.3;
com_downlink_Itransmit = 330E-3; % 730mA
com_downlink_Ityp = 100E-3; % 80mA

com_beacon_Vcc = 7.15;
com_beacon_Itransmit = 85E-3; % 85 mA
com_beacon_Ityp = 0; % The beacon is now part of the normal radio
com_beacon_length = 2; % 2 seconds
com_beacon_interval = 418/60;    % 418 seconds

% EPS Characteristics
eps_power_typ = 0.25;
eps_power_heat = 0.25;
eps_runtime = 1;

% Payload Characteristics
rad_Vcc = 3.3;
rad_I = 30E-3;
%rad_Ptyp = 75E-3;
rad_num = 3;
rad_runtime = 1/3600;    % 1 second
rad_runs = 17; % Per Hour

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Perform the power calculations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Motherboard Power
mb_power_typ = mb_Ityp*mb_Vcc;
mb_power_sleep = mb_Isleep*mb_Vcc;

% PPM Power
ppm_power_typ = ppm_Ityp*ppm_Vcc;
ppm_power_sleep = ppm_Isleep*ppm_Vcc;

% Payload Power
pay_power = (rad_I*rad_Vcc);

% Communications Power
com_power_downlink = com_downlink_Vcc*com_downlink_Itransmit;
com_power_beacon = com_beacon_Vcc*com_beacon_Itransmit;
com_power_typ = (com_beacon_Vcc*com_beacon_Ityp)+(com_downlink_Vtyp*com_downlink_Ityp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solar Cell Information
%
% Assuming each side has 50% solar cell coverage (50 cm^2 OR 0.005 m^2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cell_max_generation = 1.65; % Watts
cell_efficiency = 1.0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute per-orbit power data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
orbit_mb_power = mb_power_typ*(orbit_period/60);    % Motherboard consumption
orbit_ppm_power = ppm_power_typ*(orbit_period/60);  % PPM Consumption

orbit_downlink_power = com_power_downlink*(orbit_coverage_time/60);                          % Consumption for downlinking
orbit_beacon_power = com_power_beacon*(com_beacon_length/60)*(orbit_period/com_beacon_interval);  % Consumption for the beacon
orbit_com_transient = com_power_typ*(orbit_period-orbit_coverage_time)/60;                   % Consumption for standby
orbit_com_total = orbit_downlink_power + orbit_beacon_power + orbit_com_transient;           % Total draw from coms system

orbit_eps_heat = eps_power_heat*(orbit_dark_time/60);        % Total draw with heaters (no sun)
orbit_eps_nonheat = eps_power_typ*(orbit_light_time/60);     % total draw without heaters (sun)
orbit_eps_total = orbit_eps_heat+orbit_eps_nonheat;          %Total EPS draw over orbit

orbit_pay_power = rad_num*pay_power*rad_runtime*orbit_rad_runs; % Total paylod power draw

orbit_downlink_draw = orbit_mb_power + orbit_ppm_power + orbit_downlink_power + orbit_beacon_power + orbit_com_transient + orbit_eps_total + orbit_pay_power; % Total downlink orbit power draw
orbit_normal_draw = orbit_mb_power + orbit_ppm_power + orbit_beacon_power + orbit_com_transient + orbit_eps_total + orbit_pay_power; % Total normal orbit power draw

orbit_solar_charge = cell_max_generation*cell_efficiency*orbit_light_time/60;

orbit_net_downlink_power = orbit_solar_charge-orbit_downlink_draw;
orbit_net_normal_power = orbit_solar_charge-orbit_normal_draw;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(display == 1)

    fprintf('Power Draws (Watts):\n\n')
    fprintf('Motherboard:\n');
    fprintf('Typical Power Draw: %f\n', mb_power_typ);
    fprintf('Sleep Power Draw: %f\n\n', mb_power_sleep);
    
    fprintf('PPM:\n');
    fprintf('Typical Power Draw: %f\n', ppm_power_typ);
    fprintf('Sleep Power Draw: %f\n\n', ppm_power_sleep);

    fprintf('Communications:\n');
    fprintf('Downlink Power Draw: %f\n', com_power_downlink);
    fprintf('Beacon Power Draw: %f\n', com_power_beacon);
    fprintf('Typical Power Draw: %f\n\n', com_power_typ);
    
    fprintf('EPS:\n');
    fprintf('Typical Power Draw: %f\n', eps_power_typ);
    fprintf('Maximum Power Draw: %f\n\n', eps_power_heat);
    
    fprintf('Payload:\n');
    fprintf('Typical Power Draw (one run):%f\n', pay_power);
    
    % display the power draw in terms of the battery and the orbit
    
    fprintf('Power Draws (Watt-hours) for the %s orbit:\n\n', orbit_name);
    fprintf('Processing:\n');
    fprintf('Motherboard Power Draw: %f\n', orbit_mb_power);
    fprintf('Pluggable Processing Module Power Draw: %f\n\n', orbit_ppm_power);
    
    fprintf('Communications:\n');
    fprintf('Downlink Power Draw: %f\n', orbit_downlink_power);
    fprintf('Beacon Power Draw: %f\n', orbit_beacon_power);
    fprintf('Typical Power Draw: %f\n', orbit_com_transient);
    fprintf('Total Power Draw: %f\n\n', orbit_com_total);
    
    fprintf('EPS:\n');
    fprintf('Non-heat Power Draw: %f\n', orbit_eps_nonheat);
    fprintf('Heat Power Draw: %f\n', orbit_eps_heat);
    fprintf('Total Power Draw: %f\n\n', orbit_eps_total);
    
    fprintf('Payload:\n');
    fprintf('Power Draw: %f\n\n', orbit_pay_power);
    
    fprintf('Total Downlink Orbit Power Draw: %f Watt-hours\n', orbit_downlink_draw);
    fprintf('Total Charging Power: %f Watt-hours\n', orbit_solar_charge);
    fprintf('Net Downlink Orbit Power Draw: %f Watt-hours\n\n', orbit_net_downlink_power);
    
    fprintf('Total Normal Orbit Power Draw: %f Watt-hours\n', orbit_normal_draw);
    fprintf('Total Charging Power: %f Watt-hours\n', orbit_solar_charge);
    fprintf('Net Normal Orbit Power Draw: %f Watt-hours\n', orbit_net_normal_power);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return the power draws in an array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

power_draws.mb_power_typ = mb_power_typ;
power_draws.mb_power_sleep = mb_power_sleep;
power_draws.ppm_power_typ = ppm_power_typ;
power_draws.ppm_power_sleep = ppm_power_sleep;
power_draws.com_power_beacon = com_power_beacon;
power_draws.com_power_downlink = com_power_downlink;
power_draws.com_power_typ = com_power_typ;
power_draws.eps_power_typ = eps_power_typ;
power_draws.eps_power_heat = eps_power_heat;
power_draws.pay_power = pay_power;
power_draws.cell_power = cell_max_generation*cell_efficiency;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Write the power draw to a file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file = fopen(output_file,'w');
% 
% fprintf(file,'mb_power_typ,%f\n',mb_power_typ);
% fprintf(file,'mb_power_sleep,%f\n',mb_power_sleep);
% fprintf(file,'ppm_power_typ,%f\n',ppm_power_typ);
% fprintf(file,'ppm_power_sleep,%f\n',ppm_power_sleep);
% fprintf(file,'com_power_downlink,%f\n',com_power_downlink);
% fprintf(file,'com_power_typ,%f\n',com_power_typ);
% fprintf(file,'eps_power_typ,%f\n',eps_power_typ);
% fprintf(file,'eps_power_heat,%f\n',eps_power_heat);
% fprintf(file,'pay_power,%f\n',pay_power);
% 
% fclose(file);

end
