% clear all; close all;

% get files with a UI
% start_path = '';
% start_path = uigetdir(start_path);
% files = dir([start_path '/data/*.gpx']);

% get files directly in the current directory
files = dir('data/*.gpx');
dates = {files(:).name};

% Get the date strings for the legend
new_dates = cell(length(dates),1);
for i_date = 1:length(dates)
    new_dates{i_date} = dates{i_date}(9:end-9);
end

% Set the smoothing window size
smoothLength = 20;

% Save the distance unit constants
mile = 1609.34; km = 1000;

% Initilize the handles for the plots 
h = zeros(1,length(dates));

for i_date = 1:length(dates)
    p = gpxread(['data/' dates{i_date}]);
    
    %Find and remove any unusable times
    idx = find(strcmp(p.Time, ''));
    
    if ~isempty(idx)
        p(idx) = [];
    end
    
    Lat = p.Latitude;
    Lon = p.Longitude;
    
    %% Calculate distance between two adjacent points of track line in the unit of degree
    ellipsoid = wgs84Ellipsoid;
    d = zeros(1,length(p)-1);
 
    for i=1:length(p)-1
        d(i) = distance(Lat(i),Lon(i),Lat(i+1),Lon(i+1),ellipsoid);
    end
    
    cumulative_dis = cumsum(d);
    total_dis = sum(d);
    
    %% compute the times
    timeStr = strrep(p.Time, 'T', ' ');
    timeStr = strrep(timeStr, 'Z', '');
    
    p.DateNumber = datenum(timeStr);
    day = fix(p.DateNumber(1));
    p.TimeOfDay = p.DateNumber - day;
    
    time_steps = diff(p.TimeOfDay)*60*60*24;
    speed = d./time_steps;
    time_min = (p.TimeOfDay(3:end)-p.TimeOfDay(1))*60*24;
    
    % fast smoothing with the given smoothing length
    speed_smooth = smooth(speed(2:end)*3.6,smoothLength);
    
    %% plot
       
    % Build the figure
    h(i_date) = plot(time_min,speed_smooth,'color',1-[.9 .9 .9]*  (i_date / length(dates)),'DisplayName',dates{i_date});
    hold on; xlabel('Time (minutes)'); ylabel('Speed (km/h)'); axis tight;
    
    n_km = floor(total_dis/km);
    n_mile = floor(total_dis/mile);
    
    %list of all the markers
    km_l = km*1:n_km;
    mile_l = mile*1:n_mile;
    dis_l = [km_l mile_l];
    dis_l = sort(dis_l);
    
    % loop through items in the list and draw them
    for i_mark = 1:length(dis_l); 
        if rem(dis_l(i_mark),1000) == 0
            label = 'KM';
        else
            label = 'Mile';
        end
        build_marker(i_mark,d,time_min,dis_l(i_mark),speed_smooth,label);
    end
    
       
    
end

% Add the title and legend to the plot
title(['Smooth Length: ' num2str(smoothLength) ' - Total Distance ' num2str(round(total_dis)) ' meters']);
legend(h, new_dates);

% Autosize for consistent comparison
% xlim([0 20]); ylim([4 20]);




