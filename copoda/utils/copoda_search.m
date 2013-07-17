% copoda_search Search for a string in COPODA matlab files
%
% copoda_search(PATTERN), prettyprints search results of PATTERN into
% all matlab files from the path of COPODA.
% 
% See also: copoda_path
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
function varargout = copoda_search(varargin)

pattern = varargin{1};

plist = strread(copoda_path,'%s','delimiter',':');

ii = 0;
N = 0;
t0 = now;
for ip = 1 : length(plist)
	mlist = dir(fullfile(plist{ip},'*.m'));
	for im = 1 : length(mlist)
		N = N + 1;
		mfile = fullfile(plist{ip},mlist(im).name);
		tline = readh1line(mfile);
		if ischar(tline)
			is  = strfind(lower(tline),lower(pattern));
%			is  = regexp(lower(tline),lower(pattern));
			if ~isempty(is)
				[pa na ex] = fileparts(mfile);
				ii = ii + 1;
				RESULT(ii).file = mfile;
				RESULT(ii).path = pa;
				RESULT(ii).name = na;
				RESULT(ii).ext    = ex;
%				RESULT(ii).h1line = tline;
				RESULT(ii).h1line = regexprep(tline,sprintf('(\\w*)%s(\\w*)',pattern),sprintf('$1[%s]$2',pattern),'ignorecase');
				if ~isempty(strfind(mfile,'@'))
					class_name = mfile(strfind(mfile,'@'):end);
					RESULT(ii).name = fullfile(fileparts(class_name),na);
				end% if 
			end% if 
		end% if 
	end% for im
end% for ip

if ~exist('RESULT','var')
	disp('No results');
	return
end% if 

NR = length(RESULT);

% Display results:
n = get(0,'commandWindowSize');
res = sprintf('Found %i result(s) in %i files related to COPODA',NR,N);
tim = stralign(n(1)-length(res)-1,sprintf('(in %0.4f seconds)',(now-t0)*86400),'left');
disp(sprintf('\n%s %s\n',res,tim))
for ifct = 1 : length(RESULT)
	disp(sprintf('%s: %s (%s)',stralign(20,RESULT(ifct).name,'left'),stralign(50,RESULT(ifct).h1line,'left'),RESULT(ifct).file));
end


end %functioncopoda_search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function tl = readh1line(mfile)

	[pa na ex] = fileparts(mfile);

	done = 0;
	fid = fopen(mfile,'r');
	fseek(fid,0,'bof');
	il = 0;
	tl = '';
	while done ~= 1
		tline = fgetl(fid);
		if ischar(tline)
			tl = strtrim(tline);
			if ~isempty(tl)
				if tl(1) == '%'
					tl = tl(2:end);
					tl = strtrim(tl);
					tl = tl(max([1 min(strfind(tl,' '))]):end);
					% tl = strrep(tl,sprintf('%% %s',na),'');
					% tl = strrep(tl,sprintf('%%%s' ,na),'');
					% tl = strrep(tl,sprintf('%%%s' ,upper(na)),'');
					% tl = strrep(tl,sprintf('%% %s',upper(na)),'');
					% tl = strrep(tl,sprintf('%%%s' ,lower(na)),'');
					% tl = strrep(tl,sprintf('%% %s',lower(na)),'');
					% tl = regexprep(tl,sprintf('(\\w*)%%%s(\\w*)',na),'','ignorecase');
					tl = strtrim(tl);
					done = 1;				
				end
			else
				done = 1;
			end
		else
			done = 1;
		end% if 
	end% end while
	fclose(fid);


end %functionreadh1line
