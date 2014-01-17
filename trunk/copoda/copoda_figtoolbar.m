% copoda_figtoolbar Add the COPODA figure toolbar
%
% [] = copoda_figtoolbar([OBJ])
% 
% Add the COPODA toolbar to a figure.
%
% Inputs:
%	OBJ is either a database or a transect object
%
% Help:
%	Please, see the webpage:
%		TODO
%
% Created: 2010-05-06.
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
function varargout = copoda_figtoolbar(varargin)

% Figure handle:
fighl = gcf;

% Delete existing toolbar on this figure:
delete(findall(fighl,'Tag','copoda_figtoolbar'));	

% Delete pre-existing figure app datas:
if isappdata(fighl,'sla'),rmappdata(fighl,'sla');end
if isappdata(fighl,'OBJ'),rmappdata(fighl,'OBJ');end
%if isappdata(fighl,'MMAPinfo'),rmappdata(fighl,'MMAPinfo');end

% Delete pre-existing active station/transect:
try,delete_active_station;end
try,delete_active_transect;end
try,delete(findobj(fighl,'tag','track'));end

% Create a brand new toolbar:
tbh = uitoolbar(fighl,'Tag','copoda_figtoolbar');  	

% Provide platform slash to figure datas:
if ispc, sla = '\'; else, sla = '/'; end
setappdata(fighl,'sla',sla);

% Get COPODA object if provided:		
switch nargin
	case 0 % No arguments
		OBJ = [];
	otherwise
		OBJ = varargin{1};
		switch class(OBJ)
			case {'database','transect'}
				% OK
			otherwise
				error('If providing argument to copoda_figtoolbar, it must be a database or a transect object')
		end%witch
end%switch	

% Provide COPODA object to figure datas:
setappdata(fighl,'OBJ',OBJ);

% Add buttons to the toolbar once we have OBJ
addbuttons(tbh); 
	
% We'll need to preserve informations about the map projection:
if isappdata(fighl,'MMAPinfo')
	 % If these informations are already in the figure, we keep them
else % or we load what's currently available
	global MAP_COORDS MAP_PROJECTION MAP_VAR_LIST
	MMAPinfo.coords = MAP_COORDS;
	MMAPinfo.proj   = MAP_PROJECTION;
	MMAPinfo.varl   = MAP_VAR_LIST;
	setappdata(fighl,'MMAPinfo',MMAPinfo); 
end

% Change the color of the figure to indicate we have copoda objects inside
switch class(getappdata(fighl,'OBJ'))
	case {'database','transect'}
		set(fighl,'color',[.9 .9 1]);
end


end %functioncopoda_figtoolbar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- BUTTONS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function addbuttons(tbh)

%saveOBJ(tbh,'off');
%loadOBJ(tbh,'off');
		
selectT(tbh,'off');
selectS(tbh,'off');

drawtracks(tbh,'on');
drawprofiles(tbh,'off');
Tzoomout(tbh,'off');

zoomin(tbh,'on');
disptopo(tbh,'off');
Ssize(tbh,'off');

cutdomain(tbh,'on');
valid(tbh,'off');

info(tbh,'on');	
dataB(tbh,'off');

nuke(tbh,'on');

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data display
% Increase/decrease station location marker size
function varargout = Ssize(tbh,sep);
	
tooltip = 'Increase/Decrease Station size';

OBJ = getappdata(gcf,'OBJ');
	
switch class(OBJ)
	case {'database','transect'}
		enable = 'on';
	otherwise
		enable = 'off';
end

% Add the button to the COPODA toolbar
CData = load(fullfile(copoda_readconfig('copoda_data_folder'),'icon_Ssizing.mat'));%CData.A = abs(CData.A-.2);
pth = uipushtool('Parent',tbh,'CData',CData.A,'Enable','on','Tag','copoda_Ssizebutton',...
         'TooltipString',tooltip,'Separator',sep,...
         'HandleVisibility','on','ClickedCallback',{@Ssize_action});

% Check if we have station on the figure and if not, disable the button:
a = findobj(get(tbh,'parent'),'tag','station_location');
if isempty(a)
	set(pth,'Enable','off')
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data display
% Show/hide topographic contours
function varargout = disptopo(tbh,sep);
	

htopo = findall(get(tbh,'parent'),'tag','topography');
if isempty(htopo)
	tooltip = 'Show topographic contours';
else
	tooltip = 'Hide topographic contours';
end
	
OBJ = getappdata(gcf,'OBJ');
	
switch class(OBJ)
	case {'database','transect'}
		enable = 'on';
	otherwise
		enable = 'off';
end

% Add the button to the COPODA toolbar
CData = load(fullfile(copoda_readconfig('copoda_data_folder'),'icon_topo.mat'));%CData.A = abs(CData.A-.2);
pth = uipushtool('Parent',tbh,'CData',CData.A,'Enable','on','Tag','copoda_topobutton',...
         'TooltipString',tooltip,'Separator',sep,...
         'HandleVisibility','on','ClickedCallback',{@disptopo_action});

% Check if we have station on the figure and if not, disable the button:
a = findobj(get(tbh,'parent'),'tag','station_location');
if isempty(a)
	set(pth,'Enable','off')
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data display
% Open new figure with select transect track
function varargout = nuke(tbh,sep);
	
tooltip = 'Delete subplot profiles and unselect everything on current window';

% Add the button to the COPODA toolbar
CData = load(fullfile(copoda_readconfig('copoda_data_folder'),'icon_nuke.mat'));CData.A = abs(CData.A-.2);
pth = uipushtool('Parent',tbh,'CData',CData.A,'Enable','on','Tag','copoda_nukebutton',...
         'TooltipString',tooltip,'Separator',sep,...
         'HandleVisibility','on','ClickedCallback',{@nuke_action});

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data display
% Open new figure with select transect track
function varargout = Tzoomout(tbh,sep);

ftop = get(tbh,'parent');	
tooltip = 'Show selected transect track in new window';

% Add the button to the COPODA toolbar
CData = load(fullfile(copoda_readconfig('copoda_data_folder'),'icon_Tzoomout.mat'));CData.A = abs(CData.A-.2);
pth = uipushtool('Parent',tbh,'CData',CData.A,'Enable','on','Tag','copoda_Tzoomoutbutton',...
         'TooltipString',tooltip,'Separator',sep,...
         'HandleVisibility','on','ClickedCallback',{@Tzoomout_action});

if strcmp(get(ftop,'tag'),'profile_plot') | strcmp(get(ftop,'tag'),'transect_plot') | strcmp(get(ftop,'tag'),'waterfall_plot')
	% This is a profile plot
	set(pth,'Enable','on')
	set(pth,'TooltipString','Plot track in new window');
else
	% Check if we have an active transect on the figure and if not, disable the button:
	a = findobj(get(tbh,'parent'),'tag','activetransect');
	if isempty(a)
		set(pth,'Enable','off')
	end

end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data display
% Highlight tracks
function varargout = drawtracks(tbh,sep);
	
OBJ = getappdata(gcf,'OBJ');
tooltip = 'Show track(s)';

% Add the button to the COPODA toolbar
CData = load(fullfile(copoda_readconfig('copoda_data_folder'),'icon_track.mat'));CData.A = abs(CData.A-.2);
pth = uipushtool('Parent',tbh,'CData',CData.A,'Enable','on','Tag','copoda_tracksbutton',...
         'TooltipString',tooltip,'Separator',sep,...
         'HandleVisibility','on','ClickedCallback',{@drawtracks_action});

% Check if we have station on the figure and if not, disable the button:
a = findobj(get(tbh,'parent'),'tag','station_location');
if isempty(a)
	set(pth,'Enable','off')
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input/Output
% Save the current object on disk
function varargout = saveOBJ(tbh,sep);
	
OBJ = getappdata(gcf,'OBJ');
sla = getappdata(gcf,'sla');
switch class(OBJ)
	case 'database'
		tooltip = 'Save this Database';
		enable  = 'on';
	case 'transect'
		tooltip = 'Save this Transect';
		enable  = 'on';
	otherwise	
		tooltip = '';
		enable  = 'off';
end

% This button is not available yet !
enable = 'off';

% Add the button to the COPODA toolbar
CData = load(sprintf('%s%sicon_save.mat',copoda_readconfig('copoda_data_folder'),sla));
CData.A = abs(CData.A-.2);
pth = uipushtool('Parent',tbh,'CData',CData.A,'Enable',enable,'Tag','copoda_savebutton',...
         'TooltipString',tooltip,'Separator',sep,...
         'HandleVisibility','on');

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Input/Output
% Load an COPODA object
function varargout = loadOBJ(tbh,sep)

OBJ = getappdata(gcf,'OBJ');
sla = getappdata(gcf,'sla');

switch class(OBJ)
	case {'database','transect'}
		enable = 'off';
	otherwise
		enable = 'on';
end

% Add the button to the COPODA toolbar
CData = load(sprintf('%s%sicon_load.mat',copoda_readconfig('copoda_data_folder'),sla));
CData.A = abs(CData.A-.2);
pth = uipushtool('Parent',tbh,'CData',CData.A,'Enable',enable,'Tag','copoda_loadbutton',...
         'TooltipString','Load a COPODA object','Separator',sep,...
         'HandleVisibility','on','ClickedCallback',{@load_action});

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data display
% Add the zoom in button to the toolbar
function varargout = zoomin(tbh,sep)

OBJ = getappdata(gcf,'OBJ');
sla = getappdata(gcf,'sla');
	
switch class(OBJ)
	case {'database','transect'}
		enable = 'on';
	otherwise
		enable = 'off';
end

% Add the button to the COPODA toolbar
CData = load(sprintf('%s%sicon_zoomin3.mat',copoda_readconfig('copoda_data_folder'),sla));
CData.A = abs(CData.A-.2);
pth = uipushtool('Parent',tbh,'CData',CData.A ,'Enable',enable,'Tag','copoda_zoominbutton',...
         'TooltipString','Zoom in the map','Separator',sep,...
         'HandleVisibility','on','ClickedCallback',{@zoomin_action});

% Check if we have station on the figure and if not, disable the button:
a = findobj(get(tbh,'parent'),'tag','station_location');
if isempty(a)
	set(pth,'Enable','off')
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Data display
% Add the profile button to the toolbar
function varargout = drawprofiles(tbh,sep)

OBJ = getappdata(gcf,'OBJ');
sla = getappdata(gcf,'sla');

switch class(OBJ)
	case {'database','transect'}
		enable = 'on';
	otherwise
		enable = 'off';
end

% Add the button to the COPODA toolbar
CData = load(sprintf('%s%sicon_profile2.mat',copoda_readconfig('copoda_data_folder'),sla));
CData.A = abs(CData.A-.2);
pth = uipushtool('Parent',tbh,'CData',CData.A,'Enable',enable,'Tag','copoda_profilebutton',...
         'TooltipString','Plot profile(s) from a station','Separator',sep,...
         'HandleVisibility','on','ClickedCallback',{@drawprofiles_action});

% Check if we have a station on the figure and if not, disable the button:
a = findobj(get(tbh,'parent'),'tag','station_location');
if isempty(a)
	set(pth,'Enable','off');
end

% Check if this is a profile plot to which we could add more variables:
if isappdata(gcf,'id_station')
	set(pth,'Enable','on');
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OBJ manipulation
% Add the cut button to the toolbar
function varargout = cutdomain(tbh,sep)

OBJ = getappdata(gcf,'OBJ');
sla = getappdata(gcf,'sla');

switch class(OBJ)
	case 'database'
		tooltip = 'Cut the Database';
		enable  = 'on';
	case 'transect'
		tooltip = 'Cut the Transect';
		enable  = 'on';
	otherwise	
		tooltip = '';
		enable  = 'off';
%		error('I don''t know this object class !');
end

% Add the button to the COPODA toolbar
CData = load(sprintf('%s%sicon_cut2.mat',copoda_readconfig('copoda_data_folder'),sla));
CData.A = abs(CData.A-.2);
pth = uipushtool('Parent',tbh,'CData',CData.A,'Enable',enable,'Tag','copoda_cutbutton',...
         'TooltipString',tooltip,'Separator',sep,...
         'HandleVisibility','on','ClickedCallback',{@cut_action});

% Check if we have station on the figure and if not, disable the button:
a = findobj(get(tbh,'parent'),'tag','station_location');
if isempty(a)
	set(pth,'Enable','off')
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OBJ manipulation
% Add the validation button to the toolbar
function varargout = valid(tbh,sep)

