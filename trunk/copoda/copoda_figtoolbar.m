% copoda_figtoolbar Add the COPODA figure toolbar
%
% [] = copoda_figtoolbar(OBJ)
% 
% Add the COPODA toolbar to a figure.
%
% Inputs:
%	OBJ is either a database or a transect object
%
% Created: 2010-05-06.
% http://code.google.com/p/copoda
% Copyright (c)  2010, COPODA

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
function varargout = copoda_figtoolbar(OBJ,varargin)

% Existing toolbars on this figure:
fighl = gcf;
tbh0  = findall(fighl,'Type','uitoolbar');

% We remove it and re-create it to update:
if ~isempty(tbh0)
	delete(findobj(tbh0,'Tag','copoda_figtoolbar'));
end
tbh  = uitoolbar(fighl,'Tag','copoda_figtoolbar');	

global MAP_COORDS MAP_PROJECTION MAP_VAR_LIST
MMAPinfo.coords = MAP_COORDS;
MMAPinfo.proj = MAP_PROJECTION;
MMAPinfo.varl = MAP_VAR_LIST;

%
figdatas.OBJ  = OBJ;
figdatas.MMAP = MMAPinfo;

% Add buttons to the toolbar:
drawprofiles(figdatas,tbh);
%stationsinformations(OBJ,tbh); 
cutdomain(figdatas,tbh);
zoomin(figdatas,tbh);

end %functioncopoda_figtoolbar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- BUTTONS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add the zoom in button to the toolbar
function varargout = zoomin(figdatas,tbh)

if ispc, sla = '\'; else, sla = '/'; end

% Add the button to the COPODA toolbar
A = load(sprintf('%s%sicon_zoomin.mat',copoda_readconfig('copoda_data_folder'),sla));
pth = uipushtool('Parent',tbh,'CData',A.A,'Enable','on','Tag','copoda_zoominbutton',...
         'TooltipString','Zoom in the map','Separator','off',...
         'HandleVisibility','on','ClickedCallback',{@zoomin_action},'userdata',figdatas);

% Check if we have station on the figure and if not, disable the button:
a = findobj(get(tbh,'parent'),'tag','station_location');
if isempty(a)
	set(pth,'Enable','off')
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add the cut button to the toolbar
function varargout = cutdomain(figdatas,tbh)

if ispc, sla = '\'; else, sla = '/'; end

% Add the button to the COPODA toolbar
A = load(sprintf('%s%sicon_scissors.mat',copoda_readconfig('copoda_data_folder'),sla));
pth = uipushtool('Parent',tbh,'CData',A.A,'Enable','on','Tag','copoda_cutbutton',...
         'TooltipString','Cut database/transect','Separator','off',...
         'HandleVisibility','on','ClickedCallback',{@cut_action},'userdata',figdatas);

% Check if we have station on the figure and if not, disable the button:
a = findobj(get(tbh,'parent'),'tag','station_location');
if isempty(a)
	set(pth,'Enable','off')
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add the station info button to the toolbar
function varargout = stationsinformations(figdatas,tbh)

if ispc, sla = '\'; else, sla = '/'; end

% Add the button to the COPODA toolbar
A = load(sprintf('%s%sicon_profiletoolbutton.mat',copoda_readconfig('copoda_data_folder'),sla));
pth = uipushtool('Parent',tbh,'CData',A.A,'Enable','on','Tag','copoda_stinfobutton',...
         'TooltipString','Informations about a station','Separator','off',...
         'HandleVisibility','on','ClickedCallback',{@stinfo_action},'userdata',figdatas);

% Check if we have station on the figure and if not, disable the button:
a = findobj(get(tbh,'parent'),'tag','station_location');
if isempty(a)
	set(pth,'Enable','off')
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Add the profile button to the toolbar
function varargout = drawprofiles(figdatas,tbh)

if ispc, sla = '\'; else, sla = '/'; end

