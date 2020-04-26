clear; close all;

Ntraj = 7; % order of reference trajectory
t0 = 0.0;
t1 = 0.05; % Step end time
ttick = 0.01; % grid

% Boundary condition
initval = zeros((Ntraj+1)/2,1); % initial condition (all zero)
pos1 = 1.0e-3; % Final position [m]
finval = [pos1; zeros((Ntraj+1)/2-1,1);]; % final condition (all zero except final position)

% Polynomial Trajectory generation 
pBasis = polySolve(t0,t1,initval,finval,Ntraj);

%% Plot
Ts = 1e-3;
t = -t1:Ts:t1*2;
y1 = outPolyBasis(pBasis,1,t);
y2 = outPolyBasis(pBasis,2,t);
y3 = outPolyBasis(pBasis,3,t);
y4 = outPolyBasis(pBasis,4,t);

hfig = figure; 
subplot(2,2,1);
plot(t,y1,'b'); hold on;
scatter([t0,t1],[initval(1),finval(1)], 'b', 'filled');
xlabel('time [s]');
title('position');
subplot(2,2,2);
plot(t,y2,'b'); hold on;
scatter([t0,t1],[initval(2),finval(2)], 'b', 'filled');
xlabel('time [s]');
title('velocity');
subplot(2,2,3);
plot(t,y3,'b'); hold on;
scatter([t0,t1],[initval(3),finval(3)], 'b', 'filled');
xlabel('time [s]');
title('acceleration');
subplot(2,2,4);
plot(t,y4,'b'); hold on;
scatter([t0,t1],[initval(4),finval(4)], 'b', 'filled');
xlabel('time [s]');
title('jerk');

% FigTools required
% https://github.com/ThomasBeauduin/FigTools
if exist('pubfig','file')
    pfig = pubfig(hfig);
    expfig('ex1','-png');
end