OBJ = getappdata(gcf,'OBJ');
sla = getappdata(gcf,'sla');

switch class(OBJ)
	case 'database'
		tooltip = 'Validate this Database';
		enable  = 'on';
	case 'transect'
		tooltip = 'Validate this Transect';
		enable  = 'on';
	otherwise	
		tooltip = '';
		enable  = 'off';
%		error('I don''t know this object class !');
end

% Add the button to the COPODA toolbar
CData = load(sprintf('%s%sicon_valid.mat',copoda_readconfig('copoda_data_folder'),sla));
CData.A = abs(CData.A-.2);
pth = uipushtool('Parent',tbh,'CData',CData.A,'Enable',enable,'Tag','copoda_cutbutton',...
         'TooltipString',tooltip,'Separator',sep,...
         'HandleVisibility','on','ClickedCallback',{@valid_action});

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Informations display
% Add the OBJ information button to the toolbar
function varargout = dataB(tbh,sep)

OBJ = getappdata(gcf,'OBJ');
sla = getappdata(gcf,'sla');

switch class(OBJ)
	case 'database'
		tooltip = 'Display informations about this Database';
		enable  = 'on';
	case 'transect'
		tooltip = 'Display informations about this Transect';
		enable  = 'on';
	otherwise	
		tooltip = '';
		enable  = 'off';
%		error('I don''t know this object class !');
end

% Add the button to the COPODA toolbar
CData = load(sprintf('%s%sicon_database2.mat',copoda_readconfig('copoda_data_folder'),sla));CData.A = abs(CData.A-.2);
pth = uipushtool('Parent',tbh,'CData',CData.A,'Enable',enable,'Tag','copoda_OBJbutton',...
         'TooltipString',tooltip,'Separator',sep,...
         'HandleVisibility','on','ClickedCallback',{@database_action});

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Informations display
% Add the station selection button to the toolbar
function varargout = selectS(tbh,sep)

OBJ = getappdata(gcf,'OBJ');
sla = getappdata(gcf,'sla');

enable = 'on';
switch class(OBJ)
	case 'database'
		TooltipString = 'Select a station in the database';
	case 'transect'
		TooltipString = 'Select a station in the transect';
	otherwise
		TooltipString = '';
end

% Add the button to the COPODA toolbar
CData = load(fullfile(copoda_readconfig('copoda_data_folder'),'icon_wizardS.mat'));CData.A = abs(CData.A-.2);
pth = uipushtool('Parent',tbh,'CData',CData.A,'Enable',enable,'Tag','copoda_Sselectbutton',...
         'TooltipString',TooltipString,'Separator',sep,...
         'HandleVisibility','on','ClickedCallback',{@selectS_action});

% Check if we have station in the figure and if not, disable the button:
a = findobj(get(tbh,'parent'),'tag','station_location');
if isempty(a)
	set(pth,'Enable','off')
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Informations display
% Add the transect selection button to the toolbar
function varargout = selectT(tbh,sep)

OBJ = getappdata(gcf,'OBJ');
sla = getappdata(gcf,'sla');

switch class(OBJ)
	case {'database','transect'}
		enable = 'on';
	otherwise
		enable = 'off';
end

% Add the button to the COPODA toolbar
CData = load(fullfile(copoda_readconfig('copoda_data_folder'),'icon_wizardT.mat')); CData.A = abs(CData.A-.2);
pth = uipushtool('Parent',tbh,'CData',CData.A,'Enable',enable,'Tag','copoda_Tselectbutton',...
         'TooltipString','Select a transect in the database','Separator',sep,...
         'HandleVisibility','on','ClickedCallback',{@selectT_action});

% Check if we have station in the figure and if not, disable the button:
a = findobj(get(tbh,'parent'),'tag','station_location');
if isempty(a)
	set(pth,'Enable','off')
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Informations display
% Add the information button to the toolbar
function varargout = info(tbh,sep)

OBJ = getappdata(gcf,'OBJ');
sla = getappdata(gcf,'sla');

switch class(OBJ)
	case {'database','transect'}
		enable = 'on';
	otherwise
		enable = 'off';
end

% Add the button to the COPODA toolbar
CData = load(sprintf('%s%sicon_info.mat',copoda_readconfig('copoda_data_folder'),sla));CData.A = abs(CData.A-.2);
pth = uipushtool('Parent',tbh,'CData',CData.A,'Enable',enable,'Tag','copoda_infobutton',...
         'TooltipString','Information about selected object','Separator',sep,...
         'HandleVisibility','on','ClickedCallback',{@info_action});

% Check if we have station on the figure and if not, disable the button:
a = [ findobj(get(tbh,'parent'),'tag','activestation') findobj(get(tbh,'parent'),'tag','activetransect') ];
if isempty(a)
	set(pth,'Enable','off')
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- ACTIONS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Increase/decrease station location marker size
function Ssize_action(hObject,eventdata)
	
tbh  = get(hObject,'parent');	
ftop = get(tbh,'parent');
OBJ  = getappdata(ftop,'OBJ');
MMAPinfo = getappdata(ftop,'MMAPinfo');
adjustmmap(MMAPinfo);
busy


a = findobj(ftop,'tag','station_location');
if ~isempty(a)

for ia = 1 : length(a)
	if isa(a,'cell')
		b = a{ia};
	else
		b = a(ia);
	end
	switch get(b,'type')
		case 'line'
%			keyboard		
			size_table = [1:9 10:2:14];
			s0 = get(b,'markersize');
			ii = find(size_table==s0);
			if isempty(ii)
				ii = 1;
			elseif find(ii == length(size_table))
				ii = 1;
			else
				ii = ii + 1;
			end
			set(b,'markersize',size_table(ii));
		case 'hggroup'
			size_table = [1 5 8 10:10:100];
			s0 = get(b,'SizeData');
			ii = find(size_table==s0);
			if isempty(ii)
				ii = 1;
			elseif find(ii == length(size_table))
				ii = 1;
			else
				ii = ii + 1;
			end
			set(b,'SizeData',size_table(ii));drawnow
		otherwise
			disp(sprintf('Weird type found here (%s)',get(b,'type')));
			keyboard
	end
end%for ia
	
	
end%if
idle	

end%funtion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SHow/hide topography
function disptopo_action(hObject,eventdata)
	
tbh  = get(hObject,'parent');	
ftop = get(tbh,'parent');
OBJ  = getappdata(ftop,'OBJ');
MMAPinfo = getappdata(ftop,'MMAPinfo');
adjustmmap(MMAPinfo);
set(0,'currentfigure',ftop);
busy

htopo = findall(ftop,'tag','topography');
if isempty(htopo)
	% Topo not plotted yet:
	optimap(OBJ,'topo',true,'dogrid',false,'coast',false);   
	set(findobj(tbh,'tag','copoda_topobutton'),'tooltipstring','Hide topography');
else
	state = get(htopo,'visible');
	if isa(state,'cell')
		for ii=1:length(state)
			switch state{ii}
				case 'on',  set(htopo(ii),'visible','off');
					set(findobj(tbh,'tag','copoda_topobutton'),'tooltipstring','Show topography');
				case 'off', set(htopo(ii),'visible','on');
					set(findobj(tbh,'tag','copoda_topobutton'),'tooltipstring','Hide topography');
			end
		end
	else
		switch state
			case 'on',  set(htopo,'visible','off');
				set(findobj(tbh,'tag','copoda_topobutton'),'tooltipstring','Show topography');
			case 'off', set(htopo,'visible','on');
				set(findobj(tbh,'tag','copoda_topobutton'),'tooltipstring','Hide topography');
		end
	end
end
idle

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Try to close everything and clean
function nuke_action(hObject,eventdata)
	
tbh  = get(hObject,'parent');	
ftop = get(tbh,'parent');	
	
% Close figure(s) with zoom:
figlist = get(0,'children');
a = strfind(get(figlist,'tag'),'subtrack_plot_niv');
if ~isempty(a)
	for ii=1:length(a)
		if a{ii}==1
			close(figlist(ii));
		end
	end
end

% Active stuff
try,delete_active_station;end
try,delete_active_transect;end

% Annotations	
try,delete(findobj(ftop,'tag','zoominbox'));end
try,delete(findobj(ftop,'tag','track'))	;end
try,set(findobj(tbh,'tag','copoda_tracksbutton'),'tooltipstring','Show track(s)');;end
	
% Close profile plots	
try,delete(findobj(get(0,'children'),'tag','profile_plot'));end
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Highlight tracks
function Tzoomout_action(hObject,eventdata)
	
tbh  = get(hObject,'Parent');
ftop = get(tbh,'Parent');
OBJ  = getappdata(ftop,'OBJ');
MMAPinfo = getappdata(ftop,'MMAPinfo');
adjustmmap(MMAPinfo);

if strcmp(get(ftop,'tag'),'profile_plot') | strcmp(get(ftop,'tag'),'transect_plot') | strcmp(get(ftop,'tag'),'waterfall_plot')
	
	% We're calling from a profile plot
	switch class(OBJ)
		case 'database'
			error('I don''t know why a database is data of a profile plot !!!');
		case 'transect'		
			f = figure;
			tracks(OBJ);
		otherwise
			error
	end
	
else	

	if isappdata(ftop,'active_transect')
	
		active_transect = getappdata(ftop,'active_transect');
		switch class(OBJ)
			case 'database'
				f = figure;
				tracks(OBJ(active_transect.iT));
			case 'transect'
				if active_transect.iT == 9999					
					f = figure;
					tracks(OBJ);
				else
					warning('We shouldn''t be here ! there''s an active transect but no database or not 9999');
				end
			otherwise
				% we shouldn't be here
				disp('Tzoomout_action with active_transect and app transect');
				keyboard
		end
	
	else	
		% May be, we're in a profile figure
		disp('No active transect on this figure');
	
	end%if
	
end%if	
	
adjustmmap(MMAPinfo);
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Highlight tracks
function drawtracks_action(hObject,eventdata)
	
tbh  = get(hObject,'Parent');
ftop = get(tbh,'Parent');
OBJ  = getappdata(ftop,'OBJ');
MMAPinfo = getappdata(ftop,'MMAPinfo');
adjustmmap(MMAPinfo);
busy

% If a track object is already active, we delete it
if findobj(ftop,'tag','track')
	delete(findobj(ftop,'tag','track'))	
	set(findobj(tbh,'tag','copoda_tracksbutton'),'tooltipstring','Show track(s)');
	idle
	return
end


% If a station is active, we plot the corresponding transect track
if isappdata(ftop,'active_station')
	
	active_station = getappdata(ftop,'active_station');
	switch class(OBJ)
		case 'database'
			y = extract(OBJ(active_station.iT),'LATITUDE');
			x = extract(OBJ(active_station.iT),'LONGITUDE');
		case 'transect'
			y = extract(OBJ,'LATITUDE');
			x = extract(OBJ,'LONGITUDE');
	end	
	set(0,'currentfigure',ftop);
	p = m_plot(x,y,'r','tag','track');
	
%	keyboard
	
elseif isappdata(ftop,'active_transect')
	% Nothing to do here, the transect is already on screen
	
else
	
	switch class(OBJ)
		case 'database' % Highlight all tracks, one color per transect;
			cmap = hsv(length(OBJ));
			for it = 1 : length(OBJ)
				y = extract(OBJ(it),'LATITUDE');
				x = extract(OBJ(it),'LONGITUDE');
				set(0,'currentfigure',ftop);
				p(it) = m_plot(x,y,'color',cmap(it,:),'tag','track');
			end%for it
			
		case 'transect' % Highlight the track
			y = extract(OBJ,'LATITUDE');
			x = extract(OBJ,'LONGITUDE');	
			set(0,'currentfigure',ftop);		
			p = m_plot(x,y,'r','tag','track');
	end
	
	
end%if	
set(findobj(tbh,'tag','copoda_tracksbutton'),'tooltipstring','Hide track(s)');
idle

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Informations about a station or transect selected
function info_action(hObject,eventdata)
	
tbh  = get(hObject,'Parent');
ftop = get(tbh,'Parent');
OBJ  = getappdata(ftop,'OBJ');

whatsactive = [];
if isappdata(ftop,'active_transect')
	whatsactive = 'transect';
elseif isappdata(ftop,'active_station')
	whatsactive = 'station';
else
	whatsactive = '';
end

switch whatsactive
	case 'transect'
		active_transect = getappdata(ftop,'active_transect');
		OBJ(active_transect.iT)
	
	case 'station'
		disp_Sinfo(ftop);
	
	otherwise
		disp('This button shouldn''t be on ! nothing active !')
