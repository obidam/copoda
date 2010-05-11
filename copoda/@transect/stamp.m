% stamp Create a string to recap transect informations
%
% STR = stamp(T,[TYPE])
% 
% Create a string STR to recap transect T informations
%
%
% Created: 2009-07-30.
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


function STP = stamp(T,varargin)

st_type = 1;
sep = '|';
if nargin >= 2
	st_type = varargin{1};
end
if nargin >= 3
	sep = varargin{2};
end

switch st_type
	case {1,2,3}
%		sep = '|';
		alignment = 'center';
		file = clean_file(T);
		if st_type == 1
			STP = sprintf('%s%s%s%s%s%s%s%s%s%s%s%s',...
						sep,algn10(file,sep,alignment),sep,...
						algn10(T.cruise_info.NAME,sep,alignment),sep,...
						algn10(T.cruise_info.SHIP_NAME,sep,alignment),sep,...
						algn10(T.cruise_info.PI_NAME,sep,alignment),sep,...
						algn10(datestr(median(T.geo.STATION_DATE),'mmm-yy'),sep,alignment),sep);
		elseif st_type == 2
			STP = sprintf('%s%s%s%s%s%s%s%s%s%s%s%s',...
						sep,algn20(file,sep,alignment),sep,...
						algn20(T.cruise_info.NAME,sep,alignment),sep,...
						algn20(T.cruise_info.SHIP_NAME,sep,alignment),sep,...
						algn20(T.cruise_info.PI_NAME,sep,alignment),sep,...
						algn20(datestr(median(T.geo.STATION_DATE),'mmm-yy'),sep,alignment),sep);
		elseif st_type == 3
			STP = sprintf('%s%s%s%s%s%s%s%s%s%s%s%s',...
						sep,algn30(file,sep,alignment),sep,...
						algn30(T.cruise_info.NAME,sep,alignment),sep,...
						algn30(T.cruise_info.SHIP_NAME,sep,alignment),sep,...
						algn30(T.cruise_info.PI_NAME,sep,alignment),sep,...
						algn30(datestr(median(T.geo.STATION_DATE),'mmm-yy'),sep,alignment),sep);
		end
	case 4
		alignment = 'center';
		file = clean_file(T);
		STP = sprintf('%s%s%s%s%s%s%s%s%s%s%s%s',...
					sep,algn20(file,sep,alignment),sep,...
					algn20(T.cruise_info.PI_NAME,sep,alignment),sep,...
					algn20(datestr(median(T.geo.STATION_DATE),'mmm-yy'),sep,alignment),sep);
	case 5
		STP = sprintf('%s',T.cruise_info.NAME);
	case 6
		STP = sprintf('%s on %s under %s (%s) supervision',T.cruise_info.NAME,T.cruise_info.SHIP_NAME,T.cruise_info.PI_NAME,T.cruise_info.PI_ORGANISM);
		
end

end %function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%
function str = algn10(str,sep,aln)
	if length(str) > 10
		str = [str(1:10-3) '...'];
	end
	str = ['' strjust(sprintf('%10s',str),aln) ''];
end %function
%%%%%%%%%%%%%%%
function str = algn20(str,sep,aln)
	if length(str) > 20
		str = [str(1:20-3) '...'];
	end
	str = ['' strjust(sprintf('%20s',str),aln) ''];
end %function
%%%%%%%%%%%%%%%
function str = algn30(str,sep,aln)
	if length(str) > 30
		str = [str(1:30-3) '...'];
	end
	str = ['' strjust(sprintf('%30s',str),aln) ''];
end %function

%%%%%%%%%%%%%%%
function file = clean_file(T)
	
	% Remove extension from file name
	file = T.file;
	is = strfind(file,'.');
	if ~isempty(is)
		is = max(is);
		file = file(1:is-1);
	end

	% Keep last folder only:
	if ispc, sla = '\'; 
	else, sla = '/'; end
	is = strfind(file,sla);
	if ~isempty(is)
		is = max(is)+1;
		file = file(is:end);
	end

	% For hydroLPO files, also remove the extension:
	file = strrep(file,'_dep','');
	
end%function



