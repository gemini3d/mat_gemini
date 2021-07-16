function dat = frame3Dcurvne(filename)
arguments
  filename (1,1) string {mustBeNonzeroLengthText}
end

[~,~,ext] = fileparts(filename);

assert(isfile(filename), "not a file: " + filename)

switch ext
  case '.dat', dat = read_raw(filename);
  case '.h5'
    dat.ne = h5read(filename, '/ne');
  case '.nc', dat.ne = ncread(filename, 'neall');
  otherwise, error('frame3Dcurvne:not_implemented', 'unknown file type %s',filename)
end

dat.filename = filename;
dat.lxs = size(dat.ne, 1:3);

end % function


function dat = read_raw(filename)
%% SIMULATION SIZE
lxs = gemini3d.simsize(fileparts(filename));
%% SIMULATION RESULTS
fid=fopen(filename,'r');

dat.time = gemini3d.read.time(fid);

ns=fread(fid,prod(lxs),'real*8');
ns=reshape(ns, lxs);

fclose(fid);

dat.ne = ns;

end % function
