function hf = make_glowfig(visible)
arguments
  visible (1,1) logical
end

hf = figure('toolbar', 'none', 'Name', 'aurora', 'Unit', 'pixels',  'Visible', visible);
pos = get(hf, 'position');
set(hf, 'position', [pos(1), pos(2), 800, 500])

end
