% transect_demo Demonstration of a Transect object
%
% [] = transect_demo(i)
% 
% Launch transect demos:
% i = 1, 2 or 3
%
% Created: 2010-04-22.
% http://copoda.googlecode.com
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

function varargout = transect_demo(varargin)

if nargin ~= 1
	error('You must specify an example to run (1 to 3)')
end

EXAMPLE_i = varargin{1};
clc
switch EXAMPLE_i
	case 1, example_1;
	case 2, example_2;
	case 3, example_3;
end%switch



end %functiondemo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = example_1(varargin)
	
more on
	
disp(sprintf('\n============= EXAMPLE 1 =============\n'));
disp(sprintf('Let''s try to mimic a Transect object with OVIDE 2002 informations and datas.\n'))
disp(sprintf('============= EXAMPLE 1 =============\n'));

disp(sprintf('%% CREATE AN EMPTY DEFAULT TRANSECT OBJECT AND FILL IN BASIC PROPERTIES:'))
disp(sprintf('\tT = transect;'))
disp(sprintf('\tT.source = ''The best lab in the world !'';'))
disp(sprintf('\tT.creator = ''John Doe'';'))
disp(sprintf('\tT.file = ''no_source_file_at_this_point'';'))
disp(sprintf('\tT.file_date = datenum(1000,1,1,0,0,0);'))
disp(sprintf('\tT.created = now;'))

	
disp(sprintf('\n%% FILL IN CRUISE INFORMATIONS:'))
disp(sprintf('\tT.cruise_info = cruise_info(''NAME'',''OVIDE 2002'',''PI_NAME'',''H. Mercier'',...\n\t\t''PI_ORGANISM'',''LPO-CNRS'',''SHIP_NAME'',''Thalassa'',''SHIP_WMO_ID'',''FNFP'',...\n\t\t''DATE'',[datenum(2002,6,18,0,0,0) datenum(2002,7,10,0,0,0)],''N_STATION'',100);'));

disp(sprintf('\n%% FILL IN AXIS INFORMATIONS:'))
disp(sprintf('%% NOTE THAT WE ENSURE THAT ALL FIELDS ARE IN THE FORM N_STATIONS X N_LEVELS OR N_STATIONS X 1'))
disp(sprintf('\tT.geo.STATION_NUMBER = [1:100]'';'));
disp(sprintf('\tT.geo.STATION_DATE   = linspace(datenum(2002,6,18,0,0,0),datenum(2002,7,10,0,0,0),100)'';'));
disp(sprintf('\tT.geo.LATITUDE       = linspace(40.3,59.8,100)''; %% We approximate the cruise track by a straight line'));
disp(sprintf('\tT.geo.LONGITUDE      = linspace(350.5,317.4,100)'';'));
disp(sprintf('\tT.geo.POSITIONING_SYSTEM = ''GPS'';'));
disp(sprintf('\tT.geo.PRES         = meshgrid(1035*9.8*[0:10:5330]/10000,1:100); %% A sample every 10dbar between the surface and 5330db'));
disp(sprintf('\tT.geo.MAX_PRESSURE = 1035*9.8*5330/10000*ones(100,1); %% Flat bottom'));
disp(sprintf('\tT.geo.DEPH         = meshgrid(0:-10:-5330,1:100);'));

disp(sprintf('\n%% FILL IN DATAS:'))
disp(sprintf('\tLet''s first simulate a temperature field:'));
disp(sprintf('\t\t cont = meshgrid(linspace(2,1,100),1:534)''.*meshgrid(1+20*exp(T.geo.DEPH(1,:)/5e2),1:100);'));
disp(sprintf('\tWe can now use the classic following structure assignment:'))
disp(sprintf('\t\tT.data = struct(''TEMP'',odata(''name'',''TEMP'',''long_name'',''Temperature'',''unit'',''degC'',''cont'',cont));'));
disp(sprintf('\tBut this method may be risky because it overwrites the default data property.'))
disp(sprintf('\tSo, we will use the simpler form making use of the COPODA function setodata:'))
disp(sprintf('\t\tT = setodata(T,''TEMP'',odata(''name'',''TEMP'',''long_name'',''Temperature'',''unit'',''degC'',''cont'',cont));'));
disp(sprintf('\tAnd then remove empty variables created by default constructor:'));
disp(sprintf('\t\tT = clean_empty_variables(T);'))
	
