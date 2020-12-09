function h = plotinit(xg, visible)
arguments
  xg (1,1) struct
  visible (1,1) logical = true
end

%Csp = ceil(sqrt(Nt));
%Rsp = ceil(Nt/Csp);

pos2d = [0.1 0.1 0.3 0.3];
pos3d = [0.1 0.1 0.8 0.3];

if any(xg.lx(2:3)==1)           %2D simulation
  figpos = pos2d;
else                            %3D simulation
  figpos = pos3d;
end

h(1) = figure('Name', 'V1', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h(2) = figure('Name', 'Ti', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h(3) = figure('Name', 'Te', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h(4) = figure('Name', 'J1', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h(5) = figure('Name', 'V2', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h(6) = figure('Name', 'V3', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h(7) = figure('Name', 'J2', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h(8) = figure('Name', 'J3', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h(9) = figure('Name', 'Topside Potential Phi', 'units', 'normalized', 'position', pos2d, 'Visible', visible);

h(10) = figure('Name', 'Ne', 'units', 'normalized', 'position', figpos, 'Visible', visible);

end % function
