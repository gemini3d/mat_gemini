function dat = loadframe3Dcurvne(filename)

narginchk(1,1)

[~,~,ext] = fileparts(filename);

assert(isfile(filename), 'not a file: %s', filename)

switch ext
  case '.dat', dat = read_raw(filename);
  case '.h5', dat.ne = h5read(filename, '/neall');
  case '.nc', dat.ne = ncread(filename, 'neall');
  otherwise, error('loadframe3Dcurvne:not_implemented', 'unknown file type %s',filename)
end

dat.filename=filename;

lxs = gemini3d.simsize(filename);

if any(lxs(2:3) == 1)    % 2D sim
  dat.ne = squeeze(dat.ne);
end

end % function


function dat = read_raw(filename)
%% SIMULATION SIZE
lxs = gemini3d.simsize(fileparts(filename));
%% SIMULATION RESULTS
fid=fopen(filename,'r');

dat.time = gemini3d.vis.get_time(fid);

ns=fread(fid,prod(lxs),'real*8');
ns=reshape(ns, lxs);

fclose(fid);

dat.ne = ns;

end % function
