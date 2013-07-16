% subsref Subscripted reference: Define how to access object content
%
% b = subsref(a,index)
% 
% Subscripted reference: Define how to access object content.
%
% Rev. by Guillaume Maze on 2013-07-16: Added comments and help
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

%- 1st level indexing
switch index(1).type
	
	%-- Parenthesis indexing: a(<...>)
	case '()'
		cont = a.cont;		
		b = cont(index(1).subs{:});
		
	%-- OOP indexing: a.<...>
	case '.'
		switch index(1).subs
			%--- String properties:	
			case 'name', b = a.name;
			case 'unit', b = a.unit;
			case 'long_name', b = a.long_name;
			case 'long_unit', b = a.long_unit;
			
			%--- Numerical properties:
			case 'cont',
				switch size(index,2)
					case 1 %----- return: a.cont
						b = a.cont;
					case 2 %----- 2nd level indexing, return: a.cont(<...>)
						b = a.cont;
						b = b(index(2).subs{:});
					otherwise
						error('Invalid index');
				end% switch 
							
			%--- Undocumented properties:
			case 'prec', b = a.prec;
			case 'prec_conv', b = a.prec_conv;
			case 'dims',      b = a.dims;
			otherwise
				error('Invalid field name');
		end
	
	%-- Cell indexing: a{<...>}
	case '{}'
		error('Cell array indexing not support by odata objects');
end

end %function