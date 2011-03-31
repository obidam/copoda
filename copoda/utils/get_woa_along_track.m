% get_woa_along_track Interpolate World Ocean Atlas data along a ship track
%
% [val z] = get_woa_along_track(x,y,'VAR',[IM,DPT])
% 
% Interpolate World Ocean Atlas data along a ship track given by (x,y)
% VAR:
%	'temp','t','temperature','theta'
%	'psal','salt','s','salinity'
%	'oxyl'
%	'aou'
%	'oxsl'
%	'phos'
%	'nitr'
%	'silc'
%
% IM could be a numeric month number or a character for the annual clim
% 
% Rev. by Guillaume Maze on 2011-03-09: Now use WOA 2009
% Created: 2009-06-17.
% http://copoda.googlecode.com
% Copyright 2010, COPODA

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

function varargout = get_woa_along_track(varargin)

global nctbx_options;
preserv = nctbx_options;
clear global nctbx_options;

%%%%%%
X = varargin{1};
Y = varargin{2};
V = lower(strtrim(varargin{3}));
if nargin >= 4
	if isnumeric(varargin{4})
		tp = '0112'; % for monthly objectively analysed climatology on a 1x1 deg grid
		im = varargin{4};
	else
		tp = '00'; % for annual objectively analysed climatology on a 1x1 deg grid
		im = 1;
	end
else
	tp = '00'; % for annual objectively analysed climatology on a 1x1 deg grid
	im = 1;
end
	
if nargin == 5
	z = varargin{5};
else
	z  = fliplr(-5500+1:1:0);	
end	
	
% How to we find files:
pathi = abspath('~/data/WOA/2009/netcdf');

% Misc:
suff  = 'an1.nc';
switch tp
	case '0112' 
		atlas.name     = 'WOA09mc';
		atlas.longname = 'World Ocean Atlas 2009, Monthly Climatology';
	case '00';
		atlas.name     = 'WOA09ac';
		atlas.longname = 'World Ocean Atlas 2009, Annual Climatology';
end %switch


switch V
	case {'temp','t','temperature','theta'}
		field.name = 'THETA';
		field.longname = 'Temperature';
		field.unit = '^oC';
	case {'oxyl'}
		field.name = 'DIOX';
		field.longname = 'Dissolved oxygen';
		field.unit = 'ml/l';
	case {'aou'}
		field.name = 'AOU';
		field.longname = 'Apparent oxygen utilization';
		field.unit = 'ml/l';
	case {'psal','salt','s','salinity'}
		field.name = 'SALT';
		field.longname = 'Salinity';
		field.unit = 'PSU';
	case {'oxsl'}
		field.name = 'THETA';
		field2 = 'SALT';
		field.longname = 'Oxygen Solubility';
		field.unit = 'ml/l';
	case {'phos'}
		field.name = 'PHOS';
		field.longname = 'Phosphate';
		field.unit = 'mumol/l';
	case {'nitr'}
		field.name = 'NITR';
		field.longname = 'Nitrate';
		field.unit = 'mumol/l';
	case {'silc'}
		field.name = 'SILC';
		field.longname = 'Silicate';
		field.unit = 'mumol/l';
end

%%%%%%

% Load axis:
[t,dpt,lat,lon] = WOA09_grid(tp);
ndpt = length(dpt);
nlat = length(lat);
nlon = length(lon);
iX = find(lon>=nanmin(X) & lon<= nanmax(X));
iY = find(lat>=nanmin(Y) & lat<= nanmax(Y));

missval = 1e20;
nc = netcdf(sprintf('%s/WOA09_%s_%s%s',pathi,field.name,tp,suff),'nowrite');
if strfind(V,'oxsl'), nc2 = netcdf(sprintf('%s/WOA09_%s_%s%s',pathi,field2,tp,suff),'nowrite');end
Cout = zeros(length(X),length(z));

if nargout == 0,figure;iw=3;jw=1;subplot(iw,jw,1);plotworld;figure_tall;end

