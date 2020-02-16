function y = outPolyBasis(pBasis,n,t,showFig,symflag)
% outPolyBasis - output value of polynomial basis functions
%
% y = outPolyBasis(pBasis,n,t)
%       pBasis : created by polySolve
%            n : r_n (eg. r_1: posref, r_2: velref...)
% Author       : Wataru Ohnishi, the University of Tokyo, 2017
%%%%%

if nargin < 2
    n = 1;
end
if nargin < 4
    showFig = 0;
end
if nargin < 5
    symflag = 0;
end

if ~iscell(pBasis) % single poly trajectories
    test = pBasis;
    pBasis = cell(1,1); pBasis{1} = test; clear test
end

if nargin < 3
    dT = pBasis{1}.BCt(2) - pBasis{1}.BCt(1);
    Ts = dT/1000;
    t = pBasis{1}.BCt(1)-dT:Ts:pBasis{end}.BCt(2)+dT;
end

npoly = length(pBasis); % number of trajectories
norg = n;

for k = 1:npoly
    t_sym = sym('t_sym','real');
    if norg > length(pBasis{k}.a_vpas(:,1)) % symbolic diff for high-order trajectory
        T_sym = sym('t_sym_',[length(pBasis{k}.a_vpas(1,:)),1]);
        for k2 = 1:length(T_sym)
            T_sym(k2) = t_sym^(k2-1);
        end
        y_sym = fliplr(pBasis{k}.a_vpas(1,:))*T_sym;
        for kk = length(pBasis{k}.a_vpas(:,1))+1:norg
            diff_y_sym = diff(y_sym,kk-1);
            pBasis{k}.a_vpas = ...
                [pBasis{k}.a_vpas;
                zeros(1,length(pBasis{k}.a_vpas(1,:))-length(sym2poly(diff_y_sym))), sym2poly(diff_y_sym)];
        end
        n = length(pBasis{k}.a_vpas(:,1));
    end
end

nmax = max(cellfun(@(x)length(x.a_vpas),pBasis));
T_sym2 = sym('t_sym_',[nmax,1]);
for k = 1:length(T_sym2)
    T_sym2(k) = t_sym^(k-1);
end
T_sym2 = flipud(T_sym2);

[BCt,indices] = pBasisToBCt(pBasis,t);


if ~symflag % numeric answer
    y = zeros(1,length(t));
    if n > length(pBasis{1}.BC0)
        %             y(1:indices(1)-1) = polyval(pBasis{1}.a_vpas(n,:),t(indices(1)));
        y(1:indices(1)-1) = 0;
    else
        y(1:indices(1)-1) = pBasis{1}.BC0(n);
    end
    for k = 1:length(BCt)-1
        y(indices(k):indices(k+1)-1) = ...
            polyval(pBasis{k}.a_vpas(n,:),t(indices(k):indices(k+1)-1));
    end
    if n > length(pBasis{end}.BC1)
        %             y(indices(end):end) = polyval(pBasis{end}.a_vpas(n,:),t(indices(end)));
        y(indices(end):end) = 0;
    else
        y(indices(end):end) = pBasis{end}.BC1(n);
    end
else % symbolic answer
    y = sym('y',[1,length(t)]);
    y(1:indices(1)-1) = pBasis{1}.BC0(n);
    for k = 1:length(BCt)-1
        y(indices(k):indices(k+1)-1) = ...
            subs(pBasis{k}.a_syms(n,:)*T_sym2,t_sym,t(indices(k):indices(k+1)-1));
    end
    y(indices(end):end) = pBasis{end}.BC0(n);
end

if showFig
    hfig = figure;
    plot(t,y);
    stitle = sprintf('$r_{%d}$',norg);
    title(stitle);
    pfig = pubfig(hfig);
end

end


function [BCt,indices] = pBasisToBCt(pBasis,t)
BCt = cellfun(@(x)x.BCt(1),pBasis);
BCt = [BCt,pBasis{end}.BCt(end)];

tmp = arrayfun(@(x)find(abs(x-t)<eps),BCt,'UniformOutput',false);
if any(cellfun(@isempty,tmp))
    warning('Sampled time vector does not contain boudary condition!');
    indices = arrayfun(@(x)find(t<x,1,'last'),BCt)+1;
else
    indices = arrayfun(@(x)find(abs(x-t)<eps),BCt);
end
end

