function [zUEN, xUEN, yUEN]=geomag2UENgeomag(alt, mlon, mlat)
arguments
  alt {mustBeReal}
  mlon {mustBeReal}
  mlat {mustBeReal}
end

Re=6370e3;

theta = pi/2- deg2rad(mlat);
phi = deg2rad(mlon);
% r=alt+Re;

meantheta=mean(theta, 'all');
meanphi=mean(phi, 'all');

yUEN=-1*Re*(theta-meantheta);               %north dist. runs backward from zenith angle
xUEN=Re*sin(meantheta)*(phi-meanphi);       %some warping done here (using meantheta)
zUEN=alt;

end
