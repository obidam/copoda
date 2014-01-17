% isempty True for empty OData content
%
% ISEMPTY(OD) returns 1 if OD.cont is an empty array and 0 otherwise. 
% An empty array has no elements, that is prod(size(OD.cont))==0.
%
% Created: 2013-07-19
% http://copoda.googlecode.com
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

% Backward compatibility issue with version 1.0 of odata:
% Now apply built-in function 'isempty' on the odata 'cont' propertie.
% In version 1.0, object was considered empty if 'cont' was full of NaNs
% whatever its size.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RES = isempty(OD)

RES = isempty(OD.cont);

% N = prod(size(OD));
% n = length(find(isnan(OD.cont(:))==1));

% if N == n
% 	RES = true;
% else
% 	RES = false;
% end

end %functionisempty
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
