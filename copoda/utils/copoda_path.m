% copoda_path Create the list of folders related to COPODA
%
% COPODA_PATH, by itself, prettyprints COPODA's current search path.
%
% P = COPODA_PATH returns a string containing the path in P.
% 
% Created: 2013-07-17.
% http://code.google.com/p/copoda
% Copyright 2013, COPODA

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
function varargout = copoda_path(varargin)

%
ii = 0;

copoda_root = strrep(fileparts(which('transect')),'@transect','');
copoda_root = strrep(copoda_root,fullfile('copoda',filesep),'');

% Classes:
ii=ii+1; plist(ii) = {fileparts(which('odata'))};
ii=ii+1; plist(ii) = {fileparts(which('cruise_info'))};
ii=ii+1; plist(ii) = {fileparts(which('transect'))};
ii=ii+1; plist(ii) = {fileparts(which('database'))};

% Folders:
ii=ii+1; plist(ii) = {fullfile(copoda_root,'copoda')};
ii=ii+1; plist(ii) = {fullfile(copoda_root,'copoda','utils')};
ii=ii+1; plist(ii) = {fullfile(copoda_root,'copoda','transcripts')};

% Users contrib:
user_list = get_list_of_contrib_folders(copoda_root);
for iu = 1 : length(user_list)
	ii=ii+1; plist(ii) = {user_list{iu}};
	
	more_list = {'@odata';'@cruise_info';'@transect';'@database'};
	for im = 1 : length(more_list)
		if exist(fullfile(user_list{iu},more_list{im}))
			ii=ii+1; plist(ii) = {fullfile(user_list{iu},more_list{im})};
		end% if
	end% for im 
	
end% for ii

%
switch nargout
	case 0
		disp(sprintf('\n\t\tPATH COPODA\n'));
		for ii = 1 : length(plist)
			disp(sprintf('\t%s',plist{ii}));
		end% for ii
	case 1
		p = plist{1};
		for ii = 2 : length(plist)
			p = sprintf('%s:%s',p,plist{ii});
		end% for ii
		varargout(1) = {p};
	otherwise
		error('Bad number of output');
end% switch 


end %functioncopoda_path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flist = get_list_of_contrib_folders(copoda_root);
	
	contribH = fullfile(copoda_root,'copoda_contrib');
	
	ic = 0;
	if exist(contribH,'dir')
		contrib_list = dir(contribH);
		for ii = 1 : length(contrib_list)
			if contrib_list(ii).isdir & ~strcmp(contrib_list(ii).name,'.') & ~strcmp(contrib_list(ii).name,'..') & ~strcmp(contrib_list(ii).name,'.svn')
				ic = ic + 1;
				flist(ic) = {fullfile(contribH,contrib_list(ii).name)};
			end
		end
	end
	if ic == 0 
		flist = {};
	end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
