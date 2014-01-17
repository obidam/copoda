% helpt Display help for transect object methods
%
% helpt(METHOD) 
% Display help for transect object method METHOD. 
% This functions is a shortcut for:
%	help transect/METHOD
%
% helpt('user')
% helpt('dev')
% helpt('contrib')
% 	Display the list of COPODA functions tagged with the 
% mentionned client level (not restricted to transect).
%
% See also: helpt,cpd_tags
%
% Created: 2011-06-06.
% Rev. by Guillaume Maze on 2014-01-04: Added tag *-level shortcut
% http://code.google.com/p/copoda
% Copyright 2011, COPODA

% Tags for documentation:
%TAGS user-level,help

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = helpt(varargin)

if nargin == 0
	help('helpt');
	return
else
	method = varargin{1};
end% if 

switch method
	case {'user','dev','contrib'}
		cpd_tags(sprintf('%s-level',method));
	otherwise
		eval(sprintf('help transect/%s',method));
end%switch

end %functionhelpt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
