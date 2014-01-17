% subsref Subscripted reference: Define how to access object content
%
% b = subsref(a,index)
% 
% Subscripted reference: Define how to access object content.
%
% Rev. by Guillaume Maze on 2013-07-17: Implemented strict enforcement of 2nd level indexing size
% Rev. by Guillaume Maze on 2013-07-17: Implementation of the () indexing through simple shortcut
% Rev. by Guillaume Maze on 2013-07-16: Added 2nd level of indexing for all documented properties
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

if size(index,2) > 2
	throw(MException('odata:ops','Invalid indexing !'));
end% if 


%- 1st level indexing
switch index(1).type
	
	%-- Parenthesis indexing: a(<...>)
	case '()'
		% This is a shortcut to the 'cont' property.
		% Eg: od(1,end) <=> od.cont(1,end)
		new_index(1).type = '.';
		new_index(1).subs = 'cont';
		new_index(2) = index(1);
		b = subsref(a,new_index);
		
	%-- OOP indexing: a.<...>
	case '.'
	
		% Test for weird indexing (mix of string and indeces):		
		if size(index,2) == 2
			% Look for strings different than ':' in the indexing:
			has_string = 0;
			l = index(2).subs;
			for il = 1 : length(l)
				if ischar(l{il}) 
					if ~strcmp(l{il},':')
						has_string = 1;
					end% if 
				end% if 
			end% for il			
			% Look for string in the indexing:
			if has_string
				% Eg: od.cont(2,'unit')
				% Eg: od.name('long_name')
				throw(MException('odata:ops','Invalid indexing !'));
			end% if 
		end% if 
	
		%
		switch index(1).subs
			%--- String properties:	
			case {'name','unit','long_name','long_unit'}
				%% For some reasons I don't understant yet, this synthax doesn't work:
				% b = getfield(a,index(1).subs); 
				%% So I use a simple eval to assign to b the property value:
				% eval(sprintf('b = a.%s;',index(1).subs)); 
				
				%---- 2nd level indexing:
				switch size(index,2)
					case 1 %----- 1 level indexing, return: a.<...>
						eval(sprintf('b = a.%s;',index(1).subs));
						
					case 2 %----- 2 level indexing, return: a.<...>(<...>)
						switch index(2).type
							case '()'
								eval(sprintf('b = a.%s;',index(1).subs));
								b = b(cell2mat(index(2).subs));
							otherwise
								throw(MException('odata:ops',sprintf('Only parenthesis indexing allowed to access the odata object ''%s'' property !',index(1).subs)));
						end% if
				end% switch 
				
			%--- Numerical properties:
			case 'cont',
				%---- 2nd level indexing:							
				switch size(index,2)
					case 1 %----- return: a.cont
						if 1
							b = a.cont;						
						else
							b = netcdf.getVar(a.nc.ncid,a.nc.varid);
							b(b==a.nc.fval) = NaN;
						end% if 
					case 2 %----- 2nd level indexing, return: a.cont(<...>)
						switch index(2).type
							case '()'								
								b = a.cont;
								b = subsref(b,index(2));
								% if prod(size(index(2).subs)) ~= prod(size(size(b)))
								% 	throw(MException('odata:ops','Indexing must match the dimension of the odata object !'));																	
								% else
								% 	b = b(index(2).subs{:});
								% end% if 
							otherwise
								throw(MException('odata:ops','Only parenthesis indexing allowed to access the odata object ''cont'' property !'));								
						end% if 
					otherwise
						error('Invalid index');
				end% switch 
							
			%--- Undocumented properties:
			case 'prec', b = a.prec;
			case 'prec_conv', b = a.prec_conv;
			case 'dims',      b = a.dims;
			case 'nc', b = a.nc;
			otherwise
				error('Invalid field name');
		end
	
	%-- Cell indexing: a{<...>}
	case '{}'
		throw(MException('odata:ops','Cell array indexing not support by odata objects'));
		
end% switch 

end %function