%% GEMINI_NAMELIST reads simulation config*.nml Fortran namelist files
% Fortran namelist is a standard format.
% returns a struct with the namelist variables as fields.
function p = gemini_namelist(apath)
arguments
  apath (1,1) string
end

fn = gemini3d.find.config(apath);
assert(~isempty(fn), "Invalid simulation directory: no simulation config file config.nml found in " + apath)

%% required namelists
p = gemini3d.read.namelist(fn, 'base');

t0 = datetime(p.ymd(1), p.ymd(2), p.ymd(3)) + seconds(p.UTsec0);
p.times = t0:seconds(p.dtout):(t0 + seconds(p.tdur));

p = merge_struct(p, gemini3d.read.namelist(fn, 'flags'));
p = merge_struct(p, gemini3d.read.namelist(fn, 'files'));

%% optional namelists
if ~isfield(p, 'nml')
  p.nml = fn;
end

p = read_if_present(p, fn, 'setup');
if isfield(p, 'eqdir')
  p.eq_dir = p.eqdir;
end

if isfield(p, 'setup_functions')
  if ischar(p.setup_functions)
    p.setup_functions = string({p.setup_functions});
  end
end

%% neutral_perturb
p = read_if_present(p, fn, 'neutral_perturb');
if isfield(p, 'source_dir')
  p.sourcedir = p.source_dir;
end

if ~isfield(p, 'sourcemlat'), p.sourcemlat = []; end
if ~isfield(p, 'sourcemlon'), p.sourcemlon = []; end

p = read_if_present(p, fn, 'neutral_BG');

p = read_if_present(p, fn, 'precip');
% don't make prec_dir absolute here, to respect upcoming p.outdir

p = read_if_present(p, fn, "precip_BG");

p = read_if_present(p, fn, 'efield');
% don't make E0_dir absolute here, to respect upcoming p.outdir

p = read_if_present(p, fn, 'glow');

p = read_if_present(p, fn, 'milestone');

p = read_if_present(p, fn, 'aurora_parameters');

p = read_if_present(p, fn, 'replication');

end


function p = read_if_present(p, fn, namelist)
%% READ_IF_PRESENT read a namelist, if it exists
% otherwise don't modify the input struct

try
  p = merge_struct(p, gemini3d.read.namelist(fn, namelist));
catch excp
  if excp.identifier ~= "gemini3d:read:namelist:namelist_not_found"
    rethrow(excp)
  end
end

end
