function cAur = loadglow_aurmap(filename)
%% loads simulated auroral emissions
arguments
  filename (1,1) string
end

[~,~,ext] = fileparts(filename);

switch ext
  case '.h5', cAur = loadglow_aurmap_hdf5(filename);
  otherwise, error('gemini3d:plot:loadglow_aurmap:value_error', 'unknown file type %s', filename)
end

end

function cAur = loadglow_aurmap_hdf5(filename)
cAur = squeeze(h5read(filename, '/aurora/iverout'));
end % function
