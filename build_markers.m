function [] = build_markers(marker_num,dist,times,unit,speed,marker_str)
%BUILD_MARKERS Build markers is used to build distance markers on the plot
    % Find the first point at the / or after the completion of the km
    j = find(cumsum(dist)>=(unit*marker_num),1);

    % build the marker with minutes and seconds
    markers{marker_num} = [floor(times(j)) rem(times(j),1)*60];

    % add the marker
    scatter(times(j),speed(j));

    % add the marker text
    text(times(j),speed(j),[marker_str num2str(marker_num) ...
        ': ' num2str(markers{marker_num}(1)) ':' ...
        num2str(markers{marker_num}(2)) 's' ]);
end

