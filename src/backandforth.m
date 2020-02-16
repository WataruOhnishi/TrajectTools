function pBasis = backandforth(trajType,BCt,BCp,np,showFig)

trajType = lower(trajType);
nofpoly = length(BCt)-1;
pBasis_set = cell(1,nofpoly);

switch trajType
    case 'pos'
        for k = 1:nofpoly
            initval = [BCp(k); zeros((np+1)/2-1,1);];
            finval = [BCp(k+1); zeros((np+1)/2-1,1);];
            pBasis_set{k} = polySolve(BCt(k),BCt(k+1),initval,finval,np,0);
        end
    otherwise
        error('error!')
end

pBasis = pBasis_set;

if showFig
    dt = (pBasis{end}.BCt(end)-pBasis{1}.BCt(1));
    t = pBasis{1}.BCt(1)-dt/10:dt/1000:pBasis{end}.BCt(end)+dt/10;
    pltPolyBasis(pBasis,1,t,showFig);
end

end