disp(sprintf('\n\n%% NOW LET''S SEE WHAT WE CREATED'))
disp(sprintf('\n\nPress any key to continue ...'));
T = transect;
T.source = 'The best lab in the world !';
T.creator = 'John Doe';
T.file = 'no_source_file_at_this_point';
T.file_date = datenum(1000,1,1,0,0,0);
T.created = now;
T.cruise_info = cruise_info('NAME','OVIDE 2002','PI_NAME','H. Mercier','PI_ORGANISM','LPO-CNRS','SHIP_NAME','Thalassa','SHIP_WMO_ID','FNFP','DATE',[datenum(2002,6,18,0,0,0) datenum(2002,7,10,0,0,0)],'N_STATION',100);

T.geo.STATION_NUMBER = [1:100]';
T.geo.STATION_DATE = linspace(datenum(2002,6,18,0,0,0),datenum(2002,7,10,0,0,0),100)';
T.geo.LATITUDE = linspace(40.3,59.8,100)';
T.geo.LONGITUDE = linspace(350.5,317.4,100)';
T.geo.POSITIONING_SYSTEM = 'GPS';
T.geo.PRES = meshgrid(1035*9.8*[0:10:5330]/10000,1:100);
T.geo.MAX_PRESSURE = 1035*9.8*5330/10000*ones(100,1);
T.geo.DEPH = meshgrid(0:-10:-5330,1:100);

cont = meshgrid(linspace(2,1,100),1:534)'.*meshgrid(1+20*exp(T.geo.DEPH(1,:)/5e2),1:100);
% T.data = struct('TEMP',odata('name','TEMP','long_name','Temperature','unit','degC','cont',cont));
T = setodata(T,'TEMP',odata('name','TEMP','long_name','Temperature','unit','degC','cont',cont));
T = clean_empty_variables(T);

%stophere

pause;clc;
disp(sprintf('\n%% THE DISPLAY FROM: >> T'))
	T
disp(sprintf('\n\nPress any key to continue ...'));pause;clc;	

disp(sprintf('\n%% THE DISPLAY FROM: >> whos T\n'))
	whos T	
disp(sprintf('\n%% WE DO SEE HERE THAT THE CLASS OF T IS TRANSECT AND THAT THE SIZE INDICATES N_STATIONS X N_LEVELS\n'))
disp(sprintf('\n\nPress any key to continue ...'));pause;clc


disp(sprintf('\n\n%% YOU CAN NOW USE SPECIFIC TRANSECT METHODS TO CHECK OUT THE CONTENT, FOR EXAMPLE:'));
disp(sprintf('\n\n%% PLOT THE CRUISE TRACK COLORED BY THE STATION DATES:'));
disp(sprintf('\tplot(T,''track'')'));
	plot(T,'track')	
	disp(sprintf('\n\nPress any key to continue ...'));pause;	
	
disp(sprintf('\n\n%% PLOT THE TEMPERATURE FIELD:'));
disp(sprintf('\tplot(T,''TEMP'')'));
	plot(T,'TEMP')
	disp(sprintf('\n\nPress any key to continue ...'));pause;
	
disp(sprintf('\n\n%% SIMPLY CALL ''PLOT'' WITHOUT ARGUMENTS TO SEE WHAT''S AVAILABLE IN T:'));
disp(sprintf('%% DISPLAY FROM: >> plot(T)\n'))
	plot(T)
	
