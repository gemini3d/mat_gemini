function [thetat,phit] = geog2geomag(lat,lon,year)
arguments
  lat {mustBeNumeric}
  lon {mustBeNumeric}
  year {mustBeNumeric}
end

% Schmidt semi-normalised spherical harmonic coefficients are from http://wdc.kugi.kyoto-u.ac.jp/igrf/coef/igrf13coeffs.html
% Calculation of thetan and phin are based on Millward et al., 1996
% For year < 1985, use the same coefficients as for 1985
case ismember(year, 1920:1987)
thetan=deg2rad(1.1000e+01);
phin=deg2rad(2.8900e+02);
case ismember(year, 1988:1992)
thetan=deg2rad(1.0862e+01);
phin=deg2rad(2.8887e+02);
case ismember(year, 1993:1997)
thetan=deg2rad(1.0677e+01);
phin=deg2rad(2.8858e+02);
case ismember(year, 1998:2002)
thetan=deg2rad(1.0457e+01);
phin=deg2rad(2.8843e+02);
case ismember(year, 2003:2007)
thetan=deg2rad(1.0252e+01);
phin=deg2rad(2.8819e+02);
case ismember(year, 2008:2012)
thetan=deg2rad(9.9840e+00);
phin=deg2rad(2.8779e+02);
case ismember(year, 2013:2017)
thetan=deg2rad(9.6869e+00);
phin=deg2rad(2.8739e+02);
case ismember(year, 2018:2025)
thetan=deg2rad(9.4105e+00);
phin=deg2rad(2.8732e+02);
end

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
