function [R] = eAngles2rotM(yaw, pitch, roll)
% [R] = eAngles2rotM(yaw, pitch, roll)
% Computes the rotation matrix R given the Euler angles (yaw, pitch, roll). 
% Inputs:
%	yaw: angle of rotation around the z axis
%	pitch: angle of rotation around the y axis
%	roll: angle of rotation around the x axis
% Outputs:
%	R: rotation matrix

R = [cosd(pitch)*cosd(roll), cosd(roll)*sind(pitch)*sind(yaw) - cosd(yaw)*sind(roll), cosd(roll)*cosd(yaw)*sind(pitch) + sind(roll)*sind(yaw);
    sind(roll)*cosd(pitch), sind(roll)*sind(pitch)*sind(yaw) + cosd(yaw)*cosd(roll), sind(roll)*sind(pitch)*cosd(yaw) - cosd(roll)*sind(yaw);
    -sind(pitch), cosd(pitch)*sind(yaw), cosd(pitch)*cosd(yaw)];

end




