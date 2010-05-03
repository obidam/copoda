% diagramTS_OXSL Plot a T,S diagram of Oxygen solubility
%
% [] = diagramTS_OXSL()
% 
% For reference purposes, this function plots 
% a T,S diagram of Oxygen solubility computed with
% sw_satO2 as:
%
% T = 273.15 + T * 1.00024; % convert T to Kelvin:
% % constants for Eqn (4) of Weiss 1970
% a1 = -173.4292;
% a2 =  249.6339;
% a3 =  143.3483;
% a4 =  -21.8492;
% b1 =   -0.033096;
% b2 =    0.014259;
% b3 =   -0.0017000;
% % Eqn (4) of Weiss 1970
% lnC = a1 + a2.*(100./T) + a3.*log(T./100) + a4.*(T./100) + ...
%       S.*( b1 + b2.*(T./100) + b3.*((T./100).^2) );
% O2sol = exp(lnC);
%
%
% Created: 2009-08-05.
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

function varargout = diagramTS_OXSL(varargin)


TEMP = [-1.5:1/10:40];
PSAL = [20:40];
[T S] = meshgrid(TEMP,PSAL);
OXSL = sw_satO2(S,T);

builtin('figure');hold on
[cs,h] = contourf(TEMP,PSAL,OXSL,[0:.1:20]);set(h,'edgecolor',[1 1 1]*.3);
[cs,h] = contour(TEMP,PSAL,OXSL,[0:.5:20]);set(h,'edgecolor','k');
clabel(cs,h,'rotation',0,'fontweight','bold')
grid on, box on
xlabel('Temperature (^oC)');
ylabel('Salinity (PSU)');
title('Solubility (saturation) of Oxygen in sea water in ml/l','fontweight','bold')
line([1 1]*mean(TEMP),get(gca,'ylim'),'color','r','linewidth',2)
line(get(gca,'xlim'),[1 1]*mean(PSAL),'color','r','linewidth',2)


end %function