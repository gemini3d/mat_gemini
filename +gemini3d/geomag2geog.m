function [lat,lon] = geomag2geog(thetat,phit,year)

 if ~exist('year','var')
     % If year is not specified, set it 1985 by default
      year = 1985;
 end
 
arguments
  thetat {mustBeNumeric}
  phit {mustBeNumeric}
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

%enforce phit = [0,2pi]
phit = mod(phit, 2*pi);

thetag2p=acos(cos(thetat).*cos(thetan)-sin(thetat).*sin(thetan).*cos(phit));

beta=acos( (cos(thetat)-cos(thetag2p).*cos(thetan))./(sin(thetag2p).*sin(thetan)) );

phig2 = zeros(size(phit));

i = phit > pi;
phig2(i)=phin-beta(i);

i = phit <= pi;
phig2(i)=phin+beta(i);

phig2 = mod(phig2, 2*pi);

thetag2=pi/2-thetag2p;
lat = rad2deg(thetag2);
lon = rad2deg(phig2);

end
