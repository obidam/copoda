% plot Plot content of a transect object
%
% hl = plot(T,FIELD)
% 
% This method creates a plot of the variable FIELD
% contained into the transect object T.
%
% FIELD can also be:
%	'all'	: plot all available variables.
%	'allin1': plot all available variables in 1 figure.
%	'track'	: plot a map with the track of the transect.
%
% Simply type plot(T) to get a list of available plots.
%
% The plot is adjusted to the nb of dimensions of FIELD.
% 1-D variable: Not yet supported
% 2-D variable: pcolor axis defined as:
%			x-axis from T.geo.STATION_NUMBER
%			y-axis from T.geo.DEPH
% 3-D variable: Not yet supported
%
% Output hl is handle from:
% hl = [f gc p tt] with:
%	f: the figure
%	gc: the axes
%	p: the pcolor (for 2-D var)
%	tt: the title
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
	help_plot(T);
	if nargout == 1
		varargout(1) = {datanames(T,1)};
	end
	return
end

vr = varargin{2};
if isnumeric(vr)
	error('transect:plot:BadArgument','2nd argument must be a string')
elseif check_options(T,vr)
	help_plot(T);
	error('transect:plot:NotAField',sprintf('''%s'' option is non-available within plot transect.\n%s',vr));
end

if nargin == 3
	typ = varargin{3};
else
	typ = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT :
if ~strcmp(lower(vr),'track') & ~strcmp(lower(vr),'tracks')
%- Plot odatas:
	
		do_allin1 = 0;
		if strcmp(lower(vr),'all')
			vr_list = datanames(T);
		elseif strcmp(lower(vr),'allin1')
			do_allin1 = 1;
			vr_list = datanames(T);
		else
		 	vr_list = {vr};
	%		od = getfield(T.data,T.data.STATION_PARAMETERS(1));
	%		if ndims(od.cont) ~= 2 
	%			error(sprintf('Cannot plot transect OData with %i dimension(s)',ndims(od.cont)));
	%		elseif ndims(od.cont)==2 & ~isempty(find(size(od.cont)==1)) & 
	%			error('Cannot plot one dimensional OData from this transect object')
	%		end
		end

		%%%%%%%
		nv = size(vr_list,1);
		for iv = 1 : nv
			vr = vr_list{iv};
			if do_allin1 & iv == 1
				f(iv) = builtin('figure');
				copoda_figtoolbar(T);
				
				switch nv
					case 1, iw=1;jw=1;
					case 2, iw=2;jw=1;
					case 3, iw=2;jw=2;
					case 4, iw=2;jw=2;
					case 5, iw=3;jw=2;
					case 6, iw=3;jw=2;
				end
				subplot(iw,jw,iv);
			elseif do_allin1	
				subplot(iw,jw,iv);
			else
				f(iv) = builtin('figure');
				copoda_figtoolbar(T);
			end
			switch typ
				%%%%%%%%%%%%%%%%%%%%%%
				case 1  %-- pcolors:			
					[p(iv) ti] = pcolor_thisfield(T,vr);
				%%%%%%%%%%%%%%%%%%%%%%
				case 2  %-- profiles:
					[p(iv,:) ti] = profile_thisfield(T,vr);
					
			end%switch	
			gc(iv) = gca;
			
			if do_allin1
				tt(iv) = ti;
			else
				if size(vr_list,1) > 1 & iv==1
					pos = get(f(iv),'position');
					dx = 15; dy = dx;
				elseif size(vr_list,1) > 1
					set(f(iv),'position',[pos(1)+(iv-1)*dx pos(2)-(iv-1)*dy pos(3:4)])
				end
				set(gcf,'name',getfield(getfield(T.data,vr),'long_name'));
				tt(iv) = title(title_this(getfield(T.data,vr)));
			end
	
		end %for iv

		%%%%%%%
		switch nargout
			case 1
				varargout(1) = {[f ; gc ; p ; tt]};
		end
		
		

		
			
		

	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT TRACK:
elseif strcmp(lower(vr),'track') | strcmp(lower(vr),'tracks')
%- Tracks:

	if nargin == 3
		plot_track(T,varargin{3});
		copoda_figtoolbar(T);
	else
		plot_track(T,1);
		copoda_figtoolbar(T);
	end

else
	error('don''t know what to plot !');
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%%%%%%%%%%%%%%%%%%%
function [pc ti] = profile_thisfield(T,FIELD)
	d = getfield(T,'data',FIELD);
	c = d.cont;
	if ~isempty(T.geo.DEPH) & T.geo.DEPH ~= 0
		y = T.geo.DEPH;
		diry = 'normal';
		ylab = 'Depth';
	elseif ~isempty(T.geo.PRES)
		y = T.geo.PRES;
		diry = 'reverse';
		ylab = 'Pressure';
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
	ti = title(title_this(d),'interpreter','none');
end


%%%%%%%%%%%%%%%%%%%
function [pc ti] = pcolor_thisfield(T,FIELD)
	d = getfield(T,'data',FIELD);
	c = d.cont;
	if ~isempty(T.geo.DEPH)
		y = T.geo.DEPH;
		ylab = 'Depth';
		diry = 'normal';
	elseif ~isempty(T.geo.PRES)
		y = T.geo.PRES;
		ylab = 'Pressure';
		diry = 'reverse';
	else
		y = 1:size(c,2);
		ylab = '?';
		diry = 'normal';
	end
	if ~isempty(T.geo.STATION_NUMBER)
		x = T.geo.STATION_NUMBER; xl='Station number';
	elseif ~isempty(T.geo.STATION_DATE)
		x = T.geo.STATION_DATE; xl='Station date';
	else
		x = 1 : size(c,1);
	end
	x = meshgrid(x,1:size(y,2))';
		
	if size(x) == size(c)
		pc = pcolor(x,y,c);
	else
		pc = pcolor(x,y,c');
	end
	shading flat;
%	p=plot(x,y,'.');set(p,'color','k');
	
	xlabel(xl);
	set(gca,'ydir',diry);	
	ylabel(ylab);
	ti = title(title_this(d),'interpreter','none');
end

%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%
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
function str = help_plot(T)
	str = disp_field(T);
	disp(sprintf('Fields available for this transect object are: %s',str));
	if isempty(inputname(1)),Tname = 'your_transect_object'; else,Tname=inputname(1);end
	disp(sprintf('List of available command plots:'));
	disp(sprintf('	plot(%s,''%s'') %% %s',Tname,'all','Plot all available variables'))
	disp(sprintf('	plot(%s,''%s'') %% %s',Tname,'allin1','Plot all available variables in 1 figure'))
	disp(sprintf('	plot(%s,''%s'') %% %s',Tname,'track','Plot a map with the track of the transect'))
	fi = datanames(T,1);
	for ii = 1 : length(fi)
		disp(sprintf('	plot(%s,''%s'')',Tname,fi{ii}))
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rep = check_options(T,vr)
	if  ~isfield(T.data,vr) & ...
		~strcmp(lower(vr),'all') & ...
		~strcmp(lower(vr),'allin1') & ...
		~strcmp(lower(vr),'track') & ...
		~strcmp(lower(vr),'tracks')
		rep = true;
	else
		rep = false;
	end
end



