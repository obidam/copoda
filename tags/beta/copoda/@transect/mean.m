% mean Compute a mean vertical profiles of a transect data
%
% [] = mean()
% 
% HELPTEXT
%
%
% Created: 2009-07-29.
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


function p = mean(varargin)

T = varargin{1};
if nargin == 2
	fields = {varargin{2}};
	fields_ok = datanames(T);
	found=0;for iv = 1 : size(fields_ok,1),if strcmp(fields{1},fields_ok{iv}),found=1;end;end
	if found == 0
		error('Invalid field name');
	end
else
	fields = datanames(T);
end

for iv = 1 : size(fields,1)
	od = getfield(T.data,fields{iv});
	p(iv,:) = nanmean(od.cont,1);
end %for iv




end %function