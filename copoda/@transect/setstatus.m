% setstatus Set the status of an odata object in a transect data property
%
% T = setstatus(T,VARNAME,STATUS)
% 
% Set the status of variable(s) given by VARNAME (odata fields in transect.data)
% to STATUS.
%
% Inputs:
%	T: Transect object
%	VARNAME: a cell of strings or a string with the transect.data property name(s) of
%		odata object(s), ie anyone return by datanames(T)
%	STATUS: a string with 'R' or 'V' to indicate the status of variables given by VARNAME
%		If more than one variables are given by VARNAME and length of STATUS is 1, all
%		variables status will be set to STATUS.
%
% Outputs:
%	T: Update transect object
%
% Eg:
%	T = setstatus(T,'OXYK','V');
%	T = setstatus(T,{'OXYK';'OXSL'},'V');
%
% Created: 2010-06-08.
% http://code.google.com/p/copoda
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
function T = setstatus(T,VARNAME,STATUS)

if ischar(VARNAME)
	VARNAME = {VARNAME};
end
if length(VARNAME) ~= length(STATUS) & length(STATUS) ~= 1
	error('STATUS must be of length 1 or defined for each VARNAME')
end

for iv = 1 : length(VARNAME)
	try 
		id = dstatus(T,VARNAME{iv},1);
		if length(STATUS) == 1
			T = setfield(T,'data','PARAMETERS_STATUS',{id},STATUS(1));
		else
			T = setfield(T,'data','PARAMETERS_STATUS',{id},STATUS(iv));
		end
	catch
		error(sprintf('%s not defined in this transect data property',VARNAME{iv}));
	end
end%for iv
	

end %functionsetstatus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%














