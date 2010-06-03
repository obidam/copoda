% extract Extract values from a transect object
%
% [C [C1 C2 ...]] = extract(T,VARN,[CRITER,VARL])
% 
% Extract values C of variable VARN from transect object T according
% to selection criteria CRITER. It can also extract other variables
% specified in VARL and returned in C1, C2, etc ...
%
% Inputs:
%	T : a transect object
%	VARN (string): Any field from geo or data properties of T
%	CRITER (string): An expression to verify in order to select values.
%		Relational operators are:
% 		eq         - Equal                             == 
% 		ne         - Not equal                         ~= 
% 		lt         - Less than                          < 
% 		gt         - Greater than                       > 
% 		le         - Less than or equal                <= 
% 		ge         - Greater than or equal             >=
%	VARL (cell of strings): Other fields to extract
%	
% Ouput:
%	C (double) : Selected values as a 1xN array
%
% Possible variables to appear in VARN, VARL or CRITER are any of those from:
%	fieldnames(T.geo) % except 'MAX_PRESSURE' and 'POSITIONING_SYSTEM'
%	and
%	datanames(T)
%
% Examples:
%	C = extract(T,'TEMP'); % All temperatures
%	C = extract(T,'LATITUDE','LATITUDE > 20 & LATITUDE < 40 & LONGITUDE > 360-100 & LONGITUDE < 360'); % Latitudes within a box
%	C = extract(T,'DEPH','TEMP>20');
%	C = extract(T,'OXYK','TEMP>15 | DEPH>=-1000');
%	[Cz Cx Cy] = extract(T,'DEPH',{'LONGITUDE';'LATITUDE'});
%	
% Tricks:
%	- Outputs C are defined where none of the fields are NaN.
% 	- Positions are reversible for CRITER and VARL:
%		[Cz Cx Cy] = extract(T,'DEPH',{'LONGITUDE';'LATITUDE'},'TEMP>10');
% 		is similar to:
%		[Cz Cx Cy] = extract(T,'DEPH','TEMP>10',{'LONGITUDE';'LATITUDE'});
%	- Shortcuts for CRIT (not for VARN and VARL !) are available:
%		LON, LONG, X stand for LONGITUDE
%		LAT, Y stand for LATITUDE
%		DEPTH, X stand for DEPH
%		PRESS, P stand for PRES
%		TIME, T  stand for STATION_DATE
%		Example:
%			C = extract(T,'DEPH','Z > -1000 & T > datenum(2000,1,1,0,0,0)');
%			is similar to:
%			C = extract(T,'DEPH','DEPH > -1000 & STATION_DATE > datenum(2000,1,1,0,0,0)');
% 	- This will return the deepest sample for wich the Temperature is higher or equal to 20 degC
% 		min(extract(T,'DEPH','TEMP>=20')) 
% 	- Highlight a layer within a 3D view of the transect:
%		[Cz Cx Cy Ctemp] = extract(T,'DEPH',{'LONGITUDE';'LATITUDE';'TEMP'});
%		clf;plot3(Cx,Cy,Cz,'b.');hold on,xlabel('Long');ylabel('Lat');zlabel('Depth')
%		[Cz Cx Cy Ctemp] = extract(T,'DEPH',sprintf('TEMP>%0.1f-1&TEMP<%0.1f+1',nanmean(Ctemp),nanmean(Ctemp)),{'LONGITUDE';'LATITUDE';'TEMP'}); 
%		plot3(Cx,Cy,Cz,'r.'); grid on,box on
% 	- 3D view of the transect with a colorbar function of a the variable
%		[Cz Cx Cy C] = extract(T,'DEPH',{'LONGITUDE';'LATITUDE';'TEMP'});
%		clf;hold on
%		N = 10;
%		cx = linspace(nanmin(C),nanmax(C),N);
%		cmap=jet(N);colormap(cmap);caxis(cx([1 N]));
%		if length(C)>1000,dp=10;else,dp=1;end
%		for ip = 1 : dp : length(Cz)
%			p(ip) = plot3(Cx(ip),Cy(ip),Cz(ip),'.','color',cmap(find(cx>=C(ip),1),:));
%		end%for ip
%		xlabel('Long');ylabel('Lat');zlabel('Depth')
%		colorbar,grid on,box on,view(3)
%
%
% Created: 2009-09-20.
% Rev. by Guillaume Maze on 2009-09-21: Added multiple fields extraction option
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


function varargout = extract(T,varargin)

