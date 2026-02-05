needsPackage"HolonomicSystems";
preOperationAstFn = (m, LT, NL, wmp, memo) -> (
    if memo#?m then return memo#m;
    best := m;
    bestW := sum for i from 0 to (#(flatten exponents m)-1) list (flatten exponents m)#i * wmp#i;
    for k from 0 to #LT-1 do (
      if m % (LT#k) == 0 then (
        cand := preOperationAstFn((m // (LT#k)) * (NL#k), LT, NL, wmp, memo);
        cw := sum for i from 0 to (#(flatten exponents cand)-1) list (flatten exponents cand)#i * wmp#i;
        if cw < bestW then (best = cand; bestW = cw);
      );
    );
    memo#m = best;
    best
  );
  OperationAstFn = (monomialsList, LT, NL, wmp) -> (
    memo := new MutableHashTable;
    apply(monomialsList, m -> preOperationAstFn(m, LT, NL, wmp, memo))
  );
  ChoosefFn = (A, sigma, nonsigma) -> (
    K := gens ker transpose substitute (submatrix(A, , apply(sigma, j->j-1)), QQ);          -- d x r（列が基底）
    f := submatrix(K, , {0});
    done := {};
    for i in nonsigma do (
      ai := submatrix(substitute(A, QQ), , {i});
      if (transpose f * ai)_(0,0) == 0 then (
        j := first select(0..(numcols K-1), t -> ((transpose submatrix(K, , {t})) * ai)_(0,0) != 0);
        b := submatrix(K, , {j});
        bad := {};
        for p in (done | {i}) do (
          ap := submatrix(substitute(A, QQ), , {p});
          fp := (transpose f * ap)_(0,0);
          bp := (transpose b    * ap)_(0,0);
          if bp != 0 then bad = bad | { -fp/bp };
        );
        t := 1;
        while member(sub(t,QQ), set bad) do t = t+1;
        f = f + t*b;
      );
      done = done | {i};
    );
    transpose f
  );
nonTrivialIndicialOperators = (A,beta,w,thetaRing) -> (
  wmp = (-w) | w;
  d = numrows A;
  n = numcols A;
  D = makeWA(QQ[x_1..x_n]);
  I' = ideal(0_D);
  IA = toricIdealPartials(A,D);
  InwIA = inw(substitute(IA, D), wmp);
  gbwIA = flatten entries gens gbw(substitute(IA, D), wmp);
  LeadTermsOfgbwIA = for i from 0 to (#gbwIA - 1) list inw(gbwIA#i, wmp);
  NonLeadTermsOfgbwIA = for i from 0 to (#gbwIA - 1) list -(gbwIA#i - LeadTermsOfgbwIA#i);
  SM = standardPairs monomialIdeal substitute(InwIA, QQ[dx_1..dx_n]);
  EM = select(SM, p -> #(p#1) != d);
  SMList = for i from 0 to (#SM - 1) list {flatten exponents SM#i#0, apply(positions(flatten exponents product SM#i#1, x -> x != 0), j -> j+1)};
  EMList = select(SMList, p -> #(p#1) != d);
  EMbetaList = select(EMList, p -> (
    Asigma = substitute(submatrix(A, , apply(p#1, j -> j-1)), QQ);
    Ac = substitute(submatrix(A, , select(0..n-1, i -> not member(i, apply(p#1, j -> j-1)))), QQ);
    betaMat = substitute(transpose matrix{beta}, QQ);
    pc = substitute(transpose matrix{toList apply(select(0..n-1, i -> not member(i, apply(p#1, j -> j-1))), i -> (p#0)#i)}, QQ);
    rhs = betaMat - Ac * pc;
    solvable = (rank(Asigma) == rank(Asigma | rhs))
  ));
  while #EMbetaList > 0 do (
    (a,sigma) = ((first EMbetaList)#0, (first EMbetaList)#1);
    newsigma = sigma;
    nonnewsigma = toList (set(0..n-1)-set apply(newsigma, j -> j-1));
    i = 0;
    T = {};
    thetaa = product flatten toList apply(0..(#a-1), i -> {D_i^(a#i) * D_(i + n)^(a#i)});
    SUList = select(SMList, p -> all(positions(a, i -> i > 0), j -> (p#0#j >= a#j) or member(j+1, p#1)));
    topSUgList = select(SUList, p -> #(p#1) == d);
    preembSUgList = delete({a,sigma}, select(SUList, p -> #(p#1) != d));
    f = ChoosefFn(A, newsigma, nonnewsigma);
    while i != d - #sigma do (
      g = sum(n, i -> ((f*A_i)_0)*D_i*D_(i+n)) - (f*substitute(transpose matrix{beta}, QQ))_(0,0);
      embSUgList = select(preembSUgList, p -> (sum(n, i -> ((f*A_i)_0)*(p#0#i))) - (f*substitute(transpose matrix{beta}, QQ))_(0,0) != 0);
      SUgList = unique(topSUgList | embSUgList);
      if (#SUgList == 0) then (q = 1_D) else (
        sigma0 = set apply(sigma, i -> i-1);
        lpList = apply(SUgList, p -> (
          p10 = apply(p#1, i -> i-1);
          j = if (sigma0 <= set p10) then (
            first select(0..n-1, k ->
              (not member(k, p10)) and (a#k != (p#0)#k)
            )
            ) else (
            first sort toList((sigma0) - (set p10))
          );
          D_(j)*D_(j+n) - (p#0)#j
        ));
        q = product unique lpList
      );
      h = sum OperationAstFn(terms(q*thetaa*g), LeadTermsOfgbwIA, NonLeadTermsOfgbwIA, wmp);
      inwh = inw(h, wmp);
      for t from 0 to n-1 do (
        aplus1t = apply(#a, i -> if i==t then a#i + 1 else a#i);
        thetaaplus1t = product flatten toList apply(0..(n-1), i -> {D_i^(aplus1t#i) * D_(i+n)^(aplus1t#i)});
        if (((f * submatrix(substitute(A, QQ), , {t}))_(0,0))*q*thetaaplus1t - inwh) % sub(IA, D) == 0_D
        then (T = append(T, t+1));
      );
      inwhg = inwh * g;
      r = inwhg % InwIA;
      c = if (#(terms r) == #(terms inwh) and (r)%(inwh) == 0) then sub((flatten entries (coefficients (inwhg % InwIA))#1)#0,QQ)/sub((flatten entries (coefficients (inwh % InwIA))#1)#0,QQ) else ("doesntexist");
      while (class c === QQ and isMember(inwhg - c*inwh,InwIA)) do (
        h' = sum OperationAstFn(terms(inwhg), LeadTermsOfgbwIA, NonLeadTermsOfgbwIA, wmp);
        h = h' - c*h;
        inwh = inw(h, wmp);
        inwhg = inwh * g;
        r = inwhg % InwIA;
        c = if (#(terms r) == #(terms inwh) and (r)%(inwh) == 0) then sub((flatten entries (coefficients (inwhg % InwIA))#1)#0,QQ)/sub((flatten entries (coefficients (inwh % InwIA))#1)#0,QQ) else ("doesntexist");
      );
      I' = I' + ideal(inwh);
      i = i+1;
      if i != d - #sigma then (
        newsigma = toList(set newsigma + set T);
        nonnewsigma = toList (set(0..n-1)-set apply(newsigma, j -> j-1));
        f = ChoosefFn(A, newsigma, nonnewsigma);
      );
    );
    EMbetaList = delete({a, sigma}, EMbetaList);
  );
  DistI = flatten entries gens(ideal select(flatten entries gens distraction(I',thetaRing), f -> f != 0));
  DistI
);
fakeIndicialIdeal = (A,beta,w,thetaRing) -> (
  wmp = (-w) | w;
  n = numcols A;
  D = makeWA(QQ[x_1..x_n]);
  IA = toricIdealPartials(A,D);
  InwIA = inw(substitute(IA, D), wmp);
  Find = distraction(InwIA, thetaRing) + distraction(ideal(eulerOperators(A,beta,D)),thetaRing);
  Find
);