% Add the button to the COPODA toolbar
A = load(sprintf('%s%sicon_profile.mat',copoda_readconfig('copoda_data_folder'),sla));
pth = uipushtool('Parent',tbh,'CData',A.A,'Enable','on','Tag','copoda_profilebutton',...
         'TooltipString','Plot station profile(s)','Separator','off',...
         'HandleVisibility','on','ClickedCallback',{@drawprofiles_action},'userdata',figdatas);

% Check if we have station on the figure and if not, disable the button:
a = findobj(get(tbh,'parent'),'tag','station_location');
if isempty(a)
	set(pth,'Enable','off')
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- ACTIONS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select a rectangular region, extract station in new
% database and plot it on a new figure
% Called when pushed the zoom in button.
function zoomin_action(hObject,eventdata)
	
tbh  = get(hObject,'Parent');
ftop = get(tbh,'Parent');
figdatas = get(hObject,'UserData');
OBJ      = figdatas.OBJ;
MMAPinfo = figdatas.MMAP;

switch class(OBJ)
	case 'database'
	
		delete(findobj(ftop,'tag','zoominbox'))
		[LON LAT] = drawarectangle(ftop,MMAPinfo);
		if ~isempty(LON)
			drawnow;
			d = cut(OBJ,[LON;LAT]);
			if isa(d,'database')
				pos0 = get(ftop,'position');  tag0 = get(ftop,'tag');
				if strfind(tag0,'subtrack_plot_niv')
					niv0 = str2num(tag0(strfind(tag0,'subtrack_plot_niv')+length('subtrack_plot_niv'):end));
				else
					niv0 = 0;
				end
				niv = niv0 + 1;
				pop = simplepopup(ftop,'Plotting...');drawnow
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
%				evalin('base',sprintf('f=figure;'))
%				evalin('base',sprintf('copoda_zoominbutton_data=get(findobj(figure(%i),''tag'',''copoda_zoominbutton''),''userdata'');',ftop));
%				evalin('base',sprintf('copoda_zoominbutton_data=cut(copoda_zoominbutton_data.OBJ,[%s;%s]);',num2str(LON),num2str(LAT)))								
%				evalin('base',sprintf('builtin(''figure'',f);tracks(copoda_zoominbutton_data);clear copoda_zoominbutton_data'));
			end
		end
		adjustmmap(MMAPinfo);
		builtin('figure',ftop);
		set(0,'CurrentFigure',ftop);
	
	case 'transect'
			warndlg('Cut is not implemented for transect objects yet')
			warning('Cut is not implemented for transect objects yet');
	otherwise
			errordlg('We must have a database or transect object to work with !')
			error('We must have a database or transect object to work with !')
end%switch

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw a polygon with the mouse and cut the database within it
% Called when pushed the cut button.
function cut_action(hObject,eventdata)
	
tbh  = get(hObject,'Parent');
ftop = get(tbh,'Parent')
figdatas = get(hObject,'UserData');
OBJ      = figdatas.OBJ;
MMAPinfo = figdatas.MMAP;

switch class(OBJ)
	case 'database'
		[pol(1,:) pol(2,:) p but] = drawmpoly(ftop,MMAPinfo);	
		if isempty(but),but=2;end
		if but == 2 
			if size(pol,2) <= 3 & (pol(:,1) == pol(:,end))
				error('You need at least 3 points !');
			else			
				d = cut(OBJ,pol);
				if isa(d,'database')
					res = savenewobj(ftop,'Please enter the name of the new database to be saved in your workspace');
%					res = askaquestionwithtextanswer(ftop,'Please enter the name of the new database to be saved in your workspace');
					if ~isempty(res)
%						keyboard
						switch res{2}
							case 1 % Only save
								assignin('base',res{1},d);
								disp(sprintf('New database %s added to your workspace',res{1}));
								
							case 2 % Save and plot					
								assignin('base',res{1},d);
								disp(sprintf('New database %s added to your workspace',res{1}));
								f = figure;tracks(d);
								
								adjustmmap(MMAPinfo);
								builtin('figure',ftop);
								set(0,'CurrentFigure',ftop);
							case 3	% Only plot
								f = figure;tracks(d);
								
								adjustmmap(MMAPinfo);
								builtin('figure',ftop);
								set(0,'CurrentFigure',ftop);
						end					
					end
				else
					warning('No stations in this area !')
				end
			end
		else
			return;
		end
