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
%

narginchk(1,2)
if nargin < 2, max_cpu = []; end

%% config.nml file or directory or simsize.h5?
if is_folder(sizefn)
  dsize = simsize(sizefn);
elseif is_file(sizefn)
  [~,~,ext] = fileparts(sizefn);
  if any(strcmp(ext, {'.h5', '.nc', '.dat'}))
    dsize = simsize(sizefn);
  elseif any(strcmp(ext, {'.ini', '.nml'}))
    params = read_config(sizefn);
    % OK to use indat_size because we're going to run a sim on this machine
    dsize = simsize(params.indat_size);
  else
    error('get_mpi_count:file_not_found', '%s is not a file or directory', sizefn)
  end
else
  error('get_mpi_count:file_not_found', '%s is not a file or directory', sizefn)
end

N = max_mpi(dsize, max_cpu);

end % function
