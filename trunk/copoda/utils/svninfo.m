% svninfo Retrieve Distribution information from svn info command
%
% NEWS = svninfo(PATH_UNDER_SVN_CONTROL)
% 
% Retrieve distribution information from svn info command.
% Go to PATH_UNDER_SVN_CONTROL, then run 'svn info --xml' and returns
% all informations.
%
% Outputs:
%
%
% Created: 2010-05-27.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = svninfo(varargin)

if nargin ~= 1
	error('You must specify a folder under svn control')
end

pathsvn = varargin{1};
d = dir(fullfile(pathsvn,'.svn'));
if isempty(d)
	error(sprintf('svn: ''%s'' is not a working copy',pathsvn));
end

[st res] = system(sprintf('svn info %s --xml',pathsvn));

try
	a = res(strfind(res,'<entry')+6:end); a = a(1:min(strfind(a,'>'))-1);
	b = a(strfind(a,'kind="')+6:end); b = b(1:min(strfind(b,'"'))-1);
	svn.entry.kind = b;

	b = a(strfind(a,'path="')+6:end); b = b(1:min(strfind(b,'"'))-1);
	svn.entry.path = b;

	b = a(strfind(a,'revision="')+10:end); b = b(1:min(strfind(b,'"'))-1);
	svn.entry.revision = b;

	svn.url = res(strfind(res,'<url>')+5:strfind(res,'</url>')-1);

	repo = res(strfind(res,'<repository>')+12:strfind(res,'</repository>')-1);
	svn.repository.root = repo(strfind(repo,'<root>')+6:strfind(repo,'</root>')-1);
	svn.repository.uuid = repo(strfind(repo,'<uuid>')+6:strfind(repo,'</uuid>')-1);

	varargout(1) = {svn};

catch
	varargout(1) = {'?'};
end



end %functionsvninfo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% <?xml version="1.0"?>
% <info>
% 	<entry kind="dir" path="." revision="16">
% 		<url>https://copoda.googlecode.com/svn/trunk</url>
% 		<repository>
% 			<root>https://copoda.googlecode.com/svn</root>
% 			<uuid>904b3b22-837f-9646-09c2-551967d61ab2</uuid>
% 		</repository>
% 		<wc-info>
% 			<schedule>normal</schedule>
% 			<depth>infinity</depth>
% 		</wc-info>
% 		<commit revision="7">
% 			<author>maze.guillaume</author>
% 			<date>2010-05-03T10:53:13.913727Z</date>
% 		</commit>
% 	</entry>
% </info>







