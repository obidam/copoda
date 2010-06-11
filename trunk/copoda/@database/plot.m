% plot Plot for database object
% 
% plot(D,VARN1,[VARN2])
%
% Plot a histogram among samples of D of the variable VARN1 (a field
% from datanames(D).
% VARN1 can also be 'time' to show the number of stations per year.
%
% If VARN2 is specified (again, a field from datanames(D)), the function
% plots the scatter plots VARN1 vs VARN2
%
% You may also try: 
%	help database/tracks
%
% Created: 2009-07-29.
% Rev. by Guillaume Maze on 2009-09-20: Added C1,C2 scatter plots
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


function varargout = plot(D,varargin)

switch nargin-1
	case 1
		varn1 = varargin{1};
	case 2
		varn1 = varargin{1};
		varn2 = varargin{2};
end%switch

switch nargin-1
	case 1 
		if ismember(varn1,datanames(D))
			% histogram of variables
			C = extract(D,varn1);
			figure
			hist(C,20);
			grid on, box on
			title(sprintf('Histogram of %s\n%s',varn1,D.name));
			xlabel(varn1);
			ylabel('Number of values in the database');
			disp('Warning: Note that this histogram may be skewed if vertical axis are different among the transects');
		else
			switch varn1
				case 'time'
					t = extract(D,'STATION_DATE');
					figure
					hist(t,20);
					datetick('x','yyyy');
					xlabel('years');ylabel('Number of stations');
					grid on, box on
					title(sprintf('%s',D.name));
			end%switch
		end
	case 2 % scatter plot of 2 properties
		C1 = read_this(D,varn1);
		C2 = read_this(D,varn2);
		if length(C1)==1 & isnan(C1(1)),error(sprintf('%s field not found in this database',varn1));end
		if length(C2)==1 & isnan(C2(1)),error(sprintf('%s field not found in this database',varn2));end
		if length(C1)~=length(C2),error(sprintf('%s and %s not of the same size in this database',varn1,varn2));end
		figure
		plot(C1,C2,'.');
		grid on, box on
		title(sprintf('Scatter plot of %s vs %s\n%s',varn2,varn1,D.name));
		xlabel(varn1);
		ylabel(varn2);
	
	otherwise
		disp('Please, specify a variable to plot')
end%switch



end %function



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function C = read_this(D,varn)
	C = NaN;
	for it = 1 : length(D)
		try 
			c = getfield(D.transect{it}.data,varn,'cont');
			c = c(:);
		catch
			c = NaN;
		end
		C = cat(1,C,c);
	end%for it
end