%		delete(findobj(ftop,'tag','drawmpoly'))
	
	case 'transect'
			warndlg('Cut is not implemented for transect objects yet')
			warning('Cut is not implemented for transect objects yet');
	otherwise
			errordlg('We must have a database or transect object to work with !')
			error('We must have a database or transect object to work with !')
end		
	
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select variables then stations and plot vertical profiles 
% on separate windows.
% Called when pushed the profile button.
function drawprofiles_action(hObject,eventdata)
	
tbh  = get(hObject,'Parent');
ftop = get(tbh,'Parent');
figdatas = get(hObject,'UserData');
OBJ      = figdatas.OBJ;
MMAPinfo = figdatas.MMAP;
plotted = false; % Did we plot something ?

adjustmmap(MMAPinfo);
builtin('figure',ftop);
set(0,'CurrentFigure',ftop);

% Get stations lat/lon on the figure:
% Note, from here we must have LON,LAT defined
% It has been checked before if they exist
[LON LAT] = recup_stations_location_on_map(ftop,MMAPinfo);

% Ask to pick one or more variables to plot:
VARN = datalistselectionpopup(ftop,OBJ);

% Select stations and plot profiles:
if ~isempty(VARN)
	done = 0;
	while done ~= 1
		[but iT iS p mlon mlat] = pickonestation(OBJ,LAT,LON,MMAPinfo);
		if but ~= 1
			delete(p);
			done = 1;
		else
	
			if isa(OBJ,'database')
				T = OBJ.transect{iT};
			elseif isa(OBJ,'transect')
				T = OBJ;
			else
				error('We must have a database or transect object to work with !')
			end
		
			% Plot the profile of VARN:
				ztyp = 'DEPH';
				%ztyp = 'PRES';			
				for iv = 1 : length(VARN)
					pos0 = get(ftop,'position');
										
					f(iv) = figure; set(f(iv),'tag','profile_plot');
					od = subsref(T,substruct('.','data','.',VARN{iv}));
					z  = subsref(T,substruct('.','geo','.',ztyp,'()',{iS,':'}));
					p = plot(od.cont(iS,:),z);
					set(p,'marker','.');
					grid on,box on;
					title(sprintf('%s (%s)\n%s',od.name,od.long_name,stamp(T,5)),'fontweight','bold');
					set(gcf,'name',sprintf('%s (%s)',stamp(T,5),od.name));
					xlabel(sprintf('%s (%s)',od.unit,od.long_unit));
					ylabel(ztyp);
					l = legend(p,sprintf('LAT=%0.1f, LON=%0.1f\n%s\nStation #%i',mlat,mlon,datestr(T.geo.STATION_DATE(iS)),T.geo.STATION_NUMBER(iS)));
					set(l,'location','eastoutside');
										
					% Figure position
					% n   = length(findobj(get(0,'children'),'tag','profile_plot'));
					% pos = get(f(iv),'position');
					% z0  = pos0(1)+pos0(4)-pos(4);
					% set(f(iv),'position',[pos0(1)+pos0(3) z0-20*(n-1) pos(3) pos(4)]);
					
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

			builtin('figure',ftop);
			set(0,'CurrentFigure',ftop);
		end%if
	end%swhile

end%if

%delete(findobj(gcf,'tag','activestation'));
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
	disp(sprintf('Type the following command to close profiles figures:\ndelete(findobj(get(0,''children''),''tag'',''profile_plot''))'));
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read longitude/latitudes of stations on a figure
function [LON LAT] = recup_stations_location_on_map(ftop,MMAPinfo);
% ftop is the handle of the figure

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
			otherwise
				disp(sprintf('Weird type found here (%s)',get(b,'type')));
				keyboard
		end
	end%for ia
	
	else
		LON = NaN;
		LAT = NaN;
	end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select one station from a map
