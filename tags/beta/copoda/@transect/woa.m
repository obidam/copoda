% woa Create a reference transect from the World Ocean Atlas
%
% Twoa = woa(T)
% 
% Create a reference transect from the World Ocean Atlas.
% Interpolate the World Ocean Atlas annual climatology on the
% tracks of the transect T.
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

T = varargin{1};

var_avail = {'temp','oxyl','aou','psal','oxsl','phos','nitr','silc'};
var_need  = lower(datanames(T,1));

Twoa = woa2transect(T.geo.LONGITUDE,T.geo.LATITUDE,T.geo.DEPH,intersect(var_avail,var_need));
Twoa.cruise_info.NAME = sprintf('%s on transect ''%s'' stations',Twoa.cruise_info.NAME,T.cruise_info.NAME);
Twoa.geo.STATION_DATE = T.geo.STATION_DATE;
Twoa.geo.STATION_NUMBER = T.geo.STATION_NUMBER;
Twoa.cruise_info.DATE = [min(T.geo.STATION_DATE) max(T.geo.STATION_DATE)];

% Try to add needed fields with validate:
var_need2 = upper(setdiff(var_need,var_avail));
if ~isempty(intersect(var_need2,'OXST'))
	[res Twoa] = validate(Twoa,0,1,8);
end
if ~isempty(intersect(var_need2,'SIG0'))
	[res Twoa] = validate(Twoa,0,1,11);
end
if ~isempty(intersect(var_need2,'AOU'))
	[res Twoa] = validate(Twoa,0,1,6);
end

varargout(1) = {Twoa};

end %functionwoa
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







