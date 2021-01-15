function [yaw, pitch, roll] = rotM2eAngles(R)
% [yaw, pitch, roll] = rotM2eAngles(R)
% Computes the Euler angles (yaw, pitch, roll) given an input rotation matrix R.
% Inputs:
%	R: rotation matrix
% Outputs:
%	yaw: angle of rotation around the z axis
%	pitch: angle of rotation around the y axis
%	roll: angle of rotation around the x axis

seno_roll=R(3,1);
roll=asin(seno_roll);
seno_yaw=(R(3, 2))/cos(roll);
yaw=asin(seno_yaw);
seno_pitch=(R(2, 1))/cos(roll);
pitch=asin(seno_pitch);

end




