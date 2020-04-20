function dat = loadframe3Dcurvne(filename)

narginchk(1,1)

[~,~,ext] = fileparts(filename);

assert(is_file(filename), [filename,' is not a file.'])

switch ext
  case '.dat', dat = read_raw(filename);
  case {'.h5'}, dat= read_hdf5(filename);
  case ('.nc'), dat = read_nc4(filename);
  otherwise, error(['unknown file type ',filename])
end

dat.filename=filename;
dat.Ti=[];
dat.Te=[];
dat.v1=[];
dat.v2=[];
dat.v3=[];
dat.J1=[];
dat.J2=[];
dat.J3=[];
dat.Phitop=[];

lxs = simsize(filename);

if any(lxs(2:3) == 1)    % 2D sim
  dat.ne = squeeze(dat.ne);
end
end % function


function dat = read_hdf5(filename)
 dat.ne = h5read(filename, '/neall');
end % function

function dat = read_nc4(filename)
 dat.ne = ncread(filename, '/neall');
end % function


function dat = read_raw(filename)
%% SIMULATION SIZE
lxs = simsize(fileparts(filename));
%% SIMULATION RESULTS
fid=fopen(filename,'r');
simdt(fid);

ns=fread(fid,prod(lxs),'real*8');
ns=reshape(ns, lxs);

fclose(fid);

dat.ne = ns;

end % function
