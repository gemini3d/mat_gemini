function plan = buildfile
plan = buildplan(localfunctions);

check_paths = ["+gemini3d/", "test"];

if ~isMATLABReleaseOlderThan("R2024a")

  plan("check") = matlab.buildtool.tasks.CodeIssuesTask(check_paths, ...
    IncludeSubfolders=true, ...
    WarningThreshold=0, Results="CodeIssues.sarif");

  plan("test") = matlab.buildtool.tasks.TestTask("test", Strict=false, TestResults="TestResults.xml");

elseif ~isMATLABReleaseOlderThan("R2023b")

  plan("check") = matlab.buildtool.tasks.CodeIssuesTask(check_paths, ...
    IncludeSubfolders=true, ...
    WarningThreshold=0);

  plan("test") = matlab.buildtool.tasks.TestTask("test", Strict=false);

end

if plan.isTask("test")
  plan.DefaultTasks = "test";
  plan("test").Dependencies = "setup";
end

end


function setupTask(~)

setup()

gemini3d.sys.macos_path()

% leave this assert here to fail CI as "setup()" only warns, and CI will seem to pass
% but actually be skipping several tests.
exe = gemini3d.find.gemini_exe("msis_setup");
assert(~isempty(exe), "need to setup Gemini3D and/or set environment variable GEMINI_ROOT")
end
