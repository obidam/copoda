% cpd_tags Search tags in COPODA
%
% [] = cpd_tags([TAGS_LIST])
% 
% HELP TEXT
%
% Inputs:
%
% Outputs:
%
%
% Created: 2013-12-31.
% http://code.google.com/p/copoda
% Copyright 2013, COPODA

% Tags for documentation:
%TAGS user-level,search,help,tags

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
function varargout = cpd_tags(varargin)

%- 
t0 = now;
%pattern = varargin{1};

%- 
plist = strread(copoda_path,'%s','delimiter',':');

%- List all tags by files:
NS = 0;
N = 0;
for ip = 1 : length(plist)
	mlist = dir(fullfile(plist{ip},'*.m'));
	for im = 1 : length(mlist)
		mfile  = fullfile(plist{ip},mlist(im).name);
		h1line = readh1line(mfile);
		these_tags = unique(mtags(mfile));
		NS = NS + 1;
		if ~isempty(these_tags)
			N = N + 1;			
			RESULT(N,1) = {mlist(im).name};
			RESULT(N,2) = {these_tags};
			RESULT(N,3) = {h1line};
			
			RESULT(N,4) = {''};
			if ~isempty(strfind(mfile,'@'))
				class_name = fileparts(mfile(strfind(mfile,'@'):end));
				RESULT(N,4) = {class_name(2:end)};
			end% if

		end% if 
	end% for im
end% for ip
if ~exist('RESULT','var')
	disp('No results');
	return
end% if 
clear ip im mlist mfile h1line these_tags

%- List unique tags:
TAGS  = RESULT{1,2};
FILES = RESULT(1,1);
for in = 2 : N
	TAGS = union(TAGS,RESULT{in,2});
	FILES = cat(1,FILES,RESULT{in,1});
end% for in
clear in
TAGS = sort(TAGS'); 

%- Create file index of tags:
INDEX = sparse(N,length(TAGS));
for in = 1 : N
	[these_tags icols] = intersect(TAGS,RESULT{in,2});
	INDEX(in,icols) = 1;
end% for ifile
clear in icols these_tags

%stophere

%-
if nargin == 1
	%stophere
	pattern = varargin{1};
	if ischar(pattern)
		%pattern = {pattern};
	end% if 
	pattern = lower(pattern);
	icol    = find(~cellfun('isempty', strfind(lower(TAGS), pattern)));
	[in ic] = find(INDEX(:,icol)==1);
	RESULT = RESULT(in,:);
	N = length(in);
	
	%- Display results:
	% Print header
	n = get(0,'commandWindowSize');
	res = sprintf('Found this tag %i times in %i files related to COPODA',N,NS);
	tim = stralign(n(1)-length(res)-1,sprintf('(in %0.4f seconds)',(now-t0)*86400),'left');
	disp(sprintf('\n%s %s\n',res,tim))

	% Print list of results, sorted by class
	class_list = {'database','transect','cruise_info','odata',''};
	for icl = 1 : length(class_list)
		found = false;
		for ifct = 1 : N
			if strcmp(RESULT{ifct,4},class_list{icl})
				if ~found
					found = true;
					if strcmp(class_list{icl},'')
						disp(sprintf('COPODA functions:'));
					else
						disp(sprintf('Methods for class %s:',class_list{icl}));
					end% if 
				end% if 
			%	disp(sprintf('%s: %s (%s)',stralign(20,RESULT(ifct).name,'left'),stralign(50,RESULT(ifct).h1line,'left'),RESULT(ifct).file));
				disp(sprintf('\t%s: %s',stralign(20,RESULT{ifct,1},'left'),stralign(50,RESULT{ifct,3},'left')));
			end% if 
		end% for ifct
	end% for icl
	
	
	return
end% if 


% Display results:
n = get(0,'commandWindowSize');
res = sprintf('Found %i result(s) in %i files related to COPODA',NR,N);
tim = stralign(n(1)-length(res)-1,sprintf('(in %0.4f seconds)',(now-t0)*86400),'left');
disp(sprintf('\n%s %s\n',res,tim))
for ifct = 1 : length(RESULT)
	disp(sprintf('%s: %s (%s)',stralign(20,RESULT(ifct).name,'left'),stralign(50,RESULT(ifct).h1line,'left'),RESULT(ifct).file));
end



end %functioncpd_tags
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
