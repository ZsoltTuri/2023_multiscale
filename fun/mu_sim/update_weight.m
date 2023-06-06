function next_weight = update_weight(var)
    arguments
        var.tested_weights      
        var.action_potential_history
    end
    % determine next weight after the first step
    if length(var.tested_weights) == 1 
        if var.action_potential_history == 1
            next_weight = var.tested_weights(end) * 0.5; 
        else 
            next_weight = var.tested_weights(end); % next_weight = var.tested_weights * 1.5;
        end
    % determine next weight afterwards
    else 
        response_sec_last = var.action_potential_history(end - 1); 
        response_last = var.action_potential_history(end);
        idx_hit = find(var.action_potential_history == 1);
        idx_fail = find(var.action_potential_history == 0);
        % if there are still no response after the first step
        if isempty(idx_hit)
            next_weight = var.tested_weights(end) * 1.5;
        else    
            last_good_weight = var.tested_weights(idx_hit(end));
            % after two consecutive hits: decrease weight
            if response_sec_last == 1 && response_last == 1
                amount = (var.tested_weights(end - 1) - var.tested_weights(end)) * 0.5;
                next_weight = var.tested_weights(end) - amount;
            % after two consecutive failures: increase weight
            elseif response_sec_last == 0 && response_last == 0
                next_weight = (last_good_weight + var.tested_weights(end)) * 0.5; 
            % otherwise: find iterim value (i.e., calculate the average of the last two weights)
            else
                next_weight = (var.tested_weights(end) + var.tested_weights(end - 1)) * 0.5;
            end   
        end
    end
    next_weight = round(next_weight, 7);
end