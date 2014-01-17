% profile Plot one chart per variable and per station
%
% [] = profile(T,[OPTION,VALUE])
% 
% Plot vertical profile(s) using the transect object T.
% This method can overlay more than one station on a single axes
% but no more than one variable.
%
% List of options: 
% 	'VARN' (VALUE: cell of strings)
% 		List of variables to plot.
%		It can be any output from: datanames(T).
% 		Default: 'TEMP'
% 		If more than one variable is specified, see option 'groupedby'
% 		to control how axes will be grouped.
%	'groupedby' (VALUE: string)
% 		Define how to group the plot.
% 		It can be one of the following:
%			'none': one figure per variable (multiple figures).
%			'fig':  one subplot per variable (single figure).
% 		Default: 'none'
% 	'chart' (VALUE: string)
% 		Define the type of chart to use.
% 		It can be one of the following:
% 			'line': Use a classic line chart
% 			'bar' : Use a horizontal bar chart (only for one station)
% 		Default: 'line'
%	'iS' (VALUE: double or string)
% 		Station index to plot.
%		It can be one or more integers between 1 and size(T,1)
%		or 'all' to use all stations.
% 		Default: 1
%	'reducer' (VALUE: function handle or string)
% 		Reduce data to the output of a function applied to profiles given by option iS
% 		along level index.
%		It can be a function handle or one of the following mashup:
% 			'stats': Plot mean-std/mean/mean+std
% 			'range': Plot min/median/max along
% 		No default value
% 
%	'ztyp' (VALUE: string)
% 		Vertical axis
% 		Any T.geo property (DEPH, PRES, etc ...)
% 		Default: 'DEPH'
%	'zlab' (VALUE: string)
% 		Label for the vertical axis
% 		Default: '(m)'
%	'zlim' (VALUE: double)
% 		Limits of the vertical axis
% 		Default: 'auto'
%	'xlim' (VALUE: cell array of doubles)
% 		Limits of the horizontal axis, one pair for each variables in VARN.
% 		Default: 'auto'
% 
% Eg:
% 	profile(T); % Use default options
%	profile(T,'iS',5) % Plot 5th profile
%	profile(T,'VARN',{'TEMP';'PSAL'}); % Plot temperature and salinity from the 1st profile (two figures)
%	profile(T,'VARN',{'TEMP';'PSAL'},'groupedby','fig'); % Same as above using subplots on a single figure
% 	profile(T,'VARN','TEMP','reducer',@nanmean); % Plot mean temperature profile
% 	profile(T,'VARN',datanames(T),'iS',7,'groupedby','fig'); % Plot 7th profile of all existing variables on a single figure
% 	profile(T,'VARN',datanames(T),'iS','all','groupedby','fig','reducer','stats');
%
% See Also:
%	multiprofiles, datanames
%
% Rev. by Guillaume Maze on 2014-01-17: Extreme make over ! No backward compatible !
% 	Added reducer, groupedby and chart options. Remove call to multiprofiles method.
% Rev. by Guillaume Maze on 2011-05-24: Added 'xtyp' option to call 'multiprofiles' by default
% Created: 2010-05-25.
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
function varargout = profile(T,varargin)
	
%- Default options:

%-- Define the Y axis
ztyp = 'DEPH';   

%-- Define the X axis
VARN = {'TEMP'}; % one figure per variable (multiple figures could be open)
xlim = {'auto'};

%-- Which station index ?
iS = 1;

%-- How to group the plots ?
groupedby = 'none'; % Plot one variable per figure (no grouping)
%groupedby = 'fig';  % Plot one variable per subplot on a single figure

%-- Type of chart:
chart = 'line';

%-- Detailled options for line charts:
linechart = {'color','k','linewidth',1,'linestyle','-','marker','none','markersize',6,'markeredgecolor','auto','markerfacecolor','none'};
linechart_opts = linechart(1:2:end);

%-- Detailled options for bar charts:
barchart = {'barwidth',1,'facecolor','flat','edgecolor','k','linestyle','-'};
barchart_opts = barchart(1:2:end);

%- Load User options:
if mod(nargin-1,2) ~=0
	error('Arguments must come in pair: OPTION,VALUE')
end% if
% Load all options:
for in = 2 : 2 : nargin-1
	eval(sprintf('%s = varargin{%i};',varargin{in-1},in));
end% for in

