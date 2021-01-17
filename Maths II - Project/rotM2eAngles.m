function [yaw, pitch, roll] = rotM2eAngles(R)
% [yaw, pitch, roll] = rotM2eAngles(R)
% Computes the Euler angles (yaw, pitch, roll) given an input rotation matrix R.
% Inputs:
%	R: rotation matrix
% Outputs:
%	yaw: angle of rotation around the z axis
%	pitch: angle of rotation around the y axis
%	roll: angle of rotation around the x axis

pitch=asind(-(R(3,1)));
if pitch == 90
    minus_yaw = asind(R(1,2));
    roll = 0;
    yaw = minus_yaw+roll;
elseif pitch == -90
    plus_yaw = asind(R(1,2));
    roll = 0;
    yaw = plus_yaw - roll;
elseif pitch ~= 90 || pitch ~= -90
    yaw = atan2d(real((R(3,2))/cosd(pitch)),real((R(3,3))/cosd(pitch)));
    roll = atan2d(real((R(2,1))/cosd(pitch)),real((R(1,1))/cosd(pitch)));

end




