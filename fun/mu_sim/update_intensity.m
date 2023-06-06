function next_intensity = update_intensity(var)
    arguments
        var.tested_intensities      
        var.action_potential_history
    end
    % determine next stimulation intensity after the first step
    if length(var.tested_intensities) == 1 
        if var.action_potential_history == 1
            next_intensity = var.tested_intensities(end) * 0.5; 
        else 
            next_intensity = var.tested_intensities(end); % next_intensity = var.tested_intensities * 1.5;
        end
    % determine next stimulation intensity afterwards
    else 
        response_sec_last = var.action_potential_history(end - 1); 
        response_last = var.action_potential_history(end);
        idx_hit = find(var.action_potential_history == 1);
        idx_fail = find(var.action_potential_history == 0);
        % if there are no response after the first step
        if isempty(idx_hit)
            next_intensity = var.tested_intensities(end) * 1.5;
        else    
            last_good_intensity = var.tested_intensities(idx_hit(end));
            max_failure = max(var.tested_intensities(idx_fail));
            difference = last_good_intensity - max_failure;
            % after two consecutive hits: decrease stimulation intensity
            if response_sec_last == 1 && response_last == 1
                if difference == 2 % to avoid overestimation of threshold with 1% MSO (due to floor)
                    next_intensity = (last_good_intensity + max_failure) / 2;  
                else 
                    amount = (var.tested_intensities(end - 1) - var.tested_intensities(end)) * 0.5;
                    next_intensity = var.tested_intensities(end) - amount;
                    next_intensity = floor(next_intensity); % avoid to stuck at 1% MSO above the threshold
                end
            % after two consecutive failures: increase stimulation intensity
            elseif response_sec_last == 0 && response_last == 0
                next_intensity = (last_good_intensity + var.tested_intensities(end)) * 0.5; 
            % otherwise: find iterim intensities (i.e., calculate the average of the last two stimulation intensities)
            else
                next_intensity = (var.tested_intensities(end) + var.tested_intensities(end - 1)) * 0.5;
            end   
        end
    end
    next_intensity = round(next_intensity);
end