end%switch


end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select a transect
function selectT_action(hObject,eventdata)
	
tbh  = get(hObject,'Parent');
ftop = get(tbh,'Parent');
sla  = getappdata(ftop,'sla');
OBJ  = getappdata(ftop,'OBJ');
MMAPinfo = getappdata(ftop,'MMAPinfo');

if ~isempty(findobj(gcf,'tag','activetransect'))
	
	delete_active_transect;
	
else

	adjustmmap(MMAPinfo);
	builtin('figure',ftop);
	set(0,'CurrentFigure',ftop);

	% Get stations lat/lon on the figure:
	% Note, from here we must have LON,LAT defined.
	% It has been checked before if they exist
	busy,[LON LAT] = recup_stations_location_on_map(ftop,MMAPinfo);idle

	% Select one station:
	busy,[but iT iS p mlon mlat] = pickonestation(LAT,LON,'activetransect');idle
	if ~isnan(p),delete(p);end

	if but == 1 % Highlight the transect
		busy
		
		% Delete active station if needed:
		delete_active_station;
	
		% Highlight the transect on the map:
		switch class(OBJ)
			case 'database'
				xactiv = extract(OBJ(iT),'LONGITUDE');
				yactiv = extract(OBJ(iT),'LATITUDE');
			case 'transect'
				% iT is set to NaN by default from pickonestation
				% We set it to 9999 to indicate we're not in a database but we want to select the transect
				iT = 9999;
				xactiv = extract(OBJ,'LONGITUDE');
				yactiv = extract(OBJ,'LATITUDE');
		end
		pt = m_plot(xactiv,yactiv,'rx');
		set(pt,'tag','activetransect');
		set(pt,'linestyle','-','linewidth',2);
		
		%
		engage_active_transect(iT,iS);
		idle
	end%if
	
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load a COPODA matlab file and plot it on the empty figure
function load_action(hObject,eventdata)
	
tbh  = get(hObject,'Parent');
ftop = get(tbh,'Parent');
OBJ  = getappdata(ftop,'OBJ');

switch class(OBJ)
	case {'database','transect'}
		errordlg('A COPODA object is already loaded in this figure');
	otherwise
		
end
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select a station then display informations about it
function selectS_action(hObject,eventdata)
	
tbh  = get(hObject,'Parent');
ftop = get(tbh,'Parent');
OBJ  = getappdata(ftop,'OBJ');
MMAPinfo = getappdata(ftop,'MMAPinfo');

adjustmmap(MMAPinfo);
builtin('figure',ftop);
set(0,'CurrentFigure',ftop);

if ~isempty(findobj(gcf,'tag','activestation'))	
	
	delete_active_station;
	
else

	% Get stations lat/lon on the figure:
	% Note, from here we must have LON,LAT defined
	% It has been checked before if they exist
	busy,[LON LAT] = recup_stations_location_on_map(ftop,MMAPinfo);idle

	% Select one station:
	busy,[but iT iS p mlon mlat] = pickonestation(LAT,LON,'activestation');idle
	if ~isnan(p),set(p,'markersize',12,'color','r');end

	if but == 1
		
		% Delete active transect if needed:
		delete_active_transect;
		
		% Set all what we need for actions:
		engage_active_station(iT,iS,p,mlon,mlat);
		
	end%if

	
end


end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display a popup window with informations about the object
function database_action(hObject,eventdata)
	
tbh  = get(hObject,'Parent');
ftop = get(tbh,'Parent');

clc
OBJ  = getappdata(ftop,'OBJ')


end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run validate method on Object
function valid_action(hObject,eventdata)
	
tbh  = get(hObject,'Parent');
ftop = get(tbh,'Parent');
OBJ  = getappdata(ftop,'OBJ');
validate(OBJ);


end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select a rectangular region, extract station in new
% database and plot it on a new figure
% Called when pushed the zoom in button.
function zoomin_action(hObject,eventdata)
	
tbh  = get(hObject,'Parent');
ftop = get(tbh,'Parent');
OBJ  = getappdata(ftop,'OBJ');
MMAPinfo = getappdata(ftop,'MMAPinfo');

delete(findobj(ftop,'tag','zoominbox'))
adjustmmap(MMAPinfo);
builtin('figure',ftop);
set(0,'CurrentFigure',ftop);

switch class(OBJ)
	case 'database'
	
		[LON LAT] = drawarectangle;
		if ~isempty(LON)
			drawnow;
			pop = simplepopup(ftop,'Zooming ...');drawnow
			busy
			
			d = cut(OBJ,[LON;LAT]);
			if isa(d,'database')
				pos0 = get(ftop,'position');  tag0 = get(ftop,'tag');
				if strfind(tag0,'subtrack_plot_niv')
					niv0 = str2num(tag0(strfind(tag0,'subtrack_plot_niv')+length('subtrack_plot_niv'):end));
				else
					niv0 = 0;
				end
				niv = niv0 + 1;
				if isempty(strfind(d.name,'Zoom from'))
					d.name = sprintf('Zoom from %s',d.name);
				end
					f = figure('tag',sprintf('subtrack_plot_niv%i',niv));
					tracks(d);
					delete(pop);				
				waitfor(pop);
				
				% Redistribute figure along the main one (on the right);
				phl = findobj(get(0,'children'),'tag',sprintf('subtrack_plot_niv%i',niv)); n = length(phl); phl = sort(phl);
				scs = get(0,'screensize');
				for ih = 1 : length(phl)
					pos = get(phl(ih),'position');
					z0  = pos0(2)+pos0(4)-440+20;
					x0  = min([scs(3)-570 pos0(1)+pos0(3)]);% We ensure figures stay on screen
					set(phl(ih),'position',[x0 z0-20*(ih-1) 570 440]);
				end
				adjustmmap(MMAPinfo);
				builtin('figure',ftop);
				set(0,'CurrentFigure',ftop);				
			else
				delete(pop);
				w=warndlg('No stations in this box !');			
				waitfor(w);
				adjustmmap(MMAPinfo);
				builtin('figure',ftop);
				set(0,'CurrentFigure',ftop);
			end
			idle
		end
		adjustmmap(MMAPinfo);
		builtin('figure',ftop);
		set(0,'CurrentFigure',ftop);
	
	case 'transect'
	
		[LON LAT] = drawarectangle;
		if ~isempty(LON)
			drawnow;
			pop = simplepopup(ftop,'Zooming ...');drawnow
			busy
			
			t = cut(OBJ,[LON;LAT]);
			if isa(t,'transect')
				pos0 = get(ftop,'position');  tag0 = get(ftop,'tag');
				if strfind(tag0,'subtrack_plot_niv')
					niv0 = str2num(tag0(strfind(tag0,'subtrack_plot_niv')+length('subtrack_plot_niv'):end));
				else
					niv0 = 0;
				end
				niv = niv0 + 1;
				if isempty(strfind(t.cruise_info.NAME,'Zoom from'))
					t.cruise_info.NAME = sprintf('Zoom from %s',t.cruise_info.NAME);
				end
					f = figure('tag',sprintf('subtrack_plot_niv%i',niv));
					tracks(t);
					delete(pop);			
				waitfor(pop);
				
				% Redistribute figure along the main one (on the right);
				phl = findobj(get(0,'children'),'tag',sprintf('subtrack_plot_niv%i',niv)); n = length(phl); phl = sort(phl);
				scs = get(0,'screensize');
				for ih = 1 : length(phl)
					pos = get(phl(ih),'position');
					z0  = pos0(2)+pos0(4)-440+20;
					x0  = min([scs(3)-570 pos0(1)+pos0(3)]);% We ensure figures stay on screen
					set(phl(ih),'position',[x0 z0-20*(ih-1) 570 440]);
				end	
				adjustmmap(MMAPinfo);
				builtin('figure',ftop);
				set(0,'CurrentFigure',ftop);			
			else
				w=warndlg('No stations in this box !');			
				waitfor(w);
				adjustmmap(MMAPinfo);
				builtin('figure',ftop);
				set(0,'CurrentFigure',ftop);
			end
			idle
		end
		adjustmmap(MMAPinfo);
		builtin('figure',ftop);
		set(0,'CurrentFigure',ftop);
		idle
	otherwise
			errordlg('We must have a database or transect object to work with !')
			error('We must have a database or transect object to work with !')
end%switch

delete(findobj(ftop,'tag','zoominbox'))

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw a polygon with the mouse and cut the database within it
% Called when pushed the cut button.
function cut_action(hObject,eventdata)
	
tbh  = get(hObject,'Parent');
ftop = get(tbh,'Parent');
OBJ  = getappdata(ftop,'OBJ');
MMAPinfo = getappdata(ftop,'MMAPinfo');
	
delete(findobj(ftop,'tag','drawmpoly'))

switch class(OBJ)
	case 'database'
		[pol(1,:) pol(2,:) p but] = drawmpoly(ftop);	
		if isempty(but),but=2;end
		if but == 2 
			if size(pol,2) <= 3 & (pol(:,1) == pol(:,end))
				warndlg('You need at least 3 points !');
				delete(findobj(ftop,'tag','drawmpoly'))
			else			
				d = cut(OBJ,pol);
				if isa(d,'database')
					res = savenewobj(ftop,sprintf('Please enter the name of the new database\nto be saved in your workspace:'));
%					res = askaquestionwithtextanswer(ftop,'Please enter the name of the new database to be saved in your workspace');
					if ~isempty(res)
						switch res{2}
							case 1 % Only save
								assignin('base',res{1},d);
								disp(sprintf('New database ''%s'' added to your workspace',res{1}));								
								h=warndlg('Meta informations of this new database are inherited from its parent');
								waitfor(h);
							case 2 % Save and plot					
								assignin('base',res{1},d);
								disp(sprintf('New database ''%s'' added to your workspace',res{1}));			
								pop = simplepopup(ftop,'Plotting...');drawnow
									f = figure;tracks(d);
									delete(pop);
								waitfor(pop);
								h=warndlg('Meta informations of this new database are inherited from its parent');
								waitfor(h);
								
							case 3	% Only plot
							pop = simplepopup(ftop,'Plotting...');drawnow
								f = figure;tracks(d);
								delete(pop);			
							waitfor(pop);								

						end%switch
					else	
						delete(findobj(ftop,'tag','drawmpoly'))				
					end
				else
					warndlg('No stations in this area !')
					delete(findobj(ftop,'tag','drawmpoly'))							
				end
			end
		else
			delete(findobj(ftop,'tag','drawmpoly'))		
			return;
		end
	
	case 'transect'
		%stophere
		[pol(1,:) pol(2,:) p but] = drawmpoly(ftop);	
		if isempty(but),but=2;end
		if but == 2 
				if size(pol,2) <= 3 & (pol(:,1) == pol(:,end))
					warndlg('You need at least 3 points !');
					delete(findobj(ftop,'tag','drawmpoly'))
				else			
					t = cut(OBJ,pol);
					if isa(t,'transect')
						res = savenewobj(ftop,sprintf('Please enter the name of the new transect\nto be saved in your workspace:'));
						if ~isempty(res)
							switch res{2}
								case 1 % Only save
									assignin('base',res{1},t);
									disp(sprintf('New transect ''%s'' added to your workspace',res{1}));
									h=warndlg('Meta informations of this new transect are inherited from its parent');
									waitfor(h);
									
								case 2 % Save and plot					
									assignin('base',res{1},t);
									disp(sprintf('New transect ''%s'' added to your workspace',res{1}));
									
									pop = simplepopup(ftop,'Plotting...');drawnow
										f = figure;tracks(t);
										delete(pop);			
									waitfor(pop);
																		
									h=warndlg('Meta informations of this new transect are inherited from its parent');
									waitfor(h);
									
								case 3	% Only plot
									pop = simplepopup(ftop,'Plotting...');drawnow
										f = figure;tracks(t);
										delete(pop);			
									waitfor(pop);

							end%switch
						else	
							delete(findobj(ftop,'tag','drawmpoly'))				
						end
					else
						warndlg('No stations in this area !')
						delete(findobj(ftop,'tag','drawmpoly'))
					end
				end
			else				
				delete(findobj(ftop,'tag','drawmpoly'))
				return;
			end
	otherwise
		errordlg('We must have a database or transect object to work with !')
		error('We must have a database or transect object to work with !')
end		
delete(findobj(ftop,'tag','drawmpoly'))
	
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select variables then stations and plot vertical profiles 
% on separate windows.
% Called when pushed the profile button.
function drawprofiles_action(hObject,eventdata)

