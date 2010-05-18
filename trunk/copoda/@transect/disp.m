% disp Display informations about a transect object
%
% [] = disp(T,[FORMAT])
% 
% T is the transect informations are taken from.
% FORMAT determined how informations are being display.
%	1: Short
%	2: Long
%	3: Only datas
%
%
% Created: 2009-07-28.
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


function varargout = disp(Tlist,varargin)

forma = 1; % Default view is short
if nargin == 2
	forma = varargin{1};
	if isempty(find([1 2 3]-forma==0))
		error('Bad format')
	end
end

for iT = 1 : length(Tlist)
	T = Tlist(iT);
	
switch forma
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LONG
	case 2
%		disp('#################################################################################################')
		disp(' ')
		disp('============================== TRANSECT OBJECT CONTENT DESCRIPTION ==============================');
%		disp('#################################################################################################')
		disp(' ')
		disp_field(T);
		disp(' ')
		disp('1) ================================== GENERAL INFORMATIONS ======================================');
		disp_prop('Source',T.source);
		disp_prop('Creator',T.creator);
		disp_prop('File',strrep(T.file,getenv('HOME'),'~'));
		disp_prop('Created',datestr(T.created));
		disp_prop('Modified',datestr(T.modified));
		disp('2) =================================== CRUISE INFORMATIONS ======================================');
		disp_cruise(T.cruise_info);
		disp('3) ==================================== AXES INFORMATIONS =======================================');
		disp_geo(T.geo);
		disp('4) ==================================== DATA INFORMATIONS =======================================');
		disp_data(T);
		disp('#################################################################################################')
		
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SHORT
	case 1
%		disp('#################################################################################################')
		disp(' ')
		disp('============================== TRANSECT OBJECT CONTENT DESCRIPTION ==============================');
%		disp('#################################################################################################')
		disp(' ')
		disp_field(T);
		disp(' ')
		disp('1) ================================== GENERAL INFORMATIONS ======================================');
		disp_prop('Source',T.source);
		disp_prop('Creator',T.creator);		
		disp_prop('File',strrep(T.file,getenv('HOME'),'~'));
		disp_prop('Created',datestr(T.created));
		disp_prop('Modified',datestr(T.modified));
		disp('2) =================================== CRUISE INFORMATIONS ======================================');
		disp_cruise(T.cruise_info);
		disp('3) ==================================== AXES INFORMATIONS =======================================');
		disp_geo(T.geo);
		disp('4) ======================================== DATA LIST ===========================================');
		disp_data_short(T);
%		disp('#################################################################################################')
		disp(' ')
		disp('Try disp(T,2) for a more extensive description of datas for this transect object')
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ONLY DATAS
	case 3
		disp(' ')
		disp(sprintf('===== DATA LIST FOR TRANSECT OBJECT FROM %s: %s (%s)',T.cruise_info.NAME,T.source,T.creator));
		disp_data_short(T);
		disp(' ')
	
end %switch

end

end %function




%%%%%%%%%%%%%%%%%%%
function str = disp_field(T)
	fi = fieldnames(T); 
	str = sprintf('Informations obtained from subfields: %s,',fi{1});
	for ii = 2 : size(fi,1)-1
		if (length(str)+length(fi{ii}))>97, str = sprintf('%s\n',str);end
		str = sprintf('%s %s,',str,fi{ii});
	end
	str = sprintf('%s and %s.',str,fi{end});
	disp(str);
end


%%%%%%%%%%%%%%%%%%%
function varargout = disp_prop(name,value)
	blk = ' ';	
	disp(sprintf('%5s %20s: %s',blk,name,value));	
end

%%%%%%%%%%%%%%%%%%%% 
function varargout = disp_data(A)

	f = datanames(A);
	if isnumeric(f)
		disp_prop('','No filled datas !');
	else
		for iv = 1 : size(f,1)
			v = getfield(A.data,f{iv});
			if isa(v,'odata')
				if ~isempty(v.cont) & (~isempty(v.name) | ~isempty(v.long_name))
					v
				else
					disp_prop(cell2mat(f(iv)),'Empty');
				end
			end
		end
	end

end


