function [q,p,phi] = geomag2dipole(alt,mlon,mlat)
arguments
  alt {mustBeReal}
  mlon {mustBeReal}
  mlat {mustBeReal}
end

Re=6370e3;

theta= pi/2- deg2rad(mlat);
phi= deg2rad(mlon);
r=alt+Re;

q= (Re./r).^2 .* cos(theta);
p= r/Re ./ sin(theta).^2;

end
