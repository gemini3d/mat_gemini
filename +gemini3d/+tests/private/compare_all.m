function compare_all(tc, outdir, refdir, opts)
%% compare entire output directory data files, and input files
%
% absolute and relative tolerance account for slight IEEE-754 based differences,
% including non-associative, non-commutative floating-point arithmetic.
% these parameters are a bit arbitrary.

% per MZ Oct 17, 2018:
% Ti,Te=1 K
% ne=1e6 m-3
% vi,v2,v3=1 m/s
% J1,J2,J3 = 1e-9

% MZ wants to change what we consider signficant...
% Ti,Te=5 K
% ne=1e7 m-3
% vi,v2,v3=2 m/s
% J1,J2,J3 = 1e-9

arguments
  tc (1,1) matlab.unittest.TestCase
  outdir (1,1) string
  refdir (1,1) string
  opts.only (1,:) string = string.empty
  opts.file_format string = string.empty
end

tol.rtol = 1e-5;
tol.rtolN = 1e-5;
tol.rtolT = 1e-5;
tol.rtolJ = 1e-5;
tol.rtolV = 1e-5;
tol.atol = 1e-8;
tol.atolN = 1e9;
tol.atolT = 100;
tol.atolJ = 1e-7;
tol.atolV = 50;

assert(~gemini3d.fileio.samepath(outdir, refdir), outdir + " and " + refdir + " are the same folder.")

%% check output dirs
if isempty(opts.only) || strlength(opts.only) == 0 || any(opts.only == "out")
  compare_output(tc, outdir, refdir, tol);
end
%% check input dirs
if isempty(opts.only) || strlength(opts.only) == 0 || any(opts.only == "in")
  compare_input(tc, outdir, refdir, tol, opts.file_format);
end

end % function
