function [a,u] = rotMat2Eaa(R)
% [a,u] = rotMat2Eaa(R)
% Computes the angle and principal axis of rotation given a rotation matrix R. 
% Inputs:
%	R: rotation matrix
% Outputs:
%	a: angle of rotation
%	u: axis of rotation 

a = acosd((trace(R)-1)*0.5);
I = eye(3);

if a == 0
   axis = [0 0 0]';
elseif a == 180
    M = (R+I)/2;
    axis = [sqrt(M(1,1)) sqrt(M(2,2)) sqrt(M(3,3))]';
else
    C = ((R-R')/(2*sind(a)));
    axis = [C(3,2) C(1,3) C(2,1)]';
end

if a == 0
    u = axis;
else
    u = axis/norm(axis);

end

