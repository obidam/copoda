% datanames Return data names from a transect object
%
% DN = datanames(T,[OPT])
% 
% Return non-empty data names from the transect object T, i.e. the list of
% odata objects in T.data, except STATION_PARAMETERS and PARAMETERS_STATUS, 
% with non-empty content and a defined name or long_name
%
% Inputs:
%	T: a Transect object
%	OPT: 
%		0 (default) returns non-empty fields having names (INCLUDED fields 
%			with content set to a NaN)
%		1 returns non-empty fields having names (EXCLUDING fields 
%			with content set to a NaN)
%		2 returns all fields but STATION_PARAMETERS and PARAMETERS_STATUS
% Output:
%	DN: a cell of strings with fields from T.data
%
%
% Created: 2009-07-29.
% Rev. by Guillaume Maze on 2010-04-20: Added options for misc results
% Rev. by Guillaume Maze on 2010-05-05: Don't dstatus anymore (improve perf)
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


function fi = datanames(T,varargin)

if nargin == 2
	incempty = varargin{1};
	if incempty ~= 0 && incempty ~= 1 && incempty ~= 2
		error('Optional argument in @transect/datanames must be either 0, 1 or 2')
	end
else
	incempty = 0;
end

t  = T.data;
fi = fieldnames(t);
%fi = setdiff(fi,'STATION_PARAMETERS');
%fi = setdiff(fi,'PARAMETERS_STATUS');
ikeep = 0;
for iv = 1 : length(fi)
%	v = getfield(t,fi{iv});
	eval(sprintf('v = t.%s;',fi{iv}));
%	eval(sprintf('vname   = t.%s.name;',fi{iv}));
%	eval(sprintf('vlong_name = t.%s.long_name;',fi{iv}));
	if isa(v,'odata') % % Is an OData object (not supposed to happen, so we don't test)
		switch incempty
			case 0 % Default output
				if (~isempty(v.name) || ~isempty(v.long_name))					
					ikeep = ikeep + 1;
					keep(ikeep) = iv;
				end
			case 1 % 
				if (~isempty(v.name) || ~isempty(v.long_name))
					
					% Much faster code:
					if ~isempty(v) | ( prod(size(v.cont))==1 && ~isnan(v.cont) )					
						ikeep = ikeep + 1;
						keep(ikeep) = iv;
					end
					
					% Better but much slower code:
%					eval(sprintf('v = t.%s;',fi{iv}));
					% switch dstatus(T,fi{iv})
					% 	case 'R'
					% 		if length(v.cont)~=1 
					% 			ikeep = ikeep + 1;
					% 			keep(ikeep) = iv;
					% 		end
					% 	case 'V'
					% 		if isnan(v.cont)								
					% 			ikeep = ikeep + 1;
					% 			keep(ikeep) = iv;
					% 		else
					% 			warning('Found a virtual variable with a content not set to NaN !');
					% 		end							
					% 	otherwise
					% 		error('Unexpected status for variable')
					% end%switch

				end
			case 2
				ikeep = ikeep + 1;
				keep(ikeep) = iv;
		end
		
	else % Not an OData object
%		error('Found an unexpected field into Transect object data property');
	end
end

if exist('keep','var')
	fi = fi(keep);
	% Sort fields alphabeticaly:
	fi = sort(fi);
	fi = fi';
else
	fi = NaN;
end




end %function