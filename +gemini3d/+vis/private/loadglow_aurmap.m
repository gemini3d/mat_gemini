function cAur = loadglow_aurmap(filename, lx2, lx3, lwave)
%% loads simulated auroral emissions
arguments
  filename (1,1) string
  lx2 (1,1) {mustBeInteger,mustBePositive}
  lx3 (1,1) {mustBeInteger,mustBePositive}
  lwave (1,1) {mustBeInteger,mustBePositive}
end

[~,~,ext] = fileparts(filename);

switch ext
  case '.dat', cAur = loadglow_aurmap_raw(filename, lx2, lx3, lwave);
  case '.h5', cAur = loadglow_aurmap_hdf5(filename);
  case '.nc', cAur = loadglow_aurmap_nc(filename);
  otherwise, error('loadglow_aurmap:value_error', 'unknown file type %s', filename)
end

end


function cAur = loadglow_aurmap_raw(filename, lx2, lx3, lwave)

fid=fopen(filename,'r');
cAur = fread(fid,lx2*lx3*lwave,'real*8');
fclose(fid);

cAur = reshape(cAur,[lx2,lx3,lwave]);
%cAur = reshape(cAur,[lwave,lx2,lx3]);
%cAur=permute(cAur,[2,3,1]);
end % function


function cAur = loadglow_aurmap_hdf5(filename)
cAur = squeeze(h5read(filename, '/aurora/iverout'));
end % function


function cAur = loadglow_aurmap_nc(filename)
cAur = squeeze(ncread(filename, 'iverout'));
end % function
