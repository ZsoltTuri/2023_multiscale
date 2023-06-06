function Rz = create_matsimnibs(radian, offset)
    Rz = [cos(radian) -sin(radian) 0 0;
          sin(radian) cos(radian)  0 0;
          0 0 -1 (offset);
          0 0 0 1];
end

% You can flip the coil at the target by 180 deg; so the coil's stimulation site is
% pointing up (to the air; away from the head model) 
% Rz = [cos(radian) -sin(radian) 0 0;
%           sin(radian) cos(radian)  0 0;
%           0 0 1 (offset);
%           0 0 0 1];