%%%%%%%%%%%%%%%%%%%% 
function varargout = disp_data_short(A)
	
	% We now make a disctinction between Real data with NaN and the others.
	% A Real data with a NaN is data not defined, while a Virtual data has a content set to NaN
	
	f = datanames(A,1);
	if isnumeric(f)
		disp_prop('','No filled datas !');
	else
		for iv = 1 : length(f)
			v = getfield(A.data,f{iv});
			switch dstatus(A,f{iv})
				case 'R'
					disp_prop(sprintf('%i (%s, Real)',iv,f{iv}),sprintf('[%s] %s',v.name,v.long_name));
				case 'V'
					disp_prop(sprintf('%i (%s, Virt)',iv,f{iv}),sprintf('[%s] %s',v.name,v.long_name));
				otherwise
					error(sprintf('%s has an unexpected status (must be R or V)',v.name));
			end
		end
	end
	try
		if isnumeric(f)
			f = '';
		end
		f = setdiff(datanames(A,0),f);
		if (iscell(f) & ~isempty(f)) | (isnumeric(f) & ~isnan(f))
			disp_prop('Found empty datas - ','-');			
			for iv = 1 : length(f)
				v = getfield(A.data,f{iv});
				switch dstatus(A,f{iv})
					case 'R'
						disp_prop(sprintf('%i (%s, Real)',iv,f{iv}),sprintf('[%s] %s',v.name,v.long_name));
					case 'V' % We shouldn't be here !
						disp_prop(sprintf('%i (%s, Virt)',iv,f{iv}),sprintf('[%s] %s',v.name,v.long_name));
					otherwise
						error(sprintf('%s has an unexpected status (must be R or V)',v.name));
				end
			end
		end%if empty
	end%try
end


%%%%%%%%%%%%%%%%%%%% 
function varargout = disp_geo(A)
	
	blk = ' ';
	if ~isempty(A.LATITUDE)
		disp_prop('Latitude range',sprintf('From %2.1fN to %2.1fN',...
											min(A.LATITUDE),max(A.LATITUDE)));
	end 
	if ~isempty(A.LONGITUDE)
		disp_prop('Longitude range',sprintf('From %2.1fE to %2.1fE',...
											min(A.LONGITUDE),max(A.LONGITUDE)));
	end	
	if ~isempty(A.DEPH)
		disp_prop('Depth range',sprintf('From %2.1fm to %2.1fm',...
											max(max(A.DEPH)),min(min(A.DEPH))));
	end
	if ~isempty(A.STATION_DATE)
		disp_prop('Date range',sprintf('From %s to %s (%3.0f days)',...
					datestr(min(A.STATION_DATE),'mmm. dd yyyy'),...
					datestr(max(A.STATION_DATE),'mmm. dd yyyy'),...
					max(A.STATION_DATE)-min(A.STATION_DATE)))
	end
	
end

%%%%%%%%%%%%%%%%%%%% This one should be a copy of @cruise_info/display.m
function varargout = disp_cruise(C)

blk = ' ';
	if ~isempty(C.NAME),   disp_prop('Name',C.NAME);end
	if ~isempty(C.PI_NAME) 
		if ~isempty(C.PI_ORGANISM)
			disp_prop('PI (Affiliation)',sprintf('%s (%s)',C.PI_NAME,C.PI_ORGANISM));
		else
			disp_prop('PI',C.PI_NAME);
		end
	end
	if ~isempty(C.SHIP_NAME)
		if ~isempty(C.SHIP_WMO_ID)
			disp_prop('Ship (WMO ID)',sprintf('%s (%s)',C.SHIP_NAME,C.SHIP_WMO_ID));
		else
			disp_prop('Ship',C.SHIP_NAME);
		end
	end
	if ~isempty(C.DATE)
		disp_prop('Date',sprintf('From %s to %s (%3.0f days)',...
					datestr(min(C.DATE),'mmm. dd yyyy'),...
					datestr(max(C.DATE),'mmm. dd yyyy'),diff(C.DATE)));
	end
	if ~isempty(C.N_STATION)
		disp_prop('Number of station(s)',num2str(C.N_STATION))
	end
end


