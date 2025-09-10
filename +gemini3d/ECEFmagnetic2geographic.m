function [alt,glon,glat]=ECEFmagnetic2geographic(x,y,z)

% Convert ECEF Magnetic Cartesian coodinates to alt,glon,glat

arguments
    x {mustBeNumeric}
    y {mustBeNumeric}
    z {mustBeNumeric}
end

% spherical magnetic coordinates
r=sqrt(x.^2 + y.^2 + z.^2);
theta=acos(z./r);
phi=atan2(y,x);

% magnetic lat/lon and alt
alt=r-6370e3;
[glat,glon]=geomag2geog(theta,phi);
end %function