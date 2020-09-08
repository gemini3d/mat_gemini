suite = matlab.unittest.TestSuite.fromPackage('gemini3d.tests');
names = {suite.Name};
Ntests = length(names);

test_count = 0;
for s = ["test_lint", "test_unit", "test_hdf5", "test_netcdf", "test_msis", ...
         "test_dryrun", "test_project_hdf5", "test_plot", "test_project_netcdf"]
  i = contains(names, s);
  result = run(suite(i));
  if any(cell2mat({result.Failed}))
    error(result.Name)
  end
  test_count = test_count + sum(i);
end

fprintf('ran %d / %d tests\n', test_count, Ntests)
