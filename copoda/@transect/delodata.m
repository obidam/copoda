% delodata Delete an OData object in a transect.data property
%
% T = delodata(T,ODNAME)
% 
% Delete the OData object named ODNAME in the transect T data property.
% ODNAME can be a string or a cell of strings to delete more than 1 object.
%
% Created: 2010-06-03.
% http://copoda.googlecode.com
% Copyright 2010, COPODA

% Tags for documentation:
%TAGS user-level,delete,data,variable,odata

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
function T = delodata(T,ODnamelist)

if ischar(ODnamelist)
	ODnamelist = {ODnamelist};
end

for iod = 1 : length(ODnamelist)
	ODname = ODnamelist{iod};

	if isdata(T,ODname,0)
	
		b = T.data;
		[ia id] = intersect(fieldnames(b),ODname); clear ia	
		b = rmfield(b,ODname);
	
		ii = 1:length(b.PARAMETERS_STATUS);
		b.PARAMETERS_STATUS = b.PARAMETERS_STATUS(ii(ii~=id));
		T.data = b;
	
	else
		
		% Nothing to delete, odata not here !
		
	end% if 

end%for iod

end %functiondelodata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
