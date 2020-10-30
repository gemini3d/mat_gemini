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

dsize = gemini3d.simsize(sizefn);

if isempty(dsize)
  N = 1;
else
  N = gemini3d.sys.max_mpi(dsize, max_cpu);
end

end % function
