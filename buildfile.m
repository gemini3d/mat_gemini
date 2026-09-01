function plan = buildfile

assert(~isMATLABReleaseOlderThan('R2023a'), 'MatGemini requires Matlab >= R2023a. You are running Matlab %s', version())

plan = buildplan(localfunctions);
plan.DefaultTasks = "setup";

if isMATLABReleaseOlderThan("R2023b")
  plan("test_unit") = matlab.buildtool.Task(Actions=@(context) test_run(context, "unit"));
  plan("test_msis") = matlab.buildtool.Task(Actions=@(context) test_run(context, "msis"));
  plan("test_gemini") = matlab.buildtool.Task(Actions=@(context) test_run(context, "gemini"));
  plan("test") = matlab.buildtool.Task(Dependencies=["test_unit", "test_msis", "test_gemini"]);
else
  testTaskArgs = {fullfile(plan.RootFolder, "test"), "Strict", false};

  if ~isMATLABReleaseOlderThan("R2024a")
    testTaskArgs(end+1:end+2) = {"TestResults","TestResults.xml"};
  end

  if isMATLABReleaseOlderThan("R2024b")
    plan("test_unit") = matlab.buildtool.tasks.TestTask(testTaskArgs{:}, Tag="unit");
    plan("test_msis") = matlab.buildtool.tasks.TestTask(testTaskArgs{:}, Tag="msis");
    plan("test_gemini") = matlab.buildtool.tasks.TestTask(testTaskArgs{:}, Tag="gemini");
    plan("test") = matlab.buildtool.Task(Dependencies=["test_unit", "test_msis", "test_gemini"]);
  else
    plan("test:msis") = matlab.buildtool.tasks.TestTask(testTaskArgs{:}, Tag="msis");
    plan("test:gemini") = matlab.buildtool.tasks.TestTask(testTaskArgs{:}, Tag="gemini");
    plan("test:unit") = matlab.buildtool.tasks.TestTask(testTaskArgs{:}, Tag="unit");
    plan("test").Dependencies = "setup";
  end
end

if isMATLABReleaseOlderThan("R2024b")
  plan("test_unit").Dependencies = "setup";
  plan("test_msis").Dependencies = "setup";
  plan("test_gemini").Dependencies = "setup";
end

end


function setupTask(context, envfile)
arguments
  context
  envfile {mustBeTextScalar} = '~/gemini3d.env'
end

meta = jsondecode(fileread(fullfile(context.Plan.RootFolder, 'codemeta.json')));

setup_gemini3d(envfile, meta.softwareRequirements{1})

gemini3d.sys.macos_path()

exe = gemini3d.find.gemini_exe('msis_setup');
if isempty(exe)
  warning("need to setup Gemini3D 'cmake --workflow build && cmake --install build' and set environment variable GEMINI_ROOT")
end

gem_exe = gemini3d.find.gemini_exe('gemini.bin');
if isempty(gem_exe)
  warning("could not find gemini.bin")
end

end


function packageTask(context)

uuid = "dd893656-62a3-41c7-bbf5-c091313bc634";
name = "gemini3d";

opts = matlab.addons.toolbox.ToolboxOptions(context.Plan.RootFolder, uuid);
opts.OutputFile = fullfile(context.Plan.RootFolder, name + ".mltbx");

meta = fileread(fullfile(context.Plan.RootFolder, "codemeta.json"));
meta = jsondecode(meta);

opts.ToolboxName = meta.name;
% opts.ToolboxVersion = meta.version;
opts.ToolboxFiles = fullfile(context.Plan.RootFolder, "+" + name);

opts.SupportedPlatforms.Win64 = true;
opts.SupportedPlatforms.Mac = true;
opts.SupportedPlatforms.Glnxa64 = true;
opts.SupportedPlatforms.MatlabOnline = true;

opts.MinimumMatlabRelease = "R2024b";
opts.MaximumMatlabRelease = "";

opts.RequiredAddons = struct(Name="stdlib", ...
  Identifier="fd5ea185-e475-4416-af11-1c26cb6212b2", ...
  EarliestVersion="0.0", LatestVersion="999.0", ...
  DownloadURL=string(meta.softwareRequirements{1}));

matlab.addons.toolbox.packageToolbox(opts)

disp(opts.OutputFile + " created")

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


function test_run(context, tag)

test_root = fullfile(context.Plan.RootFolder, "test");

suite = testsuite(test_root, InvalidFileFoundAction="error", Tag=tag);

runner = testrunner('textoutput');
r = runner.run(suite);

assert(~isempty(r), 'No tests were run')

Lf = sum([r.Failed]);
Lok = sum([r.Passed]);
Lk = sum([r.Incomplete]);
Lt = numel(r);
assert(Lf == 0, sprintf('%d / %d tests failed', Lf, Lt))

if Lk
  fprintf('%d / %d tests skipped\n', Lk, Lt);
end

fprintf('%d / %d tests succeeded\n', Lok, Lt);

end