error(nargchk(1,3,nargin-1,'struct'));
switch nargin-1
	case 1
		varn1 = varargin{1};
		if ~ischar(varn1),error('2st argument must be a string');end
		if nargout == 0
			error(sprintf('Number of outputs must match number of fields extracted (here: N=1)'));
		end	
	case 2
		varn1 = varargin{1};
		if ~ischar(varn1),error('2st argument must be a string');end
		
		v2 = varargin{2};
		if ischar(v2)
			crite = varargin{2};
			if nargout == 0
				error(sprintf('Number of outputs must match number of fields extracted (here: N=1)'));
			end

		elseif iscell(v2)
			varnL = varargin{2};
			if nargout ~= 1+length(varnL)
				error(sprintf('Number of outputs must match number of fields extracted (here: N=%i)',1+length(varnL)));
			end
		else
			error('3rd argument must be a string (CRITER) or a cell (VARL)');
		end
	case 3
		varn1 = varargin{1};
		if ~ischar(varn1),error('2st argument must be a string');end
		
		v2 = varargin{2};
		v3 = varargin{3};
		if ischar(v2) & iscell(v3)
			crite = varargin{2};
			varnL = varargin{3};
		elseif iscell(v2) & ischar(v3) 
			varnL = varargin{2};
			crite = varargin{3};
		else
			error('3rd and 4th arguments must be a string (CRITER) or a cell (VARL)');
		end
		
		if nargout ~= 1+length(varnL)
			error(sprintf('Number of outputs must match number of fields extracted (here: N=%i)',1+length(varnL)));
		end
end%switch		


%%%%%%%%%%%%%%%%%%%%%% Extract with criteria:
if exist('crite')
	%%% Re-format the selection criteria to be performed:
	% (Eg: move 'TEMP > 20' to 'T.data.TEMP.cont' > 20)
	new_crite = reformat(T,crite);
%	disp(sprintf('Criteria: %s\nInterpreted as: %s',crite,new_crite));
	
	%%% Extract:
	C = 9999;	
	clear c
	try 	
		%%% Read original field:
		c = get_this(T,varn1,1);
		%%% Apply criteria:
		ii = find(double(eval(new_crite))==1);
		c = c(ii)';
		%%% Eventualy extract other fields:
		if exist('varnL','var')
			for iv = 1 : length(varnL)
				cL = get_this(T,varnL{iv},1);
				CL(iv,:) = cL(ii)';
			end%for iv			
		end%if
	catch
		l = lasterror;
		disp(sprintf('Error when extracting this:\n%s\n%s',new_crite,l.message));
		c = 9999;
		if exist('varnL','var')
			for iv = 1 : length(varnL)				
				CL(iv,:) = 9999;
			end%for iv		
		end%if
			
	end%try
	C = c(:)';


%%%%%%%%%%%%%%%%%%%%%% Extract ALL:
else	
	if ~exist('varnL','var')
		C = get_this(T,varn1,0);
		C = C(:)';
	%%% Eventualy extract other fields:
	else
		C = get_this(T,varn1,1);
		C = C(:)';
		for iv = 1 : length(varnL)
			cL = get_this(T,varnL{iv},1);
			CL(iv,:) = cL(:)';
		end%for iv	
	end%if
end %if


%%%%%%%%%%%%%%%%%%%%%% Format output:


if exist('varnL','var')
	
	str = 'ii = find( C~=9999 & isnan(C)==0 &';
	for iv = 1 :  size(CL,1)
		str = [str sprintf(' CL(%i,:) ~= 9999 & isnan(CL(%i,:))==0 &',iv,iv)];
	end
	str(end) = ')';
	str = [str ';'];
	eval(str);
	
	varargout(1) = {C(ii)};
	for iv = 1 : size(CL,1)
		varargout(iv+1) = {CL(iv,ii)};
	end%for iv

else

	ii = find(C~=9999 & isnan(C)==0);
	varargout(1) = {C(ii)};
	
end				

end %function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = get_this(T,varn,twoD)
%	stophere
	%%%%% Read field into c:
		geo_list = get_geo_list;
		%%% Is it a geo field ?		
		for iv = 1 : length(geo_list)
			if strfind(varn,geo_list{iv})
%				c = getfield(T.geo,varn);
				c = subsref(T,substruct('.','geo','.',varn));
				break
			end
		end
		%%% Otherwise it's a data:
		if ~exist('c','var')
