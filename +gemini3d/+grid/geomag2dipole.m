function [q,p,phi]=geomag2dipole(alt,mlon,mlat)
arguments
  alt {mustBeNumeric}
  mlon {mustBeNumeric}
  mlat {mustBeNumeric}
end

Re=6370e3;

theta=pi/2-mlat*pi/180;
phi=mlon*pi/180;
r=alt+Re;

q=(Re./r).^2.*cos(theta);
p=r/Re./sin(theta).^2;

end %function
