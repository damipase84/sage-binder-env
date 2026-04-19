def interval_sol(sol):
    ll=len(sol)
    sol_set=RealSet()
    for i in range(ll):
        if type(sol[i])==type([1 ,2]):
            l1=len(sol[i])
            if l1==0:
                sol_set=RealSet(-oo,oo)
            elif l1==1:
                val=sol[i][0].right()
                temp_eq=0==val
                if val.is_real()==False:
                    val=sol[i][0].left()
                    temp_eq=val==0
                temp_set=RealSet(sol[i][0]-temp_eq)
                if temp_set.is_finite():
                    sol_set=sol_set+RealSet([val,val])
                else:
                    if temp_set.sup()==oo:
                        if temp_set==temp_set.interior():
                            sol_set=sol_set+RealSet.unbounded_above_open(val)
                        else:
                            sol_set=sol_set+RealSet.unbounded_above_closed(val)
                    else:
                        if temp_set==temp_set.interior():
                            sol_set=sol_set+RealSet.unbounded_below_open(val)
                        else:
                            sol_set=sol_set+RealSet.unbounded_below_closed(val)
            else:
                if type(sol[i][0])==type([0,1]):
                    eq1=sol[i][0][0]
                    eq2=sol[i][1][0]
                else:
                    eq1=sol[i][0]
                    eq2=sol[i][1]
                val1=eq1.right()
                val2=eq2.right()
                
                temp_eq1=0==val1
                temp_eq2=0==val2
                
                if val1.is_real()==False:
                    val1=eq1.left()
                    temp_eq1=val1==0
                if val2.is_real()==False:
                    val2=eq2.left()
                    temp_eq2=val2==0
                temp_set1=RealSet(eq1-temp_eq1)
                temp_set2=RealSet(eq2-temp_eq2)
                if temp_set1==temp_set1.interior():
                    if temp_set2==temp_set2.interior():
                        sol_set=sol_set+RealSet(val1,val2)
                    else:
                        sol_set=sol_set+RealSet.open_closed(val1,val2)
                else:
                    if temp_set2==temp_set2.interior():
                        sol_set=sol_set+RealSet.closed_open(val1,val2)
                    else:
                        sol_set=sol_set+RealSet([val1,val2])
        else:
            eq=sol[i]
            val=eq.right()
            if val.is_real():
                sol_set=sol_set+RealSet([val, val])
            else:
                sol_set=RealSet(-oo,oo)
    return sol_set

##############################
def plot_sign_prod(factor_list,condizioni):
    nf=len(factor_list) # numero fattori
    fun=1
    for i in range(nf):
        fun=fun*factor_list[i]
    cc=solve(condizioni)
    cc_Set=interval_sol(cc)
    ss=solve(fun>=0)
    ss_Set=interval_sol(ss)
    sol_Set=ss_Set.intersection(cc_Set)

    bound=sol_Set.boundary() # boundary values
    nb=bound.n_components()
    if nb>1:
        bound_min=bound[0].lower()
        bound_max=bound[-1].lower()
        leng=bound_max-bound_min
        val_xmin=bound_min-0.4*leng
        val_xmax=bound_max+0.4*leng
    else:
        bound_mean=bound[0].lower()
        val_xmin=bound_mean-5
        val_xmax=bound_mean+5

    ll=line([[val_xmin,0.1],[val_xmax,0.1]],color='black',thickness=0.5)
    ll=ll+text('$x$',[val_xmax,0.3])
    for i in range(nb):
        bound_val=bound[i].lower()
        ll=ll+line([[bound_val,0.1],[bound_val,-nf-1.1]],color='black',thickness=0.5)
        ll=ll+text(bound_val,[bound_val,0.3])
        
    for i in range(nf):

        fact=factor_list[i]
        ss=solve(fact>=0)
        fact_Set=interval_sol(ss)
        ll=ll+line_sign(fact_Set,sol_Set,cc_Set,-i-1,fact)
    ll=ll+line_sign(sol_Set,sol_Set,cc_Set,-nf-1,fun)
    ll.axes_color('white')
    ll.axes_label_color('white')
    ll.tick_label_color('white')
    show(ll,axes_labels=['$x$',' '],ymin=-nf-2,ymax=0.2,ticks=[None,None],figsize=[6,3])
