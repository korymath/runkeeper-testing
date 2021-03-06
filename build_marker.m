function [marker, split] = build_marker(marker_num,dist,times,unit,speed,...
    marker_str,run_number,n_runs,markers)
%BUILD_MARKERS build_marker is used to build distance markers on the plot
% Find the first point at the / or after the completion of the km
j = find(cumsum(dist)>=(unit*marker_num),1);

x_loc = times(j);

% build the marker with minutes and seconds
marker = [floor(x_loc) rem(times(j),1)*60];
split = marker; 

% marker size and color
a = 200;

% KM marker coloring, Red Green Blue, Yellow
co = [0 0 1;
    0 0.5 0;
    1 0 0;
    1 1 0];

% Mile coloring
co_mile = [0 0.75 0.75;
    0.75 0 0.75;
    0.75 0.75 0];


% Transparency based on run number
exp_amt = 5;
marker_atten = (((10^exp_amt) ^ (run_number/n_runs) )  /((10^exp_amt)*1.111112)+.1); 

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


if run_number == n_runs %change text edge colour
    edge_col = [0 0 0];
else
    edge_col = [.9 .9 .9];
end

if run_number >= n_runs-1  %only plot splits for last couple runs
    % add the marker text
    n_min = marker(1);
    n_sec = marker(2);
    
    % calculate the splits if this is not the first marker
    if marker_num > 1
        n_min = marker(1) - markers{marker_num-1}(1);
        n_sec = marker(2) - markers{marker_num-1}(2);
        if n_sec < 0 %since subtracting seconds and minutes separately
            n_min = n_min - 1;
            n_sec = 60 + n_sec;
        end
    end
    
    split(1) = n_min;
    split(2) = n_sec;
    
    if n_sec < 10
        str_sec = ['0' num2str(n_sec)];
        str_min = num2str(n_min);
    elseif n_sec > 59
        str_sec = '00';
        str_min = num2str(n_min+1);
        
        split(1) = split(1)+1;
        split(2) = 0;
    else
        str_sec = num2str(n_sec);
        str_min = num2str(n_min);
    end
    
    horz_offset = {-0.2,0.2};
    horz_align = {'right','left'};
    
    
    
    text(x_loc+horz_offset{mod(run_number,2)+1},speed(j),...
        [marker_str num2str(marker_num) ' ' str_min ':' str_sec 's' ],...
        'HorizontalAlignment',horz_align{mod(run_number,2)+1},...
        'EdgeColor',edge_col,...
        'BackgroundColor','white',...
        'FontSize',10);
    
end
% vline(x_loc)

end

