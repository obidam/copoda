% copoda_figtoolbar Add the COPODA figure toolbar
%
% [] = copoda_figtoolbar()
% 
% HELP TEXT
%
% Inputs:
%
% Outputs:
%
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

% Existing toolbars:
tbh0 = findall(gcf,'Type','uitoolbar');

% We remove it and re-create it to update:
if ~isempty(tbh0)
	delete(findobj(tbh0,'Tag','copoda_figtoolbar'));
end
tbh  = uitoolbar(gcf,'Tag','copoda_figtoolbar');	

% Add elements:
drawprofiles(OBJ,tbh);
%graphtool(tbh);
%sgetool(tbh);
	

end %functioncopoda_figtoolbar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = drawprofiles(OBJ,varargin)

if nargin > 1
	if ischar(varargin{1})
		par = NaN;
	else
		% We have a parent to attach the button:
		par = varargin{1};
	end
else
	% We don't have a parent uitoolbar so we create one.
	% Before that, we check if doesn't already exists:
	tbh = findall(gcf,'Type','uitoolbar');
	delete(findobj(tbh,'Tag','copoda_profiletool'));
	% Create the toolbar:
	par = uitoolbar(gcf,'Tag','copoda_profiletool');	
		
end

%%%%%%%%%%%%%%%%%%
if ispc, sla = '\'; else, sla = '/'; end

if ~isnan(par)
	A = load(sprintf('%s%sicon_profiletoolbutton.mat',copoda_readconfig('copoda_data_folder'),sla));
	pth = uipushtool('Parent',par,'CData',A.A,'Enable','on','Tag','copoda_profilebutton',...
          'TooltipString','Plot a profile','Separator','off',...
          'HandleVisibility','on','ClickedCallback',{@drawprofiles_action},'userdata',OBJ);
	a = findobj(gcf,'tag','station_location');
	if isempty(a)
		set(pth,'Enable','off')
	end

else
	tbh = findall(gcf,'Type','uitoolbar');
	delete(findobj(tbh,'Tag','copoda_profiletool'));	
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function drawprofiles_action(hObject,eventdata)
	
mhABOUT = get(hObject,'Parent');
ftop = get(mhABOUT,'Parent');
OBJ  = get(hObject,'UserData');

% Get stations lat/lon on the figure:
a = findobj(ftop,'tag','station_location');

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
	end
end%for ia

% Ask to pick one :
VARN = datalistselectionpopup(ftop,OBJ);
if ~isempty(VARN)
	done = 0;
	while done ~= 1
		[but iT iS p mlon mlat] = pickonestation(OBJ,LAT,LON);
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
				T = OBJ;
			end
		
			% Plot the profile of VARN:
				ztyp = 'DEPH';
				%ztyp = 'PRES';			
				for iv = 1 : length(VARN)
					f(iv) = figure;
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
				end

			builtin('figure',ftop);
		end%if
	end%swhile

end%if
delete(findobj(gcf,'tag','activestation'));

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [but iT iS p mlon mlat] = pickonestation(OBJ,LAT,LON);

	[x y but] = ginput(1); % Pick one point with the mouse
	[mlon mlat] = m_xy2ll(x,y); % Convert point coords to lat/lon
	
	% Find the closest station of the point:
	for ip = 1 : length(LAT)
		d(ip) = m_lldist([mlon LON(ip)],[mlat LAT(ip)]);
	end
	[dmin ii] = min(d);
	p = m_plot(LON(ii),LAT(ii),'rs','tag','activestation');
	
	% Identify the transect/station
	if isa(OBJ,'database')
		for it = 1 : length(OBJ)
			T = OBJ.transect{it};
			if find(T.geo.LATITUDE==LAT(ii)) & find(T.geo.LONGITUDE==LON(ii))
				iT = it;
				iS = find(T.geo.LATITUDE==LAT(ii));			
				return
			end
		end
	elseif isa(OBJ,'transect')
		iT = NaN;
		if find(OBJ.geo.LATITUDE==LAT(ii)) & find(OBJ.geo.LONGITUDE==LON(ii))
			iS = find(OBJ.geo.LATITUDE==LAT(ii));			
			return
		end
	else
		error('We must have a database or transect object to work with !')
	end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dlist = datalistselectionpopup(ftop,OBJ);
	
if 0	
	dlist  = datanames(OBJ);
	choice = menu('Choose a variable to plot',dlist);
	choice = [1 5];
	dlist  = dlist(choice);
else
	
	thif = builtin('figure');
	set(thif,'toolBar','none','menubar','none','name','Select variables to profile','numberTitle','off');
	
	dlist  = datanames(OBJ);	
	choice = [];
	
	listchoice = uicontrol('Parent',thif,'Style','listbox',...
	                'String',dlist,...
	                'Max',length(dlist),'Min',1,'Value',1,'tag','list');
	set(listchoice,'units','normalized','position',[.3 .2 .4 .7]);
	listchoiceOK = uicontrol('Parent',thif,'Style','pushbutton',...
	                'String','Ok','Callback',{@validlist});
	set(listchoiceOK,'units','normalized','position',[.3 .125 .4 .05]);
	listchoiceCANCEL = uicontrol('Parent',thif,'Style','pushbutton',...
	                'String','Cancel','Callback',{@abort});
	set(listchoiceCANCEL,'units','normalized','position',[.3 .05 .4 .05]);
	waitfor(thif);
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



