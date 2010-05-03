% subsref H1LINE
%
% [] = subsref()
% 
% HELPTEXT
%
%
% Created: 2009-07-23.
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

function b = subsref(a,index)

switch index(1).type
	% case '()'
	% 	switch cell2mat(index.subs(:))
	% 		case 1, b = a.NAME;
	% 		case 2, b = a.PI_NAME;
	% 		case 3, b = a.PI_ORGANISM;
	% 		case 4, b = a.SHIP_NAME;
	% 		case 5, b = a.SHIP_WMO_ID;
	% 		case 6, b = a.DATE;
	% 		case 7, b = a.N_STATION;
	% 		otherwise
	% 			error('Invalid index');
	% 	end
	case '.'
		switch index(1).subs
			case 'NAME', 	  	 
				if size(index,2) == 1
					b = a.NAME;
				elseif size(index,2) == 2
					b = a.NAME;
					b = b(cell2mat(index(2).subs));
				else
					error('Invalid index');
				end
				
			case 'PI_NAME',	  	 
				if size(index,2) == 1
					b = a.PI_NAME;
				elseif size(index,2) == 2
					b = a.PI_NAME;
					b = b(cell2mat(index(2).subs));
				else
					error('Invalid index');
				end
				
			case 'PI_ORGANISM', 	 
				if size(index,2) == 1
					b = a.PI_ORGANISM;
				elseif size(index,2) == 2
					b = a.PI_ORGANISM;
					b = b(cell2mat(index(2).subs));
				else
					error('Invalid index');
				end
				
			case 'SHIP_NAME', 	 
				if size(index,2) == 1
					b = a.SHIP_NAME;
				elseif size(index,2) == 2
					b = a.SHIP_NAME;
					b = b(cell2mat(index(2).subs));
				else
					error('Invalid index');
				end
				
			case 'SHIP_WMO_ID', 	 
				if size(index,2) == 1
					b = a.SHIP_WMO_ID;
				elseif size(index,2) == 2
					b = a.SHIP_WMO_ID;
					b = b(cell2mat(index(2).subs));
				else
					error('Invalid index');
				end
				
			case 'DATE', 
				if size(index,2) == 1
					b = a.DATE;
				elseif size(index,2) == 2
					b = a.DATE;
					b = b(cell2mat(index(2).subs));
				else
					error('Invalid index');
				end
			
			case 'N_STATION',
					if size(index,2) == 1
						b = a.N_STATION;
					elseif size(index,2) == 2
						b = a.N_STATION;
						b = b(cell2mat(index(2).subs));
					else
						error('Invalid index');
					end		
			otherwise
				error('Invalid field name for cruise_info class');
		end
	case '{}'
		error('Cell array indexing not support by cruise_info class');
end





end %function