###########################

def line_sign(fact_Set,sol_Set,cc_Set,yval,fun):
    bound=sol_Set.boundary() # boundary values
    bound_fact=fact_Set.boundary()
    nb=bound.n_components()
    if nb>1:
        bound_min=bound[0].lower()
        bound_max=bound[-1].lower()
        leng=bound_max-bound_min
        val_xmin=bound_min-0.4*leng
        val_xmax=bound_max+0.4*leng
    else:
        bound_mean=bound[0].lower()
        leng=10
        val_xmin=bound_mean-5
        val_xmax=bound_mean+5
    xvali=bound[0].lower()
    ll=line([[val_xmin,yval],[val_xmax,yval]],color='blue',linestyle='--',thickness=1)
    if cc_Set.inf()==xvali:
        ll=ll+line([[val_xmin,yval],[xvali,yval]],color='red')
    elif fact_Set.inf()==-oo:
        ll=ll+line([[val_xmin,yval],[xvali,yval]],color='blue')
    for i in range(nb):
        xvali=bound[i].lower()
        if xvali not in cc_Set:
            ll=ll+point([[xvali,yval]],size=50,color='red')
        elif xvali in bound_fact:
            ll=ll+point([[xvali,yval]],size=50,color='blue')
        if i != nb-1: 
            xvalip1=bound[i+1].lower()
            xvalm=(xvalip1+xvali)/2
            if xvalm not in cc_Set:
                ll=ll+line([[xvali,yval],[xvalip1,yval]],color='red')
            elif xvalm in fact_Set:
                ll=ll+line([[xvali,yval],[xvalip1,yval]],color='blue')
        elif i==nb-1: 
            if cc_Set.sup()==xvali:
                ll=ll+line([[bound[-1].lower(),yval],[val_xmax,yval]],color='red')
            elif fact_Set.sup()==+oo:
                ll=ll+line([[bound[-1].lower(),yval],[val_xmax,yval]],color='blue')
    ll=ll+text(fun,[val_xmin-0.2*leng,yval+0.2])
    return ll
#################################

def plot_sign_fract(num,den,condizioni):
    nf=2 # numero fattori
    factor_list=[num, den]
    fun=num/den
    cc=solve(condizioni)
    cc1=solve(den!=0)
    cc_Set=interval_sol(cc)
    cc_Set=cc_Set.intersection(interval_sol(cc1)) # condizioni esistenza
    ss=solve(fun>=0)
    ss_Set=interval_sol(ss)
    sol_Set=ss_Set.intersection(cc_Set)

    bound=sol_Set.boundary() # boundary values
    nb=bound.n_components()
    if nb>1:
        bound_min=bound[0].lower()
        bound_max=bound[-1].lower()
        leng=bound_max-bound_min
        val_xmin=bound_min-0.4*leng
        val_xmax=bound_max+0.4*leng
    else:
        bound_mean=bound[0].lower()
        val_xmin=bound_mean-5
        val_xmax=bound_mean+5

    ll=line([[val_xmin,0.1],[val_xmax,0.1]],color='black',thickness=0.5)
    ll=ll+text('$x$',[val_xmax,0.3])
    for i in range(nb):
        bound_val=bound[i].lower()
        ll=ll+line([[bound_val,0.1],[bound_val,-nf-1.1]],color='black',thickness=0.5)
        ll=ll+text(bound_val,[bound_val,0.3])
        
    for i in range(nf):

        fact=factor_list[i]
        ss=solve(fact>=0)
        fact_Set=interval_sol(ss)
        ll=ll+line_sign(fact_Set,sol_Set,cc_Set,-i-1,fact)
    ll=ll+line_sign(sol_Set,sol_Set,cc_Set,-nf-1,fun)
    ll.axes_color('white')
    ll.axes_label_color('white')
    ll.tick_label_color('white')
    show(ll,axes_labels=['$x$',' '],ymin=-nf-2,ymax=0.2,ticks=[None,None],figsize=[6,3])