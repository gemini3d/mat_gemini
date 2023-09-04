function [thetat,phit] = geog2geomag(lat,lon)
%% geog2geomag geographic to geomagnetic
% does not account for changes in geomagnetic field over time
arguments
  lat {mustBeNumeric}
  lon {mustBeNumeric}
end

thetan = deg2rad(11);
phin = deg2rad(289);

%enforce [0,360] longitude
loncorrected = mod(lon, 360);

thetagp = pi/2 - deg2rad(lat);
phig = deg2rad(loncorrected);

thetat = acos(cos(thetagp).*cos(thetan)+sin(thetagp).*sin(thetan).*cos(phig-phin));
argtmp = (cos(thetagp)-cos(thetat).*cos(thetan))./(sin(thetat).*sin(thetan));
alpha = acos( max(min(argtmp,1),-1) );
phit = zeros(size(lat));

i = (phin>phig & phin-phig>pi) | (phin<phig & phig-phin<pi);
phit(i) = pi-alpha(i);

i = ~( (phin>phig & phin-phig>pi) | (phin<phig & phig-phin<pi) );
phit(i) = alpha(i)+pi;

end
