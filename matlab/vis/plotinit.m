function h = plotinit(xg, visible)
narginchk(1,2)

validateattributes(xg, {'struct'}, {'scalar'}, mfilename, 'grid',1)

if nargin<2,  visible=true; end
validateattributes(visible, {'logical'}, {'scalar'}, mfilename, 'figure visibility', 2)

%Csp = ceil(sqrt(Nt));
%Rsp = ceil(Nt/Csp);

pos2d = [0.1 0.1 0.3 0.3];
pos3d = [0.1 0.1 0.8 0.3];

if any(xg.lx(2:3)==1)  %2D simulation
  figpos = pos2d;
else                            %3D simulation
  figpos = pos3d;
end

h.f1 = figure('Name', 'V1', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h.f2 = figure('Name', 'Ti', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h.f3 = figure('Name', 'Te', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h.f4 = figure('Name', 'J1', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h.f5 = figure('Name', 'V2', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h.f6 = figure('Name', 'V3', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h.f7 = figure('Name', 'J2', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h.f8 = figure('Name', 'J3', 'units', 'normalized', 'position', figpos, 'Visible', visible);

h.f9 = figure('Name', 'Topside Potential Phi', 'units', 'normalized', 'position', pos2d, 'Visible', visible);

h.f10 = figure('Name', 'Ne', 'units', 'normalized', 'position', figpos, 'Visible', visible);

end % function
