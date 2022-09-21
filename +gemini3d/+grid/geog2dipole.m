function [q,p,phi] = geog2dipole(alt,glon,glat)
arguments
  alt {mustBeNumeric}
  glon {mustBeNumeric}
  glat {mustBeNumeric}
end

[theta,phi] = gemini3d.geog2geomag(glat,glon);
mlat=90-theta*180/pi;
mlon=phi*180/pi;

[q,p,phi] = gemscr.geomag2dipole(alt,mlon,mlat);

end %function geog2dipole