function [but iT iS p mlon mlat] = pickonestation(OBJ,LAT,LON,MMAPinfo);
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
	adjustmmap(MMAPinfo);

	[x y but] = ginput(1); % Pick one point with the mouse
	[mlon mlat] = m_xy2ll(x,y); % Convert point coords to lat/lon
	
	% Find the closest station of the point:
	for ip = 1 : length(LAT)
		d(ip) = m_lldist([mlon LON(ip)],[mlat LAT(ip)]);
	end
	[dmin ii] = min(d); 
	ii = ii(1); % Ensure we selected only one point
	p = m_plot(LON(ii),LAT(ii),'rs','tag','activestation');
	
	% Identify the transect/station
	if isa(OBJ,'database')
		for it = 1 : length(OBJ)
			T = OBJ.transect{it};
			Tlat = T.geo.LATITUDE;
			Tlon = T.geo.LONGITUDE;
			if find( abs(Tlat-LAT(ii)) < 50*eps ) & find( abs(Tlon-LON(ii)) < 50*eps )
				iT = it;
				iS = find(T.geo.LATITUDE==LAT(ii),1);			
				return
			end
		end
		% If we made it through here, there's a problem !
%		keyboard
		
	elseif isa(OBJ,'transect')
		iT = NaN;
		Tlat = OBJ.geo.LATITUDE;
		Tlon = OBJ.geo.LONGITUDE;
		if find( abs(Tlat-LAT(ii)) < 50*eps ) & find( abs(Tlon-LON(ii)) < 50*eps )
			iS = find(OBJ.geo.LATITUDE==LAT(ii),1);			
			return
		end
	else
		error('We must have a database or transect object to work with !')
	end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Popup to select one or more datas within a database/transect object
function dlist = datalistselectionpopup(ftop,OBJ);
	
if 0	
	dlist  = datanames(OBJ);
	choice = menu('Choose a variable to plot',dlist);
	choice = [1 5];
	dlist  = dlist(choice);
else
	
	thif = builtin('figure');
	postop = get(ftop,'position');
	posthi = get(thif,'position');
	set(thif,'toolBar','none','menubar','none','name','Select variable(s)','numberTitle','off');
	set(thif,'position',[postop(1:2) posthi(3:4)],'color','w');
	
	switch class(OBJ)
		case 'database'			
			dlist  = datanames(OBJ,1); % In all transect
		case 'transect'
			dlist  = datanames(OBJ,1); % Non empty
	end
	[a idefaultval] = intersect(dlist,'TEMP'); clear a
	choice = [];
	
	% Create list to display:
	if 0
		dlstring = dlist; % Basic data names
	else
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

	end
	
	listchoice = uicontrol('Parent',thif,'Style','listbox',...
	                'String',dlstring,'backgroundcolor','w',...
	                'Max',length(dlstring),'Min',1,'Value',idefaultval,'tag','list');
	set(listchoice,'units','normalized','position',[.1 .2 .8 .75],'FontName',get(0,'FixedWidthFontName'));
	
	listchoiceOK = uicontrol('Parent',thif,'Style','pushbutton','backgroundcolor','w',...
	                'String','Ok','Callback',{@validlist});
	set(listchoiceOK,'units','normalized','position',[.3 .125 .4 .05],'FontName',get(0,'FixedWidthFontName'));
	
	listchoiceCANCEL = uicontrol('Parent',thif,'Style','pushbutton','backgroundcolor','w',...
	                'String','Cancel','Callback',{@abort});
	set(listchoiceCANCEL,'units','normalized','position',[.3 .05 .4 .05],'FontName',get(0,'FixedWidthFontName'));
		
	waitfor(listchoiceOK);
	dlist = dlist(choice);
end

	function validlist(hObject,eventdata)
		
		thif = get(hObject,'Parent');
		selected = get(findobj(thif,'tag','list'),'value');
		assignin('caller','choice',selected);
		delete(get(hObject,'Parent'));
		
	end%function
	
	function abort(hObject,eventdata)
		delete(get(hObject,'Parent'));
	end%function

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw a polygon on the map and return coordinates
function varargout = drawmpoly(ftop,MMAPinfo)