tbh  = get(hObject,'Parent');
ftop = get(tbh,'Parent');
OBJ  = getappdata(ftop,'OBJ');
MMAPinfo = getappdata(ftop,'MMAPinfo');

plotted = false; % Did we plot something ?

adjustmmap(MMAPinfo);
builtin('figure',ftop);
set(0,'CurrentFigure',ftop);

if isappdata(ftop,'id_station') & isappdata(ftop,'var_plotted')
	
	% This is already a profile plot
	% so we're probably trying to add more variables to a profile.
	% and we then need to remove from the list the already plotted
	% variables.
	% Moreover, if this is a waterfall or a transect_plot profiles plot, then we can
	% only list variables such as the MLD
	var_plotted = getappdata(ftop,'var_plotted');	
	switch get(ftop,'tag')
		case 'profile_plot'
			VARN = datalistselectionpopup(var_plotted);idle
			try  ,VARN = cat(1,var_plotted,VARN);
			catch,VARN = cat(2,var_plotted,VARN);end
			multiprofiles(OBJ,'VARN',VARN,'iS',getappdata(ftop,'id_station'));			
		case {'waterfall_plot','transect_plot'}
			% we need to add to var_plotted all NPROF x NLEVELS variables which cannot be
			% plotted on a waterfall and a transect_plot
			switch class(OBJ)
				case 'transect'
					[NP NL] = size(OBJ); 
					dlist   = datanames(OBJ,1); % Non empty					
					keep = zeros(1,length(dlist));
					for id=1:length(dlist)
						[np nl] = size(getfield(OBJ,'data',dlist{id}));
						if np==NP & nl==1
							keep(id) = 1;
						end% if 
					end% for id
					VARN = datalistselectionpopup(union(var_plotted,dlist(keep==0)));idle
					try  ,VARN = cat(1,var_plotted,VARN);
					catch,VARN = cat(2,var_plotted,VARN);end
					if     strcmp(get(ftop,'tag'),'waterfall_plot')
						multiprofiles(OBJ,'VARN',VARN,'iS',getappdata(ftop,'id_station'),'plotype',3);
					elseif strcmp(get(ftop,'tag'),'transect_plot')
						stophere
					else
						error('I didn''t expected to end up here !')
					end% if 
					
				case 'database'
					error('I didn''t expected to end up here !')
			end% switch 			
				
		otherwise
			error('I didn''t expected to end up here !')
	end% switch 
	

else

	% Get stations lat/lon on the figure:
	% Note, from here we must have LON,LAT defined
	% It has been checked before if they exist
	[LON LAT] = recup_stations_location_on_map(ftop,MMAPinfo);

	% Ask to pick one or more variables to plot:
	VARN = datalistselectionpopup;idle

	% Select stations and plot profiles:
	if ~isempty(VARN)
	
		% If a station is active, we use this one:
		if isappdata(ftop,'active_station')

			active_station = getappdata(gcf,'active_station');
			switch class(OBJ)
				case 'database'
					T = OBJ(active_station.iT);
				case 'transect'
					T = OBJ;
			end
			plotted = plot_profile('ftop',ftop,'ztyp','DEPH','VARN',VARN,'T',T,'iS',active_station.iS);
	
		% If a transect is active, we use station from it:
		elseif isappdata(ftop,'active_transect')	
		
			active_transect = getappdata(gcf,'active_transect');
			if isa(OBJ,'transect')
				T = OBJ;
			else
				T = OBJ(active_transect.iT);
			end
		
			if length(VARN)*size(T,1) > 5
				resp = mquestdlg(ftop,sprintf('You''re about to open more than %i figures',length(VARN)*size(T,1)), ...
			                         'COPODA', ...
			                         'Continue', 'Cancel','Use a pcolor plot instead','Use a waterfall plot instead');
				
				switch resp
					case 'Continue',
						for is = 1 : size(T,1)
							plotted = plot_profile('ftop',ftop,'ztyp','DEPH','VARN',VARN,'T',T,'iS',is);
						end%for is
					case 'Cancel',
					case 'Use a pcolor plot instead'
						is = 1:size(T,1);
						plotted = plot_profile('ftop',ftop,'ztyp','DEPH','VARN',VARN,'T',T,'iS',is,'plottyp',[1 2 1]);				
					case 'Use a waterfall plot instead'
						plotted = plot_profile('ftop',ftop,'T',T,'VARN',VARN,'plottyp',3);
				end
	%			keyboard
			end
		
		% Otherwise we select one or more:
		else	
	
			done = 0; ifig = 0;
			while done ~= 1
				ifig = ifig + 1;
				[but iT iS p(ifig) mlon mlat] = pickonestation(LAT,LON,'profilestation');
				if but ~= 1
					done = 1;
				else			
					if ~isnan(p),set(p,'markersize',12,'color','r');end		
					if isa(OBJ,'database')
						T = OBJ.transect{iT};
					elseif isa(OBJ,'transect')
						T = OBJ;
					else
						errordlg('We must have a database or transect object to work with !')
					end
		
					plotted = plot_profile('ftop',ftop,'ztyp','DEPH','VARN',VARN,'T',T,'iS',iS);
		
					builtin('figure',ftop);
					set(0,'CurrentFigure',ftop);
				end%if
			end%swhile
	
		end%
	
	end%if we selected a variable to plot

	delete(findobj(ftop,'tag','profilestation'));
	% Redistribute one more time, figures along the main one (on the right);
	pos0 = get(ftop,'position');
	phl = findobj(get(0,'children'),'tag','profile_plot'); n = length(phl); phl = sort(phl);
	scs = get(0,'screensize');
	for ih = 1 : length(phl)
		pos = get(phl(ih),'position');
		z0  = pos0(2)+pos0(4)-440+20;
		x0  = min([scs(3)-570 pos0(1)+pos0(3)]);% We ensure figures stay on screen
		set(phl(ih),'position',[x0 z0-20*(ih-1) 570 440]);
	end

	if plotted
		disp(sprintf('\nType the following command to close profiles figures:\ndelete(findobj(get(0,''children''),''tag'',''profile_plot''))\n'));
	end

end% if already a profile

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- LOWER LEVELS SCRIPTS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot a list of profiles calling transect method 'profile' or 'multiprofiles'
function plotted = plot_profile(varargin);
	
% Default options:
ftop = gcf; % Parent window
ztyp = 'DEPH'; % Y axis
VARN = {'TEMP'}; % List of variables to plot
iS   = 1; % Which station ?
plottyp = [1 2 1]; % See transect/plot

% User options:
for in = 1 : 2 : nargin
	eval(sprintf('%s=varargin{%i};',varargin{in},in+1));
end

% Check for order in VARN
if length(VARN) > 1
	for iv = 1 : length(VARN)
		if size(getfield(T.data,VARN{iv}),2) > 1
			iok = iv;
		end% if 
	end% for iv
	iv = [iok setdiff(1 : length(VARN),iok)];
	VARN = VARN(iv);
end% if 	

if plottyp(1) == 3
	multiprofiles(T,'VARN',VARN,'plotype',3);
	plotted = true;
	return;
end

% Plot
if length(iS) == 1 % A classic profile:


	if length(VARN) > 4

		for iv = 1 : length(VARN)
			pos0 = get(ftop,'position');
			profile(T,'ztyp',ztyp,'VARN',VARN,'iS',iS);
			setappdata(gcf,'id_station',iS);
			f(iv) = gcf;
							
			% f(iv) = figure; set(f(iv),'tag','profile_plot');
			% od = subsref(T,substruct('.','data','.',VARN{iv}));
			% z  = subsref(T,substruct('.','geo','.',ztyp,'()',{iS,':'}));
			% p = plot(od.cont(iS,:),z);
			% set(p,'marker','.');
			% grid on,box on;
			% title(sprintf('%s (%s)\n%s',od.name,od.long_name,stamp(T,5)),'fontweight','bold');
			% set(gcf,'name',sprintf('%s (%s)',stamp(T,5),od.name));
			% xlabel(sprintf('%s (%s)',od.unit,od.long_unit));
			% ylabel(ztyp);
			% l = legend(p,sprintf('LAT=%0.1f, LON=%0.1f\n%s\nStation #%i',T.geo.LATITUDE(iS),T.geo.LONGITUDE(iS),datestr(T.geo.STATION_DATE(iS)),T.geo.STATION_NUMBER(iS)));
			% set(l,'location','eastoutside');
							
			% Redistribute figures along the main one (on the right);
			phl = findobj(get(0,'children'),'tag','profile_plot'); n = length(phl); phl = sort(phl);
			scs = get(0,'screensize');
			for ih = 1 : length(phl)
				pos = get(phl(ih),'position');
				z0  = pos0(2)+pos0(4)-440+20;
				x0  = min([scs(3)-570 pos0(1)+pos0(3)]);% We ensure figures stay on screen
				set(phl(ih),'position',[x0 z0-20*(ih-1) 570 440]);
			end
			plotted = true;
		end

	else
		pos0 = get(ftop,'position');				
		multiprofiles(T,'ztyp',ztyp,'VARN',VARN,'iS',iS);
		f = gcf;
%		set(f,'menubar','none','toolbar','none');copoda_figtoolbar(T);
		try,footnote;figure_tall;end
		% Redistribute figures along the main one (on the right);
		phl = findobj(get(0,'children'),'tag','profile_plot'); n = length(phl); phl = sort(phl);
		scs = get(0,'screensize');
		for ih = 1 : length(phl)
			pos = get(phl(ih),'position');
			z0  = pos0(2)+pos0(4)-440+20;
			x0  = min([scs(3)-570 pos0(1)+pos0(3)]);% We ensure figures stay on screen
			set(phl(ih),'position',[x0 z0-20*(ih-1) 570 440]);
		end
		plotted = true;
	end
	
else % We use pcolor/scatter instead

	for iv = 1 : length(VARN)
		pos0 = get(ftop,'position');
		plot(T,VARN{iv},plottyp);if plottyp(1)~=3, colorbar;end
		f = gcf;
		set(gcf,'tag','profile_plot')
%		set(f,'menubar','none','toolbar','none');copoda_figtoolbar(T);
		try,footnote;end
		% Redistribute figures along the main one (on the right);
		phl = findobj(get(0,'children'),'tag','profile_plot'); n = length(phl); phl = sort(phl);
		scs = get(0,'screensize');
		for ih = 1 : length(phl)
			pos = get(phl(ih),'position');
			z0  = pos0(2)+pos0(4)-440+20;
			x0  = min([scs(3)-570 pos0(1)+pos0(3)]);% We ensure figures stay on screen
			set(phl(ih),'position',[x0 z0-20*(ih-1) 570 440]);
		end
		plotted = true;
	end

end%if	
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Activate a transect
function engage_active_transect(iT,iS);
	
	tbh = findobj(gcf,'tag','copoda_figtoolbar');	
	
	% Load the figure with selected transect
	active_transect.iT = iT;
	active_transect.iS = iS;
	setappdata(gcf,'active_transect',active_transect);
	
	% Adjust select T button:
	CData = load(fullfile(copoda_readconfig('copoda_data_folder'),'icon_okT.mat'));CData.A = abs(CData.A-.2);
	set(findobj(tbh,'tag','copoda_Tselectbutton'),'CData',CData.A);
	set(findobj(tbh,'tag','copoda_Tselectbutton'),'tooltipstring','One transect selected, press to unselect');
		
	% Adjuts other buttons state:
	set(findobj(tbh,'tag','copoda_infobutton'),'enable','on','TooltipString','Informations about the selected transect');
	set(findobj(tbh,'tag','copoda_Tzoomoutbutton'),'enable','on');
	set(findobj(tbh,'tag','copoda_tracksbutton'),'enable','off');

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% De-activite a transect
function delete_active_transect

	tbh = findobj(gcf,'tag','copoda_figtoolbar');
	as  = findobj(gcf,'tag','activetransect');

	% Delete active transect on map:
	if ~isempty(as)
		delete(as);
	end

	% Delete active transect on figure datas:
	if isappdata(gcf,'active_transect')
		rmappdata(gcf,'active_transect');
	end

	% Adjust button icon
	CData = load(fullfile(copoda_readconfig('copoda_data_folder'),'icon_wizardT.mat'));CData.A = abs(CData.A-.2);
	set(findobj(tbh,'tag','copoda_Tselectbutton'),'CData',CData.A);
	set(findobj(tbh,'tag','copoda_Tselectbutton'),'tooltipstring','Select a transect in the database');

	% Adjuts other buttons state:
	set(findobj(tbh,'tag','copoda_infobutton'),'enable','off');
	set(findobj(tbh,'tag','copoda_Tzoomoutbutton'),'enable','off');
	set(findobj(tbh,'tag','copoda_tracksbutton'),'enable','on');

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Activate a station
function engage_active_station(iT,iS,p,mlon,mlat);
	
	tbh = findobj(gcf,'tag','copoda_figtoolbar');	
	
	% Load figure with selection informations
	active_station.iT = iT;
	active_station.iS = iS;
	active_station.p  = p;
	active_station.mlon = mlon;
	active_station.mlat = mlat;
	setappdata(gcf,'active_station',active_station);
	
	% Adjust button icon
	CData = load(fullfile(copoda_readconfig('copoda_data_folder'),'icon_okS.mat'));CData.A = abs(CData.A-.2);
	set(findobj(tbh,'tag','copoda_Sselectbutton'),'CData',CData.A);
	set(findobj(tbh,'tag','copoda_Sselectbutton'),'tooltipstring','One station selected, press to unselect');
		
	% Adjuts info button state:
	set(findobj(tbh,'tag','copoda_infobutton'),'enable','on','TooltipString','Informations about the selected station');
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% De-activate a station
function delete_active_station
	
