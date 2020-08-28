function saveframe(flagoutput, direc, filename, saveplot_fmt, h)
%% CREATES IMAGE FILES FROM PLOTS
arguments
  flagoutput (1,1) {mustBeInteger}
  direc (1,1) string
  filename (1,1) string
  saveplot_fmt (1,:) string
  h (1,:) matlab.ui.Figure = []
end

import gemini3d.vis.export_graphics

if isempty(saveplot_fmt) || saveplot_fmt == ""
  return
end

dpi = 150;
% filename has the suffix, let's ditch the suffix.
[~, stem] = fileparts(filename);

plotdir = fullfile(gemini3d.fileio.expanduser(direc), "plots");

gemini3d.fileio.makedir(plotdir)

disp("writing plots to " + plotdir)

pp = ["v1", "Ti", "Te", "J1", "v2", "v3", "J2", "J3", "Phitop", "ne"];
assert(length(pp) == length(h), "number of figures ~= number of variables")

for fmt = saveplot_fmt
  for i = 1:length(pp)
    if (flagoutput~=3 || i==10) && ~isempty(h(i))
      export_graphics(h(i), fullfile(plotdir, pp(i) + "-" + stem + "." + fmt), 'resolution', dpi)
    end
  end
end % for

end % function
