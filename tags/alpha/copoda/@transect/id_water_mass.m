% id_water_mass Identify water masses through a list of test(s) on Transect datas
%
% WM = id_water_mass(T,'VAR1',{'TEST1','PARAMETER'},'VAR2',{'TEST2','PARAMETER'},...)
% 
% This function performs a list of TEST(PARAMETER) on fields VAR in 
% transect object T in order to identify a water mass.
%
% Inputs:
%	VAR (string)	: any field within T.geo or T.data
%	TEST (string)	: can be one or more of the following:
%		'range' with PARAMETER (double) = [min max]
%			Retains: min < VAR < max
%			Example: WM = id_water_mass(T,'TEMP',{'range',[2 4]});
%		'dz' with PARAMETER (double) = [min max]
%			Retains: min < d(VAR)/dz < max
%			Example: WM = id_water_mass(T,'TEMP',{'dz',[-Inf 0.01]});
%
% Output:
%	WM is a double table of similar dimensions of T.data fields with values
%	from 0 to 1. 
%	0 is when none of the test(s) succeeded
%	1 is when all the test(s) succeeded
%
% Example:
% WM = id_water_mass(T,'TEMP',{'range',[2 5]},'LATITUDE',{'range',[35 45]});
%
% Created: 2009-08-04.
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


function R = id_water_mass(T,varargin)

crit = check_inputs(varargin{:});
if ~isstruct(crit)
	error(sprintf('Bad arguments, for more informations about arguments syntax type:\nhelp transect/id_water_mass'));
end

for it = 1 : length(crit)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RANGE test
	if isfield(crit(it),'range')
		if ~isempty(getfield(crit(it),'range'))
			%%% We first look for the field within the transect object:
			if isdata(T,crit(it).field)
				OD = getfield(T.data,crit(it).field);
				C = OD.cont;
			else
				switch crit(it).field
					case {'STATION_DATE','STATION_NUMBER','LATITUDE','LONGITUDE','PRES','DEPH'}
						C = getfield(T.geo,crit(it).field);
						% Test dimensions:
						field = datanames(T);
						OD = getfield(T.data,field{1}); Cref = OD.cont;
						switch prod(size(C))
							case prod(size(Cref)) % Nothing to do, probably same dimensions
							case size(Cref,1) % this is probably a NSTATIONS x 1
								[C a] = meshgrid(C,1:size(Cref,2)); clear a
								C = C';	
								C(isnan(Cref)) = NaN;
							case size(Cref,2) % this is probably a NLEVELS x 1
								[C b] = meshgrid(C,1:size(Cref,1)); clear b
								C(isnan(Cref)) = NaN;
							otherwise
								error('To do: extend dimensions cases');
						end %switch
						
					otherwise
					 	error(sprintf('Invalid property %s to id this water mass',crit(it).field));
				end
			end
			%%% Then, we perform the test:
			switch crit(it).range(1)
				case -Inf
					switch crit(it).range(2)
						case Inf
							pii = ones(size(C));							
						otherwise							
							pii = zeros(size(C));
							pii(C<max(crit(it).range)) = 1;
					end %switch
				otherwise
					switch crit(it).range(2)
						case Inf
							pii = zeros(size(C));
							pii(C>min(crit(it).range)) = 1;
						otherwise
							if 0
								pii = zeros(size(C));
								pii = abs(pii - nanmean(crit(it).range));
								pii(pii>abs(diff(crit(it).range))/2) = 1;
								pii(pii==1) = NaN;
								pii = 1 - pii;
								pii = pii - nanmin(pii(:));
								pii = pii./xtrm(pii);
							else
								pii = zeros(size(C));
								pii(C>min(crit(it).range) & C<max(crit(it).range)) = 1;
							end
							
					end %switch
			end % switch

			r = pii;
			r(isnan(C)) = NaN;
		end
	end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DZ test
	if isfield(crit(it),'dz')
		if ~isempty(getfield(crit(it),'dz'))
			disp('dz test is not implemented yet !')
		end
	end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
	if it == 1
		R = r;
	else
		R(r==0) = 0;
		R(R~=0) = R(R~=0) + r(R~=0);
	end
end

% Normalize:
R = R - nanmin(R(:));
R = R./xtrm(R);
end %function


%%%%%%%%%%%%%%%%
function crit = check_inputs(varargin);
	
	if mod(nargin,2) ~= 0 | nargin == 0
		crit = NaN;
	else
		n = nargin;
		crit = struct;
		ii = 0;
		for iprop = 1 : 2 : n
			prop_nam = varargin{iprop};
			prop_val = varargin{iprop+1};
			ii = ii  + 1;
			crit(ii).field = prop_nam;
			crit = setfield(crit,{ii},prop_val{1},prop_val{2});
		end
	
	end
	
end %function



