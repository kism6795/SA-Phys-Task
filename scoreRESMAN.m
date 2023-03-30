function sa_scores = scoreRESMAN(response_data, rate_data, resman_data, sa_scores, flow_rates, trial_num)
%{
in response_data:
1 = yes
2 = no
%}
%for i = 1:length(rate_data.times)
    i = trial_num;
    current_pump_status = getPumpStatus(rate_data.times(i,:), resman_data.times, resman_data.pumps, resman_data.actions);
    current_fuel_levels = getFuelLevels(rate_data.times(i,:), resman_data.times, resman_data.fuel_levels, current_pump_status, flow_rates);
    
    %% LEVEL 1 Questions
    if ~isempty(response_data.QID19{i})
        % Is pump 1 turned on?
        if str2num(response_data.QID19{i}) == 1 && current_pump_status(1) == 1
            % correct if 'yes' and 'on'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID19{i}) == 2 && current_pump_status(1) == 0
            % correct if 'no' and 'off'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID19{i}) == 2 && current_pump_status(1) == 2
            % correct if 'no' and 'failed'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end
    
    if ~isempty(response_data.QID20{i})
        % Is pump 2 turned off?
        if str2num(response_data.QID20{i}) == 1 && current_pump_status(2) == 0
            % correct if 'yes' and 'off'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID20{i}) == 2 && current_pump_status(2) == 1
            % correct if 'no' and 'on'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID20{i}) == 2 && current_pump_status(2) == 2
            % correct if 'no' and 'failed'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end

    if ~isempty(response_data.QID21{i})
        % Is pump 3 currently failed?
        if str2num(response_data.QID21{i}) == 1 && current_pump_status(3) == 2
            % correct if 'yes' and 'failed'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID21{i}) == 2 && current_pump_status(3) == 1
            % correct if 'no' and 'on'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID21{i}) == 2 && current_pump_status(3) == 0
            % correct if 'no' and 'off'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end    

    if ~isempty(response_data.QID22{i})
        % Is pump 4 turned on?
        if str2num(response_data.QID22{i}) == 1 && current_pump_status(4) == 1
            % correct if 'yes' and 'on'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID22{i}) == 2 && current_pump_status(4) == 0
            % correct if 'no' and 'off'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID22{i}) == 2 && current_pump_status(4) == 2
            % correct if 'no' and 'failed'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end
    
    if ~isempty(response_data.QID23{i})
        % Is pump 5 turned off?
        if str2num(response_data.QID23{i}) == 1 && current_pump_status(5) == 0
            % correct if 'yes' and 'off'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID23{i}) == 2 && current_pump_status(5) == 1
            % correct if 'no' and 'on'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID23{i}) == 2 && current_pump_status(5) == 2
            % correct if 'no' and 'failed'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end

    if ~isempty(response_data.QID24{i})
        % Is pump 6 currently failed?
        if str2num(response_data.QID24{i}) == 1 && current_pump_status(6) == 2
            % correct if 'yes' and 'failed'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID24{i}) == 2 && current_pump_status(6) == 1
            % correct if 'no' and 'on'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID24{i}) == 2 && current_pump_status(6) == 0
            % correct if 'no' and 'off'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end        
    
    if ~isempty(response_data.QID25{i})
        % Is pump 7 turned on?
        if str2num(response_data.QID25{i}) == 1 && current_pump_status(7) == 1
            % correct if 'yes' and 'on'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID25{i}) == 2 && current_pump_status(7) == 0
            % correct if 'no' and 'off'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID25{i}) == 2 && current_pump_status(7) == 2
            % correct if 'no' and 'failed'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end
    
    if ~isempty(response_data.QID26{i})
        % Is pump 8 turned off?
        if str2num(response_data.QID26{i}) == 1 && current_pump_status(8) == 0
            % correct if 'yes' and 'off'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID26{i}) == 2 && current_pump_status(8) == 1
            % correct if 'no' and 'on'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID26{i}) == 2 && current_pump_status(8) == 2
            % correct if 'no' and 'failed'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end
    
    if ~isempty(response_data.QID27{i})
        % Is the fuel level of tank A below 2000?
        if str2num(response_data.QID27{i}) == 1 && current_fuel_levels(1) <= 2000
            % correct if 'yes' and 'below 2000'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID27{i}) == 2 && current_fuel_levels(1) >= 2000
            % correct if 'no' and 'above 2000'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end
    
    if ~isempty(response_data.QID28{i})
        % Is the fuel level of tank B above 3000?
        if str2num(response_data.QID28{i}) == 1 && current_fuel_levels(2) >= 3000
            % correct if 'yes' and 'above 3000'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID28{i}) == 2 && current_fuel_levels(2) <= 3000
            % correct if 'no' and 'below 3000'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end
    
    if ~isempty(response_data.QID29{i})
        % Is the fuel level of tank C above 800?
        if str2num(response_data.QID29{i}) == 1 && current_fuel_levels(3) >= 800
            % correct if 'yes' and 'above 800'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID29{i}) == 2 && current_fuel_levels(3) <= 800
            % correct if 'no' and 'below 800'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end

    if ~isempty(response_data.QID30{i})
        % Is the fuel level of tank D below 800?
        if str2num(response_data.QID30{i}) == 1 && current_fuel_levels(4) <= 800
            % correct if 'yes' and 'below 800'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        elseif str2num(response_data.QID30{i}) == 2 && current_fuel_levels(4) >= 800
            % correct if 'no' and 'above 800'
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end

    if ~isempty(response_data.QID31{i})
        % Is the flow rate for pump 1 above 700 (when switched on)?
        if str2double(response_data.QID31{i}) == 1
            % correct if 'yes' (P1 = 1000)
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end
    
    if ~isempty(response_data.QID32{i})
        % Is the flow rate for pump 2 above 600 (when switched on)?
        if str2double(response_data.QID32{i}) == 2
            % correct if 'no' (P2 = 500)
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end
    
    if ~isempty(response_data.QID33{i})
        % Is the flow rate for pump 3 below 700 (when switched on)?
        if str2double(response_data.QID33{i}) == 2
            % correct if 'no' (P3 = 800)
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end
    
    if ~isempty(response_data.QID34{i})
        % Is the flow rate for pump 4 below 600 (when switched on)?
        if str2double(response_data.QID34{i}) == 1
            % correct if 'yes' (P4 = 400)
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end
    
    if ~isempty(response_data.QID35{i})
        % Is the flow rate for pump 5 above 400 (when switched on)?
        if str2double(response_data.QID35{i}) == 1
            % correct if 'yes' (P5 = 500)
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end
    
    if ~isempty(response_data.QID36{i})
        % Is the flow rate for pump 6 below 400 (when switched on)?
        if str2double(response_data.QID36{i}) == 2
            % correct if 'no' (P6 = 500)
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end
    
    if ~isempty(response_data.QID37{i})
        % Is the flow rate for pump 7 above 700 (when switched on)?
        if str2double(response_data.QID37{i}) == 2
            % correct if 'no' (P7 = 700)
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end
    
    if ~isempty(response_data.QID38{i})
        % Is the flow rate for pump 8 above 700 (when switched on)?
        if str2double(response_data.QID38{i}) == 1
            % correct if 'yes' (P8 = 800)
            sa_scores(i,1) = sa_scores(i,1) + 1;    % level 1 SA
        else
            %incorrect
        end
    end