tbh = findobj(gcf,'tag','copoda_figtoolbar');
as  = findobj(gcf,'tag','activestation');

% Delete active station on map:
if ~isempty(as)
	delete(as);
end

% Delete active station on figure datas:
if isappdata(gcf,'active_station')
	rmappdata(gcf,'active_station');
end

% Adjust button icon
CData = load(fullfile(copoda_readconfig('copoda_data_folder'),'icon_wizardS.mat'));CData.A = abs(CData.A-.2);
set(findobj(tbh,'tag','copoda_Sselectbutton'),'CData',CData.A);
switch class(getappdata(gcf,'OBJ'))
	case 'database'
		TooltipString = 'Select a station in the database';
	case 'transect'
		TooltipString = 'Select a station in the transect';
end
set(findobj(tbh,'tag','copoda_Sselectbutton'),'tooltipstring',TooltipString);

% Adjuts info button state:
set(findobj(tbh,'tag','copoda_infobutton'),'enable','off');

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display information about a station:
function disp_Sinfo(fighl);
	
	OBJ = getappdata(fighl,'OBJ');
	active_station = getappdata(fighl,'active_station');
	iT = active_station.iT;
	iS = active_station.iS;
	mlon = active_station.mlon;
	mlat = active_station.mlat;
	
	switch class(OBJ)
		case 'database'
			T = OBJ.transect{iT};
			disp(sprintf('\nDatabase: %s',OBJ.name))
			disp(sprintf('\t|-> Transect # %i: %s',iT,T.cruise_info.NAME))
			disp(sprintf('\t\t|-> Station # %i ',iS));
			disp(sprintf('\t\t\tLAT = %0.3f, LON = %0.3f\n\t\t\tDATE: %s\n\t\t\tSTATION ID %i',mlat,mlon,datestr(T.geo.STATION_DATE(iS),'yyyy-mmm-dd HH:MM'),T.geo.STATION_NUMBER(iS)));
			varn = datanames(T);
			for iv=1:length(varn)
				od = subsref(T,substruct('.','data','.',varn{iv}));	
				switch dstatus(T,varn{iv},0)
					case 'R'
						if length(find(isnan(od.cont(iS,:))==0))~=0
							nonempty(iv) = true;
							if exist('vlist','var')
								vlist = sprintf('%s\n\t\t\tReal - [%s] %s',vlist,varn{iv},od.long_name);
							else
								vlist = sprintf('Real - [%s] %s',varn{iv},od.long_name);
							end
						else
							nonempty(iv) = false;
						end
					case 'V'
						if exist('vlist','var')
							vlist = sprintf('%s\n\t\t\tVirtual - [%s] %s',vlist,varn{iv},od.long_name);
						else
							vlist = sprintf('Virtual - [%s] %s',varn{iv},od.long_name);
						end
				end

			end
			disp(sprintf('\t\t\tNON EMPTY VARIABLES: %i',length(nonempty==1)));
			disp(sprintf('\t\t\t%s',vlist));

		
		case 'transect'
			T = OBJ;
			disp(sprintf('\nTransect: %s',T.cruise_info.NAME))
			disp(sprintf('\t|-> Station # %i ',iS));
			disp(sprintf('\t\tLAT = %0.3f, LON = %0.3f\n\t\tDATE: %s\n\t\tSTATION ID %i',mlat,mlon,datestr(T.geo.STATION_DATE(iS),'yyyy-mmm-dd HH:MM'),T.geo.STATION_NUMBER(iS)));
			varn = datanames(T);
			for iv=1:length(varn)
				od = subsref(T,substruct('.','data','.',varn{iv}));	
				switch dstatus(T,varn{iv},0)
					case 'R'
						if length(find(isnan(od.cont(iS,:))==0))~=0
							nonempty(iv) = true;
							if exist('vlist','var')
								vlist = sprintf('%s\n\t\tReal - [%s] %s',vlist,varn{iv},od.long_name);
							else
								vlist = sprintf('Real - [%s] %s',varn{iv},od.long_name);
							end
						else
							nonempty(iv) = false;
						end
					case 'V'
						if exist('vlist','var')
							vlist = sprintf('%s\n\t\tVirtual - [%s] %s',vlist,varn{iv},od.long_name);
						else
							vlist = sprintf('Virtual - [%s] %s',varn{iv},od.long_name);
						end
				end

			end
			disp(sprintf('\t\tNON EMPTY VARIABLES: %i',length(nonempty==1)));
			disp(sprintf('\t\t%s',vlist));
		
		otherwise
			errordlg('We must have a database or transect object to work with !')
	end
	
end%fucntion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read longitude/latitudes of stations on a figure
function [LON LAT] = recup_stations_location_on_map(ftop,MMAPinfo);
% ftop is the handle of the figure

if ~isappdata(ftop,'station_locations')

	adjustmmap(MMAPinfo);
	a = findobj(ftop,'tag','station_location');
	if ~isempty(a)

	for ia = 1 : length(a)
		if isa(a,'cell')
			b = a{ia};
		else
			b = a(ia);
		end
		switch get(b,'type')
			case 'line'
				if ~exist('LON','var')
					[LON LAT] = m_xy2ll(get(b,'xdata'),get(b,'ydata')); % Convert point coords to lat/lon
				else
					[lo la] = m_xy2ll(get(b,'xdata'),get(b,'ydata')); % Convert point coords to lat/lon
					LON = [LON lo];
					LAT = [LAT la];
				end		
			case 'hggroup'
				[LON LAT] = m_xy2ll(get(b,'xdata'),get(b,'ydata')); % Convert point coords to lat/lon
			otherwise
				disp(sprintf('Weird type found here (%s)',get(b,'type')));
				keyboard
		end
	end%for ia
	
	else
		LON = NaN;
		LAT = NaN;
	end

	station_locations.LON = LON;
	station_locations.LAT = LAT;
	setappdata(ftop,'station_locations',station_locations);
	
else

	station_locations = getappdata(ftop,'station_locations');
	LON = station_locations.LON;
	LAT = station_locations.LAT;

end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select one station from a map
function [but iT iS p mlon mlat] = pickonestation(LAT,LON,varargin);
% If OBJ is a database
%	iT: the corresponding transect within the database
%	iS: the corresponding station in the transect
% If OBJ is a transect:
%	iT: NaN
%	iS: the corresponding station in the transect
%
%	but: is the button pressed with the mouse
%	p: handle of the point selected (little red square)
%	mlon,mlat: long/lat of the station selected
%

if nargin == 3
	TAG = varargin{1};
else
	TAG = 'activestation';
end

OBJ      = getappdata(gcf,'OBJ');
MMAPinfo = getappdata(gcf,'MMAPinfo');
adjustmmap(MMAPinfo);
gmethod = 1;


switch gmethod
	case 1
		[x y but]   = ginput(1);    % Pick one point with the mouse
		[mlon mlat] = m_xy2ll(x,y); % Convert point coords to lat/lon
	
		if but == 1
			busy
	
			% Find the closest station of the point:
			for ip = 1 : length(LAT)
				d(ip) = lldist([mlat LAT(ip)],[mlon LON(ip)])/1e3; % Distance in km
			end
			method = 3;
			switch method
				case 1 % SELECT THE CLOSEST STATION
					[dmin ii] = min(d); 
					if length(ii) > 1
						warning('I found more than one station for this location');
						keyboard
					end
					ii = ii(1); % Ensure we selected only one point
			
				case 2 % FIND STATIONS WITHIN A GIVEN RADIUS
					rad = 25;
					pp = m_range_ring(mlon,mlat,rad);			
					ii = find(d<=rad);
					if length(ii) > 1				
						warning('I found more than one station for this location');
						ii=ii(1);
					elseif isempty(ii)
						w=warndlg('No stations in this area');
						waitfor(w);
						but = NaN;
						iT = NaN; iS = NaN; p = NaN;
						return
					else
						ii = ii(1);
					end
			
				case 3 % SELECT THE CLOSEST STATION and check if another one is also very close		
					% 1st check if a station is in the area:
					rad = 50;
					ii  = find(d<=rad);
					if isempty(ii)
						w=warndlg('No stations in this area');
						waitfor(w);
						but = NaN;
						iT = NaN; iS = NaN; p = NaN;
						return
					end
			
					% 2nd we choose the closest station		
					[dmin ii] = min(d);
					ii = ii(1); % Ensure we selected only one point
			
					% 3rd we check if other stations are close:
					rad = 10; % Max radius in km around the closest station
					ii2 = find(d <= dmin(1)+rad);			
					if isempty(setxor(ii2,ii))
						% No other stations around, we continue ...
						p = m_plot(LON(ii),LAT(ii),'rs','tag',TAG);
						% Identify the transect/station
						[iT iS] = identify_station_from_coord(OBJ,LAT(ii),LON(ii));
						return
					else
		%				disp(sprintf('I found more than one station close to this location\nLet me identify them ...'))
						hlpop = simplepopup(gcf,'Identifying stations in the area ... ');drawnow
						% We need to propose these other stations:				
						for is = 1 : length(ii2)
							[iT iS] = identify_station_from_coord(OBJ,LAT(ii2(is)),LON(ii2(is)));
							switch class(OBJ)
								case 'database'
									slist(is) = {sprintf('Distance = %0.0f km / Transect: %s / LON = %0.2f / LAT = %0.2f',d(ii2(is)),stamp(OBJ(iT),5),LON(ii2(is)),LAT(ii2(is)))};							
								case 'transect'
									slist(is) = {sprintf('Distance = %0.0f km / Station date: %s / LON = %0.2f / LAT = %0.2f',d(ii2(is)),datestr(OBJ.geo.STATION_DATE(iS)),LON(ii2(is)),LAT(ii2(is)))};													
							end
							TT(is) = iT;
							SS(is) = iS;
						end
						delete(hlpop);
						is = menu('Choose a station to plot',slist);
						if is ~= 0
							ii = ii2(is);
							p = m_plot(LON(ii),LAT(ii),'rs','tag','activestation');
							iT = TT(is);
							iS = SS(is);
							return
						else
							but = NaN;
							iT = NaN; iS = NaN; p = NaN;
							return
						end
					end
			
			end%switch method
			p = m_plot(LON(ii),LAT(ii),'rs','tag',TAG);
	
			% Identify the transect/station
			[iT iS] = identify_station_from_coord(OBJ,LAT(ii),LON(ii));
			idle
	
		else
			but = NaN;
			iT = NaN; iS = NaN; p = NaN;
			idle
			return
		end
		idle


	case 2
		gtrack_on;idle
		getappdata(gcf,'clickData')
		stophere
%		[but iT iS p mlon mlat]

end%switch

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Popup to select one or more datas within a database/transect object
function dlist = datalistselectionpopup(varargin)
	
if 0	
	ftop = gcf;
	OBJ  = getappdata(ftop,'OBJ');
	dlist = datanames(OBJ);
	switch class(OBJ)
		case 'database'	
			for iv = 1 : length(dlist)
				od = subsref(OBJ(1),substruct('.','data','.',dlist{iv}));
				dlstring(iv) = {sprintf('%7s: %s [%s]',dlist{iv},od.long_name,od.unit)};
			end		
		case 'transect'
			for iv = 1 : length(dlist)
				od = subsref(OBJ,substruct('.','data','.',dlist{iv}));
				dlstring(iv) = {sprintf('%7s: %s [%s]',dlist{iv},od.long_name,od.unit)};
			end
	end
	[s,v] = listdlg('PromptString','Choose one or more variable to plot','ListString',dlstring,'ListSize',[500 300],'Name','COPODA');
	if v == 1
		dlist  = dlist(s);
	else
		dlist = {};
	end
	
