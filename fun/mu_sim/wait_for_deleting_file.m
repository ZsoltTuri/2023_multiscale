function wait_for_deleting_file(file)
    deleted = false;
    while deleted == false
        if isfile(file)
            deleted = false;
            delete file;
        else 
            deleted = true;
        end
    end
end