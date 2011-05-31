% check Check transect object structure validity
%
% RES = check(T)
% 
% Check transect object structure validity.
% List of tests:
%	- Orientation of geo properties
%	- N_STATION in cruise_info vs size of T
%
%
% Created: 2010-06-03.
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
function res = check(T,varargin)

verb = true;
it   = 0;

if nargin == 2
	verb = varargin{1};
end

% Check geo property:
it=it+1;
[res(it) ns nl] = check_or(T,verb);

% Check N_STATION in cruise_info
it=it+1;
if T.cruise_info.N_STATION ~= ns
	res(it) = false;
	if verb,disp(sprintf('Warning: N_STATION in cruise_info property not similar to actual number of stations defined in geo property !'));end
	if verb,disp(sprintf('\tHelp: Fix this with T.cruise_info.N_STATION = size(T,1);'));end
else 
	res(it) = true;
end


% Output
if find(res==0)
	res = false;
else
	res = true;
end

end %functioncheck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [res ns nl] = check_or(T,verb)
	res = true;
	
	%%%%% Check localisation informations:
	unilist = {'STATION_DATE';'STATION_NUMBER';'LATITUDE';'LONGITUDE'};
	if isfield(subsref(T,substruct('.','geo')),'MAX_PRESSURE')
		if prod(size(subsref(T,substruct('.','geo','.','MAX_PRESSURE')))) > 1
			unilist = {'STATION_DATE';'STATION_NUMBER';'LATITUDE';'LONGITUDE';'MAX_PRESSURE'};
		end	
	end
	for iv = 1 : length(unilist)
		[a(iv) b] = size(subsref(T,substruct('.','geo','.',unilist{iv})));
		if b ~= 1
			res = false;
			if verb,disp(sprintf('Warning: %s not of dimensions N_STATIONS x 1',unilist{iv}));end			
		end
		if strcmp(unilist{iv},'STATION_NUMBER'), 
			if subsref(T,substruct('.','geo','.',unilist{iv},'()',{1})) == 9999, ns0=0;
			else, ns0=a(iv);end
		end
	end%for iv
	if length(unique(a)) ~= 1		
		res = false;
		if verb,disp(sprintf('Warning: geo property has fields not consistent with each others\n\tHelp: STATION_DATE, STATION_NUMBER, LATITUDE, LONGITUDE and MAX_PRESSURE should be of dimensions N_STATIONS x 1'));end
		ns = ns0;
	elseif ns0 ~= 0
		ns = unique(a); % to avoid calling size(T)
	else
		ns = 0;
	end
	clear a b

	%%%%% Check vertical axis: N_STATIONS x N_LEVELS or 1 x N_LEVELS
	unilist = {'PRES';'DEPH'};
	if isempty(intersect(fieldnames(T.geo),unilist))
		res = false;
		if verb,disp(sprintf('Warning: PRES and DEPH not defined ! we need a vertical axis !'));end
	end
	unilist = intersect(fieldnames(T.geo),unilist);
	for iv = 1 : length(unilist)
		[a(iv) b(iv)] = size(subsref(T,substruct('.','geo','.',unilist{iv})));
	end
	
	if length(unique(b)) ~= 1		
		res = false;
		if verb,disp(sprintf('Warning: geo property has fields not consistent with each others\n\tHelp: DEPH and PRES should be of dimensions N_STATIONS x N_LEVELS or 1 x N_LEVELS'));end
		nl = NaN;
	else
		nl = unique(b);
	end
	
	for iv = 1 : length(unilist)
		if a(iv) ~= 1 & a(iv) ~= ns
			res = false;
			if verb,disp(sprintf('Warning: %s should be of dimensions N_STATIONS x N_LEVELS or 1 x N_LEVELS',unilist{iv}));end
		end
	end%for iv

end%function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%














