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

setup()
setup_macos()

exe = gemini3d.find.gemini_exe("msis_setup");
assert(~isempty(exe), "need to setup Gemini3D and/or set environment variable GEMINI_ROOT")
end

function testTask(~)
assertSuccess(runtests('gemini3d.test'))
end
