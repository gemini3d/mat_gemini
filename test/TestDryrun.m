classdef TestDryrun < matlab.unittest.TestCase

properties
  datapath
  outdir
end

methods(TestClassSetup)

function check_stdlib(tc)
try
  gemini3d.sys.check_stdlib()
catch e
  tc.fatalAssertFail(e.message)
end
end

function check_root(tc)
try
  gemini3d.root();
catch e
  tc.fatalAssertFail(e.message)
end
end


function check_mpiexec(tc)
[s, ~] = system('mpiexec -help');
tc.assumeEqual(s, 0, "MPIEXEC not found or working")
end


function setup_sim(tc)

n = "gemini3d.run";

exe = gemini3d.find.gemini_exe(n);
tc.assumeNotEmpty(exe, n +" program not found. Compile with https://github.com/gemini3d/gemini3d.git")

name = "mini2dew_eq";

cwd = fileparts(mfilename('fullpath'));
tc.datapath = fullfile(cwd, "data", name);

% get files if needed
try
  gemini3d.fileio.download_and_extract(name, fullfile(cwd, "data"))
catch e
  catcher(e, tc)
end
tc.outdir = tc.createTemporaryFolder();
end

end


methods(Test, TestTags="gemini")


function test_dryrun(tc)

try
  gemini3d.run(tc.outdir, tc.datapath, dryrun=true)
catch e
  catcher(e, tc)
end

end
end

end
