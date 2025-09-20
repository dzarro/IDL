
pro test,x,y,ikey=ikey,okey=okey,_ref_extra=extra

if n_elements(x) eq 0 then x=2


y=x^2

if n_elements(ikey) eq 0 then ikey=11

okey=ikey^2


return & end