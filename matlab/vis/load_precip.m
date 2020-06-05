function dat = load_precip(filename)

dat.Q = h5read(filename, '/Qp');
dat.E0 = h5read(filename, '/E0p');

end % function