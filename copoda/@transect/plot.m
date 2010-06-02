% plot Plot content of a transect object
%
% hl = plot(T,WHAT,[TYPE])
% 
% This method creates a plots from datas
% contained into the transect object T.
%
% WHAT can be:
%	-'all'	 : plot all available variables.
%	-'allin1': plot all available variables in 1 figure.
%	-'track' : plot a map with the track of the transect.
%		(call to transect method 'tracks')
%	- one or more of the data fields as return by datanames(T)
%
% TYPE is 1x3 matrix to indicate the type of plot and axis.
% TYPE(1) determine the type of plot:
%	1 (default): Use scatter
%	2: Use pcolor
%	3: Use plot
% TYPE(2) determine the type of X-axis:
%	1 (default): X axis is the distance in km from the 1st station
%	2: X axis is the station date (given T.geo.STATION_DATE)
%	3: X axis is the station number (given T.geo.STATION_NUMBER)
%	4: X axis is the station index
%	5: X axis is the station latitude
%	6: X axis is the station longitude
% TYPE(3) determine the type of Y-axis:
%	1 (default): Y axis is depth in meter (given T.geo.DEPH)
%	2: Y axis is pressure in hPa (given T.geo.PRES)
%	3: Y axis is the vertical level index
%
% Note that omitting TYPE(2) or TYPE(2:3) is fixed by using default values.
% If TYPE is char, we use a 'raw' data plot with TYPE = [1 4 3]
%
% Simply type plot(T) to get a list of available plots.
%
% OUTPUT:
%	hl: a list of key object handles in the figure(s)
%
% Created: 2009-07-23.
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


