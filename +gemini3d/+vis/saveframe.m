function saveframe(flagoutput, direc, filename, saveplot_fmt, h)
%% CREATES IMAGE FILES FROM PLOTS
narginchk(5,5)
validateattributes(flagoutput, {'numeric'}, {'scalar'}, mfilename)
validateattributes(direc, {'char'}, {'vector'}, mfilename)
validateattributes(filename, {'char'}, {'vector'}, mfilename)
validateattributes(h, {'struct'}, {'vector'}, mfilename, 'figure handles', 5)

if isempty(saveplot_fmt)
  return
end
if ischar(saveplot_fmt)
  saveplot_fmt = {saveplot_fmt};
end

dpi = 150;
% filename has the suffix, let's ditch the suffix.
[~, stem] = fileparts(filename);

plotdir = fullfile(expanduser(direc), 'plots');

makedir(plotdir)

disp(['writing plots to ', plotdir])

for fmt = saveplot_fmt

  if flagoutput~=3
    export_graphics(h.f1, fullfile(plotdir, ['v1-', stem, '.', fmt{:}]), 'Resolution', dpi)
    export_graphics(h.f2, fullfile(plotdir, ['Ti-', stem, '.', fmt{:}]), 'Resolution', dpi)
    export_graphics(h.f3, fullfile(plotdir, ['Te-', stem, '.', fmt{:}]), 'Resolution', dpi)
    export_graphics(h.f4, fullfile(plotdir, ['J1-', stem, '.', fmt{:}]), 'Resolution', dpi)
    export_graphics(h.f5, fullfile(plotdir, ['v2-', stem, '.', fmt{:}]), 'Resolution', dpi)
    export_graphics(h.f6, fullfile(plotdir, ['v3-', stem, '.', fmt{:}]), 'Resolution', dpi)
    export_graphics(h.f7, fullfile(plotdir, ['J2-', stem, '.', fmt{:}]), 'Resolution', dpi)
    export_graphics(h.f8, fullfile(plotdir, ['J3-', stem, '.', fmt{:}]), 'Resolution', dpi)
    if ~isempty(h.f9)
      export_graphics(h.f9, fullfile(plotdir, ['Phitop-', stem, '.', fmt{:}]), 'Resolution', dpi)
    end
  end
  export_graphics(h.f10, fullfile(plotdir, ['ne-', stem, '.', fmt{:}]), 'Resolution', dpi)
end % for

end % function
