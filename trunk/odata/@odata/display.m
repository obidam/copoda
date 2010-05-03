% display H1LINE
%
% [] = display()
% 
% HELPTEXT
%
%
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

function varargout = display(O)

disp('OData object content description =======================================================');

disp_prop('Long Name [short]',sprintf('%s [%s]',O.long_name,O.name));
disp_prop('Long Unit [short]',sprintf('%s [%s]',O.long_unit,O.unit));
disp_prop('Content statistics',sprintf('Max=%f, Min=%f, Mean=%f, STD=%f',...
							nanmax(O.cont(:)),nanmin(O.cont(:)),...
							nanmean(O.cont(:)),nanstd(O.cont(:))));
if ~isempty(O.prec)
	disp_prop('Precision',sprintf('Max=%f, Min=%f',...
								nanmax(O.prec(:)),nanmin(O.prec(:))));
end
if ~isempty(O.prec_conv)							
	disp_prop('Precision Convention',O.prec_conv);
end

ns = size(O.cont);str='';
str = sprintf('%i',ns(1));
if ndims(O.cont)>1, for id = 2 : ndims(O.cont)
	str = sprintf('%s x %i',str,ns(id));
end,end		
disp_prop('Size',str)

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
end %function



%%%%%%%%%%%%%%%%%%%
function varargout = disp_prop(name,value)
	blk = ' ';	
	disp(sprintf('%5s %20s: %s',blk,name,value));	
end


