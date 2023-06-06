function coordinates = extract_svg_coordinates(filename)
  
    % read in all lines
    fid = fopen(filename);
    tline = fgetl(fid);
    lines = cell(0, 0);
    i = 1;
    while ischar(tline)
        tline = fgetl(fid);
        lines{i, 1} = tline;
        i = i + 1;
    end

    % subset cell array
    mask = zeros(length(lines)-1, 1);
    for i = 1:length(lines)-1
        mask(i, 1) = contains(lines{i, 1}, '<circle'); % '<ellips'
    end
    idx = find(mask, 1, 'first');

    mask = false(length(lines), 1);
    mask(idx:end) = true; 
    lines = lines(mask, 1);
    
    % get mask for x
    mask = zeros(length(lines)-1, 1);
    for i = 1:length(lines)-1
        mask(i, 1) = contains(lines{i, 1}, 'cx');
    end
    mask = [mask; 0];
    mask = logical(mask);
    
    % Extract X coordinates
    x = {lines{mask, 1}}';
    x = regexp(x,'[\d*\.]*\d*','match');
    x = [x{:}]';
    X = zeros(length(x), 1);
    for i = 1:length(x)
        X(i, 1) = str2double(x{i, 1});
    end
    
    % get mask for y
    mask = zeros(length(lines)-1, 1);
    for i = 1:length(lines)-1
        mask(i, 1) = contains(lines{i, 1}, 'cy');
    end
    mask = [mask; 0];
    mask = logical(mask);
    
    % Extract Y coordinates
    y = {lines{mask, 1}}';
    y = regexp(y,'[\d*\.]*\d*','match');
    y = [y{:}]';
    Y = zeros(length(y), 1);
    for i = 1:length(y)
        Y(i, 1) = str2double(y{i, 1});
    end

    % Correct X and Y
    X = X - min(X);
    Y = Y - min(Y); 
    coordinates = [X, Y];
    coordinates = vertcat(coordinates(10:end, :), coordinates(1:9, :));
    coordinates = sortrows(coordinates); 

    % Plot figure
    plot(coordinates(:, 1), coordinates(:, 2), '.', MarkerSize = 15)
    %yline(max(Y) - 16)
    pbaspect([2.6 1 1])
    daspect([1 1 1])
    axis tight
    xlim([0, 56])
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

end