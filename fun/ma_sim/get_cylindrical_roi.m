function index = get_cylindrical_roi(matrix, cylinder)
    % https://math.stackexchange.com/questions/3518495/check-if-a-general-point-is-inside-a-given-cylinder
    rA = cylinder.top';
    rB = cylinder.base';
    rB = rB + [0.0001, 0, 0]';
    e = rB - rA;
    c = cross(rA, rB);
    mask = zeros(length(matrix), 3);
    % Check if coordiante is inside the cylinder
    for ii = 1:length(matrix)
        rP = matrix(ii, :)'; 
        d = norm(c + cross(e, rP)) / norm(e);
        mask(ii, 1) = d <= cylinder.radius;
        rQ = rP + (cross(e, (c + cross(e, rP))) / norm(e)^2);
        wA = norm(cross(rQ, rB)) / norm(c); 
        wB = norm(cross(rQ, rA)) / norm(c); 
        mask(ii, 2) = wA >= 0 && wA <= 1 && wB >= 0 && wB <= 1;
    end
    index = logical(mask(:, 1)==1 & mask(:, 2)==1);
end
% rA = [roi.gm_tri(roi.idx, :) - roi.gm_tri_normal(roi.idx, :)]';                % top
% rB = [roi.gm_tri(roi.idx, :) + (roi.gm_tri_normal(roi.idx, :) * roi.height)]'; % base
