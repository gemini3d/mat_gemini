function tests = test_dryrun
tests = functiontests(localfunctions);
end

function setupOnce(tc)

name = "2dew_eq";
tc.TestData.datapath = "+gemini3d/+tests/data/test" + name;

cwd = fileparts(mfilename('fullpath'));
% setup so GEMINI_ROOT is set
run(fullfile(cwd, "../../setup.m"))

% get files if needed
gemini3d.fileio.download_and_extract(name, fullfile(cwd, "data"))

% temporary working directory
tc.TestData.outdir = tc.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture('PreservingOnFailure', true)).Folder;

end


function test_MPIexec(tc) %#ok<INUSD>
gemini_exe = gemini3d.sys.get_gemini_exe();
gemini3d.sys.check_mpiexec("mpiexec", gemini_exe)
end


function test_dry_run(tc)

gemini3d.gemini_run(tc.TestData.outdir, ...
  'config', tc.TestData.datapath, ...
  'dryrun', true)
end
