function [] = build_marker(marker_num,dist,times,unit,speed,marker_str)
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

% add the marker
if strcmp(marker_str,'KM')
    scatter(x_loc,speed(j),a,co(marker_num,:),'filled');
else
    scatter(x_loc,speed(j),a,co_mile(marker_num,:),'filled');
end

% add the marker text
text(x_loc,speed(j),[marker_str num2str(marker_num) ...
    ': ' num2str(markers{marker_num}(1)) ':' ...
    num2str(markers{marker_num}(2)) 's' ]);

vline(x_loc)
end

