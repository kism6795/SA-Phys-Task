function count = getLastDatum(all_times, current_time)
% returns the index of the datapoint in all_times that occurs closest 
% BEFORE current_time

count = 1;
dimensionsOfTime = size(all_times);
while count <= dimensionsOfTime(1) && (all_times(count,1)*60 + all_times(count,2)) <= current_time
    count = count+1;
end
count = count-1;
if count < 1
    count = count+1;
end

end