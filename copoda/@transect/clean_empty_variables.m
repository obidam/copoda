% cleanemptyvariables Remove empty 'Real' variables of Transect/data OData objects
%
% T = cleanemptyvariables(T)
% 
% Remove empty 'Real' variables of Transect/data OData objects.
% An empty variable is one:
%	- with empty OData Name or OData long name property
%	- with OData content full of NaNs
%
% Created: 2010-04-20.
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


function T = clean_empty_variables(T)

D = T.data;
try 
	D = rmfield(D,'STATION_PARAMETERS');
end
try 
	PS = D.PARAMETERS_STATUS;
	D = rmfield(D,'PARAMETERS_STATUS');
end
dn = fieldnames(D);

for iv = 1 : length(dn)
	od = getfield(D,dn{iv});
	if isempty(od.name) & isempty(od.long_name) % Remove odata without names
		PS(dstatus(T,dn{iv},1)) = 'x';
		D = rmfield(D,dn{iv});
	elseif isempty(od) & dstatus(T,dn{iv}) == 'R' % Remove real odata
%	elseif prod(size(od)) > 1 & isempty(od) & dstatus(T,dn{iv}) == 'R' % Remove real odata
		PS(dstatus(T,dn{iv},1)) = 'x';
		D = rmfield(D,dn{iv});
	end
end
PS = PS(PS~='x');
D.PARAMETERS_STATUS = PS;
T.data = D;

end %functioncleanemptyvariables












