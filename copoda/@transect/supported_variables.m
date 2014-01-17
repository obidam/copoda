%supported_variables List supported variables in Transect object property data
%
% L = supported_variables(T) return the list of all supported variables as a cell
%	array of strings. 
% 
% supported_variables(T,'html') print the list of all supported variables
%	as a HTML table in a file named 'supported_variables.html' in the 
% 	current folder.
% 
% supported_variables(T,'t') pretty print the list of all supported variables
% 	in the command window. No output.
% 
% od = supported_variables(T,'odata',VARNAME) return the default odata object
% 	for the variable VARNAME which must be in the default list of supported 
% 	variables, otherwise an error is thrown.
% 
% Rev. by Guillaume Maze on 2013-07-26: Completed help and added the default 
% 	'odata' object retrieval possibility.
% Created: 2010-04-20.
% http://copoda.googlecode.com
% Copyright 2010, COPODA

%TODO The term 'variables' is not consistent with the term 'parameter' employed elsewhere in the framework.
%TAGS variable,parameter,supported,defined,documented,user-level

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


function varargout = supported_variables(T,varargin)

dl = data_list;
if isfield(dl,'STATION_PARAMETERS')
	dl = rmfield(dl,'STATION_PARAMETERS');
end
if isfield(dl,'PARAMETERS_STATUS')
	dl = rmfield(dl,'PARAMETERS_STATUS');
end
dl = orderfields(dl);
dn = fieldnames(dl);

% Output format:
typ = '';
switch nargin-1
	case 1
		typ = varargin{1};
	case 2
		typ = varargin{1};
		varname = varargin{2};
end% switch 

% Short cuts
if strcmp(typ,'odata')
	[a iv] = intersect(dn,varname); clear a
	if isempty(iv)
		error(sprintf('%s is not a supported variable for transect objects',varname));
	else
		od = getfield(dl,varname);
		varargout(1) = {od};
		return
	end% if 
end% if 

% Init output:
switch typ
	case ''
		% Nothing to do here
	case 'html'
		output_file = 'supported_variables.html';
		global diag_screen_default
		diag_screen_default.PIDlist = [2];
		fid = fopen(output_file,'w');
		diag_screen_default.fid = fid;
		diag_screen_default.forma = '%s\n';
		diag_screen(sprintf('<div align="center">'));
		diag_screen(sprintf('\t<table border="1" bordercolor="#000000" cellpadding="3" cellspacing="0">'));
		diag_screen(sprintf('\t\t<tbody>'));
		diag_screen(sprintf('\t\t<tr>'));
		diag_screen(sprintf('\t\t\t<td> Property </td>'));
		diag_screen(sprintf('\t\t\t<td> Variable name (short/long) </td>'));
		diag_screen(sprintf('\t\t\t<td> Variable unit (short/long) </td>'));
		diag_screen(sprintf('\t\t</tr>'));
	case 't'
		disp(sprintf('\n%s: %s [%s] in %s [%s]\n','TRANSECT DATA PROPERTY FIELD NAME','LONG NAME','NAME','LONG UNIT','UNIT'));		
end


% Print/save/select output:
for iv = 1 : length(dn)
	od = getfield(dl,dn{iv});
	switch typ
		case 'html'
			diag_screen(sprintf('\t\t<tr>'));
			diag_screen(sprintf('\t\t\t<td>'));
			diag_screen(sprintf('\t\t\t\t %s',dn{iv}));
			diag_screen(sprintf('\t\t\t</td>'));
			diag_screen(sprintf('\t\t\t<td>'));
			diag_screen(sprintf('\t\t\t\t %s<br>%s',od.name,od.long_name));
			diag_screen(sprintf('\t\t\t</td>'));
			diag_screen(sprintf('\t\t\t<td>'));
			diag_screen(sprintf('\t\t\t\t %s<br>%s',od.unit,od.long_unit));
			diag_screen(sprintf('\t\t\t</td>'));
			diag_screen(sprintf('\t\t</tr>'));		
		case 't'
			disp(sprintf('%33s: %s [%s] in %s [%s]',dn{iv},od.long_name,od.name,od.long_unit,od.unit));
	end
end

% Finish ouput
switch typ
	case 'html'
		diag_screen(sprintf('\t\t</tbody>'));
		diag_screen(sprintf('\t</table>'));	
		diag_screen(sprintf('</div>'));
		disp(sprintf('List of supported variables printed in file: %s',output_file));
	case ''
		varargout(1) = {dn};
end

end %functionsupported_variables











