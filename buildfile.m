function plan = buildfile
plan = buildplan(localfunctions);

check_paths = ["+gemini3d/", "test"];

if ~isMATLABReleaseOlderThan("R2023b")
  codeIssuesArgs = {"IncludeSubfolders",true, "WarningThreshold",0};
  testTaskArgs = {"test", "Strict",false};

  if ~isMATLABReleaseOlderThan("R2024a")
    codeIssuesArgs(end+1:end+2) = {"Results","CodeIssues.sarif"};
    testTaskArgs(end+1:end+2) = {"TestResults","TestResults.xml"};
  end

  plan("check") = matlab.buildtool.tasks.CodeIssuesTask(check_paths, codeIssuesArgs{:});
  plan("test") = matlab.buildtool.tasks.TestTask(testTaskArgs{:});

  plan.DefaultTasks = "test";
  plan("test").Dependencies = "setup";
end

end


function setupTask(~)

setup()

gemini3d.sys.macos_path()

% leave this assert here to fail CI as "setup()" only warns, and CI will seem to pass
% but actually be skipping several tests.
assert(~isempty(gemini3d.find.gemini_exe("msis_setup")), "need to setup Gemini3D and/or set environment variable GEMINI_ROOT")

end