% Load chart specific options:
for in = 2 : 2 : nargin-1
	switch chart
		case 'line' % Load options for line charts:
			if ~isempty(intersect(linechart_opts,varargin{in-1}))
				[opt iopt] = intersect(linechart_opts,varargin{in-1});
				linechart{2*iopt} = varargin{in};
			end% if
		case 'bar' % Load options for bar charts:
			if ~isempty(intersect(barchart_opts,varargin{in-1}))
				[opt iopt] = intersect(barchart_opts,varargin{in-1});
				barchart{2*iopt} = varargin{in};
			end% if
	end% switch 	
end% for in

%-- Adjust Y axis metadata
switch ztyp
	case 'DEPH'
		if ~exist('zlab','var'), zlab = 'Depth (m)'; end% if 
		if ~exist('zdir','var'), zdir = 'normal'; end% if 
		if ~exist('zlim','var'), zlim = 'auto'; end% if 
		
	case 'PRES'
		if ~exist('zlab','var'), zlab = 'Pression (hPa)'; end% if 
		if ~exist('zdir','var'), zdir = 'reverse'; end% if
		if ~exist('zlim','var'), zlim = 'auto'; end% if 
	
	otherwise
		if ~exist('zlab','var'), zlab = ztyp; end% if 
		if ~exist('zdir','var'), zdir = 'normal'; end% if
		if ~exist('zlim','var'), zlim = 'auto'; end% if 		
		warning('Using an un-documented vertical axis');
end% switch 

%-- Shortcuts of iS='all'
if ischar(iS) & strcmp(iS,'all') % | strcmp(iS,'mean') | strcmp(iS,'std') | strcmp(iS,'stat'))
	if strcmp(chart,'bar')
		error('You cannot use a bar chart with more than one station !')
	else
		iS = 1:size(T,1);
	end% if 
end% if 

%-- Identify the reducer function
if exist('reducer') 
	if isa(reducer,'function_handle')
		%
	elseif strcmp(reducer,'stats') 		
		reducer = @stats;		
	elseif strcmp(reducer,'range')
		reducer = @range;
	end% if 
	%
else	
	reducer = @none;
end% if 

%-- X (variables) limit:
% Define one per variable in a cell array
if ~iscell(xlim)
	xlim = {xlim};
end% if 
if length(xlim) == 1 & length(VARN) > 1
	for iv = 2 : length(VARN)
		xlim{iv} = xlim{1};
	end% for iv
end% if 

%- Determine the vertical axis:
z = subsref(T,substruct('.','geo','.',ztyp));
switch size(z,1) == size(T,1)
	case true
		z = z(iS,:);			
	case false
		z = meshgrid(z,1:length(iS));
end% switch