else
	busy
	ftop = gcf;
	OBJ  = getappdata(ftop,'OBJ');
	
	thif = builtin('figure');
	postop = get(ftop,'position');
	posthi = get(thif,'position');
	set(thif,'toolBar','none','menubar','none','name','COPODA: Select variable(s)','numberTitle','off');
	set(thif,'color',[.5 .5 1]/2);
	if ~isdocked,set(thif,'Resize','off');end
	
	switch class(OBJ)
		case 'database'			
			% If something is selected, we get variable for this object
			if isappdata(ftop,'active_transect') 
				active_transect = getappdata(ftop,'active_transect');
				dlist   = datanames(OBJ(active_transect.iT),1); % In all transect
				objname = sprintf('transect #%i, %s',active_transect.iT,OBJ.transect{active_transect.iT}.cruise_info.NAME);
				iT = active_transect.iT;
			elseif isappdata(ftop,'active_station') 
				active_station = getappdata(ftop,'active_station');
				dlist  = datanames(OBJ(active_station.iT),1); % In all transect
				objname = sprintf('station #%i in transect %s',active_station.iS,OBJ.transect{active_station.iT}.cruise_info.NAME);
				iT = active_station.iT;
			else
				dlist  = datanames(OBJ,1); % In all transect
				objname = sprintf('database %s',OBJ.name);
				iT = 1;
			end
		case 'transect'
			if isappdata(ftop,'active_station') 
				active_station = getappdata(ftop,'active_station');
				dlist   = datanames(OBJ,1); % Non empty
				objname = sprintf('station #%i in %s',active_station.iS,OBJ.cruise_info.NAME);
			else
				dlist   = datanames(OBJ,1); % Non empty
				objname = sprintf('transect %s',OBJ.cruise_info.NAME);
			end
	end
	set(thif,'name',sprintf('COPODA: Select variable(s) from %s',objname));
	
	% Eventualy removed some parameters:
	switch nargin
		case 1
			dlistout = varargin{1};
			dlist = setdiff(dlist,dlistout);
	end% switch 
	
	[a idefaultval] = intersect(dlist,'TEMP'); clear a
	choice = [];
	if isempty(idefaultval)
		idefaultval = 1;
	end% if 
	
	% Create list to display:
	ltyp = 3;
	switch ltyp		
	 	case 1 % Basic data names
			dlstring = dlist; 
	 	case 2 % More complete list description of variables
			switch class(OBJ)
				case 'database'	
					for iv = 1 : length(dlist)
						od = subsref(OBJ(iT),substruct('.','data','.',dlist{iv}));
						dlstring(iv) = {sprintf('%7s: %s [%s]',dlist{iv},od.long_name,od.unit)};
					end		
				case 'transect'
					for iv = 1 : length(dlist)
						od = subsref(OBJ,substruct('.','data','.',dlist{iv}));
						dlstring(iv) = {sprintf('%7s: %s [%s]',dlist{iv},od.long_name,od.unit)};
					end
			end% switch 
		case 3
			switch class(OBJ)
				case 'database'	
					for iv = 1 : length(dlist)
						od = subsref(OBJ(iT),substruct('.','data','.',dlist{iv}));
						dlstring(iv) = {sprintf('%7s: %s [%s]',dlist{iv},od.name,od.unit)};
					end		
				case 'transect'
					for iv = 1 : length(dlist)						
%						od = subsref(OBJ,substruct('.','data','.',dlist{iv}));
%						dlstring(iv) = {sprintf('%7s: %s [%s]',dlist{iv},od.name,od.unit)};
						odname = subsref(OBJ,substruct('.','data','.',dlist{iv},'.','name'));
						odunit = subsref(OBJ,substruct('.','data','.',dlist{iv},'.','unit'));
						dlstring(iv) = {sprintf('%7s: %s [%s]',dlist{iv},odname,odunit)};
					end
			end% switch	
	end% switch 
	idle
	
	if length(dlist) == 0
		% No variable to choose !
		listchoiceOK = uicontrol('Parent',thif,'Style','pushbutton','backgroundcolor','w',...
		                'String','No variable','Callback',{@abort});
		set(listchoiceOK,'units','normalized','position',[.3 .125 .4 .05],'FontName',get(0,'FixedWidthFontName'));
		
	else
		% Select one or more variable:
		listchoice = uicontrol('Parent',thif,'Style','listbox',...
		                'String',dlstring,'backgroundcolor','w','userdata',dlist,...
		                'Max',length(dlstring),'Min',1,'Value',idefaultval,'tag','list','Callback',{@validlistdirect});
		set(listchoice,'units','normalized','position',[.1 .2 .8 .75],'FontName',get(0,'FixedWidthFontName'));
	
		listchoiceOK = uicontrol('Parent',thif,'Style','pushbutton','backgroundcolor','w','userdata',dlist,...
		                'String','Ok','Callback',{@validlist});
		set(listchoiceOK,'units','normalized','position',[.3 .125 .4 .05],'FontName',get(0,'FixedWidthFontName'));
	
		listchoiceCANCEL = uicontrol('Parent',thif,'Style','pushbutton','backgroundcolor','w','userdata',dlist,...
		                'String','Cancel','Callback',{@abort});
		set(listchoiceCANCEL,'units','normalized','position',[.3 .05 .4 .05],'FontName',get(0,'FixedWidthFontName'));
			
		centerthis(ftop,thif);
		set([listchoice listchoiceOK listchoiceCANCEL],'FontSize',10,'FontName',get(0,'FixedWidthFontName'));
		set([listchoice listchoiceOK listchoiceCANCEL],'BackgroundColor',[.5 .5 .5],'ForegroundColor','k');
	
	end% if 
	waitfor(listchoiceOK);
end

	function validlist(hObject,eventdata)
	
		thif     = get(hObject,'Parent');
		selected = get(findobj(thif,'tag','list'),'value');
		dlist    = get(hObject,'userdata');
		assignin('caller','dlist',dlist(selected));
		delete(get(hObject,'Parent'));
	
	end%function
	
	function validlistdirect(hObject,eventdata)
		
		thif = get(hObject,'Parent');
		switch get(thif,'SelectionType')
			case 'normal'
			 % We do nothing, we need a double click
			case 'open'
				selected = get(findobj(thif,'tag','list'),'value');
				dlist    = get(hObject,'userdata');
				assignin('caller','dlist',dlist(selected));
				delete(get(hObject,'Parent'));
		end

		
	end%function
	
	function abort(hObject,eventdata)
		assignin('caller','dlist',{});
		delete(get(hObject,'Parent'));
	end%function

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw a polygon on the map and return coordinates
function varargout = drawmpoly(ftop);

%h=helpdlg(sprintf('<left click> to valide a point\n<right click> to remove the last one\n<middle click> to close the polygon, clear it from the map and return coordinates\n<return> to close the polygon, leave it on the map and return coordinates'));
disp(sprintf('\n<left click>  to valide a point'));
disp('<right click> or <del> to remove the last point')
disp('<middle click> or <return> to close and validate the polygon')
disp('<esc> to cancel') % asci 27
%waitfor(h);

builtin('figure',ftop);hold on
MMAPinfo = getappdata(ftop,'MMAPinfo');
adjustmmap(MMAPinfo);

n = 1;
[x y but] = ginput(1);
if but == 27 % Escape key
	varargout(1) = {NaN};
	varargout(2) = {NaN};
	varargout(3) = {NaN};
	varargout(4) = {but};
	return
end

[lon(n) lat(n)] = m_xy2ll(x,y);
delete(findobj(ftop,'tag','drawmpoly')); p = m_plot(lon,lat,'r-o');set(p,'tag','drawmpoly');drawnow;

done = 0;
while done ~= 1
	n = n + 1;
	[x y but] = ginput(1);
	if isempty(but) ,but = 2; end % Pressed <return>, move to middle click

	if but ~= 27
		switch but
			case 1 % left click: Valid the point and update polygon
				[lon(n) lat(n)] = m_xy2ll(x,y);
				delete(findobj(ftop,'tag','drawmpoly')); p = m_plot(lon,lat,'r-o'); set(p,'tag','drawmpoly');drawnow
			case 2 % middle click: Close the polygon and exit:
				n = n - 1;
				done = 1;
			case {3,8} % right click or del: Remove last point:
				n = n - 2; lon=lon(1:n);lat=lat(1:n);
				delete(findobj(ftop,'tag','drawmpoly'))
				delete(findobj(ftop,'tag','drawmpoly')); p = m_plot(lon,lat,'r-o'); set(p,'tag','drawmpoly');drawnow			
		end%switch
		
	else % We pressed <esc>
		delete(findobj(ftop,'tag','drawmpoly')); 
		varargout(1) = {NaN};
		varargout(2) = {NaN};
		varargout(3) = {NaN};
		varargout(4) = {but};
		return
	end
end

% close the polygon:
n = n + 1;
lon(n) = lon(1);
lat(n) = lat(1);
delete(findobj(ftop,'tag','drawmpoly')); p = m_plot(lon,lat,'r-o'); set(p,'tag','drawmpoly');drawnow

switch nargout
	case 1
		varargout(1) = {lon};
	case 2
		varargout(1) = {lon};
		varargout(2) = {lat};
	case 3
		varargout(1) = {lon};
		varargout(2) = {lat};
		varargout(3) = {p};
	case 4
		varargout(1) = {lon};
		varargout(2) = {lat};
		varargout(3) = {p};
		varargout(4) = {but};
end

end %functiondrawpoly
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw a rectangle on the map and return coordinates
function [LON LAT] = drawarectangle;

	MMAPinfo = getappdata(gcf,'MMAPinfo');

	builtin('figure',gcf);	
	set(gcf,'pointer','fullcrosshair');
	k = waitforbuttonpress;
    point1 = get(gca,'CurrentPoint');    % button down detected
	set(gcf,'pointer','botr');
    finalRect = rbbox;                   % return figure units
    point2 = get(gca,'CurrentPoint');    % button up detected
    point1 = point1(1,1:2);              % extract x and y
    point2 = point2(1,1:2);
    p1 = min(point1,point2);             % calculate locations
    offset = abs(point1-point2);         % and dimensions
    x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
    y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
    hold on
    axis manual

	adjustmmap(MMAPinfo);
	[LON LAT] = m_xy2ll(x,y);
	
    p = m_plot(LON,LAT,'r','linewidth',2);          % draw box around selected region	
	set(gcf,'pointer','arrow');
	set(p,'tag','zoominbox');
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Popup to aks a question with text answer
function res = askaquestionwithtextanswer(ftop,question);
	
	thif = builtin('figure');
	postop = get(ftop,'position');
	posthi = get(thif,'position');
	set(thif,'toolBar','none','menubar','none','name','','numberTitle','off');
	set(thif,'position',[postop(1:2) posthi(3:4)],'color','w');
	if ~isdocked,set(thif,'Resize','off');end	
	res = [];
	
	TEXT = uicontrol('Parent',thif,'Style','text',...
	                'String',question,'backgroundcolor','w');	
	set(TEXT,'units','normalized','position',[.1 .7 .8 .2],'FontName',get(0,'FixedWidthFontName'));
	
	ANSWER = uicontrol('Parent',thif,'Style','edit',...
	                'String','','backgroundcolor','w','tag','text');	
	set(ANSWER,'units','normalized','position',[.25 .7 .5 .1],'FontName',get(0,'FixedWidthFontName'));	
	
	OK = uicontrol('Parent',thif,'Style','pushbutton','backgroundcolor','w',...
	                'String','Ok','Callback',{@validthis});
	set(OK,'units','normalized','position',[.3 .125 .4 .05],'FontName',get(0,'FixedWidthFontName'));
	
	CANCEL = uicontrol('Parent',thif,'Style','pushbutton','backgroundcolor','w',...
	                'String','Cancel','Callback',{@abort});
	set(CANCEL,'units','normalized','position',[.3 .05 .4 .05],'FontName',get(0,'FixedWidthFontName'));
		
	centerthis(ftop,thif);		
	waitfor(OK);
	
	function validthis(hObject,eventdata)
		
		thif = get(hObject,'Parent');
		text = get(findobj(thif,'tag','text'),'string');
		if ~isempty(text)
			assignin('caller','res',text);
			delete(get(hObject,'Parent'));
		end
		
	end%function
	
	function abort(hObject,eventdata)
		delete(get(hObject,'Parent'));
	end%function
	
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Popup to aks a question with text answer
function res = savenewobj(ftop,question);
	
	thif = builtin('figure');
	postop = get(ftop,'position');
	posthi = get(thif,'position');
	set(thif,'toolBar','none','menubar','none','name','COPODA','numberTitle','off');
	set(thif,'position',[postop(1:2) 400 300],'color',[.5 .5 1]/2);
	res = {};
	
	TEXT = uicontrol('Parent',thif,'Style','text',...
	                'String',question,'tag','waitforthisone');	
	
	ANSWER = uicontrol('Parent',thif,'Style','edit',...
	                'String','','tag','text');
	
	OK1 = uicontrol('Parent',thif,'Style','pushbutton',...
	                'String','Save in workspace','Callback',{@validthis1});
	
	OK2 = uicontrol('Parent',thif,'Style','pushbutton',...
	                'String','Save in workspace and plot tracks','Callback',{@validthis2});
	
	OK3 = uicontrol('Parent',thif,'Style','pushbutton',...
	                'String','Plot tracks without saving in workspace','Callback',{@validthis3});
	
	CANCEL = uicontrol('Parent',thif,'Style','pushbutton',...
	                'String','Cancel','Callback',{@abort});
	
	w = .9;
	h = .075; dh = 0.01;
	b = .1; 
	set(TEXT,'units','normalized','position',  [0 .7 1 2*h],'FontName',get(0,'FixedWidthFontName'));	
	set(ANSWER,'units','normalized','position',[(1-w/2)/2 .7-h w/2 h],'FontName',get(0,'FixedWidthFontName'));	
	set(OK1,'units','normalized','position',   [(1-w)/2 b+3*(h+dh) w h],'FontName',get(0,'FixedWidthFontName'));
	set(OK2,'units','normalized','position',   [(1-w)/2 b+2*(h+dh) w h],'FontName',get(0,'FixedWidthFontName'));	
	set(OK3,'units','normalized','position',   [(1-w)/2 b+1*(h+dh) w h],'FontName',get(0,'FixedWidthFontName'));	
	set(CANCEL,'units','normalized','position',[(1-w)/2 b+0*(h+dh) w h],'FontName',get(0,'FixedWidthFontName'));	
	set([TEXT ANSWER OK1 OK2 OK3 CANCEL],'FontSize',10,'FontName',get(0,'FixedWidthFontName'));
	set([TEXT ANSWER OK1 OK2 OK3 CANCEL],'BackgroundColor',[1 1 1]/2,'ForegroundColor','k');
