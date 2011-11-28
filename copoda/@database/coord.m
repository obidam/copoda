% coord Extract profiles coordinates from a database
%
% [X, Y, [VARL]] = coord(D,[VARL])
% 
% Extract profiles coordinates from a database.
%
% Inputs:
%	D: A database object
%	VARL: A cell with a list of other parameters to get
%		for each profile. It can be any field from geo and
%		data of dimensions N_PROF x 1.

% Outputs:
%	X: Longitude of each profiles
%	Y: Latitude of each profiles
%
% Rq:
%	This function is a faster method than database/extract !
%

% Created: 2011-06-01.
% http://code.google.com/p/copoda
% Copyright 2011, COPODA

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
function varargout = coord(D,varargin)

if nargin > 1
	error('Sorry, not implemented yet !')
end% if 

X = [];
Y = [];
T = [];
for iT = 1 : length(D)
	X = [X ; D.transect{iT}.geo.LONGITUDE];
	Y = [Y ; D.transect{iT}.geo.LATITUDE];
	T = [T ; D.transect{iT}.geo.STATION_DATE];
end% for iT

if (length(X) ~= length(Y)) | (length(X) ~= length(T)) | (length(Y) ~= length(T))
	error('Latitude and longitude are not of similar length !')
end% if 

varargout(1) = {X};
varargout(2) = {Y};
varargout(3) = {T};
	
end %functioncoord
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
