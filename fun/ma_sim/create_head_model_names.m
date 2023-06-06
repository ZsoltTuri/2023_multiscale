function models = create_head_model_names(params)
    models = strings(size(params.idx));
    for i = 1:length(params.idx)
        if i < 10
            models(i, 1) = strcat('m-00', num2str(i));
        elseif i >= 10 && i < 100
            models(i, 1) = strcat('m-0', num2str(i));
        else
            models(i, 1) = strcat('m-', num2str(i));
        end  
    end
    models = convertStringsToChars(models);
end