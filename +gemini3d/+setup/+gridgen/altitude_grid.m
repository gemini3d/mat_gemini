function z = altitude_grid(alt_min, alt_max, incl_deg, d)
%% SETUP NONUNIFORM GRID IN ALTITUDE AND FIELD LINE DISTANCE
% This defines x1 for the simulations
% alt_min:  minimum altitude [m]
% alt_max: maximum altitude [m]
% incl_deg: geomagnetic inclination [deg]
% d: tanh scales
%
% example:
% x1 = altitude_grid(80e3, 1000e3, 90, [10e3, 8e3, 500e3, 150e3]);
%

arguments
  alt_min (1,1) {mustBePositive}
  alt_max (1,1) {mustBePositive, mustBeGreaterThan(alt_max, alt_min)}
  incl_deg (1,1) {mustBeNonnegative}
  d (4,1) {mustBePositive}
end

alt(1) = alt_min;

while alt(end) < alt_max
  % dalt=10+9.5*tanh((alt(end)-500)/150);
  dalt = d(1) + d(2) * tanh((alt(end) - d(3)) / d(4));
  alt(end+1) = alt(end) + dalt;
end

assert(length(alt) > 10, 'grid too small')

%% tilt for magnetic inclination
z = alt * cscd(incl_deg);
z = z(:);
%% add two ghost cells each to top and bottom
dz1 = z(2) - z(1);
dzn = z(end) - z(end-1);
z = [z(1) - 2*dz1; z(1) - dz1; z; z(end) + dzn; z(end) + 2*dzn];

end
