function [t,r] = poly2traj(a_poly,tst,t0,t1,tfin,Ts,initval,finval,showFig)
%poly2traj - Convert polynomial to 3 segmented trajectory
%
% [t,r] = poly2traj(a_poly,tst,t0,t1,tfin,Ts,n,showFig)
% tst       : Simulation start time
% t0        : Trajectory start time
% t1        : Trajectory end time
% tfin      : Simulation end time
% Ts        : Sampling time
% initval   : Initial values (n,1)
% finval    : Final values (n,1)
% showFig   : Flag to show the result (0,1)
% t         : time [tst:Ts:tfin]
% r         : Reference (n,length(time))
% Author    : Wataru Ohnishi, University of Tokyo, 2016
%%%%%

if nargin < 9
    showFig = 0;
end

Nplant = length(initval);
t = tst:Ts:tfin;
Ntime = length(t);

r = zeros(Nplant,Ntime);

for k = 1:1:Ntime
    if t(k) < t0
        for kk = 1:1:Nplant
            r(kk,k) = initval(kk);
        end
    elseif t(k) < t1
        for kk = 1:1:Nplant
            r(kk,k) = polyval(a_poly(kk,:),t(k));
        end
    else
        for kk = 1:1:Nplant
            r(kk,k) = finval(kk);
        end
    end
end


if showFig == 1
    tlength = t1 - t0;
    for kk = 1:1:Nplant
        sTitle = sprintf('r_%d(t)',kk);
        figure;
        plot(t,r(kk,:));
        title(sTitle);
        xlabel('Time [s]');
        grid on; box on;
        xlim([t0-tlength*2,t1+tlength*1]);
    end    
end

%{
% Simulation parameter
tst = -0.3;
tfin = 0.3;
% Plant parameter
Ts = 100e-6;
% Trajectory
Ntraj = 11;
initval = zeros((Ntraj+1)/2,1); % all 0
pos1 = 10.0e-3; % final position 10mm [mm]
finval = [pos1; zeros((Ntraj+1)/2-1,1);];
t0 = 0;   % start time
t1 = 0.02; % finish time
a_poly = func_kidoun(t0,t1,initval,finval,Ntraj,0);
[t,r] = func_poly2traj(a_poly,tst,t0,t1,tfin,Ts,initval,finval,1);
%}