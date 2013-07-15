% woa Create a reference database from the World Ocean Atlas
%
% Dwoa = woa(D)
% 
% Create a reference database from the World Ocean Atlas.
% Interpolate the World Ocean Atlas annual climatology on the
% tracks of all the transects in the database D.
%
% Created: 2010-05-26.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = woa(varargin)

D = varargin{1};
Dwoa = database;

for iT = 1 : length(D)
	nojvmwaitbar(length(D),iT,sprintf('Processing transect: %s',D.transect{iT}.cruise_info.NAME));
	T = woa(D.transect{iT});
	Dwoa.transect{iT} = T;
end
Dwoa = squeeze(Dwoa,[1:length(D)]);
Dwoa.name   = sprintf('World Ocean Atlas sampled on %s transects',D.name);
Dwoa.description = cat(1,'World Ocean Atlas interpolated from station in the database:',D.description);
Dwoa.source = 'National Oceanographic Data Center';

varargout(1) = {Dwoa};

end %functionwoa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%










