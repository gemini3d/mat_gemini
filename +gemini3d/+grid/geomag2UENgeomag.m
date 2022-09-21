function [zUEN,xUEN,yUEN]=geomag2UENgeomag(alt,mlon,mlat)
arguments
  alt {mustBeNumeric}
  mlon {mustBeNumeric}
  mlat {mustBeNumeric}
end

Re=6370e3;

theta=pi/2-mlat*pi/180;
phi=mlon*pi/180;
% r=alt+Re;

meantheta=mean(theta(:));
meanphi=mean(phi(:));

yUEN=-1*Re*(theta-meantheta);               %north dist. runs backward from zenith angle
xUEN=Re*sin(meantheta)*(phi-meanphi);       %some warping done here (using meantheta)
zUEN=alt;

end %function