disp(sprintf('\n\n%% AND THAT''S IT FOR THIS EXAMPLE.\n'));

s = input(sprintf('Do you want to retrieve the Transect object we just created in your workspace (y/[n]) ?\n'),'s');
if lower(s) == 'y',assignin('base','T',T); disp('T is now in your workspace'); end
	
more off	
end%Function



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = example_2(varargin)
more on

disp(sprintf('\n============= EXAMPLE 2 =============\n'));
disp(sprintf('Let''s again try to mimic a Transect object with OVIDE 2002 informations and datas.\nThis time we will create preliminary structures and fill the Transect properties\nat the end. We also make use of a virtual variable: the oxygen solubility.\n'))
disp(sprintf('============= EXAMPLE 2 =============\n'));

disp(sprintf('%% CRUISE INFORMATIONS INTO VARIABLE C (A CRUISE_INFO CLASS INSTANCE):'))
disp(sprintf('\tC = cruise_info(''NAME'',''OVIDE 2002'',...'));
disp(sprintf('\t\t''PI_NAME'',''H.Mercier'',''PI_ORGANISM'',''LPO-CNRS'',...'));
disp(sprintf('\t\t''SHIP_NAME'',''Thalassa'',''SHIP_WMO_ID'',''FNFP'',...'));
disp(sprintf('\t\t''DATE'',[datenum(2002,6,18,0,0,0) datenum(2002,7,10,0,0,0)],''N_STATION'',100);'));

disp(sprintf('\n%% CREATE THE AXES INFO STRUCTURE geoinfo:'));
disp(sprintf('%% NOTE THAT WE ENSURE THAT ALL FIELDS ARE IN THE FORM N_STATIONS X N_LEVELS OR N_STATIONS X 1'))
disp(sprintf('\tgeoinfo.STATION_NUMBER = [1:100]'';'));
disp(sprintf('\tgeoinfo.STATION_DATE   = linspace(datenum(2002,6,18,0,0,0),datenum(2002,7,10,0,0,0),100)'';'));
disp(sprintf('\tgeoinfo.LATITUDE       = linspace(40.3,59.8,100)''; %% We approximate the cruise track by a straight line'));
disp(sprintf('\tgeoinfo.LONGITUDE      = linspace(350.5,317.4,100)'';'));
disp(sprintf('\tgeoinfo.POSITIONING_SYSTEM = ''GPS'';'));
disp(sprintf('\tgeoinfo.PRES         = meshgrid(1035*9.8*[0:10:5330]/10000,1:100); %% A sample every 10dbar between the surface and 5330db'));
disp(sprintf('\tgeoinfo.MAX_PRESSURE = 1035*9.8*5330/10000*ones(100,1); %% Flat bottom'));
disp(sprintf('\tgeoinfo.DEPH         = meshgrid(0:-10:-5330,1:100);'));

disp(sprintf('\n%% DATAS INTO VARIABLE dat:'));
disp(sprintf('\t%% CREATE AN ODATA OBJECT FOR TEMPERATURE:'));
disp(sprintf('\t\tt = odata(''name'',''TEMP'',''long_name'',''Temperature'',''unit'',''degC'',...'));
disp(sprintf('\t\t\t''cont'',meshgrid(linspace(2,1,100),1:534)''.*meshgrid(1+20*exp(geoinfo.DEPH(1,:)/5e2),1:100));'));

disp(sprintf('\t%% CREATE AN ODATA OBJECT FOR SALINITY:'));
disp(sprintf('\t\ts = odata(''name'',''PSAL'',''long_name'',''Salinity'',''unit'',''psu'',...'));
disp(sprintf('\t\t\t''cont'',35.5*ones(100,534));'));

disp(sprintf('\t%% CREATE AN EMPTY ODATA OBJECT FOR OXYGEN SOLUBILITY:'));
disp(sprintf('\t\tsl = odata(''name'',''OXSL'',''long_name'',''Oxygen Solubility'',''unit'',''ml/l'');'));

