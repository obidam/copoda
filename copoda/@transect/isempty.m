% isempty Check datas in a transect object
%
% R = isempty(T)
% 
% Check if the transect object T has non-empty datas, return true/false
%
% Created: 2009-07-30.
% http://copoda.googlecode.com
% Copyright 2010, COPODA

% Tags for documentation:
%TAGS dev-level,empty,test

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


function out = isempty(T)

% if ~iscell(datanames(T,1))
% 	if isnan(datanames(T,1))
% 		out  = true;
% 	else
% 		out = false;
% 	end
% else
% 	out = false;
% end

if prod(size(T)) >= 1 % Now size(T) can return 0
	out = false;
else
	out = true;
end




end %function