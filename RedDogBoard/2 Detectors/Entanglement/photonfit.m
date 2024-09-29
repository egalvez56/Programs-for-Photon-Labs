function [ y ] = photonfit( c,x )
%This function is used to calculate the function that fits the data
%obtained in the single-photon experiment.
% The function is of the form:
% y = c1*(cos(4(x+c2)))
% The parameters are:
% c1 is the Number of counts
% c2 is the zero angle
y = c(1)*cos(4*(x+c(2))/9*pi()/180);
end

