;+
; Project     : SDAC
;                  
; Name        : DECORATE
;               
; Purpose     : IDL version of Python Decorate function
;                             
; Category    : system utility 
;               
; Syntax      : IDL> decorate,program,wrapper
;
; Inputs:     : PROGRAM = name of procedure or function to decorate
;               WRAPPER = name of wrapper program to decorate program
;              
; Outputs     : None
;
; Keywords    : SUB_PROG = name of procedure or function within program to decorate 
;                         (optional if a sub program is embedded within program code)
;               METHOD = method name if program is an object class definition
;               VERBOSE = set for verbose output
;               ERR = error string
;                          
; History     : 12-May-2026, Zarro (Retired) - written
;               
; Contact     : dzarro@solar.stanford.edu
;-    

pro decorate,program,wrapper,_ref_extra=extra,verbose=verbose,err=err

err=''
verbose=keyword_set(verbose)
redecorate=keyword_set(redecorate)

p1=prog_type(program,call=pcall,fname=fname,verbose=verbose,err=err,$
             _extra=extra,class=class,code=pcode)
if (p1 eq 0) || is_string(err) then return

p2=prog_type(wrapper,call=wcall,fname=wname,err=err,verbose=verbose)
if (p2 eq 0) || is_string(err) then return

;-- create wrapper program

pcall=strlowcase(strcompress(pcall))
wcall=strlowcase(strcompress(wcall))

;-- format according to whether program/wrapper is procedure or function

pcall2=pcall
pcall2=str_repv(pcall2,'_ref_e','_e',/fold)

prog=fname
pname=fname+'_'+get_rid()
cname=pname
if class then cname='self->'+cname
np=n_elements(pcall)
sp=strpos(pcall2[0],prog)
pcall2[0]=strmid(pcall2[0],sp,strlen(pcall2[0]))
if p1 eq 2 then begin
 pcall2[0]=str_repv(pcall2[0],prog,'out='+cname+'(',/fold)
 pcall2[0]=str_repv(pcall2[0],',','',/fold,/first)
 pcall2[np-1]=pcall2[np-1]+')'
endif else pcall2[0]=str_repv(pcall2[0],prog,cname,/fold)

wcall2=wcall
np=n_elements(wcall)
sp=strpos(wcall2[0],wname)
wcall2[0]=strmid(wcall2[0],sp,strlen(wcall2[0]))
if p2 eq 2 then begin
 wcall2[0]=str_repv(wcall2[0],wname,'out='+wname+'(',/fold)
 wcall2[0]=str_repv(wcall2[0],',','',/fold,/first)
 wcall2[np-1]=wcall2[np-1]+')'
endif 

temp=[pcall,'',wcall2,'',pcall2,'',wcall2]
if p1 eq 2 then temp=[temp,'','return,out','end'] else temp=[temp,'','return','end'] 
wcode=temp

;-- decorate program by modifying and recompiling original program with call to wrapper program. 

pcode[0]=str_repv(pcode[0],prog,pname,/fold)

;-- compile wrapper and decorated programs

compile,pcode,err=err
if is_string(err) then return
compile,wcode,err=err

return
end