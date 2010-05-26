% multiprofiles H1LINE
%
% [] = multiprofiles()
% 
% HELP TEXT
%
% Inputs:
%
% Outputs:
%
%
% Created: 2010-05-25.
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
function varargout = multiprofiles(T,varargin)
	
% Default options:
ztyp = 'DEPH';  % Y axis
VARN = {'TEMP';'PSAL';'SIG0'}; % List of variables to plot in X axis
iS   = 1; % Which station ?
zlab = '?';
zdir = 'normal';
		
% User options:
for in = 2 : 2 : nargin-1
	eval(sprintf('%s=varargin{%i};',varargin{in-1},in));
end

switch ztyp
	case 'DEPH'
		zlab = 'Depth (m)';
		zdir = 'normal';
	case 'PRES'
		zlab = 'Pression (hPa)';
		zdir = 'reverse';
end

% Plot
figure;figure_tall
set(gcf,'tag','profile_plot');

cmap = [0 0 0;1 0 0;0 0 1;0.2 .7 0.2];
if length(VARN) > 4
%	cmap = cat(1,cmap,jet(length(VARN)-4));
	cmap = jet(length(VARN));
	
%	error('I don''t know how to do with more than 4 variables')
end
	
for iv = 1 : length(VARN)
						
	od = subsref(T,substruct('.','data','.',VARN{iv}));
	z  = subsref(T,substruct('.','geo','.',ztyp,'()',{iS,':'}));
	if iv == 1
		pl(iv) = plot(od.cont(iS,:),z);
		ax_ref(iv) = gca; %set(ax_ref(iv),'tag','floatAxis');
		set(pl(iv),'color',cmap(iv,:));
		set(ax_ref(iv),'XMinorTick','on','box','on','xcolor',get(pl(iv),'color'),'ydir',zdir);		
		xlabel(sprintf('%s (%s): %s (%s)',od.name,od.unit,od.long_name,od.long_unit));
		grid on,box on;
		title(sprintf('%s\nLAT=%0.1f, LON=%0.1f, TIME=%s\nStation #%i',stamp(T,5),T.geo.LATITUDE(iS),T.geo.LONGITUDE(iS),datestr(T.geo.STATION_DATE(iS)),T.geo.STATION_NUMBER(iS)),'fontweight','bold');
		set(gcf,'name',sprintf('%s',stamp(T,5)));
	else
%		try		
			[pl(iv),ax_plot(iv-1),ax_disp(iv-1)] = floatAxisX(od.cont(iS,:),z,'-',...
					sprintf('%s (%s): %s (%s)',od.name,od.unit,od.long_name,od.long_unit));		
			set(pl(iv),'color',cmap(iv,:));	
			set(ax_disp(iv-1),'xcolor',cmap(iv,:),'ydir',zdir);
%		catch
			%keyboard
%		end
	end
			
end
set(pl,'marker','.');

end %functionmultiprofiles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hl1,ax2,ax3] = floatAxisX(varargin)
% floatAxisX  create floating x-axis for multi-parameter plot
% =========================================================================
% floatAxisX  Version 1.2 6-Mar-2000
%
% Usage: 
%   [h1,ax2,ax3] = floatAxisX(varargin)
%
% Description:
%   This Matlab function creates a floating x-axis for mutli-parameter
%   plots with different units on the same figure. For example, in oceanography,
%   it is common to plot temperature, salinity, and density versus depth.
%
%
% Input:
%   A minimum of two parameters is required. The first and second parameters are
%   the x,y pairs to plot. The third parameter (optional) specifies the linestyle
%   (defaults to 'k-' solid black). The fourth parameter (optional) specifies the
%   x-axis label for the floating axis. The fifth parameter (optional) specifies 
%   the x and y limits for the axis(this should be of the form 
%   [xlower xupper ylower yupper]).
%
% Output:
%   n/a
%
% Called by:
%   CTDplotX.m - script to demo floatAxis function
%
% Calls:
%   n/a
%
% Author:
%   Blair Greenan
%   Bedford Institute of Oceanography
%   18-May-1999
%   Matlab 5.2.1
%   greenanb@mar.dfo-mpo.gc.ca
% =========================================================================
%

