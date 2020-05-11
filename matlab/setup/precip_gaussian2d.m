function [Q] = precip_gaussian2d(pg, Qpeak, Qbackground)
%% makes a 2D Gaussian shape in Latitude, Longitude

mlon_sigma = pg.mlon_sigma;
mlat_sigma = pg.mlat_sigma;

if mlat_sigma < eps(1), mlat_sigma = eps(1); end
if mlon_sigma < eps(1), mlon_sigma = eps(1); end

Q = Qpeak * ...
    exp(-(pg.MLON - pg.mlon_mean).^2 / (2*mlon_sigma^2)) .* ...
    exp(-(pg.MLAT - pg.mlat_mean).^2 / (2*mlat_sigma^2));

Q(Q < Qbackground) = Qbackground;

end % function
