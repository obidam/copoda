% help Provide some helpful commands to look at a database object
%
% [] = help(DATABASE_OBJ)
% 
% Provide some helpful commands to look at a database object
%
% Created: 2009-11-10.
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


function varargout = help(varargin)

dname = inputname(1);
D = varargin{1};
%% Get the list of variables:
vlist = datanames(D);
nt = length(D);

clc;
disp(sprintf('\n\t\tYOU CAN TYPE THESE COMMANDS TO START LOOKING AT THE DATABASE: %s\n',D.name));


%%
disp('- Basic informations about the database:');
disp(sprintf('\theader(%s)',dname));
disp(sprintf('\t[Ntransects Nstations Nsamples] = length(%s)',dname));
disp(' ');

disp('- List transect(s) datas:');
disp(sprintf('\tdatanames(%s,0) %% Full list -> union list (default) ',dname));
disp(sprintf('\tdatanames(%s,1) %% Only variables available in all transects -> intersect list',dname));
disp(' ');

disp('- Try to validate the database through a list of different tests:');
disp(sprintf('\tvalidate(%s,1)',dname));
disp(' ');


%%
disp('- Plot stations locations on a map:');
disp(sprintf('\ttracks(%s,0) %% Plot all transects on 1 map with 1 color per cruise',dname));
disp(sprintf('\ttracks(%s,1) %% Plot all transects on 1 map with color function of time range (default)',dname));
disp(sprintf('\ttracks(%s,2) %% Plot on 1 figure, 1 transect per subplots',dname));
disp(' ');


%%
disp('- Plot variables histograms:');
for ii = 1 : length(vlist)
	disp(sprintf('\tplot(%s,''%s'')',dname,vlist{ii}))
	if ii == 4
		disp(sprintf('\tetc ...'));break;
	end
end
disp(sprintf('  YOU MAY ALSO TRY:\n\tplot(%s,''time'') %% to look at the number of samples versus time',dname));
disp(' ');

%%
disp('- Plot scatter plot of paired variables, for example:');
ieg = 0;
vlista = vlist;
vlistb = vlist;
for iva = 1 : length(vlista)
	for ivb = 1 : length(vlistb)
		if ~strcmp(vlista{iva},vlistb{ivb})
			ieg = ieg + 1;
			if ieg == 5, break,end
			disp(sprintf('\tplot(%s,''%s'',''%s'')',dname,vlista{iva},vlistb{ivb}));			
		end
	end
	if ieg == 5, disp(sprintf('\tetc ...'));break; end	
	vlistb = vlistb(2:end);
end
disp(' ');

%%
disp('- Simple access to the content of one transect, for example:')
ii = max([fix(nt/2) 1]);
disp(sprintf('\tT = %s.transect{%i} %% will extract the transect #%i of the database into the transect object T',dname,ii,ii));
disp(sprintf('\t%s = %s.transect{%i}.data.%s %% will extract the odata object %s from the transect #%i',lower(vlist{1}),dname,ii,vlist{1},vlist{1},ii));
disp(' ');

%%
if ~isempty(vlist)
	disp('- Advanced direct and selective access to data values, for example:')
	disp(sprintf('\t%s = extract(%s,''%s''); %% will return all database values of %s as 1xN double matrix',lower(vlist{1}),dname,vlist{1},vlist{1}));
	disp(sprintf('\t[%s Cz Cx Cy] = extract(%s,''%s'',{''DEPH'',''LONGITUDE'',''LATITUDE''}); %% will also return coordinates as 1xN double matrices',lower(vlist{1}),dname,vlist{1}));
	disp(sprintf('\t%s = extract(%s,''%s'',''DEPH>=-1000 & LATITUDE >= 50''); %% will extract samples only for DEPH>=-1000 and LATITUDE >= 50',lower(vlist{1}),dname,vlist{1}));
	disp(sprintf('\thelp transect/extract %% Type this for an extensive help on the extract subfunction'));
	disp(' ');
end




end %functionhelp



















