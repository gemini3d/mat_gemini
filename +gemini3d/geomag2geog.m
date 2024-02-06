function [lat,lon] = geomag2geog(thetat,phit)
%% geomag2geog converts geomagnetic coordinates to geographic coordinates
% does not account for geomagnetic changes over time
arguments
  thetat {mustBeNumeric}
  phit {mustBeNumeric}
end

thetan = deg2rad(11);
phin = deg2rad(289);

%enforce phit = [0,2pi]
phit = mod(phit, 2*pi);

thetag2p=acos(cos(thetat).*cos(thetan)-sin(thetat).*sin(thetan).*cos(phit));

beta=acos( (cos(thetat)-cos(thetag2p).*cos(thetan))./(sin(thetag2p).*sin(thetan)) );

phig2 = zeros(size(phit), like=phit);

i = phit > pi;
phig2(i)=phin-beta(i);

i = phit <= pi;
phig2(i)=phin+beta(i);

phig2 = mod(phig2, 2*pi);

thetag2=pi/2-thetag2p;
lat = rad2deg(thetag2);
lon = rad2deg(phig2);

end
