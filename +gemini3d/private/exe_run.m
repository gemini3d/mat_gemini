function ret = exe_run(cmd, mpiexec_ok)
  % intended to give option to run from py.subprocess if needed
  arguments
    cmd (1,1) string
    mpiexec_ok (1,1) logical
  end

  % p = pyenv;
  %
  % if ~isempty(p) && gemini3d.version_atleast(p.Version, "3.7")
  %   env = py.os.environ;
  %   env{"PATH"} = gemini3d.sys.mpi_path();
  %   ret =py.subprocess.check_call(cellstr(split(cmd)).', pyargs("env", env));
  %
  % else
    if mpiexec_ok
      cmd = gemini3d.sys.modify_path() + " " + cmd;
    end
    ret = system(cmd);
  % end

   end
