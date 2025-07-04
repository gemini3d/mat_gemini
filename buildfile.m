function plan = buildfile
import matlab.unittest.selectors.HasTag

plan = buildplan(localfunctions);
plan.DefaultTasks = "setup";

if ~isMATLABReleaseOlderThan("R2023b")
  codeIssuesArgs = {"IncludeSubfolders",true, "WarningThreshold",0};
  testTaskArgs = {"test", "Strict",false};

  if ~isMATLABReleaseOlderThan("R2024a")
    codeIssuesArgs(end+1:end+2) = {"Results","CodeIssues.sarif"};
    testTaskArgs(end+1:end+2) = {"TestResults","TestResults.xml"};
  end

  check_paths = ["+gemini3d/", "test/"];
  plan("check") = matlab.buildtool.tasks.CodeIssuesTask(check_paths, codeIssuesArgs{:});

  if isMATLABReleaseOlderThan("R2024b")
    plan("test") = matlab.buildtool.tasks.TestTask(testTaskArgs{:});
  else
    plan("test:msis") = matlab.buildtool.tasks.TestTask(testTaskArgs{:}, Tag="msis");
    plan("test:gemini") = matlab.buildtool.tasks.TestTask(testTaskArgs{:}, Tag="gemini");
    plan("test:unit") = matlab.buildtool.tasks.TestTask(testTaskArgs{:}, Tag="unit");
  end

  plan("test").Dependencies = "setup";
end

end


function setupTask(~, envfile)
arguments
  ~
  envfile {mustBeTextScalar} = ''
end

setup(envfile)

gemini3d.sys.macos_path()

% leave this assert here to fail CI as "setup()" only warns, and CI will seem to pass
% but actually be skipping several tests.
exe = gemini3d.find.gemini_exe("msis_setup");
assert(~isempty(exe), "need to setup Gemini3D and/or set environment variable GEMINI_ROOT")

gem_exe = gemini3d.find.gemini_exe("gemini.bin");
assert(~isempty(gem_exe), "could not find gemini.bin")


end