%- Create charts
switch groupedby
	case 'multi'
		error('Deprecated option, use multiprofile method');
		
	case 'none' %-- One figure per variable, no grouping
		
		for iv = 1 : length(VARN)
			od = subsref(T,substruct('.','data','.',VARN{iv}));
			od.cont = od.cont(iS,:);
			
			figure('tag','profile_plot'); hold on
			set(gcf,'name',sprintf('%s (%s)',stamp(T,5),od.name));	
			
			%--- Get chart data:
			[X Y ReducerLabel] = getXY(od,z,iS,reducer);

			%--- Create chart:
			switch chart
				case 'line'
					p = plot(X',Y',linechart{:});
				case 'bar'
					p = barh(Y,X,barchart{:});
				case 'area'
					stophere
					p = area(Y,X);
				otherwise
					error('Unknown chart type');
			end% switch 

			%--- Misc:
			grid on
			box on
			axis tight
			
			%--- Set up X,Y axis:
			xlabel(sprintf('%s (%s)',od.unit,od.long_unit));
			if ~strcmp(xlim{iv},'auto')
				set(gca,'xlim',xlim{iv});
			end% if
			
			ylabel(zlab);
			if ~strcmp(zlim,'auto')
				set(gca,'ylim',zlim);
			end% if
			set(gca,'ydir',zdir);
			
			%--- Title
			tit = stamp(T,6);
			tit = sprintf('%s\n%s (%s)',tit,od.name,od.long_name);			
			if length(iS) > 1
				if length(iS) > 10
					if isempty(setdiff(1:size(T),iS))
						tit = sprintf('%s\n%s all STATION TRANSECT INDEX',tit,ReducerLabel);						
					else
						tit = sprintf('%s\n%s STATION TRANSECT INDEX: %s [...]',tit,ReducerLabel,num2str(iS(1:10)));
					end% if 
				else
					tit = sprintf('%s\n%s STATION TRANSECT INDEX: %s',tit,ReducerLabel,num2str(iS));
				end% if 
			else
				tit = sprintf('%s\nLAT=%0.1f, LON=%0.1f, TIME=%s\nSTATION NUMBER %i, STATION TRANSECT INDEX %i',tit,T.geo.LATITUDE(iS),T.geo.LONGITUDE(iS),datestr(T.geo.STATION_DATE(iS)),T.geo.STATION_NUMBER(iS),iS);					
			end% if
			title(tit,'fontweight','bold','interpreter','none');
			
			%--- Add the COPODA toolbar
			setappdata(gcf,'var_plotted',VARN(iv));
			copoda_figtoolbar(T);
			
		end% for iv
		
		
		
	case 'fig' %-- One subplot

		figure('tag','profile_plot');
		set(gcf,'name',sprintf('%s',stamp(T,5)));
		copoda_figtoolbar(T);
		max_col = 4;
		jw = min([length(VARN) max_col]);
		iw = ceil(length(VARN)/jw);
		ipl = 0;
		
		for iv = 1 : length(VARN)
			od = subsref(T,substruct('.','data','.',VARN{iv}));
			od.cont = od.cont(iS,:);
							
			ipl=ipl+1;subp(ipl)=subplot(iw,jw,ipl);hold on

			%--- Get chart data:
			[X Y ReducerLabel] = getXY(od,z,iS,reducer);

			%--- Create chart:
			switch chart
				case 'line'
					p = plot(X',Y',linechart{:});			
				case 'bar'
					p = barh(Y,X,barchart{:});
				otherwise
					error('Unknown chart type');
			end% switch 

			%--- Misc:
			grid on
			box on
			axis tight
			
			%--- Set up X,Y axis:
			xlabel(sprintf('%s (%s)',od.unit,od.long_unit));
			if ~strcmp(xlim{iv},'auto')
				set(gca,'xlim',xlim{iv});
			end% if
			
			ylabel(zlab);
			if ~strcmp(zlim,'auto')
				set(gca,'ylim',zlim);
			end% if
			set(gca,'ydir',zdir);
			
			%--- Title
			tit = sprintf('%s',od.name);
			title(tit,'fontweight','bold','interpreter','none');
			
			%--- Suptitle 
			if iv == length(VARN) 
				tit = stamp(T,6);
				if length(iS) > 1
					if length(iS) > 10						
						if isempty(setdiff(1:size(T),iS))
							tit = sprintf('%s\n%s all STATION TRANSECT INDEX',tit,ReducerLabel);						
						else
							tit = sprintf('%s\n%s STATION TRANSECT INDEX: %s [...]',tit,ReducerLabel,num2str(iS(1:10)));
						end% if
					else
						tit = sprintf('%s\n%s STATION TRANSECT INDEX: %s',tit,ReducerLabel,num2str(iS));
					end% if 
				else
					tit = sprintf('%s\nLAT=%0.1f, LON=%0.1f, TIME=%s\nSTATION NUMBER %i, STATION TRANSECT INDEX %i',tit,T.geo.LATITUDE(iS),T.geo.LONGITUDE(iS),datestr(T.geo.STATION_DATE(iS)),T.geo.STATION_NUMBER(iS),iS);					
				end% if 
				tt = suptitle(tit);
				set(tt,'fontweight','bold','interpreter','none','fontsize',14);
			end% if 


		end% for iv

	otherwise %-- Unknown
		error('Unknown option PTYP value')

end% switch xtyp

end %functionprofile
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%- Compute chart data from selected profiles
function [X Y ReducerLabel] = getXY(od,z,iS,reducer)
	
	%
	reducer_name = func2str(reducer);
		
	% Compute the YData:
	if ~strcmp(reducer_name,'none') & nansum(nansum(diff(z,1)))~=0
		error('You cannot use a reduce function if the vertical axis is not similar for all selected profiles !');
	else
		Y = nanmean(z,1);
	end% if 
	
	% Compute the XData:
	switch reducer_name
		case 'stats'
			X(1,:) = nanmean(od.cont,1);
			X(2,:) = nanmean(od.cont,1)+nanstd(od.cont,[],1);
			X(3,:) = nanmean(od.cont,1)-nanstd(od.cont,[],1);
			ReducerLabel = 'Mean+/-STD profiles using';
		case 'range'
			X(1,:) = nanmin(od.cont);
			X(2,:) = nanmedian(od.cont);
			X(3,:) = nanmax(od.cont);
			ReducerLabel = 'Min/Median/Max profiles using';					
		case 'none'
			X = od.cont;
			ReducerLabel = '';
		otherwise
			X = feval(reducer,od.cont);
			ReducerLabel = sprintf('%s on profiles using',upper(reducer_name));
	end% switch 
	
end% function
