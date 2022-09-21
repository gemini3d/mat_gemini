function [zUEN,xUEN,yUEN] = geog2UENgeog(alt,glon,glat)
arguments
  alt {mustBeNumeric}
  glon {mustBeNumeric}
  glat {mustBeNumeric}
end

Re=6370e3;

theta=pi/2-glat*pi/180;   %this is the zenith angle referenced from Earth's spin axis, i.e. the geographic (as opposed to magnetic) pole
phi=glon*pi/180;

meantheta=mean(theta(:));
meanphi=mean(phi(:));

yUEN=-1*Re*(theta-meantheta);               %north dist. runs backward from zenith angle
xUEN=Re*sin(meantheta)*(phi-meanphi);       %some warping done here (using meantheta)
zUEN=alt;

end %function geog2UENgeog