disp(sprintf('\t%% CREATE THE dat STRUCTURE:'));
disp(sprintf('\t\tdat = struct(''TEMP'',t,''PSAL'',s,''OXSL'',sl);'));

disp(sprintf('\n%% NOW WE CREATE THE TRANSECT OBJECT:'));
disp(sprintf('\t T = transect(''source'',''The best lab in the world !'',''creator'',''John Doe'',...'));
disp(sprintf('\t\t''file'',''no_source_file_at_this_point'',''file_date'',datenum(1000,1,1,0,0,0),...'));
disp(sprintf('\t\tcruise_info'',C,''geo'',geoinfo,''data'',dat);'));

disp(sprintf('\n\n%% NOW LET''S SEE WHAT WE CREATED'))
disp(sprintf('\n\nPress any key to continue ...'));

C = cruise_info('NAME','OVIDE 2002',...
'PI_NAME','H.Mercier','PI_ORGANISM','LPO-CNRS',...
'SHIP_NAME','Thalassa','SHIP_WMO_ID','FNFP',...
'DATE',[datenum(2002,6,18,0,0,0) datenum(2002,7,10,0,0,0)],'N_STATION',100);

geoinfo.STATION_NUMBER = [1:100]';
geoinfo.STATION_DATE = linspace(datenum(2002,6,18,0,0,0),...
datenum(2002,7,10,0,0,0),100)';
geoinfo.LATITUDE = linspace(40.3,59.8,100)';
geoinfo.LONGITUDE = linspace(350.5,317.4,100)';
geoinfo.POSITIONING_SYSTEM = 'GPS';
geoinfo.PRES = meshgrid(1035*9.8*[0:10:5330]/10000,1:100);
geoinfo.MAX_PRESSURE = 1035*9.8*5330/10000*ones(100,1);
geoinfo.DEPH = meshgrid(0:-10:-5330,1:100);

