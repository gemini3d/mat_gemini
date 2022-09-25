function cAur = loadglow_aurmap(filename)
%% loads simulated auroral emissions
arguments
  filename (1,1) string
end

cAur = squeeze(h5read(filename, '/aurora/iverout'));

end
