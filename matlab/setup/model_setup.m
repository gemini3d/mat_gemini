function p = model_setup(p, outdir)
%% determines what kind of setup is needed and does it.

narginchk(1, 2)
if nargin < 2, outdir = []; end

% this is a top-level script, so be sure environment is setup
cwd = fileparts(mfilename('fullpath'));
if ~exist('is_file', 'file')
  run(fullfile(cwd, '../../setup.m'))
end
%% parse input
if isstruct(p)
  % pass
elseif ischar(p)
  % path to config.nml
  p = read_nml(p);
else
  error('model_setup:value_error', 'need path to config.nml')
end

if isempty(outdir)
  if ~isfield(p, 'outdir') || isempty(p.outdir)
    error('model_setup:file_not_found', 'please specify outdir or p.outdir')
  end
else
  % override with outdir regardless
  p.outdir = outdir;
end

makedir(p.outdir)
fprintf('copying config.nml to %s\n', p.outdir);
copy_file(p.nml, p.outdir)
%% allow output to new directory
if isfield(p, 'prec_dir')
  p.prec_dir = fullfile(p.outdir, path_tail(p.prec_dir));
end
if isfield(p, 'E0_dir')
  p.E0_dir = fullfile(p.outdir, path_tail(p.E0_dir));
end
%% is this equilibrium or interpolated simulation
if isfield(p, 'eqdir')
  model_setup_interp(p)
else
  model_setup_equilibrium(p)
end

if ~nargout, clear('p'), end
end % function
