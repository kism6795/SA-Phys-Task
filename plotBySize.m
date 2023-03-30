% inds is the specific indices you want to pull out of all the data, like if you wanted to only do this for one subject, or if you wanted to exclude a subject you could specify all the other indices. If you just wanted to do it with all the data you could make inds = 1:length(WL_data); 

% make a 10 x 10 matrix of workload scores vs workload predictions, with the number
% of outcomes at each combination in that cell.

function ax = plotBySize(x_data, y_data)
%% count xy data
xy = -999*ones(length(x_data),length(y_data));
n = -999*ones(length(x_data),2);
count = 1;
found = 0;
for i = 1:length(x_data)
    for j = 1:length(y_data)
        
        if (xy(j,1) == x_data(i))
            found = 1;
            break;
        end
    end
    if found
        xn(j,2) = xn(j,2)+1;
    else
        xn(count,1) = x_data(i);
        xn(count,2) = 1;
        count = count+1;
    end
end
xn = xn(1:count-1,:);

% Count y_data
yn = -999*ones(length(y_data),2);
count = 1;
for i = 1:length(y_data)
    found = 0;
    for j = 1:length(y_data)
        if (yn(j,1) == y_data(i))
            found = 1;
            break;
        end
    end
    if found
        yn(j,2) = yn(j,2)+1;
    else
        yn(count,1) = y_data(i);
        yn(count,2) = 1;
        count = count+1;
    end
end
yn = yn(1:count-1,:);

%%
WL_mat = zeros(10,10);
for i = 1:length(inds)
    WL_mat(WL_data(inds(i)), WL_universal_descriptive(inds(i))) = WL_mat(WL_data(inds(i)), WL_universal_descriptive(inds(i)))+1;
end

ax = figure;
% plot the data points with the size of the marker representing the number of trials
scalefactor = 4; % how large the marker should be per observation
for j = 1:10
    for k = 1:10
        if WL_mat(j,k) > 0
            % then there was at least one outcomes at that combo of score
            % and prediction, so plot it with the marker size corresponding
            % to the number of observations
            plot(j, k, 'ko', 'MarkerSize', scalefactor*WL_mat(j,k)); hold on;
        end
    end
end
end