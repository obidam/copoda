% complex Construct complex result from real and imaginary parts.
%
% od = complex(od1,od2)
% 
% return an odata object with the content is the complex 
% result cont(od1) + i*cont(od2)
%
% Created: 2013-07-12.
% http://code.google.com/p/copoda
% Copyright 2013, COPODA

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

% Category for documentation:
%CAT 
% Method's type for documentation:
%TYP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function od = complex(od1,od2)

if check_units(od1,od2)

	od = odata;
	od.cont = complex(cont(od1),cont(od2));

	if ~isempty(od1.name) & ~isempty(od2.name)
		od.name = sprintf('%s + i*%s',od1.name,od2.name);
	end% if 

	if ~isempty(od1.long_name) & ~isempty(od2.long_name)
		od.long_name = sprintf('%s + i*%s',od1.long_name,od2.long_name);
	end% if 

	if ~isempty(od1.unit)
		od.unit = od1.unit;
	end% if 

	if ~isempty(od1.long_unit)
		od.long_unit = od1.long_unit;
	end% if

else

	error('Cannot create a complex with objects of different units !')

end% if 

end %functioncomplex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
