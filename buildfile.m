function plan = buildfile
plan = buildplan(localfunctions);
end

function setupTask(~)

setup()
setup_macos()

exe = gemini3d.sys.get_gemini_exe("msis_setup");
if isempty(exe)
  setup_gemini3d()
end

end

function testTask(~)
assertSuccess(runtests('gemini3d.tests'))
end
