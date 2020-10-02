function direc = caller2path()
%% gets caller path
% allows assuming top-level function path is desired path
stack = dbstack('-completenames', 1);

direc = string.empty;

if ~isempty(stack)
direc = fileparts(stack.file);
end
end
