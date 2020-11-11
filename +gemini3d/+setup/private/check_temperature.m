function check_temperature(T)

mustBeFinite(T)
mustBeNonnegative(T)
mustBeGreaterThan(max(T), 500)

end
