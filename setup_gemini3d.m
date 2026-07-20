function setup_gemini3d(envfile, stdlib_url)
arguments
  envfile {mustBeTextScalar} = ''
  stdlib_url {mustBeTextScalar} = ''
end

%% ensure matlab-stdlib is present
gemini3d.sys.check_stdlib(stdlib_url)

%% load environment file if it exists
e = stdlib.expanduser(envfile);
if isfile(e)
  disp("Loading environment file: " + e)
  loadenv(e)
end

%% check if msis_setup is found--needed to setup simulations
exe = gemini3d.find.gemini_exe("msis_setup");
if isempty(exe)
  warning("gemini3d:setup:FileNotFound", "If Gemini3D already installed, set environment variable GEMINI_ROOT to the top level Gemini3D install directory.")
end

disp("Using Gemini3D-MSIS " + exe)

end
