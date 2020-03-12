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

%REORGANIZE ACCORDING TO MATLABS CONCEPT OF A 2D or 3D DATA SET
if (lxs(2) == 1)    %a 2D simulations was done
  dat.ne = squeeze(ns(:,:,:));
%  [X3,X1]=meshgrid(x3,x1);
else    %full 3D run
%  ne=permute(ns(:,:,:),[3,2,1]);
  dat.ne = ns;
%  [X2,X3,X1]=meshgrid(x2,x3,x1);
end

end % function
