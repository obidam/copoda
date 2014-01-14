% disp Display information about an odata object in the command window
%
% [] = disp(OD,[FORMAT])
% 
% Standard command window output of ODATA objects
%
% Rev. by Guillaume Maze on 2013-07-12: Added shorter print
% Created: 2009-07-24.
% Copyright (c) 2009 Guillaume Maze. 
% http://codes.guillaumemaze.org

%
% This program is free software: you can redistribute it and/or modify it under the 
% terms of the GNU General Public License as published by the Free Software Foundation, 
% either version 3 of the License, or any later version. This program is distributed 
% in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
% implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
% GNU General Public License for more details. You should have received a copy of 
% the GNU General Public License along with this program.  
% If not, see <http://www.gnu.org/licenses/>.
%

function varargout = disp(O,varargin)

narginchk(1,2);
if nargin == 2
	form = varargin{1};
	if isempty(isin(form,[1 2]))
		error('Unsupported format id');
	end% if 
else
	form = 2;
end% if 

switch form
	case 1 %- Default print
		disp('OData object content description =======================================================');

		%-- Supported properties:
		disp_prop('Long Name [short]',sprintf('%s [%s]',O.long_name,O.name));
		disp_prop('Long Unit [short]',sprintf('%s [%s]',O.long_unit,O.unit));

		ns = size(O.cont);str='';
		str = sprintf('%i',ns(1));
		if ndims(O.cont)>1, for id = 2 : ndims(O.cont)
			str = sprintf('%s x %i',str,ns(id));
		end,end		
		disp_prop('Size',str)

		disp_prop('Content statistics',sprintf('Max=%f, Min=%f, Mean=%f, STD=%f',...
									nanmax(O.cont(:)),nanmin(O.cont(:)),...
									nanmean(O.cont(:)),nanstd(O.cont(:))));

		%-- Properties not supported:
		
		if ~isempty(O.prec)
			disp_prop('Precision',sprintf('Max=%f, Min=%f',...
										nanmax(O.prec(:)),nanmin(O.prec(:))));
		end
		if ~isempty(O.prec_conv)							
			disp_prop('Precision Convention',O.prec_conv);
		end

		odilist = O.dims;
		if ~isempty(odilist)
			ns = size(O.dims); str='';
			try 
				odname = evalin('base',sprintf('%s.name',odilist{1}));
				odaxis = evalin('base',sprintf('%s.axis',odilist{1}));
				str = sprintf('%s [%s]',odname,odaxis);
			catch
				str = '?';
			end	
			if length(O.dims)>1, 
				for id = 2 : length(O.dims)
					try 
						odname = evalin('base',sprintf('%s.name',odilist{id}));
						odaxis = evalin('base',sprintf('%s.axis',odilist{id}));
						str = sprintf('%s x %s',str,sprintf('%s [%s]',odname,odaxis));
			%			odi = evalin('base',odilist{id});
			%			str = sprintf('%s x %s',str,sprintf('%s [%s]',odi.name,odi.axis));
					catch
						str = sprintf('%s x %s',str,'?');		
					end
				end
			end
		else
			str = 'undefined in the base workspace';
		end
		disp_prop('Dimensions',str)

		disp('========================================================================================');
		
	case 2 %- Smaller print
		disp_prop_min('name (unit)',sprintf('%s (%s)',O.name,O.unit));

		ns = size(O.cont);str='';
		str = sprintf('%i',ns(1));
		if ndims(O.cont)>1, for id = 2 : ndims(O.cont)
			str = sprintf('%s x %i',str,ns(id));
		end,end		
		disp_prop_min('size',str)
		
		disp_prop_min('stats',sprintf('max=%f, min=%f, mean=%f, std=%f',...
									nanmax(O.cont(:)),nanmin(O.cont(:)),...
									nanmean(O.cont(:)),nanstd(O.cont(:))));
		
end% switch 

end %function

%%%%%%%%%%%%%%%%%%%
function varargout = disp_prop_min(name,value)
	blk = ' ';	
	disp(sprintf('%1s %11s: %s',blk,name,value));	
end



%%%%%%%%%%%%%%%%%%%
function varargout = disp_prop(name,value)
	blk = ' ';	
	disp(sprintf('%5s %20s: %s',blk,name,value));	
end


