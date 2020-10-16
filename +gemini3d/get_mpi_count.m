function N = get_mpi_count(sizefn, max_cpu)
%% get appropriate MPI image count for problem shape
%
%    Parameters
%    ----------
%    sizefn: simsize file
%    max_cpu: optional, don't use more than this many CPU cores
%
%    Returns
%    -------
%    N: number of MPI images
arguments
  sizefn (1,1) string
  max_cpu (1,1) {mustBeInteger,mustBeNonnegative} = 0
end

%% config.nml file or directory or simsize.h5?

dsize = [];

if isfolder(sizefn)
  dsize = gemini3d.simsize(sizefn);
elseif isfolder(fileparts(sizefn))
  dsize = gemini3d.simsize(fileparts(sizefn));
elseif isfile(sizefn)
  [~,~,ext] = fileparts(sizefn);
  if any(endsWith(ext, [".h5", ".nc", ".dat"]))
    dsize = gemini3d.simsize(sizefn);
  elseif any(endsWith(ext, [".ini", ".nml"]))
    params = gemini3d.read_config(sizefn);
    % OK to use indat_size because we're going to run a sim on this machine
    dsize = gemini3d.simsize(params.indat_size);
  end
end

if isempty(dsize)
  N = 1;
else
  N = gemini3d.sys.max_mpi(dsize, max_cpu);
end

end % function
