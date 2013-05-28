function [ seconds ] = compute_seconds( date_string, date_format )
%COMPUTE_SECONDS    Compute the seconds present in a given date string
%   
%   seconds = compute_seconds(date_string, date_format)
%   This returns the seconds present in the provded date string(the string
%   must be in the provided date format
%
%   The calculations in this function only go up to months, it doesn't take
%   years into account
%
%   This is useful to perform calculations using items which require being
%   in terms of time since start. Simply use this function to compute the
%   starting seconds, and then use this function again every time to
%   compute the seconds of the time stamp. By subtracting the two you will
%   get the seconds since start
%   
%   For more information on formatting the date string, and for the format
%   specifiers, please see the "Dates and Times" page in the help browser

% Variable for the seconds value of the first date (assigned in the for
% loop)
% Get a date vector from the array
tmp_date = datevec(date_string, date_format);

% Compute the seconds
sec_temp = tmp_date(6); % Add Seconds
sec_temp = sec_temp + 60*tmp_date(5); % Add Minutes (in seconds)
sec_temp = sec_temp + 60*60*tmp_date(4); % Add Hours (in seconds)
sec_temp = sec_temp + 60*60*24*tmp_date(3); % Add Days (in seconds)
sec_temp = sec_temp + 60*60*24*(day(eomdate(tmp_date(1),tmp_date(2))))*(tmp_date(2)-1); % Add months (in seconds)

seconds = sec_temp;
end

