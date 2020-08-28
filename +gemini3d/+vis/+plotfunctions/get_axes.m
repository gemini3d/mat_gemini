function ha = get_axes(h)
% create axes for figure handle
% if axes handle, just reuse it
% if no axes/figure, create a new figure + axes

if nargin < 1
  ha = axes('parent', figure);
else
  ha = axes(h);  % this is fine for Octave >= 5.0 and Matlab
end