%			c = getfield(T,'data',varn,'cont');
			c = subsref(T,substruct('.','data','.',varn,'.','cont'));
		end
	
	%%%%% Eventualy, adjust dimensions of c, must be n_prof x n_levels
		dlist = datanames(T); 
		[N_PROF N_LEVELS] = size(T); 
%		[N_PROF N_LEVELS] = size(getfield(T,'data',dlist{1})); % We suppose all datas are of similar dimensions       
		[n1 n2] = size(c);
		if n1 ~= N_PROF & n2 ~= N_LEVELS
			error(sprintf('%s of weird dimensions',varn))
		elseif n1 ~= N_PROF
			error(sprintf('Number of %s doesn''t match number of stations',varn))				            
		elseif n2 ~= N_LEVELS & twoD % Use meshgrid to move from n_PROF x 1 to n_prof x n_levels
	%		disp(sprintf('convert %s',geo_list{iv}))
			[c a] = meshgrid(c,1:N_LEVELS);c=c';
		end%if
	
end%function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function new_crite  = reformat(T,crite)
	
	geo_list  = get_geo_list;
%	new_crite = crite;
	new_crite = rm_shortcuts(crite);
	dlist = datanames(T); 
	[N_PROF N_LEVELS] = size(T);
%	[N_PROF N_LEVELS] = size(getfield(T.data,dlist{1})); % We suppose all datas are of similar dimensions
	
	%%% Adjust criteria with geo field:
	for iv = 1 : length(geo_list)
		if strfind(new_crite,geo_list{iv})		
%			c = getfield(T,'geo',geo_list{iv}); % Should be n_PROFx1 or n_profxn_levels
			c = subsref(T,substruct('.','geo','.',geo_list{iv})); % Should be n_PROFx1 or n_profxn_levels
			[n1 n2] = size(c);
			if n1 ~= N_PROF & n2 ~= N_LEVELS
				error(sprintf('%s of weird dimensions',geo_list{iv}))
			elseif n1 ~= N_PROF
				error(sprintf('Number of %s doesn''t match number of stations',geo_list{iv}))				
			elseif n2 ~= N_LEVELS % Use meshgrid to move from n_PROFx1 to n_profxn_levels
%				disp(sprintf('%s will be converted',geo_list{iv}))
				new_crite = strrep(new_crite,geo_list{iv},sprintf('meshgrid(T.geo.%s,1:%i)''',geo_list{iv},N_LEVELS));
			else
				% Geo field ok: n_prof x n_levels
				new_crite = strrep(new_crite,geo_list{iv},sprintf('T.geo.%s',geo_list{iv}));				
			end
		end%if
	end%for iv

	%%% Adjust criteria with data field:
	var_list = datanames(T);
	for iv = 1 : length(var_list)
		if strfind(new_crite,var_list{iv})
			new_crite = strrep(new_crite,var_list{iv},sprintf('T.data.%s.cont',var_list{iv}));
		end
	end%for iv

end%function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function C = rm_shortcuts(crite);	
	new_crite = crite;
	new_crite = strrep(new_crite,'(',' ( ');
	new_crite = strrep(new_crite,')',' ) ');
	new_crite = strrep(new_crite,'<',' <');
	new_crite = strrep(new_crite,'>',' >');
	new_crite = strrep(new_crite,'~',' ~');
	new_crite = strrep(new_crite,'=','= ');
	new_crite = strrep(new_crite,'= =','==');
	
	for ii=1:50
		new_crite = strrep(new_crite,'  ',' ');
	end
	s = strread(new_crite,'%s','delimiter',' ');
	C = '';
	for is = 1 : length(s)
		ch = s{is};
		if strcmp(ch,'LON') | strcmp(ch,'LONG') | strcmp(ch,'X'), ch = 'LONGITUDE';end
		if strcmp(ch,'T')   | strcmp(ch,'TIME'), ch = 'STATION_DATE';end
		if strcmp(ch,'LAT') | strcmp(ch,'Y'), ch = 'LATITUDE';end
		if strcmp(ch,'Z')   | strcmp(ch,'DEPTH'), ch = 'DEPH';end
		if strcmp(ch,'P')   | strcmp(ch,'PRESS'), ch = 'PRES';end		
		C = [C ' ' ch];
	end
	for ii=1:50
		C = strrep(C,'  ',' ');
	end
	
end%function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function geo_list = get_geo_list;
	geo_list = {'DEPH';'PRES';'LATITUDE';'LONGITUDE';'STATION_NUMBER';'STATION_DATE'};
end