method = 0;
for ipt = 1 : length(X)
	iX = find(lon>=fix(X(ipt))-1 & lon<=fix(X(ipt))+1); x = lon(iX);
	iY = find(lat>=fix(Y(ipt))-1 & lat<=fix(Y(ipt))+1); y = lat(iY);
	if 0
		C  = nc{5}(im,:,iY,iX);
		if strfind(V,'oxsl'),C2 = nc2{5}(im,:,iY,iX); C2(abs(C2)>=missval) = NaN;end		
	else
		% Identify the correct field:
		[long_namelist var_name_list] = ncvarlongname(nc);
		[a incvar] = intersect(long_namelist,'Objectively Analyzed Climatology'); clear a
		C = nc{var_name_list{incvar}}(im,:,iY,iX);
		if strfind(V,'oxsl'),C2 = nc2{var_name_list{incvar}}(im,:,iY,iX); C2(abs(C2)>=missval) = NaN;end		
	end% if 
	
	C(abs(C)>=missval) = NaN;
	switch dim(C)
		case 3 % Annual field in 3D moved to 4D
			C = reshape(C,[1 size(C,1) size(C,2) size(C,3)]);
			if strfind(V,'oxsl'),
				C2 = reshape(C2,[1 size(C2,1) size(C2,2) size(C2,3)]);
