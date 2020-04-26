clear; close all;

trajType = 'acc'; % for given acceleration constraints 

% https://jp.mathworks.com/matlabcentral/fileexchange/16352-advanced-setpoints-for-motion-systems
pos = 1;
vmax = 0.5;
amax = 0.75;
jmax = 2;
[tmake3,dd] = make3(pos,vmax,amax,jmax);
[jj,tx,j,a,v,p,tt] = profile3(tmake3,dd,tmake3(1)*1e-2,false);

tstart = 0.5;
BCt = [tstart, tstart + tt];
BCt = [BCt,BCt+BCt(end)]; % go and back
amax2 = tmake3(1)*jmax; % modified max acc
BCa = [0, 0, amax2, amax2, 0, 0, -amax2, -amax2, 0];
BCa = [BCa, -BCa];

% polynomial order for acceleration trajectory
np = 1;

% Polynomial Trajectory generation
BC = cell(2,1);
BC{1} = 0; % initial position
BC{2} = 0; % initial velocity
BC{3} = BCa; % acceleration boundary conditions
pBasis = backandforth(trajType,BCt,BC,np,false);

%% Plot
Ts = 1e-3;
t = 0:Ts:8;
y1 = outPolyBasis(pBasis,1,t);
y2 = outPolyBasis(pBasis,2,t);
y3 = outPolyBasis(pBasis,3,t);
y4 = outPolyBasis(pBasis,4,t);

hfig = figure;
subplot(2,2,1);
plot(t,y1,'b'); hold on;
xlabel('time [s]');
title('position');
subplot(2,2,2);
plot(t,y2,'b'); hold on;
plot([t(1),t(end)],[vmax,vmax],'r--');
plot([t(1),t(end)],[-vmax,-vmax],'r--');
ylim([-0.6,0.6])
xlabel('time [s]');
title('velocity');
subplot(2,2,3);
plot(t,y3,'b'); hold on;
plot([t(1),t(end)],[amax,amax],'r--');
plot([t(1),t(end)],[-amax,-amax],'r--');
xlabel('time [s]');
title('acceleration');
subplot(2,2,4);
plot(t,y4,'b'); hold on;
plot([t(1),t(end)],[jmax,jmax],'r--');
plot([t(1),t(end)],[-jmax,-jmax],'r--');
ylim([-2.5,2.5])
xlabel('time [s]');
title('jerk');

% FigTools required
% https://github.com/ThomasBeauduin/FigTools
if exist('pubfig','file')
    pfig = pubfig(hfig);
    expfig('ex5','-png');
end

