function [] = build_marker(marker_num,dist,times,unit,speed,marker_str,run_number,n_runs)
%BUILD_MARKERS build_marker is used to build distance markers on the plot
% Find the first point at the / or after the completion of the km
j = find(cumsum(dist)>=(unit*marker_num),1);

x_loc = times(j);

% build the marker with minutes and seconds
markers{marker_num} = [floor(x_loc) rem(times(j),1)*60];

% marker size and color
a = 200;

% KM marker coloring, Red Green Blue
co = [0 0 1;
    0 0.5 0;
    1 0 0];

% Mile coloring
co_mile = [0 0.75 0.75;
    0.75 0 0.75;
    0.75 0.75 0];

% Transparency based on run number
marker_atten = run_number/n_runs;

% add the marker
if strcmp(marker_str,'km')
    hs = scatter(x_loc,speed(j),a,co(marker_num,:),'filled');
    if ~verLessThan('matlab', 'R2014a')
        alpha(hs,marker_atten);
    end
else
    hs = scatter(x_loc,speed(j),a,co_mile(marker_num,:),'filled');
    if ~verLessThan('matlab', 'R2014a')
        alpha(hs,marker_atten);
    end
end

% add the marker text
n_min = markers{marker_num}(1);
n_sec = markers{marker_num}(2);

if n_sec < 10
    str_sec = ['0' num2str(markers{marker_num}(2))];
    str_min = num2str(n_min);
elseif n_sec > 59
    str_sec = '00';
    str_min = num2str(n_min+1);
else
    str_sec = num2str(markers{marker_num}(2));
    str_min = num2str(n_min);
end

horz_offset = {-0.2,0.2};
horz_align = {'right','left'};

text(x_loc+horz_offset{mod(run_number,2)+1},speed(j),...
    [marker_str num2str(marker_num) ' ' str_min ':' str_sec 's' ],...
    'HorizontalAlignment',horz_align{mod(run_number,2)+1},...
    'EdgeColor','black',...
    'BackgroundColor','white',...
    'FontSize',12);

% vline(x_loc)

end

