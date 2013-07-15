% subsasgn H1LINE
%
% [] = subsasgn()
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

function a = subsasgn(a,index,val)

switch index(1).type
	case '()'
		switch index.subs(:)
			case 1, a.name = val;
			case 2, a.unit = val;
			case 3, a.cont = val;
			case 4, a.prec = val;			
			case 5, a.prec_conv = val;
			case 6, a.long_name = val;
			case 7, a.long_unit = val;
			case 8, 
				if isa(val,'cell')
					for iv=1:length(val)
						if ~isa(val{iv},'oaxis')
							error('ODATA object dims property must be a cell of oaxis object');
						end
					end	
					a.dims = val;
				else
					error('ODATA object dims property must be a cell');
				end
			otherwise
				error('Invalid index');
		end
	case '.'
		switch index(1).subs
			case 'name', a.name = val;
			case 'unit', a.unit = val;
			case 'cont', 
				switch length(index)
					case 1
						a.cont = val;					
					otherwise
						error('Sorry, such assignment not yet available, please use only od.cont = ...;');
						% TODO Implement this simple feature asap !
				end% switch 				
			case 'prec', a.prec = val;
			case 'prec_conv', a.prec_conv = val;
			case 'long_name', a.long_name = val;
			case 'long_unit', a.long_unit = val;
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
			otherwise
				error('Invalid field name');
		end
	case '{}'
		error('Cell array indexing not support by odata objects');
end

end %function