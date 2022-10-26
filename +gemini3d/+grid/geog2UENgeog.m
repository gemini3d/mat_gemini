function [zUEN, xUEN, yUEN] = geog2UENgeog(alt, glon, glat)
arguments
  alt {mustBeReal}
  glon {mustBeReal}
  glat {mustBeReal}
end

Re=6370e3;

theta = pi/2 - deg2rad(glat);   %this is the zenith angle referenced from Earth's spin axis, i.e. the geographic (as opposed to magnetic) pole
phi = deg2rad(glon);

meantheta=mean(theta, 'all');
meanphi=mean(phi, 'all');

yUEN=-1*Re*(theta-meantheta);               %north dist. runs backward from zenith angle
xUEN=Re*sin(meantheta)*(phi-meanphi);       %some warping done here (using meantheta)
zUEN=alt;

end %function geog2UENgeog