% History
% Version 1.0 18-May-1999
% Version 1.1 31-May-1999
%    Added the ability to pass an array containing the x and y limits for
%    the axis.
% Version 1.2 6-Mar-2000
%    Added code to handle data with different y-limits. Previous versions
%    assumed all data had the same y-limits. Oops! Thanks to Jan Even Nilsen
%    (even@gfi.uib.no) for pointing this out.

% strip the arguments passed in
if (nargin < 2)
   error('floatAxis requires a minimum of three parameters')
elseif (nargin == 2)
   x = varargin{1};
   y = varargin{2};
   % default lines style (solid black line) 
   lstyle = 'k-';   
elseif (nargin == 3)
   x = varargin{1};
   y = varargin{2};  
   lstyle = varargin{3};
elseif (nargin == 4)
   x = varargin{1};
   y = varargin{2};  
   lstyle = varargin{3};
   xlbl = varargin{4};
elseif (nargin == 5)
   x = varargin{1};
   y = varargin{2};
   lstyle = varargin{3};
   xlbl = varargin{4};
   limits = varargin{5};
else
   error('Too many arguments')
end

% get position of axes
allAxes = get(gcf,'Children');
allAxes = setdiff(allAxes,findobj(gcf,'tag','footnote'));
allAxes = setdiff(allAxes,findobj(gcf,'tag','suptitle'));

ax1Pos  = get(allAxes(1),'position');

% rescale and reposition all axes to handle additional axes
for ii = 2:length(allAxes)
   if (rem(ii,2)==0) 
      % even ones in array of axes handles represent axes on which lines are plotted (2,4,6 ...)
      set(allAxes(ii),'Position',[ax1Pos(1) ax1Pos(2)+0.1 ax1Pos(3) ax1Pos(4)-0.1])
   else
      % odd ones in array of axes handles represent axes on which floating x-axis exist (1,3,5 ...)
      axPos = get(allAxes(ii),'Position');
      set(allAxes(ii),'Position',[axPos(1) axPos(2)+0.1 axPos(3) axPos(4)])
   end
end
% first axis is a special case (doesn't fall into even/odd scenario of figure children)
set(allAxes(1),'Position',[ax1Pos(1) ax1Pos(2)+0.1 ax1Pos(3) ax1Pos(4)-0.1])
ylimit1 = get(allAxes(1),'Ylim');

% get new position for plotting area of figure
ax1Pos = get(allAxes(1),'position');

% axis to which the floating axes will be referenced
ref_axis = allAxes(end);
refPosition = get(ref_axis,'position');

% overlay new axes on the existing one
ax2 = axes('Position',ax1Pos);

% plot data and return handle for the line
hl1 = plot(x,y,lstyle);
% make the new axes invisible, leaving only the line visible
set(ax2,'visible','off','ylim',ylimit1)

if (nargin < 5)
   % get the x limits for the 
   xlimit = get(ax2,'XLim');
else
   set(ax2,'XLim',[limits(1) limits(2)],'YLim',[limits(3) limits(4)]);
end

% set the axis limit mode so that it does not change if the
% user resizes the figure window
set(ax2,'xLimMode','manual')

% set up another set of axes to act as floater
ax3 = axes('Position',[refPosition(1) refPosition(2)-0.1 refPosition(3) 0.01]);
set(ax3,'box','off','ycolor','w','yticklabel',[],'ytick',[])
set(ax3,'XMinorTick','on','color','none','xcolor',get(hl1,'color'))

if (nargin < 5)
   set(ax3,'XLim',xlimit)
else
   set(ax3,'XLim',[limits(1) limits(2)],'YLim',[limits(3) limits(4)])
end

% label the axis
if (nargin > 3)
   xlabel(xlbl)
end


end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%










