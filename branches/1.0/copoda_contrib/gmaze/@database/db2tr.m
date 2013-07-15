% db2tr Transform a database into a transect object
%
% T = db2tr(D)
% 
% Transform a database into a transect object
%
% Inputs:
%
% Outputs:
%
%
% Created: 2011-10-18.
% http://code.google.com/p/copoda
% Copyright 2011, COPODA

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
function varargout = db2tr(D)

%- First we need to identify all fields from geo and data properties:
for iT = 1 : length(D)
	if iT == 1
		GEOlist = fieldnames(D.transect{iT}.geo);
	else
		GEOlist = union(GEOlist,fieldnames(D.transect{iT}.geo));
	end% if
	if iT == 1
		ODlist = fieldnames(D.transect{iT}.data);
	else
		ODlist = union(ODlist,fieldnames(D.transect{iT}.data));
	end% if
	% station dates:
	t(iT,:) = D.transect{iT}.cruise_info.DATE;
	[np nl] = size(D.transect{iT});
	if iT == 1
		IND(iT,1:2) = [1,np];
	else
		IND(iT,1) = IND(iT-1,2) + 1; 
		IND(iT,2) = IND(iT-1,2) + np; 
	end% if
	nplist(iT) = size(D.transect{iT},1);
	if iT == 1
		INDz(iT,1:2) = [1,nl];
	else
		INDz(iT,1) = 1; 
		INDz(iT,2) = nl; 
	end% if
	nzlist(iT) = size(D.transect{iT},2);
end% for iT
ODlist = setdiff(ODlist,{'PARAMETERS_STATUS';'STATION_PARAMETERS'});

%- Dimensions:
Np = size(D,2);
nl = max(nzlist);

%- Init transect:
T = transect;

%- cruise_info:
C = cruise_info; % (no arguments) creates a default cruise_info object
C.N_STATION = Np;
C.DATE = [min(t(:,1)) max(t(:,2))];
T.cruise_info = C;

%- geo:
%-- Must be there:
[Xp Yp] = coord(D);
geo.LONGITUDE = Xp;
geo.LATITUDE  = Yp;
geo.STATION_NUMBER = [1:Np]';
geo.STATION_DATE = zeros(Np,1)*NaN;

%-- Custom geo fields:
GEOcustomlist = setdiff(GEOlist,fieldnames(T.geo));

%-- Add geo variables:
for iT = 1 : length(D)
	thisT = D.transect{iT};
	n = length(thisT.geo.STATION_DATE);
	geo.STATION_DATE(IND(iT,1):IND(iT,2),1) = thisT.geo.STATION_DATE;
	geo.PRES(IND(iT,1):IND(iT,2),INDz(iT,1):INDz(iT,2)) = thisT.geo.PRES;
	geo.DEPH(IND(iT,1):IND(iT,2),INDz(iT,1):INDz(iT,2)) = thisT.geo.DEPH;
	geo.PRES(IND(iT,1):IND(iT,2),INDz(iT,2)+1:nl) = NaN;
	geo.DEPH(IND(iT,1):IND(iT,2),INDz(iT,2)+1:nl) = NaN;
	for icust = 1 : length(GEOcustomlist)
		eval(sprintf('C = thisT.geo.%s;',GEOcustomlist{icust}));
		[a b] = size(C);
		if b == 1
			eval(sprintf('geo.%s(IND(iT,1):IND(iT,2),1) = C;',GEOcustomlist{icust}));
		elseif b == nzlist(iT)
			eval(sprintf('geo.%s(IND(iT,1):IND(iT,2),INDz(iT,1):INDz(iT,2)) = C;',GEOcustomlist{icust}));		
			try
				eval(sprintf('geo.%s(IND(iT,1):IND(iT,2),INDz(iT,2)+1:nl) = NaN;',GEOcustomlist{icust}));		
			end
		end% if 
	end% for icust
	% Add one more field to secure the transect name
	geo.WMO(IND(iT,1):IND(iT,2),1) = {thisT.cruise_info.SHIP_WMO_ID};
end% for iT
T.geo = geo;

%- Add odata:
for iv = 1 : length(ODlist)
%	disp(ODlist{iv});
	eval(sprintf('od = D.transect{1}.data.%s;',ODlist{iv}));		
	for iT = 1 : length(D)
		thisT = D.transect{iT};
		eval(sprintf('C = thisT.data.%s.cont;',ODlist{iv}));
		[a b] = size(C);
		if b == 1
			if iT==1
				eval(sprintf('tmp_%s = zeros(Np,1)*NaN;',ODlist{iv}));
			end% if
			eval(sprintf('tmp_%s(IND(iT,1):IND(iT,2),1) = C;',ODlist{iv}));
		elseif b == nzlist(iT)
			if iT==1
				eval(sprintf('tmp_%s = zeros(Np,nl)*NaN;',ODlist{iv}));
			end% if
			eval(sprintf('tmp_%s(IND(iT,1):IND(iT,2),INDz(iT,1):INDz(iT,2)) = C;',ODlist{iv}));		
		end% if			
	end% for iT
	eval(sprintf('od.cont = tmp_%s;',ODlist{iv}));		
	T = setodata(T,ODlist{iv},od);	
end% for iv

%- Output:
T = clean_empty_variables(T);
% sort by date:
[a it] = sort(T.geo.STATION_DATE); clear a;
T = squeeze(T,it);
varargout(1)  = {T};

end %functiondb2tr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



























