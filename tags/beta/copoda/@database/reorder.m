% reorder Rearrange transect order of database object
%
% D = reorder(D,IND)
% 
% Rearrange all transects order of database object D
% according to new indexing IND.
% IND can be any indices between 1 and length(D).
% This function can be used to reduced D dimension.
%
% Created: 2009-07-30.
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


function D = reorder(D,IND)

%%% Check IND validity
nt = length(D);
if max(IND) > nt
	error('New indices larger than database content !');
end
if find(IND<=0)
	error('Cannot reorder within negative indices');
end

%%% Reorder:
ik = 0;
for ii = 1 : length(IND)
	ik = ik + 1;
	T  = D.transect{IND(ii)};
	C(ii) = {T};
end %for ii
D.transect = C;

%%% Update modified property:
D.modified = now;

end %function