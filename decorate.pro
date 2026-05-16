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
;               VERBOSE = set for verbose output
;               ERR = error string
;                          
; History     : 12-May-2026, Zarro (Retired) - written
;               
; Contact     : dzarro@solar.stanford.edu
;-    

pro decorate,program,wrapper,_ref_extra=extra,verbose=verbose,sub_prog=sub_prog,err=err

err=''
verbose=keyword_set(verbose)
p1=prog_type(program,call=pcall,prog_file=pfile,index=index,sub_prog=sub_prog,verbose=verbose,err=err)
if (p1 eq 0) then return

p2=prog_type(wrapper,err=err)
if (p2 eq 0) then return

;-- create wrapper program

pcall=strcompress(pcall)
chk=where(stregex(pcall,'^[f]_extra',/bool,/fold),count)
if count eq 1 then begin
 ic=chk[0] & pcall[ic]=strep2(pcall[ic],'_extra','_ref_extra')
endif

pcall2=pcall
chk=where(stregex(pcall2,'_ref_extra',/bool,/fold),count)
if count eq 1 then begin
 ic=chk[0] & pcall2[ic]=strep2(pcall2[ic],'_ref_extra','_extra')
endif

if is_string(sub_prog) then prog=sub_prog else prog=program
pname=prog+'_temp' 
np=n_elements(pcall)
sp=strpos(strlowcase(pcall2[0]),strlowcase(prog))
pcall2[0]=strmid(pcall2[0],sp,strlen(pcall2[0]))

;-- format according to whether program/wrapper is procedure or function

if p1 eq 2 then begin
 pcall2[0]=strep2(pcall2[0],prog,'out='+pname+'(')
 pcall2[0]=strep2(pcall2[0],',','')
 pcall2[np-1]=pcall2[np-1]+')'
endif else pcall2[0]=strep2(pcall2[0],prog,pname)

if p2 eq 2 then wcall='wout='+wrapper+'(_extra=extra)' else wcall=wrapper+',_extra=extra'

temp=[pcall,'',wcall,'',pcall2,'',wcall]
if p1 eq 2 then temp=[temp,'','return,out','end'] else temp=[temp,'','return','end'] 
itemp=temp

;-- decorate program by modifying and recompiling original program with call to wrapper program. 

ptemp=rd_ascii(pfile)
ptemp[index]=strep2(ptemp[index],prog,pname)

;-- write and compile wrapper and decorated programs

temp=ptemp
for i=0,1 do begin
 out_file=get_temp_file('test.pro')
 if i eq 0 then begin
  pro_dir=file_dirname(out_file)
  if i eq 0 then cd,pro_dir,current=cdir
 endif
 pro_name=file_basename(out_file,'.pro')
 out=[temp,' ','pro '+pro_name,'return & end']
 if verbose then mprint,'Writing to '+out_file
 wrt_ascii,out,out_file,/no_pad
 resolve_routine,pro_name,/either,/compile_full_file,quiet=1-verbose
 temp=itemp
endfor
cd,cdir

;file_delete,out_file,/quiet

 return
 end