function varargout = plot(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUT CHECK-IN:
error(nargchk(1,3,nargin));

T  = varargin{1};

if nargin == 1
	help_plot(T,inputname(1));
	if nargout == 1
		varargout(1) = {datanames(T,1)};
	end
	return
end

vr = varargin{2};
if isnumeric(vr)
	error('transect:plot:BadArgument','2nd argument must be a string or a cell')
elseif check_options(T,vr)
	help_plot(T);
	error('transect:plot:NotAField',sprintf('''%s'' option is non-available within plot transect.\n%s',vr));
end

if nargin == 3
	typ = varargin{3};
	if ischar(typ)
		typ = [1 4 3];
	else
		switch length(typ)
			case 1, typ = [typ 1 1];
			case 2, typ = [typ 1];
		end
	end
else
	typ = [1 1 1];
end

if ~strcmp(lower(vr),'track') & ~strcmp(lower(vr),'tracks')
	istrack = false;
else
	istrack = true;
end

switch typ(1)
	case {1,2,4}
		switch typ(2)
			case 2
				if length(unique(T.geo.STATION_DATE)) == 1
					typ(2) = 4;
					warning('All stations on the same date, move to station index as x-axis');
				end
			case 3
				if length(unique(T.geo.STATION_NUMBER)) == 1
					typ(2) = 4;
					warning('All stations with same number, move to station index as x-axis');
				end
		end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT DATAS:
if ~istrack
%- Plot odatas:
	
		do_allin1 = 0;
		if     strcmp(lower(vr),'all')
			vr_list = datanames(T);
		elseif strcmp(lower(vr),'allin1')
			do_allin1 = 1;
			vr_list = datanames(T);
		else
			if isa(vr,'cell')
			 	vr_list = vr;
			else
				vr_list = {vr};
			end
		end

		%%%%%%%
		nv = length(vr_list);
		for iv = 1 : nv
			vr = vr_list{iv};
			if do_allin1 & iv == 1
				f(iv) = figure('tag','transect_plot');
				copoda_figtoolbar(T);
				active_transect.iT = 9999;setappdata(f(iv),'active_transect',active_transect)
				switch nv
					case 1, iw=1;jw=1;
					case 2, iw=1;jw=2;
					case {3,4}, iw=2;jw=2;
					case {5,6}, iw=2;jw=3;
					case {7,8,9}, iw=3;jw=3;
					case {10,11,12}, iw=3;jw=4;
				end
				subplot(iw,jw,iv);
			elseif do_allin1	
				subplot(iw,jw,iv);
			else
				f(iv) = figure('tag','transect_plot');
				copoda_figtoolbar(T);
				active_transect.iT = 9999;setappdata(f(iv),'active_transect',active_transect)
			end
			switch typ(1)
				%%%%%%%%%%%%%%%%%%%%%%
				case 1  %-- scatter:
					handy.type(iv) = scatter_thisfield(T,vr,typ(2:end));
					
				%%%%%%%%%%%%%%%%%%%%%%
				case 2  %-- pcolors:
					handy.type(iv) = pcolor_thisfield(T,vr,typ(2:end));

				%%%%%%%%%%%%%%%%%%%%%%
				case 3  %-- profiles:
					handy.type(iv) = profile_thisfield(T,vr);
					
				%%%%%%%%%%%%%%%%%%%%%%
				case 4  %-- contourf:
					handy.type(iv) = contourf_thisfield(T,vr,typ(2:end));
					
			end%switch	
			handy.gca(iv) = gca;
			
			if do_allin1
				%tt(iv) = ti;
			else
				if size(vr_list,1) > 1 & iv==1
					pos = get(f(iv),'position');
					dx = 15; dy = dx;
				elseif size(vr_list,1) > 1
					set(f(iv),'position',[pos(1)+(iv-1)*dx pos(2)-(iv-1)*dy pos(3:4)])
				end
				set(gcf,'name',getfield(getfield(T.data,vr),'long_name'));
				%tt(iv) = title(title_this(getfield(T.data,vr)));
			end
	
		end %for iv

		%%%%%%%
		switch nargout
			case 1
				varargout(1) = {handy};
%				varargout(1) = {[f(:) ; gc(:) ; p(:) ; tt(:)]};
		end
		
end%if istrack		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT TRACK:
if istrack
%- Plot track:

	if nargin == 3
		tracks(T,varargin{3});
	else
		tracks(T);
	end

end%if
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handy = profile_thisfield(T,FIELD)
	
	d = getfield(T,'data',FIELD);
	c = d.cont;
	if ~isempty(T.geo.DEPH) & T.geo.DEPH ~= 0
		y = T.geo.DEPH;
		diry = 'normal';
		ylab = 'Depth (m)';
	elseif ~isempty(T.geo.PRES)
		y = T.geo.PRES;
		diry = 'reverse';
		ylab = 'Pressure (hPa)';
	else
		y = 1:size(c,2);
		diry = 'normal';
		ylab = '?';
	end
	hold on
	for ip = 1 : size(c,1)
		pc(ip) = plot(c(ip,:),y(ip,:),'.-');
	end
	set(gca,'ydir',diry);
	
	ylabel(ylab);
	xlabel(sprintf('%s [%s]',d.long_unit,d.unit));
	ti = title(sprintf('%s [%s]',d.long_name,d.name),'interpreter','none');
	grid on, box on 
	handy.plot = pc;
	handy.title = ti;
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handy = scatter_thisfield(T,FIELD,typ)
		
	[x y c is xlab ylab ylim diry] = getthis(T,FIELD,typ);	
	%stophere
		
	p = scatter(x(:),y(:),50,c(:),'marker','.');
		
	xlabel(xlab,'fontsize',8);	
	ylabel(ylab,'fontsize',8);
	set(gca,'ydir',diry);
	
	% We set a title for use with option 'allin1' otherwise overwritten
	ti = title(title_this(getfield(T,'data',FIELD)),'interpreter','none','fontsize',9);
	handy.title = ti;
	handy.scatter = p;
	
	axis tight
	set(gca,'ylim',ylim);
	grid on,box on
	if typ(1) == 2
		datetick('x');
	end
	
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handy = contourf_thisfield(T,FIELD,typ)
		
	[x y c is xlab ylab ylim diry] = getthis(T,FIELD,typ);	
	if size(x) == size(c)
		[cs,h] = contourf(x(is,:),y,c(is,:),20);
	else
		[cs,h] = contourf(x(is,:),y,c(is,:)',20);
	end
%	clabel(cs,h,'rotation',0,'fontsize',6);
			
	xlabel(xlab,'fontsize',8);
	ylabel(ylab,'fontsize',8);
	set(gca,'ydir',diry);	
	
	% We set a title for use with option 'allin1' otherwise overwritten
	ti = title(title_this(getfield(T,'data',FIELD)),'interpreter','none','fontsize',9);
	handy.contourf.cs = cs;
	handy.contourf.h = h;
	handy.title = ti;
	
	axis tight
	set(gca,'ylim',ylim);
	grid on,box on
	if typ(1) == 2
		datetick('x');
	end	
	
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handy = pcolor_thisfield(T,FIELD,typ)
		
	[x y c is xlab ylab ylim diry] = getthis(T,FIELD,typ);	
	if size(x) == size(c)
		p = pcolor(x(is,:),y,c(is,:));
	else
		p = pcolor(x(is,:),y,c(is,:)');
	end
	shading flat;
			
	xlabel(xlab,'fontsize',8);
	ylabel(ylab,'fontsize',8);
	set(gca,'ydir',diry);	
	
	% We set a title for use with option 'allin1' otherwise overwritten
	ti = title(title_this(getfield(T,'data',FIELD)),'interpreter','none','fontsize',9);
	handy.pcolor = p;
	handy.title = ti;
	
	axis tight
	set(gca,'ylim',ylim);
	grid on,box on
	if typ(1) == 2
		datetick('x');
	end	
	
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Not used anymore, now call transect method tracks
function varargout = plot_track(T,typ)
		y = T.geo.LATITUDE;
		x = T.geo.LONGITUDE;
		t = T.geo.STATION_DATE; 
		switch typ
			case 1
				cmap = jet(length(t));
				cx   = [min(T.geo.STATION_DATE) max(T.geo.STATION_DATE)];
				cl   = cx;
			case 2
				cmap = cseason(12);
				cx   = [0 12];
				cl   = cx;
		end
		colormap(cmap);
		dx = 10;
		dy = 5;
		m_proj('equid','lon',[min(x)-dx max(x)+dx],'lat',[min(y)-dy max(y)+dy]);
		hold on
		for ip = 1 : length(t)
			p(ip) = m_plot(x(ip),y(ip),'+','tag','station_location');
			switch typ
				case 1
					set(p(ip),'color',cmap(ip,:));
				case 2
					im = str2num(datestr(T.geo.STATION_DATE(ip),'mm')); 
					set(p(ip),'color',cmap(im,:));
			end
		end
		m_coast('patch',[1 1 1]*.6);
	%	m_grid('xtick',[-180:5:180],'ytick',[-90:5:90]);
		m_grid('xtick',[0:5:360],'ytick',[-90:5:90]);
		caxis(cx);
		cl = colorbar;
		set(cl,'ylim',cx);
		switch typ
			case 1
				yt = [min(T.geo.STATION_DATE):2:max(T.geo.STATION_DATE)];
				if length(yt) > 12, yt = yt(1:fix(length(yt)/12):length(yt));end
				set(cl,'ytick',	 yt	);
				set(cl,'yticklabel',datestr(yt,'yyyy/mm/dd'));
			case 2
				yt = [12 1:12];
				set(cl,'ytick',	 0:12	);
				set(cl,'yticklabel',datestr(datenum(1900,yt,15,0,0,0),'mmm'));
		end
		
		set(cl,'fontsize',8);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = disp_field(T)
	fi = datanames(T,1);
	if iscell(fi)
		if length(fi) >= 2
			str = sprintf('%s,',fi{1});
			for ii = 2 : length(fi)-1
				if (length(str)+length(fi{ii}))>90, str = sprintf('%s\n',str);end
				str = sprintf('%s %s,',str,fi{ii});
			end
			str = sprintf('%s and %s.',str,fi{end});
		else	
			str = sprintf('%s',fi{1});
		end
	else
		error('No datas available in this Transect');
	end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = title_this(O)

	str = sprintf('%s\n%s\n%s\n ',...
		disp_prop('Long Name [short]',sprintf('%s [%s]',O.long_name,O.name)),...
		disp_prop('Long Unit [short]',sprintf('%s [%s]',O.long_unit,O.unit)),...
		disp_prop('Content statistics',sprintf('Max=%f, Min=%f, Mean=%f, STD=%f',...
							nanmax(nanmax(O.cont)),nanmin(nanmin(O.cont)),...
							nanmean(nanmean(O.cont)),nanstd(nanstd(O.cont))))...
							...
		);
	str = sprintf('%s\n%s\n ',...
		sprintf('%s [%s]',O.long_name,O.name),...
		sprintf('%s [%s]',O.long_unit,O.unit));
	%%%%%%%%%%%%%%%%%%%
	function str = disp_prop(name,value)
		blk = ' ';	
		str = sprintf('%5s %20s: %s',blk,name,value);
	end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = help_plot(T,Tname)
	str = disp_field(T);
	fi = datanames(T,1);
	
%	disp(sprintf('Fields available for this transect object are: %s',str));
	if isempty(Tname),Tname = 'your_transect_object';end;
	disp(sprintf('List of available command plots:'));
	disp(sprintf('\tplot(%s,''%s'') %% %s',Tname,'all','Plot all available variables'))
	disp(sprintf('\tplot(%s,''%s'') %% %s',Tname,'allin1','Plot all available variables in 1 figure'))
	disp(sprintf('\tplot(%s,''%s'') %% %s',Tname,'track','Plot a map with the track of the transect'))
	
	disp(sprintf('\n\tFor FIELD with one (string) or more (cell of strings) variable(s) from:\n\t%s',str));
	disp(sprintf('\tFor example:\n\t\tFIELD = ''%s'';',fi{1}));
	if length(fi)>1
		disp(sprintf('\tor:\n\t\tFIELD = {''%s'';''%s''};',fi{1},fi{2}));
	end
	disp(sprintf('\tYou can use one of the following command:'));
	disp(sprintf('\t\tplot(%s,FIELD) %% %s',Tname,'Scatter plot with distances from 1st station as X-axis'))
	disp(sprintf('\t\tplot(%s,FIELD,[1 1]) %% %s',Tname,'Scatter plot with distances from 1st station as X-axis'))
	disp(sprintf('\t\tplot(%s,FIELD,[1 2]) %% %s',Tname,'Scatter plot with station dates as X-axis'))
	disp(sprintf('\t\tplot(%s,FIELD,[1 3]) %% %s',Tname,'Scatter plot with station numbers as X-axis'))
	disp(sprintf('\t\tplot(%s,FIELD,[1 4]) %% %s',Tname,'Scatter plot with station index as X-axis'))
	disp(sprintf('\t\tplot(%s,FIELD,[2 1]) %% %s',Tname,'Pcolor plot with distances from 1st station as X-axis'))
	disp(sprintf('\t\tplot(%s,FIELD,[2 2]) %% %s',Tname,'Pcolor plot with station dates as X-axis'))
	disp(sprintf('\t\tplot(%s,FIELD,[2 3]) %% %s',Tname,'Pcolor plot with station numbers as X-axis'))
	disp(sprintf('\t\tplot(%s,FIELD,[2 4]) %% %s',Tname,'Pcolor plot with station index as X-axis'))
	disp(sprintf('\t\tplot(%s,FIELD,3) %% %s',Tname,'Plot all profiles on the same axis'))
	
	
	% fi = datanames(T,1);
	% for ii = 1 : length(fi)
	% 	disp(sprintf('	plot(%s,''%s'')',Tname,fi{ii}))
	% end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rep = check_options(T,vr)
	if  find(isdata(T,vr)==0) & ...
		~strcmp(lower(vr),'all') & ...
		~strcmp(lower(vr),'allin1') & ...
		~strcmp(lower(vr),'track') & ...
		~strcmp(lower(vr),'tracks')
		rep = true;
	else
		rep = false;
	end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x y c is xlab ylab ylim diry] = getthis(T,FIELD,typ);	
	
	d = getfield(T,'data',FIELD);
	c = d.cont;
	switch typ(2)
		case 1
			y = T.geo.DEPH;
			ylab = 'Depth';
			diry = 'normal';
			ylim = [xtrm(T.geo.DEPH) 0];
		case 2
			y = T.geo.PRES;
			ylab = 'Pressure';
			diry = 'reverse';
			ylim = [0 xtrm(T.geo.PRES)];
		case 3		
			y = [1:size(c,2)];
			y = meshgrid(y,1:size(c,1));
			ylab = 'Level index';
			diry = 'normal';
			ylim = [1 size(c,2)];
	end
	switch typ(1)
		case 1
			[x is] = dfromo(T,[T.geo.LATITUDE(1) T.geo.LONGITUDE(1)]);x=x';
			xlab = sprintf('Distance (km) from 1st station');		
		case 2
			x = T.geo.STATION_DATE; xlab='Station date';
			is = 1:length(x);
		case 3
			x = T.geo.STATION_NUMBER; xlab='Station number';
			is = 1:length(x);
		case 4
			x = 1 : size(c,1); xlab = 'Station index';x=x';
			is = 1:length(x);
		case 5			
			x = T.geo.LATITUDE; xlab='Station Latitude';
			is = 1:length(x);
		case 6
			x = T.geo.LONGITUDE; xlab='Station Longitude';
			is = 1:length(x);
		otherwise
			error('Unknow type for plot');
	end	
	if size(x,2) == 1 & size(y,1) == 1
		[x y] = meshgrid(x,y);
		x = x';
		y = y';
		return
	end
	if size(x) ~= size(c) & size(y) ~= size(c)
%		stophere
	end
	if size(x,2) == 1
		x = meshgrid(x,1:size(y,2))';
	end
	if size(y,1) == 1
		y = meshgrid(y,1:size(x,1));
	end
	
	
	
%	disp('Stop in getthis');keyboard
%	stophere
	
end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = xtrm(C);

[m1 im1a] = max(C);
[m1 im1b] = max(m1);

[m2 im2a] = min(C);
[m2 im2b] = min(m2);

if abs(m1)>abs(m2)
     M = m1;
     if(im1a==1)&(im1b~=1),im=im1b;end
     if(im1a~=1)&(im1b==1),im=im1a;end
     if(im1a==1)&(im1b==1),im=im1a;end
     if(im1a~=1)&(im1b~=1),im=[im1a im1b];end
else
     M = m2;
     if(im2a==1)&(im2b~=1),im=im2b;end
     if(im2a~=1)&(im2b==1),im=im2a;end
     if(im2a==1)&(im2b==1),im=im2a;end
     if(im2a~=1)&(im2b~=1),im=[im2a im2b];end  
end

switch nargout
  case 0
     varargout(1)={M};
  case 1
     varargout(1)={M};
  case 2
     varargout(1)={M};
     varargout(2)={im};
end

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%