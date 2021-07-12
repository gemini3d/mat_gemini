function check_drift(v)

mustBeFinite(v)
mustBeLessThan(abs(v), 100e3)

end
