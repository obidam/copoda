% ship_code NODC Plotform (ship) code list
%
% SHIP_LIST = ship_code(STRING,[FIELD])
% 
% Look for STRING in NODC Platform (Ship) Code List.
%
% Input:
%	STRING is a string to be looked for in the database.
%	The search is case insensitive (everything moved to lower case when searched in).
%
%	Use STRING = 'update' to update from the web the data file (you need 'wget').
%
%	FIELD is a cell with 'NODC', 'WOD', 'CALL' and/or 'NAME' to restrict the search.
%
% Output:
%	SHIP_LIST is a cell with all matching ships.
%	SHIP_LIST(1,:) = {NODC_code ; WOD_code ; Call_sign ; Name};
%
% Note:
%	The database is located here:
%		copoda/utils/platformlist.mat
%	and created from downloading:
%		http://www.nodc.noaa.gov/General/NODC-Archive/platformlist.txt
%
% This file contains a list of platform (ship) names and the associated codes
% that are used by various data formats. The list is sorted by NODC Code,
% and contains a column for the NODC Code, the World Ocean Database (WOD) code,
% and the International Radio Call Sign.
%
% Source: http://www.nodc.noaa.gov/General/NODC-Archive/platformlist.txt
% http://www.meds-sdmm.dfo-mpo.gc.ca/meds/Prog_Int/J-COMM/CODES/wmotable_e.htm#ct1770 
%
% Created: 2009-09-22.
% Rev. by Guillaume Maze on 2010-04-28: Moved data file from copoda/data to copoda/utils
% Copyright (c) 2009 Guillaume Maze. 
% http://codes.guillaumemaze.org

%
% This program is free software: you can redistribute it and/or modify it under the 
% terms of the GNU General Public License as published by the Free Software Foundation, 
% either version 3 of the License, or any later version. This program is distributed 
% in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
% implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
% GNU General Public License for more details. You should have received a copy of 
% the GNU General Public License along with this program.  
% If not, see <http://www.gnu.org/licenses/>.
%

function varargout = ship_code(varargin)

% The database location:
filo = strrep(mfilename('fullpath'),'ship_code','platformlist.txt');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Update
if strcmp(varargin{1},'update')
	try 
		system(sprintf('wget -O %s "http://www.nodc.noaa.gov/General/NODC-Archive/platformlist.txt" ',filo));
		update_matfile(filo);
		disp(sprintf('NODC Platform (Ship) Code List successfully updated @ %s',filo));
		return
	catch
		error('Error when updating database from http://www.nodc.noaa.gov/General/NODC-Archive/platformlist.txt');
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Search
load(strrep(filo,'.txt','.mat'));
pattern = varargin{1};
wv = zeros(1,4);
if nargin == 2
	wh = varargin{2};
	if ~iscell(wh)==1,wh={wh};end
	for ii = 1 : length(wh)
		if strfind(wh{ii},'NODC'),wv(1) = 1;end
		if strfind(wh{ii},'WOD'), wv(2) = 1;end
		if strfind(wh{ii},'CALL'),wv(3) = 1;end
		if strfind(wh{ii},'NAME'),wv(4) = 1;end
	end
else
	wv = ones(1,4);
end
wv = find(wv==1);

ikeep = zeros(1,size(ship,1));
for iship = 1 : size(ship,1)
	for ii = 1 : length(wv)
		iv = wv(ii);
		k  = findstr(lower(clean(ship{iship,iv})),clean(lower(pattern)));
		if ~isempty(k)
			if nargout ==0 
				disp_ship(ship(iship,:));
			else
				ikeep(iship) = 1;
			end
		end
	end
end
if isempty(find(ikeep==1))
	ship = NaN;
else
	ship = ship(ikeep==1,:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Output
if nargout == 1
	varargout(1) = {ship};
end

end %function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function disp_ship(ship);
	disp(sprintf('NODC Code: %4s | WOD Code: %4s | Call sign: %s | Name: %s',ship{1},ship{2},...
	algn10(ship{3},'','left'),algn40(clean2(ship{4}),'','left')));
end

function str = algn40(str,sep,aln)
	str = [sep strjust(sprintf('%40s',str),aln) sep];
end %function

function str = algn10(str,sep,aln)
	str = [sep strjust(sprintf('%10s',str),aln) sep];
end %function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function ship = update_matfile(filo)
	
	fid = fopen(filo,'r');
	if fid<=0
		error(sprintf('Something''s wrong with the database file: %s',filo));
	end

	% Read the txt file and create the structure
	il = 0; iship = 0;
	iName = 22; % Position of the name (starts)
	iWOD  = 11; % Position of WOD (ends)
	while 1
		tline = fgetl(fid);
		if ~ischar(tline) %| il > 100
			break
		end
		if ~isempty(tline)
			il = il + 1;
			[a1 a2 a3 a4] = strread(tline,'%s%s%s%s');
			c = a1{1};
			if ~isempty(str2num(c(1))) % This is the only way I found to retain interesting lines with datas
				iship = iship + 1;
	%			disp(tline)
				% ship(iship).NODC_code = clean(tline(1:4)); % NODC_code
				% ship(iship).WOD_code  = clean(tline(5:iWOD)); % WOD_code
				% ship(iship).Call_sign = clean(tline(iWOD+1:iName-1)); % Call_sign
				% ship(iship).Name 	  = clean(tline(iName:end)); % Name
%				ship(iship,:) = {clean(tline(1:4)) ; clean(tline(5:iWOD)) ; clean(tline(iWOD+1:iName-1)) ; clean(tline(iName:end))};
				ship(iship,:) = {sprintf('%4s',clean(tline(1:4))) ; ...
								sprintf('%4s',clean(tline(5:iWOD))) ; ...
								sprintf('%10s',clean(tline(iWOD+1:iName-1))) ;...
								sprintf('%40s',clean2(tline(iName:end)))};
			end
		end
	end
	fclose(fid);
	save(strrep(filo,'.txt','.mat'),'ship');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function str = clean(str)
	for ii = 1 : 20
		str = strrep(str,' ','');
	end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function str = clean2(str)
	for ii = 1 : 20
		str = strrep(str,'  ',' ');
	end
end










