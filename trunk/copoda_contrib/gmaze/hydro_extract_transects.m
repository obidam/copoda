% hydro_extract_transects H1LINE
%
% IND = hydro_extract_transects(CRUISE,X,Y)
% 
% From the CRUISE file name, and tracks latitude/longitude
% this function extract indices of interesting legs
%
%
% Created: 2009-06-16.
% Copyright (c) 2009 Guillaume Maze. 
% http://codes.guillaumemaze.org

%
% This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or any later version.
% This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
% You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

function varargout = hydro_extract_transects(varargin)

cruise = varargin{1};
x = varargin{2};
y = varargin{3};	
	
switch cruise
	case '06MT18_1'  % A01E (1991)
		x0 = 360-42.5;
		y0 = 60;
		ii(1).val = select_1transect(x,y,x0,y0,200,180);
		
	case '06MT30_3'  % A01E (1994)
		x0 = 360-42.5;
		y0 = 60;
		ii(1).val = select_1transect(x,y,x0,y0);
		
	case '74DI230_1' % A25 (1997)
		x0 = 360-42.5;
		y0 = 60;
		ii(1).val = select_1transect(x,y,x0,y0);	
			
	case '64TR91_1' % AR07E (1991)		
		x0 = 360-42.5; y0 = 60;
		ii(1).val = select_1transect(x,y,x0,y0);
					
	case '74AB62_1' % AR07E (1991)	
		% North Leg:
		x0 = 360-42.5; y0 = 60; 
		ii1 = select_1transect(x,y,x0,y0);
		x0 = 360-10; y0 = 55; 
		ii2 = select_1transect(x,y,x0,y0);
		ii(1).val = sort([ii1 ii2]);

		% South Leg:
		nokeep = zeros(1,length(x));
		ii1 = select_1transect(x,y,360-30,56); % to be removed
		ii2 = select_1transect(x,y,360-20,53,200,90); % to be removed
		ij     = find(x<=360-29.9 & x>=360-30.1);
		[a ia] = min(y(ij));
		ii3     = find(x<=360-29.9 & x>=360-30.1 & y~=y(ij(ia)));
		ij     = find(x<=360-19.9 & x>=360-20.1);
		[a ia] = min(y(ij));
		ii4     = find(x<=360-19.9 & x>=360-20.1 & y~=y(ij(ia)));
		for ipt = 1 : length(x)
			if find(ii1==ipt),nokeep(ipt) = 1;end % remove part of 30W
			if find(ii2==ipt),nokeep(ipt) = 1;end % remove part of 20W
			if find(ii3==ipt),nokeep(ipt) = 1;end % remove rest of 30W
			if find(ii4==ipt),nokeep(ipt) = 1;end % remove rest of 20W
			if find(ii(1).val==ipt),nokeep(ipt) = 1;end % Remove 1st leg
		end
		[a ik] = find(nokeep==0);		
		ii(2).val = ik;

	case '06AZ129_1' % AR07E (1992)	
		ii(1).val = 1:length(x);		
		
	case 'Meteor 395' % AR07E (1997)
		x0 = 360-42.5;
		y0 = 60;
		ii1 = select_1transect(x,y,360-42.5,60); % to keep		
		ii2 = select_1transect(x,y,360-30,51); % to be removed
		ii3 = select_1transect(x,y,360-22,51); % to be removed
		nokeep = zeros(1,length(x));
		for ipt = 1 : length(x)
			if find(ii2==ipt),nokeep(ipt) = 1;end
			if find(ii3==ipt),nokeep(ipt) = 1;end
		end
		for ipt = 1 : length(x)
			if find(ii1==ipt),nokeep(ipt) = 0;end
		end
		ij = find(x>=360-21 & y>53);
		nokeep(ij) = 1;
		[a ik] = find(nokeep==0);
		ii(1).val = ik;
		
	case 'Meteor 39/4' % METEOR394 (1997)
		x0 = 360-42.5;	y0 = 60;
		ii(1).val = select_1transect(x,y,x0,y0);	

		x0 = 360-43;	y0 = 59.2;
		ii(2).val = select_1transect(x,y,x0,y0,200);		

		x0 = 360-49;	y0 = 61;
		ii(3).val = select_1transect(x,y,x0,y0,200,180);					

	case 'Lazier - 95011' % HUDSON95011 (1995)
		x0 = 360-42.5;	y0 = 60;
		ii(1).val = select_1transect(x,y,x0,y0);

		x0 = 360-49; y0 = 61;	
		ii(2).val = select_1transect(x,y,x0,y0,100,180);


	case 'Knorr 147-2' % KNORR147 (1996)
		x0 = 360-42.5;	y0 = 60;
		ii(1).val  = select_1transect(x,y,x0,y0);			

		x0 = 360-40;	y0 = 65;
		ii(2).val  = select_1transect(x,y,x0,y0);
			
	case 'OVIDE 02' % OVIDE (2002)
		x0 = 360-42.5;	y0 = 60;
		ii(1).val = select_1transect(x,y,x0,y0,100,180);
					
	case 'OVIDE 04' % OVIDE (2004)
		x0 = 360-42.5;	y0 = 60;
		ii(1).val = select_1transect(x,y,x0,y0,100,360);						
		
	case 'OVIDE 06' % OVIDE (2006)
		x0 = 360-42.5;	y0 = 60;
		ii(1).val = select_1transect(x,y,x0,y0,100,360);

end


switch nargout
	case 1
		varargout(1) = {ii};
		
	otherwise
		cmap(1,:) = [1 0 0];
		cmap(2,:) = [1 0 1];
		cmap(3,:) = [0 0 1];
		figure; hold on
		m_proj('equid','lon',[nanmin(x) nanmax(x)] + [-1 1],'lat',[nanmin(y) nanmax(y)] + [-1 1]);
		pp = m_plot(x,y,'+','markersize',10);
		for isec = 1 : size(ii,2)
			p = m_plot(x(ii(isec).val),y(ii(isec).val),'rp'); 
			set(p,'markersize',8,'color',cmap(isec,:));			
		end
		m_coast('patch',[1 1 1]*.6);m_grid('xtick',[0:5:360],'ytick',[-90:5:90]);
		m_elev('contour',[-4:-1]*1e3,'edgecolor',[1 1 1]*.5);
end





end %function