function [R] = Eaa2rotMat(a,u)
% [R] = Eaa2rotMat(a,u)
% Computes the rotation matrix R given an angle and axis of rotation. 
% Inputs:
%    a: angle of rotation
%    u: axis of rotation 
% Outputs:
%    R: generated rotation matrix

if (iscolumn(u) == 0)
    u = u';
end
    
u = u/norm(u);

R1 = eye(3)*cos(a);
R2 = (1-cos(a))*(u*u');
R3 = sin(a)*[0 -u(3) u(2); u(3) 0 -u(1); -u(2) u(1) 0];

R = R1+R2+R3;

end