%	set([TEXT ANSWER OK1 OK2 OK3 CANCEL],'BackgroundColor',[.5 .5 1]/3,'ForegroundColor','w');
%	set([ANSWER],'BackgroundColor',[.5 .5 1],'ForegroundColor','k');
%	set([TEXT],'BackgroundColor',[.5 .5 1]/2,'ForegroundColor','w');
			
	centerthis(ftop,thif);
%	keyboard
	waitfor(TEXT,'tag','letsgo');
	delete(thif);
	
	function validthis1(hObject,eventdata)
		
		thif = get(hObject,'Parent');
		text = get(findobj(thif,'tag','text'),'string');
		if ~isempty(text)
			if ~checkcharacters(text)
				warndlg('Please enter only letters and numbers without space (and eventually ''_'')')
				return
			else
				assignin('caller','res',{text ; 1});
				set(findobj(thif,'tag','waitforthisone'),'tag','letsgo');
			end			
		else
			warndlg('Please enter a value');	
		end
		
	end%function
	
	function validthis2(hObject,eventdata)
		
		thif = get(hObject,'Parent');
		text = get(findobj(thif,'tag','text'),'string');
		if ~isempty(text)
			if ~checkcharacters(text)
				warndlg('Please enter only letters and numbers without space (and eventualy ''_'')')
				return			
			else
				assignin('caller','res',{text ; 2});
				set(findobj(thif,'tag','waitforthisone'),'tag','letsgo');
			end
		else
			warndlg('Please enter a value');		
		end
		
	end%function
	
	function validthis3(hObject,eventdata)
		
		thif = get(hObject,'Parent');
		assignin('caller','res',{'toto' ; 3});
		set(findobj(thif,'tag','waitforthisone'),'tag','letsgo');
		
	end%function
	
	function abort(hObject,eventdata)		
		set(findobj(thif,'tag','waitforthisone'),'tag','letsgo');
	end%function
	
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- SIMPLY USEFUL SCRIPTS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reset in global m_map informations
function adjustmmap(MMAPinfo);
	
global MAP_COORDS MAP_PROJECTION MAP_VAR_LIST
MAP_COORDS     = MMAPinfo.coords;
MAP_PROJECTION = MMAPinfo.proj;
MAP_VAR_LIST   = MMAPinfo.varl;

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Popup to aks a question with text answer
function thif = simplepopup(ftop,text);
	
	pos0 = get(ftop,'position');
	thif = builtin('figure');
	set(thif,'toolBar','none','menubar','none','name','COPODA','numberTitle','off');
	if ~isdocked,
		set(thif,'Resize','off');
		set(thif,'position',[(pos0(1)+pos0(3)-300)/2 pos0(2)+pos0(4)-50 300 50]);
	end
	set(thif,'color',[.5 .5 1]/2);
	
	TEXT = uicontrol('Parent',thif,'Style','text',...
	                'String',text);	
	set(TEXT,'units','pixels','position',[1 12.5 299 25],'FontName',get(0,'FixedWidthFontName'),'fontsize',10);
	
	
	set(TEXT,'FontSize',10,'FontName',get(0,'FixedWidthFontName'));
	set(TEXT,'BackgroundColor',[.5 .5 1]/2,'ForegroundColor','w');	
	
	centerthis(ftop,thif);
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Center one figure upon another
function varargout = centerthis(HLref,HLpop)
if ~isdocked	
	
	% Position of the reference window:	
		posref = get(HLref,'position');
	% Center position on screen:
		x0 = posref(1)+posref(3)/2;
		y0 = posref(2)+posref(4)/2;
	
	% Position of the popup window:
		pospop = get(HLpop,'position');
	% Center it:
		set(HLpop,'position',[x0-pospop(3)/2 y0-pospop(4)/2 pospop(3:4)]);

end
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if a character string contains only valid characters
function RES = checkcharacters(STRING);
	
	validCHARS = 'abcdfeghijklmnopqrstuvwxyz0123456789_';
	RES = true;
	for ic = 1 : length(STRING)
		if isempty(strfind(validCHARS,lower(STRING(ic))))
			RES = false;
		end
	end
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Identify the station number and transect number from 1 location
function [iT iS] = identify_station_from_coord(OBJ,LAT,LON);
	
% Identify the transect/station
switch class(OBJ)
	case 'database'
		for it = 1 : length(OBJ)
			T    = OBJ.transect{it};
			Tlat = T.geo.LATITUDE;
			Tlon = T.geo.LONGITUDE;
			iy = find( abs(Tlat-LAT) < 50*eps );
			ix = find( abs(Tlon-LON) < 50*eps );
			if ~isempty(intersect(ix,iy))
					iT = it;
					iS = find(abs(Tlat-LAT) < 50*eps,1);			
					return
			end%if
		end%for it
		
		% If we made it through here, there's a problem !
		
		% Let's try to reduce the precision of coordinates:
		try			
			x = extract(OBJ,'LONGITUDE');
			y = extract(OBJ,'LATITUDE');
			done = 0;
			n = [10:50]; in = 1;
			while done ~= 1
				ii = find(fix(x*n(in))/n(in)==fix(LON*n(in))/n(in));
				if isempty(ii)
					in = in + 1;
				elseif length(ii) == 1
					done = 1;
				else
					done = 1;
				end
				if in > length(n), done = 1;end
			end%while
			% Then, look for it again:
			for it = 1 : length(OBJ)
				T    = OBJ.transect{it};
				Tlat = T.geo.LATITUDE;
				Tlon = T.geo.LONGITUDE;
				iy = find( abs(Tlat-y(ii)) < 50*eps );
				ix = find( abs(Tlon-x(ii)) < 50*eps );
				if ~isempty(intersect(ix,iy))
						iT = it;
						iS = find(abs(Tlat-y(ii)) < 50*eps,1);			
						return
				end%if
			end%for it
		catch
			disp('We''re stuck in pickonestation for database ! no transect found')
			keyboard
			x = extract(OBJ,'LONGITUDE');
			y = extract(OBJ,'LATITUDE');
		end
	case 'transect'
		n = 50;
		done = 0;
		while done ~= 1
			iT = NaN;
			Tlat = OBJ.geo.LATITUDE;
			Tlon = OBJ.geo.LONGITUDE;
			iy = find( abs(Tlat-LAT) < n*eps );
			ix = find( abs(Tlon-LON) < n*eps );
			if ~isempty(intersect(ix,iy))
		%			iS = find(OBJ.geo.LATITUDE==LAT(ii),1);		
					iS = find(abs(Tlat-LAT) < n*eps,1);	
					return
					done = 1;
			else
				n = 2*n;
			end
			if n > 1e3				
				disp('We''re stuck in pickonestation for transect ! no station found')
				keyboard
				x = extract(OBJ,'LONGITUDE');
				y = extract(OBJ,'LATITUDE');
			end
		end%while
	otherwise
		error('We must have a database or transect object to work with !')
end%switch

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute distance in meters between two points
% We use a local routine because the function m_lldist
% returns meter or km depending on the version of the
% m_map package !
% So I don't want to check which version is it
function dist = lldist(lat,lon)
	
	if length(lat) == 1 & length(lon)>1
		lat = lat*ones(1,length(lon));
	elseif length(lon) == 1 & length(lat)>1
		lon = lon*ones(1,length(lat));
	end
	pi180=pi/180;
	earth_radius=6378.137e3;

	long1=lon(1:end-1)*pi180;
	long2=lon(2:end)*pi180;
	lat1=lat(1:end-1)*pi180;
	lat2=lat(2:end)*pi180;

	dlon = long2 - long1; 
	dlat = lat2 - lat1; 
	a = (sin(dlat/2)).^2 + cos(lat1) .* cos(lat2) .* (sin(dlon/2)).^2;
	c = 2 * atan2( sqrt(a), sqrt(1-a) );
	dist = earth_radius * c;

	dist = dist(:)';

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out1,out2,out3] = ginput(arg1)
%GINPUT Graphical input from mouse.
%   [X,Y] = GINPUT(N) gets N points from the current axes and returns 
%   the X- and Y-coordinates in length N vectors X and Y.  The cursor
%   can be positioned using a mouse (or by using the Arrow Keys on some 
%   systems).  Data points are entered by pressing a mouse button
%   or any key on the keyboard except carriage return, which terminates
%   the input before N points are entered.
%
%   [X,Y] = GINPUT gathers an unlimited number of points until the
%   return key is pressed.
% 
%   [X,Y,BUTTON] = GINPUT(N) returns a third result, BUTTON, that 
%   contains a vector of integers specifying which mouse button was
%   used (1,2,3 from left) or ASCII numbers if a key on the keyboard
%   was used.
%
%   Examples:
%       [x,y] = ginput;
%
%       [x,y] = ginput(5);
%
%       [x, y, button] = ginput(1);
%
%   See also GTEXT, UIRESTORE, UISUSPEND, WAITFORBUTTONPRESS.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 5.32.4.9 $  $Date: 2006/12/20 07:19:10 $

out1 = []; out2 = []; out3 = []; y = [];
c = computer;
if ~strcmp(c(1:2),'PC') 
   tp = get(0,'TerminalProtocol');
else
   tp = 'micro';
end

if ~strcmp(tp,'none') && ~strcmp(tp,'x') && ~strcmp(tp,'micro'),

   if nargout == 1,
      if nargin == 1,
         out1 = trmginput(arg1);
      else
         out1 = trmginput;
      end
   elseif nargout == 2 || nargout == 0,
      if nargin == 1,
         [out1,out2] = trmginput(arg1);
      else
         [out1,out2] = trmginput;
      end
      if  nargout == 0
         out1 = [ out1 out2 ];
      end
   elseif nargout == 3,
      if nargin == 1,
         [out1,out2,out3] = trmginput(arg1);
      else
         [out1,out2,out3] = trmginput;
      end
   end

else
   	
	fig = gcf;
