clear all
close all


% get files
% start_path = '';
% start_path = uigetdir(start_path);
files = dir([start_path '*.gpx']);
dates = {files(:).name};

smoothLength = 40;
for i_date = 1:length(dates)
    p = gpxread(['' dates{i_date}]);
    Lat = p.Latitude;
    Lon = p.Longitude;
    
    %% Calculate distance between two adjacent points of track line in the unit of
    %degree
    ellipsoid = wgs84Ellipsoid;
    d = [];
    arclen = [];
    for i=1:length(p)-1
        arclen(i) = distance(Lat(i),Lon(i),Lat(i+1),Lon(i+1));
        d(i) = distance(Lat(i),Lon(i),Lat(i+1),Lon(i+1),ellipsoid);
    end
    
    %cumulative_dis = cumsum(d)
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
    
    
    %smooth
    speed_smooth = smooth(speed(2:end)*3.6,smoothLength);
    
    %% plot
    mile = 1609.34;
    km = 1000;
    
    h(i_date) =  plot(time_min,speed_smooth,'color',1-[.9 .9 .9]*  (i_date / length(dates)),'DisplayName',dates{i_date});
    hold on
    xlabel('Time (minutes)');
    ylabel('Speed (km/h)');
    axis tight;
    
    %mark first km
    j = find(cumsum(d)>=km,1);
    first_km = [floor( time_min(j)) rem(time_min(j),1)*60];
    scatter(time_min(j),speed_smooth(j));
    text(time_min(j),speed_smooth(j),['KM ' num2str(first_km(1)) ':' num2str(first_km(2)) ]);
    
    %mark first mile
    if total_dis > mile ;
        i = find(cumsum(d)>=mile,1);
        first_mile = [floor( time_min(i)) rem(time_min(i),1)*60];
        if time_min(i) < 20
            scatter(time_min(i),speed_smooth(i));
            text(time_min(i),speed_smooth(i),['Mile ' num2str(first_mile(1)) ':' num2str(first_mile(2)) ]);
        end
    end
    
    %mark second KM
    if total_dis > km*2 ;
        k = find(cumsum(d)>=km*2,1);
        second_km = [floor( time_min(k)) rem(time_min(k),1)*60];
        if time_min(k) < 20
            scatter(time_min(k),speed_smooth(k));
            text(time_min(k),speed_smooth(k),['KM2 ' num2str(second_km(1)) ':' num2str(second_km(2)) ]);
        end
    end
    
    %mark second Mile
    if total_dis > mile*2 ;
        l = find(cumsum(d)>=mile*2,1);
        second_mile = [floor( time_min(l)) rem(time_min(l),1)*60];
        if time_min(l) < 20
            scatter(time_min(l),speed_smooth(l));
            text(time_min(l),speed_smooth(l),['Mile2 ' num2str(second_mile(1)) ':' num2str(second_mile(2)) ]);
        end
    end
    
    %mark third KM
    if total_dis > km*3 ;
        m = find(cumsum(d)>=km*3,1);
        third_km = [floor( time_min(m)) rem(time_min(m),1)*60];
        if time_min(m) < 20
            scatter(time_min(m),speed_smooth(m));
            text(time_min(m),speed_smooth(m),['KM3 ' num2str(third_km(1)) ':' num2str(third_km(2)) ]);
        end
    end
    
    title(['Smooth Length: ' num2str(smoothLength) ' - Total Distance ' num2str(round(total_dis)) ' meters']);
    xlim([0 20]);
    ylim([4 20]);
end

for i_date = 1:length(dates)
  temp = dates{i_date};
  new_dates{i_date} = temp(9:end-9);
end
legend(h(1:length(dates)), new_dates);


%
%     end
%
% end