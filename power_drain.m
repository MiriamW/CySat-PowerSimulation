function [ time_codes power_drain charging_power battery_level] = power_drain(downlink_time, beacon_time, light_time, payload_time, power_draw )
%POWER_DRAIN Compute the satelite power drain
%   This will actually perform the calculations for the power draw at
%   various time intervals

% Global variables to define simulation time parameters
global SIMULATION_DURATION;
global STEP_SIZE;
global BATTERY_CAPACITY;
global STARTING_BATTERY_CAPACITY;
global start_second;
global DATA_POINTS;

data_counter = 1;
power_drain = zeros(DATA_POINTS,1);
time_codes = zeros(DATA_POINTS,1);
charging_power = zeros(DATA_POINTS,1);
battery_level = zeros(DATA_POINTS+1,1);
battery_level(1) = STARTING_BATTERY_CAPACITY; % Battery capacity

lastLight = 1;
lastDownlink = 1;
lastBeacon = 1;
lastPayload = 1;

display_counter = 1;

fprintf('\n');
% Actually run the calculations
for current_time=start_second:STEP_SIZE:(start_second+SIMULATION_DURATION)
    % Place a period on the screen every so often to show we are still
    % working
    if mod(current_time,3600) == 0
        fprintf('.\n%u',display_counter);
        display_counter = display_counter + 1;
    elseif mod(current_time,60) == 0
        fprintf('.');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determine the simulation parameters for this step
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Determine if light is present during this time step
    i = lastLight;
    isLight = false;
    while (i<=length(light_time))
        if (light_time(i,1) <= current_time) && (current_time <= light_time(i,2))
            isLight = true;  % Set the starting index
            lastLight = i;
            break;  % break out of the while loop
        elseif (current_time < light_time(i,2))
            break;
        end
        i = i+1;
    end
    
    % Determine if downlink radio is needed during this time step
    i = lastDownlink;
    isDownlink = false;
    while (i<=length(downlink_time))
        if (downlink_time(i,1) <= current_time) && (current_time <= downlink_time(i,2))
            isDownlink = true;  % Set the starting index
            lastDownlink = i;
            break;  % break out of the while loop
        elseif (current_time < downlink_time(i,2))
            break;
        end
        i = i + 1;
    end
    
    % Determine if beacon radio is needed during this time step
    i = lastBeacon;
    isBeacon = false;
    while (i<=length(beacon_time))
        if (beacon_time(i,1) <= current_time) && (current_time <= beacon_time(i,2))
            isBeacon = true;  % Set the starting index
            lastBeacon = i;
            break;  % break out of the while loop
        elseif (current_time < beacon_time(i,2))
            break;
        end
        i = i + 1;
    end
    
    % Determine if the payload is needed during this time step
    i = lastPayload;
    isPayload = false;
    while (i<=length(payload_time))
        if (payload_time(i,1) <= current_time) && (current_time <= payload_time(i,2))
            isPayload = true;  % Set the starting index
            lastPayload = i;
            break;  % break out of the while loop
        elseif (current_time < payload_time(i,2))
            break;
        end
        i = i + 1;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute the power drawn by the system
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    power_drawn = 0;
    
    % The EPS power draw
    if isLight == true
        % Normal power draw
        power_drawn = power_drawn + power_draw.eps_power_typ;
        
        % Solar cells are exposed to light
        charge_power = power_draw.cell_power*1.27; % The average power is 1.27 of a single cell
    else
        % Heaters running
        power_drawn = power_drawn + power_draw.eps_power_heat;
        charge_power = 0;
    end
        
    % Have full system if there is at least half the battery
    if (battery_level(data_counter) > 0)
        % The power draw which is always present
        power_drawn = power_draw.ppm_power_typ + power_draw.mb_power_typ;
        
        % RF Circuitry logic
        if isPayload == true
            % Taking a payload measurement has priority over transmitting
            power_drawn = power_drawn + power_draw.pay_power + power_draw.com_power_typ;
        elseif isDownlink == true
            % Downlinking data has priority over the beacon
            power_drawn = power_drawn + power_draw.com_power_downlink + power_draw.com_power_typ;
        elseif isBeacon == true
            % Beacon
            power_drawn = power_drawn + power_draw.com_power_beacon + power_draw.com_power_typ;
        else
            % Normal power draw from radios
            power_drawn = power_drawn + power_draw.com_power_typ;
        end
    else 
        power_drawn = 0.000028 + 0.22;  % Sleep power draws
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute battery level for next step
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    batt = battery_level(data_counter) - (power_drawn*STEP_SIZE/3600) + (charge_power*STEP_SIZE/3600);
    
    % Cap the battery capacity at 100 percent of full or at zero.
    if(batt < 0)
        batt = 0;
    elseif (batt > BATTERY_CAPACITY)
        batt = BATTERY_CAPACITY;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Store calculated data in the returned arrays
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Save the calculated information in the returned arrays
    time_codes(data_counter) = current_time;
    power_drain(data_counter) = power_drawn;
    battery_level(data_counter + 1) = batt;
    charging_power(data_counter) = charge_power;
    
    % Increment the counted for the data slot
    data_counter = data_counter + 1;
end

% Function end
end

