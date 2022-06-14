function plan = buildfile
plan = buildplan(localfunctions);
end

function setupTask(~)
setup()
setup_macos()
end

function testTask(~)
assertSuccess(runtests('gemini3d.tests'))
end