t = odata('name','TEMP','long_name','Temperature','unit','degC','cont',...
meshgrid(linspace(2,1,100),1:534)'.*meshgrid(1+20*exp(geoinfo.DEPH(1,:)/5e2),1:100));
s = odata('name','PSAL','long_name','Salinity','unit','psu','cont',...
35.5*ones(100,534));
sl = odata('name','OXSL','long_name','Oxygen Solubility','unit','ml/l');
dat = struct('TEMP',t,'PSAL',s,'OXSL',sl);

T = transect('source','The best lab in the world !','creator','John Doe',...
'file','no_source_file_at_this_point','file_date',datenum(1000,1,1,0,0,0),...
'cruise_info',C,'geo',geoinfo,'data',dat);

pause;clc;
disp(sprintf('\n%% THE DISPLAY FROM: >> whos'));
	whos
disp(sprintf('\n%% WE DO SEE HERE THE CLASS ODATA FOR t, s and sl'));
disp(sprintf('%% T IS A TRANSECT CLASS AND ITS SIZE INDICATES N_STATIONS X N_LEVELS (SAME AS t and s)'))
disp(sprintf('%% dat AND geoinfo ARE CLASSIC STRUCTURES, AND C IS A CRUISE_INFO CLASS'));		
disp(sprintf('\n\nPress any key to continue ...'));pause;clc;

disp(sprintf('\n%% LET''S LOOK AT THE DISPLAY FROM: >> T'))
	T
disp(sprintf('\n%% THE EMPTY VARIABLE OXSL (CONTENT OF ODATA OBJECT sl WAS SET TO NOTHING) HAS A REAL STATUS'))
disp(sprintf('%% AND THEREFORE IS IN THE EMPTY DATA LIST.'))
disp(sprintf('\n\nPress any key to continue ...'));pause;clc;

disp(sprintf('\n%% A MORE SYNTHETIC WAY TO LOOK AT A TRANSECT OBJECT DATAS IS TO CALL: >> disp(T,3)'));
	disp(T,3);
disp(sprintf('\n%% LET''S CHANGE THE OXSL STATUS TO ''VIRTUAL'' USING THE DSTATUS FUNCTION:'));
disp(sprintf('\t T.data.PARAMETERS_STATUS(dstatus(T,''OXSL'',1))=''V'';'));
	T.data.PARAMETERS_STATUS(dstatus(T,'OXSL',1))='V';
disp(sprintf('\n%% AND LOOK AGAIN AT THE DISPLAY FROM: >> disp(T,3)'))
	disp(T,3);
disp(sprintf('%% BECAUSE OXSL IS VIRTUAL, MATLAB KNOWS HOW TO COMPUTE IT IF ASKED TO,\n%% AND THEREFORE CONSIDER THE VARIABLE TO NOT BE EMPTY ANYMORE.'));

disp(sprintf('\n\nPress any key to continue ...'));pause;clc;

disp(sprintf('\n%% LET''S NOW LOOK AT THE MEMORY SIZE OF THE TRANSECT OBJECT:\n'));
	whos T
	w=whos('T');
disp(sprintf('\n%% WHICH INDICATES %i BYTES.',w.bytes));
disp(sprintf('%% IF WE CHANGE THE OXSL STATUS BACK TO ''REAL'' MATLAB WILL AUTOMATICALLY FILL THE CONTENT BECAUSE IT KNOWS HOW:'));
disp(sprintf('\t T.data.PARAMETERS_STATUS(dstatus(T,''OXSL'',1))=''R'';'));
disp(sprintf('\t disp(T,3)'))
	T.data.PARAMETERS_STATUS(dstatus(T,'OXSL',1))='R';
	disp(T,3);
disp(sprintf('\n%% LET''S AGAIN LOOK AT THE MEMORY SIZE OF THE TRANSECT OBJECT:\n'));
	whos T
	w=whos('T');
disp(sprintf('\n%% IT NOW INDICATES %i BYTES.',w.bytes));	
disp(sprintf('%% IF WE SET AGAIN THE OXSL STATUS TO ''VIRTUAL'', WE''LL GET BACK TO THE PREVIOUS CASE WITH LESS MEMORY'));

disp(sprintf('\n\n%% AND THAT''S IT FOR THIS EXAMPLE.\n'));
s = input(sprintf('Do you want to retrieve the Transect object we just created in your workspace (y/[n]) ?\n'),'s');
if lower(s) == 'y',assignin('base','T',T); disp('T is now in your workspace'); end


more off	
end%Function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = example_3(varargin)
more on

disp(sprintf('\n============= EXAMPLE 3 =============\n'));
disp(sprintf('The transect/validate method\n'));
disp(sprintf('============= EXAMPLE 3 =============\n'));


C = cruise_info('NAME','OVIDE 2002',...
'PI_NAME','H.Mercier','PI_ORGANISM','LPO-CNRS',...
'SHIP_NAME','Thalassa','SHIP_WMO_ID','FNFP',...
'DATE',[datenum(2002,6,18,0,0,0) datenum(2002,7,10,0,0,0)],'N_STATION',100);

geoinfo.STATION_NUMBER = [1:100]';
geoinfo.STATION_DATE = linspace(datenum(2002,6,18,0,0,0),...
datenum(2002,7,10,0,0,0),100)';
geoinfo.LATITUDE = linspace(40.3,59.8,100)';
geoinfo.LONGITUDE = linspace(350.5,317.4,100)';
geoinfo.POSITIONING_SYSTEM = 'GPS';
geoinfo.PRES = meshgrid(1035*9.8*[0:10:5330]/10000,1:100);
geoinfo.MAX_PRESSURE = 1035*9.8*5330/10000*ones(100,1);
geoinfo.DEPH = meshgrid(0:-10:-5330,1:100);

t = odata('name','TEMP','long_name','Temperature','unit','degC','cont',...
meshgrid(linspace(2,1,100),1:534)'.*meshgrid(1+20*exp(geoinfo.DEPH(1,:)/5e2),1:100));
s = odata('name','PSAL','long_name','Salinity','unit','psu','cont',...
35.5*ones(100,534));
sl = odata('name','OXSL','long_name','Oxygen Solubility','unit','ml/l');
dat = struct('TEMP',t,'PSAL',s,'OXSL',sl);

T = transect('source','The best lab in the world !','creator','John Doe',...
'file','no_source_file_at_this_point','file_date',datenum(1000,1,1,0,0,0),...
'cruise_info',C,'geo',geoinfo,'data',dat);

T.data.PARAMETERS_STATUS(dstatus(T,'OXSL',1))='V';

disp(sprintf('%% WE USE THE TRANSECT OBJECT CREATED BY EXAMPLE 2:'))
	T
disp(sprintf('\n\nPress any key to continue ...'));pause;clc;
	
disp(sprintf('\n%% LET''S RUN THE VALIDATE METHOD ON IT:'))
disp(sprintf('\t validate(T)\n'))
disp(sprintf('%% WILL PRINT:'))
	validate(T)

disp(sprintf('%% THE VALIDATION IS A SUCCESS !'))	
disp(sprintf('\n\nPress any key to continue ...'));pause;clc;

disp(sprintf('\n%% LET''S NOW TRY TO FIX IT AND GET THE FIXED TRANSECT INTO Tfixed:'))
disp(sprintf('\t [result Tfixed] = validate(T,1,1)\n'))
disp(sprintf('%% WILL PRINT:'))
	[result Tfixed] = validate(T,1,1);
	result

disp(sprintf('%% IT''S AGAIN A SUCCESS AND NOTE THAT WE CREATED THE SIG0 VARIABLE:\n\tdisp(Tfixed,3)'))
	disp(Tfixed,3)

disp(sprintf('%% TO BE COMPARED WITH THE INITIAL TRANSECT T:\n\tdisp(T,3)'))
	disp(T,3)

disp(sprintf('\n\nPress any key to continue ...'));pause;clc;

disp(sprintf('\n%% NOW IMAGINE YOUR PROFILES ARE NOT SORTED BY DATES AND YOU WANT THEM TO BE.'));
disp(sprintf('%% LET''S FIRST SHAKE THE ORDER OF STATIONS FROM THE PREVIOUS TRANSECT OBJECT TFIXED TO SIMULATE A MESSED TRANSECT:\n'));
disp(sprintf('\t Tfixed.geo.STATION_NUMBER(1:10)'' %% These are sorted:'));
	Tfixed.geo.STATION_NUMBER(1:10)'
disp(sprintf('\t ii = randperm(size(Tfixed,1));'));
disp(sprintf('\t Tfixed = squeeze(Tfixed,ii); %% Here, we rearrange the stations order (help validate/squeeze for more details)'));
disp(sprintf('\t Tfixed.geo.STATION_NUMBER(1:10)'' %% These are not sorted any more:'));
	ii = randperm(size(Tfixed,1));
	Tfixed = squeeze(Tfixed,ii);
	Tfixed.geo.STATION_NUMBER(1:10)'
disp(sprintf('\n%% AND TRY TO VALIDATE Tfixed (ONLY THE TEST ID#3):\n'))
	disp(sprintf('\t [result Tfixed_again] = validate(Tfixed,1,1,3)'));
	[result Tfixed_again] = validate(Tfixed,1,1,3);
	result
disp(sprintf('%% SO LET''S LOOK AT THE STATION_NUMBER AGAIN:\n'))
disp(sprintf('\t Tfixed_again.geo.STATION_NUMBER(1:10)'' %% These are sorted again:'));
	Tfixed_again.geo.STATION_NUMBER(1:10)'

disp(sprintf('\n\nPress any key to continue ...'));
	

more off
end%function






