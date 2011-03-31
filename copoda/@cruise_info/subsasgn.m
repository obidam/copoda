% subsasgn H1LINE
%
% [] = subsasgn()
% 
% HELPTEXT
%
%
% Created: 2009-07-23.
% http://copoda.googlecode.com
% Copyright 2010, COPODA

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

function a = subsasgn(a,index,val)

switch index(1).type
	case '.'
		switch index(1).subs
			case 'NAME',        a.NAME = val;
			case 'PI_NAME',     a.PI_NAME = val;
			case 'PI_ORGANISM', a.PI_ORGANISM = val;
			case 'SHIP_NAME'  , a.SHIP_NAME = val;
			case 'SHIP_WMO_ID', a.SHIP_WMO_ID = val;
			case 'DATE',        
				switch size(index,2)
					case 1
						if length(val) ~= 2
							error('The DATE property of a cruise_info object must be 2x1 datenum array')
						else
							a.DATE = val;	
						end
					case 2
						b = a.DATE;
						b = setfield(b,index(2).subs,val);
						a.DATE = b;
				end
				
			case 'N_STATION',   
				if length(val) ~= 1 | isnan(val(1)) | val(1) < 0
					error('The number of stations must be an integer')
				else
					a.N_STATION = val;
				end
			otherwise
				error('Invalid field name for cruise_info class');
		end
	case '{}'
		error('Cell array indexing not support by cruise_info class');
end

end %function
