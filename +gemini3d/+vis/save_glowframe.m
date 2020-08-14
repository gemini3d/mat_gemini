function save_glowframe(filename, saveplot_fmt, hf)
%% CREATES IMAGE FILES FROM PLOTS
narginchk(3,3)
validateattributes(filename, {'char'}, {'vector'}, mfilename, 'aurora filename', 1)

dpi = '150';

if isempty(saveplot_fmt)
  return
elseif ischar(saveplot_fmt)
  saveplot_fmt = {saveplot_fmt};
end

[outdir, outname] = fileparts(filename);
outdir = fullfile(outdir, '../plots');

for fmt = saveplot_fmt
  suffix = ['.', fmt{:}];

  outfile = fullfile(outdir, ['aurora-', outname, suffix]);
  disp(['writing ', outfile])
  export_graphics(hf, outfile, 'Resolution', dpi)
end

end % function
