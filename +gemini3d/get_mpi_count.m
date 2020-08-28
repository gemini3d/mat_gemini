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

if isfolder(sizefn)
  dsize = gemini3d.simsize(sizefn);
elseif isfolder(fileparts(sizefn))
  dsize = gemini3d.simsize(fileparts(sizefn));
elseif isfile(sizefn)
  [~,~,ext] = fileparts(sizefn);
  if any(contains(ext, [".h5", ".nc", ".dat"]))
    dsize = gemini3d.simsize(sizefn);
  elseif any(contains(ext, [".ini", ".nml"]))
    params = gemini3d.read_config(sizefn);
    % OK to use indat_size because we're going to run a sim on this machine
    dsize = gemini3d.simsize(params.indat_size);
  else
    error('get_mpi_count:file_not_found', '%s is not a file or directory', sizefn)
  end
else
  error('get_mpi_count:file_not_found', '%s is not a file or directory', sizefn)
end

N = gemini3d.sys.max_mpi(dsize, max_cpu);

end % function
