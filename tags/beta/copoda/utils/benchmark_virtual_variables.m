% benchmark_virtual_variables We test performance of virtual variables implementations
%
% [] = benchmark_virtual_variables()
% 
% We test performance of virtual variables implementations.
% We create a transect object with only Real datas and compare diagnostics and plots
% performance with a transect object using Virtual datas.
%
% Created: 2010-03-05.
% Copyright (c) 2010, Guillaume Maze (Laboratoire de Physique des Oceans).
% All rights reserved.
% http://codes.guillaumemaze.org

% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 	* Redistributions of source code must retain the above copyright notice, this list of 
% 	conditions and the following disclaimer.
% 	* Redistributions in binary form must reproduce the above copyright notice, this list 
% 	of conditions and the following disclaimer in the documentation and/or other materials 
% 	provided with the distribution.
% 	* Neither the name of the Laboratoire de Physique des Oceans nor the names of its contributors may be used 
%	to endorse or promote products derived from this software without specific prior 
%	written permission.
%
% THIS SOFTWARE IS PROVIDED BY Guillaume Maze ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, 
% INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Guillaume Maze BE LIABLE FOR ANY 
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
% LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
% BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, 
% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%

%function varargout = benchmark_virtual_variables(varargin)

% No AOU, no OXSL:
T = netcdf2transect(abspath('~/data/OVIDE/data/ovid02_dep.nc'));
[res T] = validate(T,1,1,[1 3 4 9 5 10]); % Make it ok without adding new fields

% Add solubility, real:
[res T2a] = validate(T,1,1,7);
% Add AOU, real:
[res T3a] = validate(T2a,1,1,6);

% Add solubility, virtual:
[res T2b] = validate(T,1,1,7); T2b.data.PARAMETERS_STATUS(end) = 'V';
% Add AOU, all virtual:
[res T3b] = validate(T2b,1,1,6); T3b.data.PARAMETERS_STATUS(end) = 'V';


%%%%%%%%%%%%%%%%%%%%% Test access to full content
nprof = T.cruise_info.N_STATION;
nlev  = size(T.geo.DEPH,2);
clear dt*

itest = 0; it = 0;
for iprof = 1 : 10 : nprof
	itest = itest+1;
	for iter = 1 : 20
		it = it + 1;
		nojvmwaitbar(length(1 : 10 : nprof)*20,it,'Testing access time to virtual variable content ...');
		if itest == 1
			t0 = now; c = T2a.data.OXSL.cont; dt0a(iter) = (now-t0)*86400;
			t0 = now; c = T2b.data.OXSL.cont; dt0b(iter) = (now-t0)*86400;
			t0 = now; c = T3a.data.AOU.cont;  dt1a(iter) = (now-t0)*86400;
			t0 = now; c = T3b.data.AOU.cont;  dt1b(iter) = (now-t0)*86400;
		end
	
		t0 = now; c = T2a.data.OXSL.cont(1:iprof,:); dt2a(itest,iter) = (now-t0)*86400;
		t0 = now; c = T2b.data.OXSL.cont(1:iprof,:); dt2b(itest,iter) = (now-t0)*86400;
		t0 = now; c = T3a.data.AOU.cont(1:iprof,:);  dt3a(itest,iter) = (now-t0)*86400;
		t0 = now; c = T3b.data.AOU.cont(1:iprof,:);  dt3b(itest,iter) = (now-t0)*86400;
	end%for iter
end%for iprof


for iter = 1 : 50
	iprof = randperm(nprof); iprof = iprof(1);
	t0 = now; c = T2a.data.OXSL.cont(iprof,:); dt4a(iter) = (now-t0)*86400;
	t0 = now; c = T2b.data.OXSL.cont(iprof,:); dt4b(iter) = (now-t0)*86400;
	t0 = now; c = T3a.data.AOU.cont(iprof,:);  dt5a(iter) = (now-t0)*86400;
	t0 = now; c = T3b.data.AOU.cont(iprof,:);  dt5b(iter) = (now-t0)*86400;
end%for iter


figure;hold on;figure_tall
iw=2;jw=1;ipl=0;

ipl=ipl+1;subplot(iw,jw,ipl);hold on
errorbar(1:10:nprof,nanmean(dt2b./dt2a,2),nanstd(dt2b./dt2a,1,2),'r')
errorbar(1:10:nprof,nanmean(dt3b./dt3a,2),nanstd(dt3b./dt3a,1,2),'k')
xlabel('Nb of profils loaded');
title('Virtual vs Real loading-time in % (y-axis) of n random profils (x-axis)','fontweight','bold');
grid on, box on
legend('O_2 solubility (1 virtual from 2 reals)','AOU (2 virtuals from 2 reals)',2)
set(gca,'ylim',[0 100]);

errorbar(nprof,nanmean(dt0b./dt0a),nanstd(dt0b./dt0a),'r')
errorbar(nprof,nanmean(dt1b./dt1a),nanstd(dt1b./dt1a),'k')

ipl=ipl+1;subplot(iw,jw,ipl);hold on
[h1 x1]=hist(dt4b./dt4a); h1 = h1./sum(h1)*100;
[h2 x2]=hist(dt5b./dt5a); h2 = h2./sum(h2)*100;
bar(x1,h1,'facecolor','r')
bar(x2,h2,'facecolor','k');
xlabel('Virtual vs Real loading-time in %');
ylabel('Probability among nb of tests');
title('Virtual vs Real loading-time in % (x-axis) of 1 random profil','fontweight','bold');
grid on, box on

suptitle('Virtual variables content access benchmark')

%end %functionbenchmark_virtual_variables











