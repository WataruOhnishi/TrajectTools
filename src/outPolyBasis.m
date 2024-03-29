function varargout = outPolyBasis(pBasis,n,t,showFig,symflag)
% outPolyBasis - output value of polynomial basis functions
%
% [y,hfig] = outPolyBasis(pBasis,n,t)
%       pBasis : created by polySolve
%            n : r_n (eg. r_1: posref, r_2: velref...)
%            t : time vector
%      showFig : flag to show figure
%                1: plot, 2: plot with derivatives
%      symflag : flag to symbolic output
%            y : output polynomial
%         hfig : figure handle optionally created by showFig
% Author       : Wataru Ohnishi, the University of Tokyo, 2017
%%%%%

if nargin < 2 || isempty(n), n = 1; end
if nargin < 4, showFig = false; end
if nargin < 5, symflag = false; end
if ~iscell(pBasis) % single poly trajectories
    test = pBasis;
    pBasis = cell(1,1); pBasis{1} = test; clear test
end
if nargin < 3 || isempty(t)
    dT = pBasis{1}.BCt(2) - pBasis{1}.BCt(1);
    Ts = dT/1000;
    t = pBasis{1}.BCt(1)-dT:Ts:pBasis{end}.BCt(2)+dT;
end

npoly = length(pBasis); % number of trajectories

for k = 1:npoly
    if n > length(pBasis{k}.a_vpas(:,1)) % symbolic diff for high-order trajectory
        n_diff = n - length(pBasis{k}.a_vpas(:,1));
        while n_diff > 0
            pBasis{k}.a_vpas = [pBasis{k}.a_vpas; ...
                polydiff(pBasis{k}.a_vpas(end,:));];
            pBasis{k}.a_syms = [pBasis{k}.a_syms; ...
                polydiff(pBasis{k}.a_syms(end,:));];
            pBasis{k}.BC0 = [pBasis{k}.BC0;...
                polyval(pBasis{k}.a_vpas(end,:),pBasis{k}.BCt(1))];
            pBasis{k}.BC1 = [pBasis{k}.BC1;...
                polyval(pBasis{k}.a_vpas(end,:),pBasis{k}.BCt(2))];
            n_diff = n_diff - 1;
        end
    end
end

t_segmentIdx = segmentIdx(pBasis,t);

if ~symflag % numeric answer
    y = zeros(1,length(t));
    for k = 0:1:npoly+1
        if k == 0
            idx = t_segmentIdx == 0;
            if n == 1
                y(idx) = pBasis{1}.BC0(1);
            else
                y(idx) = 0;
            end
        elseif k <= npoly
            idx = t_segmentIdx == k;
            y(idx) = polyval(double(pBasis{k}.a_vpas(n,:)),t(idx)-pBasis{k}.BCt(1));
        else
            idx = t_segmentIdx == npoly+1;
            if n == 1
                y(idx) = pBasis{end}.BC1(1);
            else
                y(idx) = 0;
            end
        end
    end
else % symbolic answer
    y = sym('y',[1,length(t)],'real');
    for k = 0:1:npoly+1
        if k == 0
            idx = t_segmentIdx == 0;
            if n == 1
                y(idx) = pBasis{1}.BC0(1);
            else
                y(idx) = 0;
            end
        elseif k <= npoly
            idx = t_segmentIdx == k;
            y(idx) = subs(poly2sym(pBasis{k}.a_syms(n,:)),t(idx)-pBasis{k}.BCt(1));
        else
            idx = t_segmentIdx == npoly+1;
            if n == 1
                y(idx) = pBasis{end}.BC1(1);
            else
                y(idx) = 0;
            end
        end
    end
end

varargout{1} = y;

if showFig == 1 % show plot
    hfig = figure;
    plot(t,y);
    stitle = sprintf('$r_{%d}$',norg);
    title(stitle);
    if exist('pubfig','file'), hfig = pubfig(hfig); end
    varargout{2} = hfig;
elseif showFig == 2 % show plot with derivatives
    stitle = {'position','velocity','acceleration','jerk'};
    hfig = figure;
    for k = 1:4
        subplot(2,2,k); plot(t,outPolyBasis(pBasis,k,t,0));
        title(stitle{k}); xlabel('time [s]');
    end
    if exist('pubfig','file'), hfig = pubfig(hfig); end
    varargout{2} = hfig;
end

end


function t_segmentIdx = segmentIdx(pBasis,t)
BCt = cellfun(@(x)x.BCt(1),pBasis);
BCt = [BCt,pBasis{end}.BCt(end),inf]; % inf for final segment

t_segmentIdx = arrayfun(@(x)find(x<BCt,1,'first'),t) - 1;

end
