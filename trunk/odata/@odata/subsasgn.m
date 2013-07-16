% subsasgn  Subscripted assignment: Assign values to object properties
%
% a = subsasgn(a,index,val)
% 
% Subscripted assignment: Assign values to object properties
%
% Rev. by Guillaume Maze on 2013-07-12: Remove the index(1).type == '()' assignment
% Rev. by Guillaume Maze on 2013-07-12: Added check on input property types
% Rev. by Guillaume Maze on 2013-07-12: Added 2nd level of assignment for string properties
% Rev. by Guillaume Maze on 2013-07-12: Added 2nd level of assignment for cont property
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

function a = subsasgn(a,index,val)

switch index(1).type
	case '()'
		if ~isnumeric(val)
			error('ODATA object property ''cont'' must be numeric !');							
		else
			switch size(index,2)						
				case 1 % od(...) = ...
					b = a.cont;
					b = subsasgn(b,index(1),val);
					a.cont = b;
				otherwise
					error('This indexing is not supported');
			end% switch 
		end% if
	% case '()'
	% 	switch index.subs(:)
	% 		case 1, a.name = val;
	% 		case 2, a.unit = val;
	% 		case 3, a.cont = val;
	% 		case 4, a.prec = val;			
	% 		case 5, a.prec_conv = val;
	% 		case 6, a.long_name = val;
	% 		case 7, a.long_unit = val;
	% 		case 8, 
	% 			if isa(val,'cell')
	% 				for iv=1:length(val)
	% 					if ~isa(val{iv},'oaxis')
	% 						error('ODATA object dims property must be a cell of oaxis object');
	% 					end
	% 				end	
	% 				a.dims = val;
	% 			else
	% 				error('ODATA object dims property must be a cell');
	% 			end
	% 		otherwise
	% 			error('Invalid index');
	% 	end
	case '.'
		switch index(1).subs
			% String properties:
			case 'name', 
				if ~ischar(val)
					error('ODATA object property ''name'' must be a string !');
				else
					switch size(index,2)
						case 1
							a.name = val;	
						case 2
							if index(2).type == '()'
								b = a.name;
								b(cell2mat(index(2).subs)) = val;
								a.name = b;
							else
								error('Cell array indexing is not supported by odata objects');
							end% if
					end% switch 					
				end% if 
			case 'unit', 
				if ~ischar(val)
					error('ODATA object property ''unit'' must be a string !');
				else
					switch size(index,2)
						case 1
							a.unit = val;	
						case 2
							if index(2).type == '()'
								b = a.unit;
								b(cell2mat(index(2).subs)) = val;
								a.unit = b;
							else
								error('Cell array indexing is not supported by odata objects');
							end% if 
					end% switch 
				end% if 
			case 'long_name',  
				if ~ischar(val)
					error('ODATA object property ''long_name'' must be a string !');
				else
					switch size(index,2)
						case 1
							a.long_name = val;	
						case 2
							if index(2).type == '()'
								b = a.long_name;
								b(cell2mat(index(2).subs)) = val;
								a.long_name = b;
							else
								error('Cell array indexing is not supported by odata objects');
							end% if 
					end% switch 					
				end% if
			case 'long_unit',  
				if ~ischar(val)
					error('ODATA object property ''long_unit'' must be a string !');
				else
					switch size(index,2)
						case 1
							a.long_unit = val;	
						case 2
							if index(2).type == '()'
								b = a.long_unit;
								b(cell2mat(index(2).subs)) = val;
								a.long_unit = b;
							else
								error('Cell array indexing is not supported by odata objects');
							end% if 
					end% switch 					
				end% if
			
			% Numerical properties:
			case 'cont'
				if ~isnumeric(val)
					error('ODATA object property ''cont'' must be numeric !');							
				else
					switch size(index,2)
						case 1 % od.cont = ...
							a.cont = val;							
						case 2 % od.cont(...) = ...
							if index(2).type == '()'
								b = a.cont;
								b = subsasgn(b,index(2),val);
								a.cont = b;
							else
								error('Cell array indexing is not supported by odata objects');
							end% if
						otherwise
					end% switch 
				end% if			
			case 'cont_deprecated', 
				switch length(index)
					case 1
						if ~isnumeric(val)
							error('ODATA object property ''cont'' must be numeric !');							
						else
							a.cont = val;

						end% if 
					otherwise
						error('Sorry, fine grained assignment not yet available, please use only od.cont = ...;');
						% TODO Implement this simple feature asap !
				end% switch 
				
			% Not supported:					
			case 'prec', a.prec = val;
			case 'prec_conv', a.prec_conv = val;
			case 'dims',
				if isa(val,'cell')
					% for iv = 1 : length(val)
					% 	% We verify in the workspace if the variable is an oaxis object:
					% 	if ~isa(evalin('base',val{iv}),'oaxis')
					% 		error('ODATA object dims property must be a cell of oaxis object');
					% 	end
					% end
					% Otherwise it's ok:
					a.dims = val;
				else
					error('ODATA object dims property must be a cell');
				end
				
			% Not listed:
			otherwise
				error('Invalid field name');
		end
	case '{}'
		error('Cell array indexing not support by odata objects');
end

end %function