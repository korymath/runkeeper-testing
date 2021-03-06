clear variables; close all;
start_path = 'data/';

% get files directly in the current directory
files = dir([start_path '*.gpx']);
dates = {files(:).name};
n_dates = length(dates);

% Get the date strings for the legend
new_dates = cell(length(dates),1);
for i_date = 1:length(dates)
    new_dates{i_date} = dates{i_date}(9:end-9);
end

% Set the smoothing window size
smoothLength = 100;

% Save the distance unit constants
mile = 1609.34; km = 1000;

% Initilize the figure and handles for the plots 
hf = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(4,4,1:8);
h = zeros(1,n_dates);

for i_date = 1:n_dates
       % Output the file date
    disp(['Processing File: ' start_path dates{i_date}]);
    
    p = gpxread([start_path dates{i_date}]);
    
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
    
    %     arclen = [];
    
    for i=1:length(p)-1
        %         arclen(i) = distance(Lat(i),Lon(i),Lat(i+1),Lon(i+1));
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
    exp_amt = 5;
    h(i_date) = plot(time_min,speed_smooth,'color',1-[.9 .9 .9]*  (((10^exp_amt) ^ (i_date/n_dates) )  /((10^exp_amt)*1.111112)+.1),'DisplayName',dates{i_date},'LineWidth',2);
    hold on; xlabel('Time (minutes)'); ylabel('Speed (km/h)'); axis tight;
    
    n_km = floor(total_dis/km);
    n_mile = floor(total_dis/mile);
    
    % Build completed markers
    i = 1;
    
    % Init a cell array to keep track of marker positions
    markers = cell(n_km+n_mile,1);
    splits = cell(n_km+n_mile,1);
    
    while (i <= n_km || i <= n_mile)
        
        if i <= n_km
            [markers{i,1}, splits{i,1}] = build_marker(i,d,time_min,km,speed_smooth,'km',i_date,n_dates,markers);
        end
        
        if i <= n_mile
            [markers{i+n_km,1}, splits{i+n_km,1}] = build_marker(i,d,time_min,mile,speed_smooth,'mile',i_date,n_dates,markers);
        end
        i = i + 1;
    end
    
    
    %save splits
    for j=1:n_km+n_mile
        out_splits(j,i_date) = (splits{j}(1)*60)+ splits{j}(2);
    end
    

 
end





%%


intervals = {'KM1','Mile1','KM2','KM3','Mile2','KM4','Mile3'};
for k = 1:size(out_splits,1)
    subplot(4,4,8+k);
    plot(1:n_dates,out_splits(k,:)/60);
    title([intervals{k} ' Splits']);
    ylabel('Minutes');
end
    
%% Add the title and legend to the plot
% title(['Last Run Distance: ' num2str(round(total_dis)) ' m']);
% [legh,objh,outh,outm] = legend(h, new_dates,'Location','EastOutside');
% set(objh,'linewidth',5);
% set(gca,'FontSize',24);

% Autosize for consistent comparison
% xlim([0 20]); ylim([4 20]);