%h=helpdlg(sprintf('<left click> to valide a point\n<right click> to remove the last one\n<middle click> to close the polygon, clear it from the map and return coordinates\n<return> to close the polygon, leave it on the map and return coordinates'));
disp(sprintf('\n<left click>  to valide a point'));
disp('<right click> or <del> to remove the last point')
disp('<middle click> or <return> to close and validate the polygon')
disp('<esc> to cancel') % asci 27
%waitfor(h);

builtin('figure',ftop);hold on
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
function [LON LAT] = drawarectangle(ftop,MMAPinfo)

	builtin('figure',ftop);	
	set(gcf,'pointer','fullcrosshair');
	k = waitforbuttonpress;
    point1 = get(gca,'CurrentPoint');    % button down detected
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
	set(thif,'toolBar','none','menubar','none','name','','numberTitle','off');
	set(thif,'position',[postop(1:2) posthi(3:4)]);
	res = {};
	
	TEXT = uicontrol('Parent',thif,'Style','text',...
	                'String',question);	
	
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
	
	w = .4;
	h = .05;
	b = .4;
	set(TEXT,'units','normalized','position',  [.1 .7 .8 h],'FontName',get(0,'FixedWidthFontName'));	
	set(ANSWER,'units','normalized','position',[(1-w/2)/2 .7-h w/2 h],'FontName',get(0,'FixedWidthFontName'));	
	set(OK1,'units','normalized','position',   [(1-w)/2 b+3*h w h],'FontName',get(0,'FixedWidthFontName'));
	set(OK2,'units','normalized','position',   [(1-w)/2 b+2*h w h],'FontName',get(0,'FixedWidthFontName'));	
	set(OK3,'units','normalized','position',   [(1-w)/2 b+1*h w h],'FontName',get(0,'FixedWidthFontName'));	
	set(CANCEL,'units','normalized','position',[(1-w)/2 b+0*h w h],'FontName',get(0,'FixedWidthFontName'));	
			
	waitfor(TEXT);
	
	function validthis1(hObject,eventdata)
		
		thif = get(hObject,'Parent');
		text = get(findobj(thif,'tag','text'),'string');
		if ~isempty(text)
			assignin('caller','res',{text ; 1});
			delete(get(hObject,'Parent'));
		end
		
	end%function
	
	function validthis2(hObject,eventdata)
		
		thif = get(hObject,'Parent');
		text = get(findobj(thif,'tag','text'),'string');
		if ~isempty(text)
			assignin('caller','res',{text ; 2});
			delete(get(hObject,'Parent'));
		end
		
	end%function
	
	function validthis3(hObject,eventdata)
		
		thif = get(hObject,'Parent');
		text = get(findobj(thif,'tag','text'),'string');
		if ~isempty(text)
			assignin('caller','res',{text ; 3});
			delete(get(hObject,'Parent'));
		end
		
	end%function
	
	function abort(hObject,eventdata)
		delete(get(hObject,'Parent'));
	end%function
	
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
	thif   = builtin('figure');
	set(thif,'toolBar','none','menubar','none','name','Copoda','numberTitle','off');
	set(thif,'position',[(pos0(1)+pos0(3)-300)/2 pos0(2)+pos0(4)-50 300 50]);
	
	TEXT = uicontrol('Parent',thif,'Style','text',...
	                'String',text);	
	set(TEXT,'units','pixels','position',[10 12.5 200 25],'FontName',get(0,'FixedWidthFontName'),'fontsize',10);
	
	% CANCEL = uicontrol('Parent',thif,'Style','pushbutton',...
	%                 'String','Cancel','Callback',{@abort});
	% set(CANCEL,'units','pixels','position',[200 12.5 50 25],'FontName',get(0,'FixedWidthFontName'),'fontsize',10);		
	

	function abort(hObject,eventdata)
		delete(get(hObject,'Parent'));
	end%function
	

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




