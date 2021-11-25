function r = root()
%% return top-level MatGemini path

root = string(what('gemini3d').path);
r = root(1);

end
