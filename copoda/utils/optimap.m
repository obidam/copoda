% optimap Plot a map optimized for a database or transect object
%
% Hlist = optimap(OBJ,[OPTIONS])
% 
% Plot a map optimized for a database or transect object, ie latitude,
% longitude, grid and topographic levels are optimized to fit the object.
%
% Inputs:
%	OBJ: either a database or a transect object.
%
% LIST OF OPTIONS:
% PROJECTION/RESOLUTION:
% 	projection = 'equid';
% 	RES = 'fhilco';
% COAST:
% 	coast      = true;
% 	coastcolor = [1 1 1]*0;
% 	landcolor  = [1 1 1]/2;
% TOPOGRAPHIC CONTOURS AND LABELS:
% 	topo       = false;
% 	topocolor  = [1 1 1]/2;
% 	topolevels = []; % leave it empty for automatic setting
% 	topolabels = false;
% 	topolabelslevels  = [];
% 	topolabelsoptions = {'rotation',0,'fontsize',6};
% GRID:
% 	dogrid = true;
% 	gridoptions = {'box','fancy'};
%
% Outputs:
%
%
% Created: 2010-05-06.
% http://copoda.googlecode.com
% Copyright 2010, COPODA

% Rev. by Guillaume Maze on 2010-05-27: Change the map limits in the case of strong aspect ratio
%
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
function varargout = optimap(OBJ,varargin)

%- Default parameters:
projection = 'equid';
%projection = 'mercator';
RES = '';
% Land and coast:
coast      = true;
coastcolor = [1 1 1]*0;
landcolor  = [1 1 1]/2;
% Topographic contours and labels:
topo       = false;
topocolor  = [1 1 1]/2;
topolevels = []; % leave it empty for automatic setting
topolabels = false;
topolabelslevels  = [];
topolabelsoptions = {'rotation',0,'fontsize',6};
% Grid:
dogrid = true;
gridoptions = {'box','fancy'};
%gridoptions = {'box','on'};

%- Load user parameters:
if nargin > 1
	for in = 1 : 2 : nargin-1
		eval(sprintf('%s = varargin{in+1};',varargin{in}));		
	end
end


%- First we get what we need:
if ispc, sla = '\'; else, sla = '/'; end
switch class(OBJ)
	case {'database','transect'}
		lat = extract(OBJ,'LATITUDE');  lat0 = lat;
		lat = [nanmin(lat) nanmax(lat)];
		lon = extract(OBJ,'LONGITUDE');	lon0 = lon;
%		lon(lon>=-180 & lon<0) = 360 + lon(lon>=-180 & lon<0); % Move to longitude east from 0 to 360	 
		lon = [nanmin(lon) nanmax(lon)];
	otherwise
		error('copoda:utils:optimap','Valid objects are database or transect')
end

%- Initiate the projection
% The projection is a function of lat and lon
% We insert some blank spaces to not have stations on the border of the grid
% The size of these spaces is a function of the size of the domain.
latfactor = 0.2; % Fraction of latitude  range to add at the top and bottom of the map
lonfactor = 0.2; % Fraction of longitude range to add at the right and left of the map
dlat = min([1 latfactor*abs(diff(lat))]);
dlon = min([1 lonfactor*abs(diff(lon))]);
LAT = [max([-90 lat(1)-dlat]) min([ 90 lat(2)+dlat])];
%LON = [max([0 lon(1)-dlon]) min([360 lon(2)+dlon])];
LON = [lon(1)-dlon lon(2)+dlon];

%
%abs(diff(LAT))./abs(diff(LON))
if abs(diff(LAT))./abs(diff(LON)) < .3 & 1
	ii = 0; done = 0;
	while done ~= 1
		ii = ii + 1;
		LAT = [max([-90 lat(1)-ii*dlat]) min([ 90 lat(2)+ii*dlat])];
		if ii==40 | abs(diff(LAT))./abs(diff(LON)) >= 1
			done = 1;
		end
	end
end
if abs(diff(LAT))./abs(diff(LON)) > 1.5
	ii = 0; done = 0;
	while done ~= 1
		ii = ii + 1;	
		dlon = min([1 lonfactor*abs(diff(lon))]);
		LON = [lon(1)-ii*dlon lon(2)+ii*dlon];
		if ii==40 | abs(diff(LAT))./abs(diff(LON)) <= 1
			done = 1;
		end
	end
end

% Set projection:
if median(lat0) > 70
%	m_proj('stereo','lon',median(lon0),'lat',90,'rad',90-abs(min(LAT)));
	m_proj('stereo','lon',median(lon0),'lat',median(lat0),'rad',(abs(diff(LAT))+dlat)/2)
elseif median(lat0) < -70
	m_proj('stereo','lon',median(lon0),'lat',-90,'rad',90-abs(max(LAT)));
else
	m_proj(projection,'lon',LON,'lat',LAT);
end

%- Draw coast with adapted resolution
if isempty(RES)
	RES = getRES(LAT,LON); 
end
if coast
	switch RES
		case 'o'  % USE m_coast
			m_coast('patch',landcolor,'edgecolor',coastcolor);
		
		otherwise % USE m_gshhs/m_usercoast
			% This function is slow when reading GSHHS bin files, so we save them in mats file in the data folder
			gshmat = sprintf('%s%sgshhs_%s.mat',copoda_readconfig('copoda_data_folder'),sla,RES);
			if ~exist(gshmat,'file')	
				m_proj('equid','lon',[0 360],'lat',[-90 90]);
				m_gshhs([RES 'c'],'save',gshmat);
				m_proj('equid','lon',LON,'lat',LAT);	
			end
			% Realy plot the coasts:
			m_usercoast(gshmat,'patch',landcolor,'edgecolor',coastcolor);
	end
end


%- Draw topography with adapted resolution and levels
if topo
	ii = findobj(gcf,'tag','topography');
	if ~isempty(ii)
		warning('There''re already topographic datas on this figure !');
	end
	
	switch RES
		case {'o','c'}
			method = 'm_elev';
		case {'l','i','h','f'}
			method = 'm_etopo2';
	end
	
	if isempty(topolevels)
		topoM = [-10000 -10];
		switch RES
			case {'o','c'},dz = 1000;
			case {'l','i'},dz = 500;
			case 'h',	dz = 250;
			case 'f',   dz = 100;
		end
		topoC = topoM(1):dz:topoM(2);
	else % User defined:
		topoC = topolevels;
	end
	[cs,h] = feval(method,'contour',topoC,'edgecolor',topocolor);
%	[cs,h] = m_etopo2('contour',topoC,'edgecolor',topocolor);
	if topolabels
		if ~isempty(topolabelslevels)
			[cs,h] = feval(method,'contour',topolabelslevels,'edgecolor',topocolor,'linewidth',1.2);			
%			[cs,h] = m_etopo2('contour',topolabelslevels,'edgecolor',topocolor,'linewidth',1.2);
			clabel(cs,h,topolabelsoptions{:});			
		else
			clabel(cs,h,topolabelsoptions{:});	
		end
	end
	set(h,'tag','topography');
end%

%- set up the grid
if dogrid
	m_grid(gridoptions{:});
end

end %functionoptimmap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RES = getRES(LAT,LON);

% The resolution of the coast line will depend on the size of the domain
dd = max([ abs(diff(LAT))  abs(diff(LON)) ]);

resc = 'fhilco'; % 6 levels of resolution
resn = [0 1 5 10 20 50 Inf];
RES  = resc(find(resn>=dd,1)-1);

%disp(sprintf('Resolution is ''%s'' (max size %0.0f)',RES,dd));

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%