%	figure(fig);

   if nargin == 0
      how_many = -1;
      b = [];
   else
      how_many = arg1;
      b = [];
      if  ischar(how_many) ...
            || size(how_many,1) ~= 1 || size(how_many,2) ~= 1 ...
            || ~(fix(how_many) == how_many) ...
            || how_many < 0
         error('MATLAB:ginput:NeedPositiveInt', 'Requires a positive integer.')
      end
      if how_many == 0
         ptr_fig = 0;
         while(ptr_fig ~= fig)
            ptr_fig = get(0,'PointerWindow');
         end
         scrn_pt = get(0,'PointerLocation');
         loc = get(fig,'Position');
         pt = [scrn_pt(1) - loc(1), scrn_pt(2) - loc(2)];
         out1 = pt(1); y = pt(2);
      elseif how_many < 0
         error('MATLAB:ginput:InvalidArgument', 'Argument must be a positive integer.')
      end
   end
   
   % Suspend figure functions
   state = uisuspend(fig);
   
   toolbar = findobj(allchild(fig),'flat','Type','uitoolbar');
   if ~isempty(toolbar)
        ptButtons = [uigettool(toolbar,'Plottools.PlottoolsOff'), ...
                     uigettool(toolbar,'Plottools.PlottoolsOn')];
        ptState = get (ptButtons,'Enable');
        set (ptButtons,'Enable','off');
   end

%   set(fig,'pointer','fullcrosshair');	
%   set(fig,'pointer','circle');
	CData = load(fullfile(copoda_readconfig('copoda_data_folder'),'icon_target.mat'));CData=CData.A(:,:,1);
	CData(CData==0)=1;
	set(fig,'PointerShapeCData',CData,'PointerShapeHotSpot',[8 8],'pointer','custom');
   fig_units = get(fig,'units');
   char = 0;

   % We need to pump the event queue on unix
   % before calling WAITFORBUTTONPRESS 
   drawnow
   
   while how_many ~= 0
      % Use no-side effect WAITFORBUTTONPRESS
      waserr = 0;
      try
		keydown = wfbp;
      catch
		waserr = 1;
      end
      if(waserr == 1)
         if(ishandle(fig))
            set(fig,'units',fig_units);
	    	uirestore(state);
            error('MATLAB:ginput:Interrupted', 'Interrupted');
         else
            error('MATLAB:ginput:FigureDeletionPause', 'Interrupted by figure deletion');
         end
      end
      
      ptr_fig = get(0,'CurrentFigure');
      if(ptr_fig == fig)
         if keydown
            char = get(fig, 'CurrentCharacter');
            button = abs(get(fig, 'CurrentCharacter'));
            scrn_pt = get(0, 'PointerLocation');
            set(fig,'units','pixels')
            loc = get(fig, 'Position');
            % We need to compensate for an off-by-one error:
            pt = [scrn_pt(1) - loc(1) + 1, scrn_pt(2) - loc(2) + 1];
            set(fig,'CurrentPoint',pt);
         else
            button = get(fig, 'SelectionType');
            if strcmp(button,'open') 
               button = 1;
            elseif strcmp(button,'normal') 
               button = 1;
            elseif strcmp(button,'extend')
               button = 2;
            elseif strcmp(button,'alt') 
               button = 3;
            else
               error('MATLAB:ginput:InvalidSelection', 'Invalid mouse selection.')
            end
         end
         pt = get(gca, 'CurrentPoint');
         
         how_many = how_many - 1;
         
         if(char == 13) % & how_many ~= 0)
            % if the return key was pressed, char will == 13,
            % and that's our signal to break out of here whether
            % or not we have collected all the requested data
            % points.  
            % If this was an early breakout, don't include
            % the <Return> key info in the return arrays.
            % We will no longer count it if it's the last input.
            break;
         end
         
         out1 = [out1;pt(1,1)];
         y = [y;pt(1,2)];
         b = [b;button];
      end
   end
   
   uirestore(state);
   if ~isempty(toolbar) && ~isempty(ptButtons)
        set (ptButtons(1),'Enable',ptState{1});
        set (ptButtons(2),'Enable',ptState{2});
   end
   set(fig,'units',fig_units);
   
   if nargout > 1
      out2 = y;
      if nargout > 2
         out3 = b;
      end
   else
      out1 = [out1 y];
   end
   
end%if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function key = wfbp
%WFBP Replacement for WAITFORBUTTONPRESS that has no side effects.

fig = gcf;
current_char = [];

% Now wait for that buttonpress, and check for error conditions
waserr = 0;
try
  h=findall(fig,'type','uimenu','accel','C');   % Disabling ^C for edit menu so the only ^C is for
  set(h,'accel','');                            % interrupting the function.
  keydown = waitforbuttonpress;
  current_char = double(get(fig,'CurrentCharacter')); % Capturing the character.
  if~isempty(current_char) && (keydown == 1)           % If the character was generated by the 
	  if(current_char == 3)                       % current keypress AND is ^C, set 'waserr'to 1
		  waserr = 1;                             % so that it errors out. 
	  end
  end
  
  set(h,'accel','C');                                 % Set back the accelerator for edit menu.
catch
  waserr = 1;
end
drawnow;
if(waserr == 1)
   set(h,'accel','C');                                % Set back the accelerator if it errored out.
   error('MATLAB:ginput:Interrupted', 'Interrupted');
end

if nargout>0, key = keydown; end
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end%function ginput
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the watch-cursor.
function busy(theFigure)

	if ~any(findall(0,'type','figure')), return, end

	if nargin < 1
%	   theFigure = gcf;
		theFigure = findall(0,'type','figure');
	end

	set(theFigure, 'Pointer', 'watch');

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the arrow-cursor.
function idle(theFigure)

	if ~any(findall(0,'type','figure')), return, end

	if nargin < 1
%	   theFigure = gcf;
		theFigure = findall(0,'type','figure');
	end

	set(theFigure, 'Pointer', 'arrow');

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = isdocked
	switch get(0,'DefaultFigureWindowStyle')
		case 'docked'
			res = true;
		otherwise
			res = false;
	end%switch
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% mouse move callback
function gtrack_OnMouseMove(src,evnt)

	% get mouse position
	pt = get(gca,'CurrentPoint');
	xInd = pt(1,1);
	yInd = pt(1,2);	

	% check if its within axes limits
	xLim = get(gca, 'XLim');	
	yLim = get(gca, 'YLim');
	if xInd < xLim(1) | xInd > xLim(2)
%		title('Out of Longitude limit');	
		return;
	end
	if yInd < yLim(1) | yInd > yLim(2)
%		title('Out of Latitude limit');
		return;
	end
	
	[lo la] = m_xy2ll(xInd,yInd);
	setappdata(gcf,'xInd',lo);
	setappdata(gcf,'yInd',la);
	
%	title(sprintf('%0.2f / %0.2f',lo,la));

	db = 0.5;
	if isempty(findobj(gcf,'tag','movingbox'))
		NW = [lo-db la+db];
		SE = [lo+db la-db];
		m_line([NW(1) SE(1) SE(1) NW(1) NW(1)],[NW(2) NW(2) SE(2) SE(2) NW(2)],'tag','movingbox');
	else
		p = findobj(gcf,'tag','movingbox');
		NW = [lo-db la+db];
		SE = [lo+db la-db];
		[x,y] = m_ll2xy([NW(1) SE(1) SE(1) NW(1) NW(1)],[NW(2) NW(2) SE(2) SE(2) NW(2)]);
		set(p,'xdata',x,'ydata',y);
	end

	station_locations = getappdata(gcf,'station_locations');
	is = find(abs(station_locations.LAT-la)<db & abs(station_locations.LON-lo)<db);
	if ~isempty(is)
		for ip = 1 : length(is)
			d(ip) = lldist([la station_locations.LAT(is(ip))],[lo station_locations.LON(is(ip))])/1e3; % Distance in km
		end
%		d = lldist([la station_locations.LAT(is)],[lo station_locations.LON(is)]);
		[dm id] = min(d); id=id(1);
		[x,y] = m_ll2xy(station_locations.LON(is(id)),station_locations.LAT(is(id)));			
		if isempty(findobj(gcf,'tag','movingstation'))
			plot(x,y,'rs','tag','movingstation');
		else
			p = findobj(gcf,'tag','movingstation');
			set(p,'xdata',x,'ydata',y);
		end
	end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% mouse click callback
function gtrack_OnMouseDown(src,evnt)
	
	switch get(gcf,'SelectionType')
		case 'normal' % left click: VALID POINT
			clickData = getappdata(gcf,'clickData');
			clickData(end+1).x = getappdata(gcf,'xInd');
			clickData(end).y   = getappdata(gcf,'yInd');	
			setappdata(gcf,'clickData',clickData);
			gtrack_off	
			uiresume(gcf);
			return
		case 'alt' % right click: CANCEL
			rmappdata(gcf,'clickData');
			gtrack_off;
			uiresume(gcf);
			return
	end

	% else add click to clickData	
	xInd = getappdata(gcf,'xInd');
	yInd = getappdata(gcf,'yInd');
	clickData = getappdata(gcf,'clickData');
	clickData(end+1).x = xInd;
	clickData(end).y   = yInd;	
	setappdata(gcf,'clickData',clickData);
	
%	fprintf('\nX = %f   Y = %f\n',xInd,yInd);

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% terminate callback
function gtrack_off(src,evnt)

	% restore default figure properties
	handles = guidata(gca);
	set(gcf, 'windowbuttonmotionfcn', handles.currFcn);
	set(gcf, 'windowbuttondownfcn', handles.currFcn2);
	set(gcf,'Pointer','arrow');
	%title(handles.currTitle);
	uirestore(handles.theState);
	handles.ID=0;
	guidata(gca,handles);
	rmappdata(gcf,'xInd');
	rmappdata(gcf,'yInd');
	delete(findobj(gcf,'tag','movingstation'))
	delete(findobj(gcf,'tag','movingbox'))
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% begin callback
function gtrack_on
	
% get current figure event functions
currFcn   = get(gcf, 'windowbuttonmotionfcn');
currFcn2  = get(gcf, 'windowbuttondownfcn');
currTitle = get(get(gca,'Title'),'String');

% add data to figure handles
handles = guidata(gca);
if (isfield(handles,'ID') & handles.ID==1)
	error('gtrack is already active.');
else
	handles.ID = 1;
end
handles.currFcn = currFcn;
handles.currFcn2 = currFcn2;
handles.currTitle = currTitle;
handles.theState = uisuspend(gcf);
guidata(gca,handles);

% declare variables
xInd = 0;
yInd = 0;
clickData = [];	
setappdata(gcf,'xInd',xInd);
setappdata(gcf,'yInd',yInd);
setappdata(gcf,'clickData',clickData);

% set event functions 
set(gcf,'Pointer','crosshair');
set(gcf, 'windowbuttonmotionfcn', @gtrack_OnMouseMove);        
set(gcf, 'windowbuttondownfcn',   @gtrack_OnMouseDown);   

uiwait;
	
end%function       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function resp = mquestdlg(ftop,tit,ftit,varargin)

pos0 = get(ftop,'position');
thif = builtin('figure');
set(thif,'toolBar','none','menubar','none','name',ftit,'numberTitle','off');
if ~isdocked,
	w = pos0(3)/2;
	h = pos0(4)/2;
	set(thif,'Resize','on');
	set(thif,'position',[pos0(1)+w/2 pos0(2)+h/2 w h]);
end
set(thif,'color',[.5 .5 1]/2);
centerthis(ftop,thif);

TEXT = uicontrol('Parent',thif,'Style','text',...
                'String',tit);	
set(TEXT,'FontName',get(0,'FixedWidthFontName'),'fontsize',10);
set(TEXT,'units','normalized','Position',[0 .89 1 .1])
set(TEXT,'BackgroundColor',[.5 .5 1]/2,'ForegroundColor','w','fontweight','bold');	

nbt = nargin-3;ii=0;
for iv = nbt : -1 : 1
	ii = ii + 1;
	listchoice(ii) = uicontrol('Parent',thif,'Style','pushbutton','backgroundcolor','w',...
	                'String',varargin{iv},'ForegroundColor',[.5 .5 1]/2,'callback',{@pickthis});
end% for iv
set(listchoice,'units','normalized','position',[.2 .89-nbt*.1 .6 .1],'FontName',get(0,'FixedWidthFontName'),'fontweight','bold');
align(listchoice,'center','fixed',4)   
waitfor(thif);

	function pickthis(hObject,eventdata)

		thif     = get(hObject,'Parent');
		assignin('caller','resp',get(hObject,'String'));
		delete(thif);

	end%function

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


















