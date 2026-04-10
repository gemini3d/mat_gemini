function plan = buildfile

plan = buildplan(localfunctions);
plan.DefaultTasks = "setup";

if ~isMATLABReleaseOlderThan("R2023b")
  testTaskArgs = {"test/", "Strict", false};

  if ~isMATLABReleaseOlderThan("R2024a")
    testTaskArgs(end+1:end+2) = {"TestResults","TestResults.xml"};
  end

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
  envfile {mustBeTextScalar} = '~/gemini3d.env'
end

setup(envfile)

gemini3d.sys.macos_path()

% leave this assert here to fail CI as "setup()" only warns, and CI will seem to pass
% but actually be skipping several tests.
exe = gemini3d.find.gemini_exe('msis_setup');
assert(~isempty(exe), "need to setup Gemini3D 'cmake --workflow build && cmake --install build' and set environment variable GEMINI_ROOT")

gem_exe = gemini3d.find.gemini_exe('gemini.bin');
assert(~isempty(gem_exe), "could not find gemini.bin")
end


function checkTask(context)
root = context.Plan.RootFolder;

c = codeIssues(root + ["/test", "/+gemini3d"]);

if isempty(c.Issues)
  fprintf('%d files checked OK with %s under %s\n', numel(c.Files), c.Release, root)
else
  disp(c.Issues)
  error("Errors found in " + join(c.Issues.Location, newline))
end

end
