% subsref H1LINE
%
% [] = subsref()
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

function b = subsref(a,index)

index

switch index(1).type
	case '()'
		cont = a.cont;		
		b = cont(index(1).subs{:});
	case '.'
		switch index(1).subs
			case 'name', b = a.name;
			case 'unit', b = a.unit;
			case 'cont', 
				if size(index,2) == 1
					b = a.cont;
				elseif size(index,2) == 2
					b = a.cont;
					b = b(index(2).subs{:});
				else
					error('Invalid index');
				end
			case 'prec', b = a.prec;
			case 'prec_conv', b = a.prec_conv;
			case 'long_name', b = a.long_name;
			case 'long_unit', b = a.long_unit;
			case 'dims',      b = a.dims;
			otherwise
				error('Invalid field name');
		end
	case '{}'
		error('Cell array indexing not support by odata objects');
end

end %function