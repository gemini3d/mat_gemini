function valid = makeValidName(name)

if isoctave
  valid = genvarname(name);
else
  valid = matlab.lang.makeValidName(name);
end

end % function
