function [thetan, phin] = schmidt_coeff(year)
%% Schmidt semi-normalised spherical harmonic coefficients
% from: http://wdc.kugi.kyoto-u.ac.jp/igrf/coef/igrf13coeffs.html
%
% Calculation of thetan and phin are based on Millward et al., 1996
% For year < 1985, use the same coefficients as for 1985

arguments
  year (1,1) {mustBeReal,mustBeInRange(year, 1920, 2026)}
end


if 1988 > year && year >= 1920
  thetan=deg2rad(1.1000e+01);
  phin=deg2rad(2.8900e+02);
elseif 1993 > year && year >= 1988
  thetan=deg2rad(1.0862e+01);
  phin=deg2rad(2.8887e+02);
elseif 1998 > year && year >= 1993
  thetan=deg2rad(1.0677e+01);
  phin=deg2rad(2.8858e+02);
elseif 2003 > year && year >= 1998
  thetan=deg2rad(1.0457e+01);
  phin=deg2rad(2.8843e+02);
elseif 2008 > year && year >= 2003
  thetan=deg2rad(1.0252e+01);
  phin=deg2rad(2.8819e+02);
elseif 2013 > year && year >= 2008
  thetan=deg2rad(9.9840e+00);
  phin=deg2rad(2.8779e+02);
elseif 2018 > year && year >= 2013
  thetan=deg2rad(9.6869e+00);
  phin=deg2rad(2.8739e+02);
elseif 2026 > year && year >= 2018
  thetan=deg2rad(9.4105e+00);
  phin=deg2rad(2.8732e+02);
else
  error('geomag2geog:ValueError', "unexpected year " + num2str(year))
end

end % function
