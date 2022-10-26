function [q, p, phi] = geog2dipole(alt, glon, glat)
arguments
  alt {mustBeReal}
  glon {mustBeReal}
  glat {mustBeReal}
end

[theta,phi] = gemini3d.geog2geomag(glat, glon);
mlat = 90 - rad2deg(theta);
mlon = rad2deg(phi);

[q,p,phi] = gemini3d.grid.geomag2dipole(alt, mlon, mlat);

end %function geog2dipole
