% setodata Add an OData object in the transect data property
%
% T = setodata(T,ODNAME,OD,[DSTATUS]) Add the OData object OD,
% in the transect T data property as a parameter named ODNAME and 
% possibly with status DSTATUS. OD must have a name and an unit.
%
% T = setodata(T,ODNAME,'V') Add the supported variable ODNAME
% in the transect T data property with a virtual status. This 
% form is a shortcut for:
%	T = setodata(T,ODNAME,supported_variables(transect,'odata',ODNAME),'V');
%
% Note that:
% - Optional argument DSTATUS can be 'R' or 'V' to set the new
%   data status. By default it's 'R'.
% - In case we're overwriting an already existing odata object,
%   and no status is specify here, previous status is preserved.
% - No consistency check is made on the dimensions of the new odata variable
% 	with those already existing in the transect object. See the transect
% 	method 'validate' for such a test.
%
% Created: 2010-06-03.
% Rev. by Guillaume Maze on 2013-12-13: Added short-cut for virtual variables
% http://copoda.googlecode.com
% Copyright 2010, COPODA

%TAGS user-level,define,load,add,set,data,manipulate

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
function T = setodata(T,ODname,OD,varargin)
	
%- Handle arguments	
if nargin == 4
	dstat = varargin{1};
	if ~ischar(dstat)
		error('DSTATUS must be ''R'' or ''V''');
	elseif ~strcmp(dstat,'R') & ~strcmp(dstat,'V')
		error('DSTATUS must be ''R'' or ''V''');		
	end	
else
	if nargin == 3 & ~isa(OD,'odata') & strcmp(OD,'V')
		T = setodata(T,ODname,supported_variables(transect,'odata',ODname),'V');
		return;
	else
		dstat = 'R';		
	end% if 
end

%- Load the list of supported variables (builtin and user-defined)
l = data_list; % This function is in the private folder

%- Set this data:
if ~isfield(l,ODname)
	error(sprintf('Invalid field name for transect.data property\nSee the list of available variables with transect method: supported_variables'))
else
	b = T.data;
	if isfield(b,'STATION_PARAMETERS')
		b = rmfield(b,'STATION_PARAMETERS');
	end
	if isfield(b,'PARAMETERS_STATUS')
		PARAMETERS_STATUS = b.PARAMETERS_STATUS; n = length(PARAMETERS_STATUS);
		b = rmfield(b,'PARAMETERS_STATUS');
	end
	
	if ~isa(OD,'odata')
		error(sprintf('%s must be an OData object',ODname));
	else
		
		% Check validity of input odata object
		% It must have a name and a unit !
		if isempty(OD.name) & isempty(OD.long_name)
			error('Your odata object must have a name');
		elseif isempty(OD.unit) & isempty(OD.long_unit)
			error('Your odata object must have an unit');
		end
		
		% Replace pre-existing field:
		if isfield(b,ODname)
			[ia id] = intersect(fieldnames(b),ODname); clear ia	
			if nargin == 4 
				% We overwrite previous status with new one:
				PARAMETERS_STATUS(id) = dstat;
				% and we ensure that a virtual variable content is set to NaN:
				if strcmp(dstat,'V')
					OD.cont = NaN;
				end
			else
				% We keep previous status
			end			
			b = setfield(b,ODname,OD);
			
		% Add new field:
		else
			% Add the field at the end:		
			b = setfield(b,ODname,OD);
			PARAMETERS_STATUS = [PARAMETERS_STATUS(1:n) dstat];
		end
	
		% Reorder fields by alphabetical order:
		[b is] = orderfields(b);
		PARAMETERS_STATUS = PARAMETERS_STATUS(is);
		b.PARAMETERS_STATUS = PARAMETERS_STATUS;
		
		T = subsasgn(T,substruct('.','data'),b);
		
	end
end

end %functionsetodata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
