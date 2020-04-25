% clear; close all;

trajType = 'jrk'; % for given acceleration constraints 

% https://jp.mathworks.com/matlabcentral/fileexchange/16352-advanced-setpoints-for-motion-systems
pos = 1;
vmax = 0.5;
amax = 0.75;
jmax = 2;
smax = 20;
[tmake4,dd] = make4(pos,vmax,amax,jmax,smax); figure
[dj,tx,d,j,a,v,p,tt] = profile4(tmake4,smax,tmake4(1)*1e-2,false);

tstart = 0.5;
BCt = [tstart, tstart + tt];
BCt = [BCt,BCt+BCt(end)]; % go and back
jmax2 = tmake4(1)*smax; % modified max jerk
BCj = [0, 0, jmax2, jmax2, 0, 0, -jmax2, -jmax2, 0, 0, -jmax2, -jmax2, 0, 0, jmax2, jmax2, 0];
BCj = [BCj, -BCj];

% polynomial order for acceleration trajectory
np = 1;

% Polynomial Trajectory generation
BC = cell(2,1);
BC{1} = 0; % initial position
BC{2} = 0; % initial velocity
BC{3} = 0; % initial acceleration
BC{4} = BCj; % acceleration boundary conditions
pBasis = backandforth(trajType,BCt,BC,np,true);

%% Plot
Ts = 1e-3;
t = 0:Ts:8;
y1 = outPolyBasis(pBasis,1,t);
y2 = outPolyBasis(pBasis,2,t);
y3 = outPolyBasis(pBasis,3,t);
y4 = outPolyBasis(pBasis,4,t);
y5 = outPolyBasis(pBasis,5,t);

hfig = figure;
subplot(3,2,1);
plot(t,y1,'b'); hold on;
xlabel('time [s]');
title('position');
subplot(3,2,2);
plot(t,y2,'b'); hold on;
plot([t(1),t(end)],[vmax,vmax],'r--');
plot([t(1),t(end)],[-vmax,-vmax],'r--');
ylim([-0.6,0.6])
xlabel('time [s]');
title('velocity');
subplot(3,2,3);
plot(t,y3,'b'); hold on;
plot([t(1),t(end)],[amax,amax],'r--');
plot([t(1),t(end)],[-amax,-amax],'r--');
xlabel('time [s]');
title('acceleration');
subplot(3,2,4);
plot(t,y4,'b'); hold on;
plot([t(1),t(end)],[jmax,jmax],'r--');
plot([t(1),t(end)],[-jmax,-jmax],'r--');
ylim([-2.5,2.5])
xlabel('time [s]');
title('jerk');
subplot(3,2,5);
plot(t,y5,'b'); hold on;
plot([t(1),t(end)],[smax,smax],'r--');
plot([t(1),t(end)],[-smax,-smax],'r--');
ylim([-25,25])
xlabel('time [s]');
title('snap');

% FigTools required
% https://github.com/ThomasBeauduin/FigTools
if exist('pubfig','file')
    pfig = pubfig(hfig);
    pfig.Dimension = [18 24];
    expfig('ex6','-png');
end

