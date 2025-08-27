function mappingException(e)

if e.identifier ~= "MATLAB:UndefinedFunction"
  rethrow(e)
end

disp('Fallback to non-Mapping Toolbox functions')

end
