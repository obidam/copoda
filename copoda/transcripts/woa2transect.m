% woa2transect Create a transect object from the annual WOA 2009 climatology
%
% T = woa2transect(LON,LAT,[DEPH,VARLIST,VERSION])
% 
% Create a transect object from the annual World Ocean Atlas 2009 climatology
% along the coordinates given by LON,LAT and eventually on the vertical grid
% given by DEPH.
%
% Inputs:
%	LON,LAT: Longitude/Latitude of points to interpolate the WOA on.
%	DEPH: a 1xN_LEVELS or N_STATIONSxN_LEVELS tables of depth to interpolate 
%		the WOA on. By default interpolate on a 1m grid.
%	VARLIST: List of variables to load. Cell of string from:
%		temp,oxyl,aou,psal,oxsl,phos,nitr,silc
%	VERSION: World Ocean Atlas version to use. A string with '2009'. The '2005'
% 		version is not supported anymore.
%
% Outputs:
%	T: a transect object from WOA datas
%
% Rev. by Guillaume Maze on 2013-11-28: Removed support for the 2005 version
% Rev. by Guillaume Maze on 2013-11-28: Now use the Matlab builtin netcdf library
% Rev. by Guillaume Maze on 2011-03-09: Now can use WOA 2009 or 2005
% Created: 2010-05-26.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = woa2transect(varargin)

%- Load default and user options:
DEPH = fliplr(-5500+1:50:0);
varlist = {'temp','psal','oxyl'};
ver = '2009';

LON = varargin{1}; LON = LON(:);
LAT = varargin{2}; LAT = LAT(:);

if nargin >= 3
	DEPH = varargin{3};
end% if 
if length(LON) ~= length(LAT)
	error('Longitude and latitude must be of similar size');
end
if nargin >= 4
	varlist = varargin{4};
end% if 
if nargin >= 5
	ver = varargin{5};
end% if 

%- Init transect object:
T = transect;
T.source  = 'National Oceanographic Data Center';
switch ver
	case '2005'
		error('This version of the Atlas is not supported anymore ! Please use 2009');
	case '2009'
		T.file    = 'ftp://ftp.nodc.noaa.gov/pub/data.nodc/woa/WOA09/NetCDFdata';
	otherwise
		error('Unknown WOA version, please use ''2005'' or ''2009''');
end% switch 

N_STATION = length(LAT);

%- Axis:
T.geo.LATITUDE  = LAT;
T.geo.LONGITUDE = LON;
T.geo.DEPH = DEPH;
T.geo.STATION_NUMBER = [1 : N_STATION]';
T.geo.STATION_DATE   = datenum(1000,1,1,0,0,0)*ones(N_STATION,1);
T.geo.POSITIONING_SYSTEM = {'Regular Grid !'};
if size(DEPH) ~= size(LAT)
	% This is probably because DEPTH is 2D
	lat = meshgrid(LAT,1:size(DEPH,2))';
	T.geo.PRES = sw_pres(abs(DEPH),lat);
	T.geo.MAX_PRESSURE = sw_pres(abs(get_elev_along_track(LON,LAT)'),LAT);
else	
	T.geo.PRES = sw_pres(abs(DEPH),LAT);
	T.geo.MAX_PRESSURE = sw_pres(abs(get_elev_along_track(LON,LAT)'),LAT);
end% if 

%- Variables:
for iv = 1 : length(varlist)
	switch ver
		case '2005'
			error('Need to be updated !');
			[val z atlas field] = woa05_along_track(LON,LAT,varlist{iv},'00',DEPH);
		case '2009'
			[val z atlas field] = woa09_along_track(LON,LAT,varlist{iv},'00',DEPH);
	end% switch 
	
	
	% Create OData object:
	od = odata('name',upper(varlist{iv}),'long_name',field.longname,'unit',field.unit,'long_unit',field.unit,...
			'cont',val);
			
	% Update transect:
	T = subsasgn(T,substruct('.','data','.',upper(varlist{iv})),od);
	
end
T = clean_empty_variables(T);

%- Cruise info:
T.cruise_info = cruise_info('NAME',sprintf('World Ocean Atlas %s',ver),'PI_NAME','','PI_ORGANISM','NODC','N_STATION',N_STATION);

%- Validate
%[res T] = validate(T,0,1);

%- Output
varargout(1) = {T};

end %functionwoa2transect
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_woa_along_track Interpolate World Ocean Atlas data along a ship track
function varargout = woa09_along_track(varargin)
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
% Rev. by Guillaume Maze on 2013-11-28: Now use the matlab netcdf builtin library
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
pathi = whereisWOA('2009');

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
nc = netcdf.open(sprintf('%s/WOA09_%s_%s%s',pathi,field.name,tp,suff));
if strfind(V,'oxsl'), nc2 = netcdf.open(sprintf('%s/WOA09_%s_%s%s',pathi,field2,tp,suff));end
Cout = zeros(length(X),length(z));

if nargout == 0,figure;iw=3;jw=1;subplot(iw,jw,1);plotworld;figure_tall;end

method = 0;
for ipt = 1 : length(X)
	iX = find(lon>=fix(X(ipt))-1 & lon<=fix(X(ipt))+1); x = lon(iX);
	iY = find(lat>=fix(Y(ipt))-1 & lat<=fix(Y(ipt))+1); y = lat(iY);

	% This is for the 2009 version:
	% Identify the correct field:
	[long_namelist var_name_list] =  netcdf.listVarLongName(nc);
	[a incvarid] = intersect(long_namelist,'Objectively Analyzed Climatology'); clear a
	C = netcdf.getVar(nc,incvarid,[iX(1)-1 iY(1)-1 0 im-1],[length(iX) length(iY) ndpt 1]); C = permute(C,[3 2 1]);
	C(abs(C)>=missval) = NaN;

	if strfind(V,'oxsl'),
		C2 = netcdf.getVar(nc2,incvarid,[iX(1)-1 iY(1)-1 0 im-1],[length(iX) length(iY) ndpt 1]); C2 = permute(C2,[3 2 1]);
		C2(abs(C2)>=missval) = NaN;
	end% if 

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
			d = interp1(dpt,d,z(ipt,:));
			h = get_elev_along_track(X(ipt),Y(ipt));
			d(find(z(ipt,:)<=h)) = NaN;
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
netcdf.close(nc);clear nc
try,netcdf.close(nc2);clear nc2,end

switch nargout
	case 1
		varargout(1) = {Cout};
	case 2
		varargout(1) = {Cout};
		varargout(2) = {z};
	case 3
		varargout(1) = {Cout};
		varargout(2) = {z};
		varargout(3) = {atlas};
	case 4
		varargout(1) = {Cout};
		varargout(2) = {z};
		varargout(3) = {atlas};
		varargout(4) = {field};
		
end

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
% Created: 2011-03-9
% Rev. by Guillaume Maze on 2013-11-28: Now use the matlab netcdf builtin library
% Copyright (c) 2011 Guillaume Maze. 
% http://codes.guillaumemaze.org

%
% This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or any later version.
% This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

pathi = whereisWOA('2009');
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

nc = netcdf.open(strcat(pathi,fil));
t = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'time')));
z = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'depth')));
y = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'lat')));
x = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'lon')));
netcdf.close(nc);

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
function pathi = whereisWOA(ver)
	switch ver
		case '2009'
			pathi = fullfile(getenv('HOME'),'data','WOA','2009','netcdf',filesep);
		case '2005'
			pathi = fullfile(getenv('HOME'),'data','WOA','2005','netcdf',filesep);
	end% switch 	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%