%% LEVEL 2 Questions    
    pumps_on = current_pump_status == 1;
    flow_A = pumps_on(1)*flow_rates(1) + pumps_on(2)*flow_rates(2) + pumps_on(8)*flow_rates(8) - pumps_on(7)*flow_rates(7) - 800;
    flow_B = pumps_on(3)*flow_rates(3) + pumps_on(4)*flow_rates(4) + pumps_on(7)*flow_rates(7) - pumps_on(8)*flow_rates(8) - 800;
    flow_C = pumps_on(5)*flow_rates(5) - pumps_on(1)*flow_rates(1);
    flow_D = pumps_on(6)*flow_rates(6) - pumps_on(3)*flow_rates(3);
    
    if ~isempty(response_data.QID53{i})
        % Is the fuel level of tank A increasing?
        % Tank A = P1+P2+P8-P7-800;
        if str2double(response_data.QID53{i}) == 1 && flow_A > 0 && current_fuel_levels(1) < 4000 
            % if 'yes' and flow rate A is positive, and tank A is NOT full
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID53{i}) == 2 && flow_A <= 0 && current_fuel_levels(1) > 0 
            % if 'no' and flow rate A is non-increasing, and tank A is NOT empty
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID54{i})
        % Is the fuel level of tank B increasing?
        % Tank B = P3+P4+P7-P8-800;
        if str2double(response_data.QID54{i}) == 1 && flow_B > 0 && current_fuel_levels(2) < 4000 
            % if 'yes' and flow rate B is positive, and tank A is NOT full
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID54{i}) == 2 && flow_B < 0 && current_fuel_levels(2) > 0 
            % if 'no' and flow rate B is non-increasing, and tank A is NOT empty
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID55{i})
        % Is the fuel level of tank C increasing?
        % Tank C = P5-P1;
        if str2double(response_data.QID55{i}) == 1 && flow_C > 0 && current_fuel_levels(3) < 2000 
            % if 'yes' and flow rate C is positive, and tank A is NOT full
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA, response i
        elseif str2double(response_data.QID55{i}) == 2 && flow_C <= 0 && current_fuel_levels(3) > 0 
            % if 'no' and flow rate C is non-increasing, and tank A is NOT empty
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID56{i})
        % Is the fuel level of tank D increasing?
        % Tank D = P6 - P3;
        if str2double(response_data.QID56{i}) == 1 && flow_D > 0 && current_fuel_levels(4) < 2000 
            % if 'yes' and flow rate D is positive, and tank A is NOT full
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID56{i}) == 2 && flow_D <= 0 && current_fuel_levels(4) > 0 
            % if 'no' and flow rate D is non-increasing, and tank A is NOT empty
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID57{i})
        % Is the flow rate for pump 1 nominal (when switched on)?
        if str2double(response_data.QID57{i}) == 1
            % if 'yes', incorrect
        elseif str2double(response_data.QID57{i}) == 2
            % if 'no', correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        end
    end
    
    if ~isempty(response_data.QID58{i})
        % Is the flow rate for pump 2 nominal (when switched on)?
        if str2double(response_data.QID58{i}) == 1
            % if 'yes', correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID58{i}) == 2
            % if 'no', incorrect
        end
    end
    
    if ~isempty(response_data.QID59{i})
        % Is the flow rate for pump 3 nominal (when switched on)?
        if str2double(response_data.QID59{i}) == 1
            % if 'yes', correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID59{i}) == 2
            % if 'no', incorrect
        end
    end
    
    if ~isempty(response_data.QID60{i})
        % Is the flow rate for pump 4 nominal (when switched on)?
        if str2double(response_data.QID60{i}) == 1
            % if 'yes', incorrect
        elseif str2double(response_data.QID60{i}) == 2
            % if 'no', correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        end
    end
    
    if ~isempty(response_data.QID61{i})
        % Is the flow rate for pump 5 nominal (when switched on)?
        if str2double(response_data.QID61{i}) == 1
            % if 'yes', correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID61{i}) == 2
            % if 'no', incorrect
        end
    end
    
    if ~isempty(response_data.QID62{i})
        % Is the flow rate for pump 6 nominal (when switched on)?
        if str2double(response_data.QID62{i}) == 1
            % if 'yes', correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID62{i}) == 2
            % if 'no', incorrect
        end
    end
    
    if ~isempty(response_data.QID63{i})
        % Is the flow rate for pump 7 nominal (when switched on)?
        if str2double(response_data.QID63{i}) == 1
            % if 'yes', incorrect
        elseif str2double(response_data.QID63{i}) == 2
            % if 'no', correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        end
    end
    
    if ~isempty(response_data.QID64{i})
        % Is the flow rate for pump 8 nominal (when switched on)?
        if str2double(response_data.QID64{i}) == 1
            % if 'yes', correct
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID64{i}) == 2
            % if 'no', incorrect
        end
    end
    
    if ~isempty(response_data.QID65{i})
        % Do you currently need to turn ON pump 1 to minimize any tank violations? (regardless of failures)
        if str2double(response_data.QID65{i}) == 1 && current_fuel_levels(1)<2000 && current_pump_status(1) ~= 1
            % if 'yes' and tank A is below 2000 and pump 1 is not on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID65{i}) == 2 && (current_fuel_levels(1)>2000 || current_pump_status(1) == 1)
            % if 'no' and (tank A is above 2000 or pump 1 is already on)
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID66{i})
        % Do you currently need to turn OFF pump 1 to minimize any tank violations? (regardless of failures)
        if str2double(response_data.QID66{i}) == 1 && current_fuel_levels(1)>2000 && current_pump_status(1) == 1
            % if 'yes' and tank A is above 2000 and pump 1 is on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID66{i}) == 2 && (current_fuel_levels(1)<2000 || current_pump_status(1) ~= 1)
            % if 'no' and (tank A is below 2000 or pump 1 is not on)
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID67{i})
        % Do you currently need to turn ON pump 2 to minimize any tank violations? (regardless of failures)
        if str2double(response_data.QID67{i}) == 1 && current_fuel_levels(1)<2000 && current_pump_status(2) ~= 1
            % if 'yes' and tank A is below 2000 and pump 2 is not on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID67{i}) == 2 && (current_fuel_levels(1)>2000 || current_pump_status(2) == 1)
            % if 'no' and (tank A is above 2000 or pump 2 is already on)
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID68{i})
        % Do you currently need to turn OFF pump 2 to minimize any tank violations? (regardless of failures)
        if str2double(response_data.QID68{i}) == 1 && current_fuel_levels(1)>2000 && current_pump_status(2) == 1
            % if 'yes' and tank A is above 2000 and pump 2 is on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID68{i}) == 2 && (current_fuel_levels(1)<2000 || current_pump_status(2) ~= 1)
            % if 'no' and (tank A is below 2000 or pump 2 is not on)
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID69{i})
        % Do you currently need to turn ON pump 3 to minimize any tank violations? (regardless of failures)
        if str2double(response_data.QID69{i}) == 1 && current_fuel_levels(2)<2000 && current_pump_status(3) ~= 1
            % if 'yes' and tank B is below 2000 and pump 3 is not on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID69{i}) == 2 && (current_fuel_levels(2)>2000 || current_pump_status(3) == 1)
            % if 'no' and (tank B is above 2000 or pump 3 is already on)
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID70{i})
        % Do you currently need to turn OFF pump 3 to minimize any tank violations? (regardless of failures)
        if str2double(response_data.QID70{i}) == 1 && current_fuel_levels(2)>2000 && current_pump_status(3) == 1
            % if 'yes' and tank B is above 2000 and pump 3 is on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID70{i}) == 2 && (current_fuel_levels(2)<2000 || current_pump_status(3) ~= 1)
            % if 'no' and (tank B is below 2000 or pump 3 is not on)
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID71{i})
        % Would turning on pump 4 help to minimize any tank current violations?
        if str2double(response_data.QID71{i}) == 1 && current_fuel_levels(2)<2000 && current_pump_status(4) ~= 1
            % if 'yes' and tank A is below 2000 and pump 4 is not on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID71{i}) == 2 && (current_fuel_levels(2)>2000 || current_pump_status(4) == 1)
            % if 'no' and (tank A is above 2000 or pump 4 is already on)
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID72{i})
        % Would turning off pump 4 help to minimize any tank current violations?
        if str2double(response_data.QID72{i}) == 1 && current_fuel_levels(2)>2000 && current_pump_status(4) == 1
            % if 'yes' and tank B is above 2000 and pump 4 is on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID72{i}) == 2 && (current_fuel_levels(2)<2000 || current_pump_status(4) ~= 1)
            % if 'no' and (tank B is below 2000 or pump 4 is not on)
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID73{i})
        % Do you currently need to turn on pump 5 to be able to use pump 1?
        if str2double(response_data.QID73{i}) == 1 && current_fuel_levels(3)==0 && current_pump_status(5) ~= 1
            % if 'yes' and tank C is empty and pump 5 is off
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID73{i}) == 2 && (current_fuel_levels(3)>0 || current_pump_status(5) == 1)
            % if 'no' and (tank C is above 0 or pump 5 is  on)
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID75{i})
        % Do you currently need to turn on pump 6 to be able to use pump 3?
        if str2double(response_data.QID75{i}) == 1 && current_fuel_levels(4)==0 && current_pump_status(6) ~= 1
            % if 'yes' and tank D is empty and pump 6 is off
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID75{i}) == 2 && (current_fuel_levels(4)>0 || current_pump_status(6) == 1)
            % if 'no' and (tank D is above 0 or pump 6 is  on)
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        else
            % incorrect
        end
    end

    if ~isempty(response_data.QID77{i})
        % Would turning off pump 7 help to minimize any tank current violations?

        if str2double(response_data.QID77{i}) == 1 && current_fuel_levels(2)<2000 && current_fuel_levels(1)>2000 && current_pump_status(7) ~= 1
            % if 'yes' and tank B is below 2000 and tank A is above 2000 and pump 7 is not on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID77{i}) == 1 && current_fuel_levels(1)>3000 && current_fuel_levels(2)<3000 && current_pump_status(7) ~= 1
            % if 'yes' and tank A is above 3000 and tank B is below 3000 and pump 7 is not on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID77{i}) == 2
            % if 'no'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
            % and 'yes' would NOT have been the correct response
            if current_fuel_levels(2)<2000 && current_fuel_levels(1)>2000 && current_pump_status(7) ~= 1
                % if tank B is below 2000 and tank A is above 2000 and pump 7 is not on
                sa_scores(i,2) = sa_scores(i,2) - 1;    % SUBTRACT level 2 SA
            elseif current_fuel_levels(1)>3000 && current_fuel_levels(2)<3000 && current_pump_status(7) ~= 1
                % if tank A is above 3000 and tank B is below 3000 and pump 7 is not on
                sa_scores(i,2) = sa_scores(i,2) - 1;    % SUBTRACT level 2 SA
            end
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID78{i})
        % Could you turn OFF pump 7 to minimize any current tank violations? (regardless of failures)
        if str2double(response_data.QID78{i}) == 1 && current_fuel_levels(1)<2000 && current_fuel_levels(2)>2000 && current_pump_status(7) == 1
            % if 'yes' and tank B is above 2000 and tank A is below 2000 and pump 7 is on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID78{i}) == 1 && current_fuel_levels(2)>3000 && current_fuel_levels(1)<3000 && current_pump_status(7) == 1
            % if 'yes' and tank A is below 3000 and tank B is above 3000 and pump 7 is on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID78{i}) == 2
            % if 'no'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
            % and 'yes' would NOT have been the correct response (i.e.
            % subtract again if 'no' is the wrong answer) am i going crazy?
            if current_fuel_levels(1)<2000 && current_fuel_levels(2)>2000 && current_pump_status(7) == 1
                % if tank B is above 2000 and tank A is below 2000 and pump 7 is on
                sa_scores(i,2) = sa_scores(i,2) - 1;    % level 2 SA
            elseif current_fuel_levels(2)>3000 && current_fuel_levels(1)<3000 && current_pump_status(7) == 1
                % if tank A is below 3000 and tank B is above 3000 and pump 7 is on
                sa_scores(i,2) = sa_scores(i,2) - 1;    % level 2 SA
            end
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID79{i})
        % Could you turn ON pump 8 to minimize any current tank violations? (regardless of failures)
        if str2double(response_data.QID79{i}) == 1 && current_fuel_levels(1)<2000 && current_fuel_levels(2)>2000 && current_pump_status(8) ~= 1
            % if 'yes' and tank A is below 2000 and tank B is above 2000 and pump 8 is not on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID79{i}) == 1 && current_fuel_levels(2)>3000 && current_fuel_levels(1)<3000 && current_pump_status(8) ~= 1
            % if 'yes' and tank B is above 3000 and tank A is below 3000 and pump 8 is not on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID79{i}) == 2
            % if 'no'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
            % and 'yes' would NOT have been the correct response
            if current_fuel_levels(1)<2000 && current_fuel_levels(2)>2000 && current_pump_status(8) ~= 1
                % if tank A is below 2000 and tank B is above 2000 and pump 8 is not on
                sa_scores(i,2) = sa_scores(i,2) - 1;    % SUBTRACT level 2 SA
            elseif current_fuel_levels(2)>3000 && current_fuel_levels(1)<3000 && current_pump_status(8) ~= 1
                % if tank B is above 3000 and tank A is below 3000 and pump 8 is not on
                sa_scores(i,2) = sa_scores(i,2) - 1;    % SUBTRACT level 2 SA
            end
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID80{i})
        % Could you turn OFF pump 8 to minimize any current tank violations? (regardless of failures)
        if str2double(response_data.QID80{i}) == 1 && current_fuel_levels(2)<2000 && current_fuel_levels(1)>2000 && current_pump_status(8) == 1
            % if 'yes' and tank A is above 2000 and tank B is below 2000 and pump 8 is on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID80{i}) == 1 && current_fuel_levels(1)>3000 && current_fuel_levels(2)<3000 && current_pump_status(8) == 1
            % if 'yes' and tank B is below 3000 and tank A is above 3000 and pump 8 is on
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
        elseif str2double(response_data.QID80{i}) == 2
            % if 'no'
            sa_scores(i,2) = sa_scores(i,2) + 1;    % level 2 SA
            % and 'yes' would NOT have been the correct response (i.e.
            % subtract again if 'no' is the wrong answer) am i going crazy?
            if current_fuel_levels(2)<2000 && current_fuel_levels(1)>2000 && current_pump_status(8) == 1
                % if tank A is above 2000 and tank B is below 2000 and pump 8 is on
                sa_scores(i,2) = sa_scores(i,2) - 1;    % level 2 SA
            elseif current_fuel_levels(1)>3000 && current_fuel_levels(2)<3000 && current_pump_status(8) == 1
                % if tank B is below 3000 and tank A is above 3000 and pump 8 is on
                sa_scores(i,2) = sa_scores(i,2) - 1;    % level 2 SA
            end
        else
            % incorrect
        end
    end

    %% LEVEL 3
    if ~isempty(response_data.QID81{i})
        % If no changes to the pumps occur, do you expect tank A to be in
        %   violation of its upper limit in 30 seconds.
        if str2double(response_data.QID81{i}) == 1 && (flow_A*0.5+current_fuel_levels(1)) > 3000
            % if 'yes' and (flow_A/min x 0.5min + current level (A) > 3000)
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        elseif str2double(response_data.QID81{i}) == 2 && (flow_A*0.5+current_fuel_levels(1)) < 3000
            % if 'no' and (flow_A/min x 0.5min + current level (A) < 3000)
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID82{i})
        % If no changes to the pumps occur, do you expect tank A to be in
        %   violation of its lower limit in 30 seconds.
        if str2double(response_data.QID82{i}) == 1 && (flow_A*0.5+current_fuel_levels(1)) < 2000
            % if 'yes' and (flow_A/min x 0.5min + current level (A) < 2000)
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        elseif str2double(response_data.QID82{i}) == 2 && (flow_A*0.5+current_fuel_levels(1)) > 2000
            % if 'no' and (flow_A/min x 0.5min + current level (A) > 2000)
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID83{i})
        % If no changes to the pumps occur, do you expect tank B to be in
        %   violation of its upper limit in 30 seconds.
        if str2double(response_data.QID83{i}) == 1 && (flow_B*0.5+current_fuel_levels(2)) > 3000
            % if 'yes' and (flow_B/min x 0.5min + current level (B) > 3000)
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        elseif str2double(response_data.QID83{i}) == 2 && (flow_B*0.5+current_fuel_levels(2)) < 3000
            % if 'no' and (flow_B/min x 0.5min + current level (B) < 3000)
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID84{i})
        % If no changes to the pumps occur, do you expect tank B to be in
        %   violation of its lower limit in 30 seconds.
        if str2double(response_data.QID84{i}) == 1 && (flow_B*0.5+current_fuel_levels(2)) < 2000
            % if 'yes' and (flow_B/min x 0.5min + current level (B) < 2000)
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        elseif str2double(response_data.QID84{i}) == 2 && (flow_A*0.5+current_fuel_levels(2)) > 2000
            % if 'no' and (flow_B/min x 0.5min + current level (B) > 2000)
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID85{i})
        % If no changes to the pumps occur, do you expect tank C to be 
        %   empty in 30 seconds.
        if str2double(response_data.QID85{i}) == 1 && (flow_C*0.5+current_fuel_levels(3)) <= 0
            % if 'yes' and (flow_C/min x 0.5min + current level (C) <= 0)
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        elseif str2double(response_data.QID85{i}) == 2 && (flow_C*0.5+current_fuel_levels(3)) > 0
            % if 'no' and (flow_C/min x 0.5min + current level (C) > 0)
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        else
            % incorrect
        end
    end
    
    if ~isempty(response_data.QID86{i})
        % If no changes to the pumps occur, do you expect tank D to be 
        %   empty in 30 seconds.
        if str2double(response_data.QID86{i}) == 1 && (flow_D*0.5+current_fuel_levels(4)) <= 0
            % if 'yes' and (flow_D/min x 0.5min + current level (D) <= 0)
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        elseif str2double(response_data.QID86{i}) == 2 && (flow_D*0.5+current_fuel_levels(4)) > 0
            % if 'no' and (flow_D/min x 0.5min + current level (D) > 0)
            sa_scores(i,3) = sa_scores(i,3) + 1;    % level 3 SA
        else
            % incorrect
        end
    end
    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

