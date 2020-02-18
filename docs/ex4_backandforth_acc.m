clear; close all;

trajType = 'acc'; % for given acceleration constraints 

tjrk = 1.5; % jrk time
tconstacc = 1;
tconstvel = 1; % constant velocity time
tdwell = 0.5; % dwelling time
% time boundary conditions
BCt = [tdwell,... % dwell
    tdwell+tjrk,... % jrk
    tdwell+tjrk+tconstacc,... % const acc
    tdwell+tjrk+tconstacc+tjrk,... % jrk
    tdwell+tjrk+tconstacc+tjrk+tconstvel,... % const vel
    tdwell+tjrk+tconstacc+tjrk+tconstvel+tjrk,... % jrk
    tdwell+tjrk+tconstacc+tjrk+tconstvel+tjrk+tconstacc,... % const acc
    tdwell+tjrk+tconstacc+tjrk+tconstvel+tjrk+tconstacc+tjrk,... % jrk
    ];
BCt = [BCt,BCt+BCt(end)]; % go and back

% max velocity
amax = 1; % m/s
% velocity boundary conditions
BCa = [0, amax, amax, 0, 0, -amax, -amax, 0];
BCa = [BCa, -BCa];

% polynomial order
np = 3;

% Polynomial Trajectory generation

BC = cell(2,1);
BC{1} = BCa; % initial position
BC{2} = 0; % initial velocity
BC{3} = 0; % initial position
pBasis = backandforth(trajType,BCt,BC,np,true);

%% Plot
Ts = 1e-3;
t = 0:Ts:20;
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
xlabel('time [s]');
title('velocity');
subplot(2,2,3);
plot(t,y3,'b'); hold on;
scatter(BCt,BCa, 'b', 'filled');
xlabel('time [s]');
title('acceleration');
subplot(2,2,4);
plot(t,y4,'b'); hold on;
xlabel('time [s]');
title('jerk');

% FigTools required
% https://github.com/ThomasBeauduin/FigTools
if exist('pubfig','file')
    pfig = pubfig(hfig);
    expfig('ex4','-png');
end
