function plan = buildfile
plan = buildplan(localfunctions);
end

function setupTask(~)

setup()
setup_macos()

exe = gemini3d.sys.get_gemini_exe("msis_setup");
assert(~isempty(exe), "need to setup Gemini3D and/or set environment variable GEMINI_ROOT")
end

function lintTask(~)
assertSuccess(runtests("+gemini3d/+test/TestLint.m"))
end

function testTask(~)
assertSuccess(runtests('gemini3d.test'))
end