%				C  = C2 + C;
				C = sw_satO2(C2,C);
			end
		case 4 % Monthly field already in 4D
	end
	
	switch method 
		case 0
			d = squeeze(nanmean(nanmean(C,3),4));
			% if strfind(V,'oxsl'),
			% 	d = squeeze(nanmean(nanmean(C,3),4));
			% end
			d = interp1(dpt,d,z);
			h = get_elev_along_track(X(ipt),Y(ipt));
			d(find(z<=h)) = NaN;
		case 1
			Xbuoy = X(ipt);
			Ybuoy = Y(ipt);
			dx = 1/16; dy = dx;
			xx = Xbuoy-dx:1/16:Xbuoy+dy; %xx = Xbuoy;
			yy = Ybuoy-dy:1/16:Ybuoy+dy; %yy = Ybuoy;
			[a b c]    = meshgrid(z,yy,xx);
			[dp la lo] = meshgrid(dpt,y,x);

			C = permute(squeeze(C(im,:,:,:)),[2 1 3]);
			s = interp3(dp,la,lo,C,a,b,c); s = permute(s,[2 1 3]);
		%	[find(squeeze(b(:,1,1))==Ybuoy) find(squeeze(c(1,1,:))==Xbuoy)]
			d = squeeze(s(:,find(squeeze(b(:,1,1))==Ybuoy),find(squeeze(c(1,1,:))==Xbuoy)));
	end %switch
	Cout(ipt,:) = d;

	if nargout == 0
		subplot(iw,jw,1);hold on; m_plot(X(ipt),Y(ipt),'r+');
		subplot(iw,jw,2);c=squeeze(nanmean(nanmean(C(im,:,:,:),3),4));plot(c,dpt,squeeze(mean(mean(C(im,:,:,:),3),4)),dpt);
		subplot(iw,jw,3);pcolor(1:length(X),z,Cout');shading flat
		drawnow
	end
	
end%for ipt
close(nc);clear nc
try,close(nc2);clear nc2,end

switch nargout
	case 1
		varargout(1) = {Cout};
	case 2
		varargout(1) = {Cout};
		varargout(2) = {z};
		
end

global nctbx_options;
nctbx_options = preserv;

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine topograpahy along ship track
function varargout = get_elev_along_track(varargin)

%
% h = get_elev_along_track(x,y)
% 
% Determine the bathymetry along the track given
% by vectors x,y.
%
%
% Created: 2009-06-16.
% Copyright (c) 2009 Guillaume Maze. 
% http://codes.guillaumemaze.org

%
% This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or any later version.
% This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

x = varargin{1};
y = varargin{2};
if nargin == 3
	N = varargin{3};
else
	N = Inf;
end

if isinf(N)
	X = x;
	Y = y;
else
%	X = interp1(1:length(x),x,1:N);
%	Y = interp1(1:length(y),y,1:N);
	a = linspace(1,length(x),N);
	X = interp1(1:length(x),x,a,'spline');
	Y = interp1(1:length(y),y,a,'spline');
end


for ipt = 1 : length(X)
	[el b c] = m_elev([X(ipt)*[1 1] Y(ipt)*[1 1]]);
	BAT(ipt) = nanmean(nanmean(el));
end

switch nargout
	case 1
		varargout(1) = {BAT};
	case 2
		varargout(1) = {BAT};
		varargout(2) = {[X;Y]};
	otherwise
		figure
		iw=2;jw=1;
		subplot(iw,jw,1);plot(x,y,'+');
		subplot(iw,jw,2);plot(BAT);xlabel('Station numbers');ylabel('Depth (m)');
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read World Ocean Atlas 2009 grid
function varargout = WOA09_grid(varargin)
%
% [t,z,y,x] = WOA09_grid(tp)
% 
% tp = '0112' for monthly atlas
% tp = '00' for climatology
%
% Created: 2011-03-09
% Copyright (c) 2011 Guillaume Maze. 
% http://codes.guillaumemaze.org

%
% This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or any later version.
% This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

pathi = abspath('~/data/WOA/2009/netcdf/');
switch nargin
	case 0
		fil   = 'WOA09_THETA_0112an1.nc';		
	case 1
		switch lower(varargin{1})
			case '0112'
				fil   = 'WOA09_THETA_0112an1.nc';
			case '00'
				fil   = 'WOA09_THETA_00an1.nc';
		end
end	

nc = netcdf(strcat(pathi,fil),'nowrite');
t  = nc{'time'}(:);
z  = nc{'depth'}(:);
y  = nc{'lat'}(:);
x  = nc{'lon'}(:);
close(nc);

% I prefer z negative, downward
z = -z;

% Adapt the longitude convention to the current COPODA one:
switch copoda_readconfig('copoda_longitude_classicsystem')
	case 0 % -180/180 (false) 
		x(x>180) = x(x>180)-360;
	case 1 % 0-360 (true)
		% Nothing to do, that's the WOA convention
end% switch 


switch nargout
	case 1
		varargout(1) = {t};
	case 2
		varargout(1) = {t};
		varargout(2) = {z};
	case 3	
		varargout(1) = {t};
		varargout(2) = {z};
		varargout(3) = {y};
	case 4
		varargout(1) = {t};
		varargout(2) = {z};
		varargout(3) = {y};
		varargout(4) = {x};
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read World Ocean Atlas 2005 grid
function varargout = WOA05_grid(varargin)
%
% [t,z,y,x] = WOA05_grid(tp)
% 
% tp = '0112' for monthly atlas
% tp = '00' for climatology
%
%
% Created: 2009-06-17.
% Copyright (c) 2009 Guillaume Maze. 
% http://codes.guillaumemaze.org

%
% This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or any later version.
% This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

pathi = abspath('~/data/WOA2005/netcdf/');
switch nargin
	case 0
		fil   = 'WOA05_THETA_0112an1.nc';		
	case 1
		switch lower(varargin{1})
			case '0112'
				fil   = 'WOA05_THETA_0112an1.nc';
			case '00'
				fil   = 'WOA05_THETA_00an1.nc';
		end
end	

nc = netcdf(strcat(pathi,fil),'nowrite');
t  = nc{'time'}(:);
z  = nc{'depth'}(:);
y  = nc{'lat'}(:);
x  = nc{'lon'}(:);
close(nc);

% I prefer z negative, downward
z = -z;

switch nargout
	case 1
		varargout(1) = {t};
	case 2
		varargout(1) = {t};
		varargout(2) = {z};
	case 3	
		varargout(1) = {t};
		varargout(2) = {z};
		varargout(3) = {y};
	case 4
		varargout(1) = {t};
		varargout(2) = {z};
		varargout(3) = {y};
		varargout(4) = {x};
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%