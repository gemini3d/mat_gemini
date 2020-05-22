function Q = precip_gaussian2d(pg, Qpeak, Qbackground)
%% makes a 2D Gaussian shape in Latitude, Longitude

if all(isfield(pg, {'mlon_sigma', 'mlat_sigma'}))
  Q = Qpeak * ...
    exp(-(pg.MLON - pg.mlon_mean).^2 / (2*pg.mlon_sigma^2)) .* ...
    exp(-(pg.MLAT - pg.mlat_mean -1.5*pg.mlat_sigma).^2 / (2*pg.mlat_sigma^2));
elseif isfield(pg, 'mlon_sigma')
  Q = Qpeak * exp(-(pg.MLON - pg.mlon_mean).^2 / (2*pg.mlon_sigma^2));
elseif isfield(pg, 'mlat_sigma')
  Q = Qpeak * exp(-(pg.MLAT - pg.mlat_mean).^2 / (2*pg.mlat_sigma^2));
else
  error('precip_gaussian2d:lookup_error', 'precipation must be defined in latitude, longitude or both')
end

Q(Q < Qbackground) = Qbackground;

end % function
