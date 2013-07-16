% subsref Subscripted reference: Define how to access object content
%
% b = subsref(a,index)
% 
% Subscripted reference: Define how to access object content
%
% Rev. by Guillaume Maze on 2013-07-12: Added 2nd level indexing to string properties
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
	
	case '{}' % Direct access to the object content: od{...} RETURN VALUES
		cont = a.cont;		
		b = cont(index(1).subs{:});
	
	case '()' % Direct access to the object content: od(...) RETURN OBJECT
		b = a;
		b.cont = a.cont(index(1).subs{:});
		
%	case '{}'
%		error('Cell array indexing not support by odata objects');

	case '.' % Access to: od.prop	
		switch index(1).subs
			% String properties:
			case 'name', 
				b = a.name;
				if size(index,2) == 2
					b = b(cell2mat(index(2).subs));
				end
			case 'unit', 
				b = a.unit;
				if size(index,2) == 2
					b = b(cell2mat(index(2).subs));
				end
			case 'long_name', 
				b = a.long_name;
				if size(index,2) == 2
					b = b(cell2mat(index(2).subs));
				end
			case 'long_unit', 
				b = a.long_unit;
				if size(index,2) == 2
					b = b(cell2mat(index(2).subs));
				end
						
			% Numerical properties:
			case 'cont', 
				if size(index,2) == 1
					b = a.cont;
				elseif size(index,2) == 2
					b = a.cont;
					b = b(index(2).subs{:});
				else
					error('Invalid index');
				end
				
			% Not supported:									
			case 'prec', b = a.prec;
			case 'prec_conv', b = a.prec_conv;
			case 'dims',      b = a.dims;
			
			% Not listed:
			otherwise
				error('Invalid field name');
		end% switch 
		
end% switch 

end %function