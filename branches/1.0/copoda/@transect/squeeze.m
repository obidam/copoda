% squeeze Rearrange profiles order of a transect object
%
% T = squeeze(T,INDEX)
% 
% Rearrange all profiles of transect object T
% according to new indexing INDEX.
%
% Inputs:
%	T: a transect object
%	INDEX: integer(s) between 1 and size(T,1)
%
% Outputs:
%	T: Reordered transect object.
%
% Rq:
%	Reorder any fields having its first dimension similar to the number of profiles
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
function T = squeeze(T,IND)

%- Check IND validity:
[N_PROF N_LEVEL] = size(T);
if find(IND>N_PROF)
	error('Cannot squeeze with an index larger than the number of profiles !')
end% if 
if find(IND<0)
	error('Cannot squeeze with a negative index !');
end% if 

%- Reorder geo properties:
geo = T.geo;
vlist = fieldnames(geo);
for iv = 1 : length(vlist)
	C = getfield(geo,vlist{iv});
	if size(C,1) == N_PROF
		C = C(IND,:);
		geo = setfield(geo,vlist{iv},C);
	end% if 
end% for iv
T.geo = geo;

%- Reorder data properties:
vlist = datanames(T,2);
for iv = 1 : length(vlist)
	if strcmp(dstatus(T,vlist{iv}),'R')
%		try
			od = getfield(T,'data',vlist{iv});
			od = reorder(od,1,IND);
			T  = setodata(T,vlist{iv},od);
%		catch ME
%			disp(sprintf('Error when re-ordering odata ''%s'' in this transect: %s',vlist{iv},stamp(T,7)));
%			throw(ME);
%		end% try
	end% if 
end% for iv

%- Reorder cruise_info properties:
T.cruise_info.N_STATION = length(IND);
T.cruise_info.DATE = [min(T.geo.STATION_DATE) max(T.geo.STATION_DATE)];


end %functionsqueeze
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%













