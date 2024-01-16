function plan = buildfile
plan = buildplan(localfunctions);
plan.DefaultTasks = "test";
plan("test").Dependencies = ["check", "setup"];
end

function checkTask(~)
% Identify code issues (recursively all Matlab .m files)
issues = codeIssues;
assert(isempty(issues.Issues),formattedDisplayText(issues.Issues))
end

function setupTask(~)

macos_path()
setup()

exe = gemini3d.find.gemini_exe("msis_setup");
assert(~isempty(exe), "need to setup Gemini3D and/or set environment variable GEMINI_ROOT")
end

function testTask(~, test_name)
arguments
  ~
  test_name (1,1) string = "*"
end

r = runtests('gemini3d.test', Name="gemini3d.test." + test_name);

assert(~isempty(r))
assertSuccess(r)
end
