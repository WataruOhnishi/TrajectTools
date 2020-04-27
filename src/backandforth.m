function pBasis = backandforth(trajType,BCt,BC,polyOrder,showFig)
%backandforth - generate polynomical basis for back and forth motion
%
% pBasis = backandforth(trajType,BCt,BC,np,showFig)
%   trajType: trajectory type, 'pos', 'vel'
%   BCt     : time boundary conditions
%   BC      : boundary conditions, e.g. position, velocity
%   np      : polynomial order
%   showFig : flag to show results
%   pBasis  : parameter for polynomial basis
%              see outPolyBasis.m
% Author    : Wataru Ohnishi, University of Tokyo, 2020
%%%%%

if nargin < 5
    showFig = false;
end

trajType = lower(trajType);
nofpoly = length(BCt)-1; % number of trajectory segments
pBasis = cell(1,nofpoly);

switch trajType
    case 'pos'
        % BC denotes the position boundary conditions
        BCp = BC;
        for k = 1:nofpoly % boudary condition calc for each segments
            initval = [BCp(k); zeros((polyOrder+1)/2-1,1);];
            finval = [BCp(k+1); zeros((polyOrder+1)/2-1,1);];
            pBasis{k} = polySolve(BCt(k),BCt(k+1),initval,finval,polyOrder,0);
        end
    case 'vel'
        % BC (cell) denotes
        % BC{1}: initial position
        % BC{2}: velocity boundary conditions
        BCp0 = BC{1};
        BCv = BC{2};
        % generate acceleration trajectory
        for k = 1:nofpoly % boudary condition calc for each segments
            initval = [BCv(k); zeros((polyOrder+1)/2-1,1);];
            finval = [BCv(k+1); zeros((polyOrder+1)/2-1,1);];
            pBasis{k} = polySolve(BCt(k),BCt(k+1),initval,finval,polyOrder,0);
        end
        pBasis = int_pBasis(pBasis,1,[BCp0]);
    case 'acc'
        % BC (cell) denotes
        % BC{1}: initial position
        % BC{2}: initial velocity
        % BC{3}: acceleration boundary conditions
        BCp0 = BC{1};
        BCv0 = BC{2};
        BCa = BC{3};
        % generate acceleration trajectory
        for k = 1:nofpoly % boudary condition calc for each segments
            initval = [BCa(k); zeros((polyOrder+1)/2-1,1);];
            finval = [BCa(k+1); zeros((polyOrder+1)/2-1,1);];
            pBasis{k} = polySolve(BCt(k),BCt(k+1),initval,finval,polyOrder,0);
        end
        pBasis = int_pBasis(pBasis,2,[BCv0;BCp0]);
    case 'jrk'
        % BC (cell) denotes
        % BC{1}: initial position
        % BC{2}: initial velocity
        % BC{3}: initial acceleration
        % BC{4}: jerk boundary conditions
        BCp0 = BC{1};
        BCv0 = BC{2};
        BCa0 = BC{3};
        BCj = BC{4};
        % generate acceleration trajectory
        for k = 1:nofpoly % boudary condition calc for each segments
            initval = [BCj(k); zeros((polyOrder+1)/2-1,1);];
            finval = [BCj(k+1); zeros((polyOrder+1)/2-1,1);];
            pBasis{k} = polySolve(BCt(k),BCt(k+1),initval,finval,polyOrder,0);
        end
        pBasis = int_pBasis(pBasis,3,[BCv0;BCp0;BCa0]);
    otherwise
        error('error!')
end

if showFig
    dt = (pBasis{end}.BCt(end)-pBasis{1}.BCt(1));
    t = pBasis{1}.BCt(1)-dt/10:dt/1000:pBasis{end}.BCt(end)+dt/10;
    stitle = {'position','velocity','acceleration','jerk'};
    hfig = figure;
    for k = 1:4
        subplot(2,2,k);
        plot(t,outPolyBasis(pBasis,k,t)); xlabel('time [s]'); title(stitle{k});
    end
    if exist('pubfig','file'), pubfig(hfig); end
end

end

