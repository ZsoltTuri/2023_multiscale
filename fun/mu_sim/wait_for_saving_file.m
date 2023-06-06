function wait_for_saving_file(file)
    created = false;
    while created == false
        if isfile(file)
            created = true;
        else 
            created = false;
        end
    end
end