% fuel level change rates
% flow rate nominality
% pump adjustments
% 30-second projection of violations/empty C/D

%% RESMAN Functions
function pump_status = getPumpStatus(current_time, pump_times, pumps, actions)
% Returns the pump states at the 'current_time' using the
% actions performed on them from time t = 00:00 onwards
pump_status = zeros(1,8);

% get index for most recent data point
current_time = current_time(1)*60 + current_time(2);
count = getLastDatum(pump_times, current_time);

% update pump status according to each event before count
for i = 1:count
    switch actions{i}
        case 'On'
            pump_status(pumps(i)) = 1;
        case 'Off'
            pump_status(pumps(i)) = 0;
        case 'Fail'
            pump_status(pumps(i)) = 2;
        case 'Fix'
            pump_status(pumps(i)) = 0;
    end
end

end



function current_fuel_levels = getFuelLevels(current_time, pump_times, fuel_levels, pump_status, flow_rates)
% Updates the fuel levels to their state at the 'current_time' using the
% most recent fuel levels and most recent pump flow rates

current_fuel_levels = zeros(1,4);

% get index for most recent data point
current_time = current_time(1)*60 + current_time(2);
count = getLastDatum(pump_times, current_time);

% calculate current fuel levels
minutes_since = (current_time - (pump_times(count,1)*60 + pump_times(count,2)))/60;
current_fuel_levels = fuel_levels(count,:);
active_pumps = find(pump_status == 1); % subset of pumps that are on;
for i = 1:length(active_pumps)
    switch active_pumps(i)
        case 1     % if pump 1 is on
            % add fuel to tank A
            current_fuel_levels(1) = current_fuel_levels(1) +...
                flow_rates(1)*minutes_since;
            % remove fuel from tank C
            current_fuel_levels(3) = current_fuel_levels(3) -...
                flow_rates(1)*minutes_since;
        case 2     % if pump 2 is on
            % add fuel to tank A
            current_fuel_levels(1) = current_fuel_levels(1) +...
                flow_rates(2)*minutes_since;
        case 3     % if pump 3 is on
            % add fuel to tank B
            current_fuel_levels(2) = current_fuel_levels(2) +...
                flow_rates(3)*minutes_since;
            % remove fuel from tank D
            current_fuel_levels(4) = current_fuel_levels(4) -...
                flow_rates(3)*minutes_since;
        case 4     % if pump 4 is on
            % add fuel to tank B
            current_fuel_levels(2) = current_fuel_levels(2) +...
                flow_rates(4)*minutes_since;     
        case 5     % if pump 5 is on
            % add fuel to tank C
            current_fuel_levels(3) = current_fuel_levels(3) +...
                flow_rates(5)*minutes_since;
        case 6     % if pump 6 is on
            % add fuel to tank D
            current_fuel_levels(4) = current_fuel_levels(4) +...
                flow_rates(6)*minutes_since;
        case 7     % if pump 7 is on
            % add fuel to tank B
            current_fuel_levels(2) = current_fuel_levels(2) +...
                flow_rates(7)*minutes_since;
            % remove fuel from tank A
            current_fuel_levels(1) = current_fuel_levels(1) -...
                flow_rates(7)*minutes_since;
        case 8     % if pump 8 is on
            % add fuel to tank A
            current_fuel_levels(1) = current_fuel_levels(1) +...
                flow_rates(8)*minutes_since;
            % remove fuel from tank B
            current_fuel_levels(2) = current_fuel_levels(2) -...
                flow_rates(8)*minutes_since;      
    end
end

% subtract from A and B for constant depletion
current_fuel_levels(1) = current_fuel_levels(1) - ...
    flow_rates(9)*minutes_since;
current_fuel_levels(2) = current_fuel_levels(2) - ...
    flow_rates(9)*minutes_since;
end
