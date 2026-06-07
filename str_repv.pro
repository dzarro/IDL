;+
; Project     : VSO
;
; Name        : STR_REPV
;
; Purpose     : Replace substrings in a string.
;               Fully vectorized version of STR_REPLACE (still experimental)
;
; Category    : utility strings
;
; Syntax      : IDL> output=str_rep(input,old,new)
;
; Inputs      : INPUT = scalar or vector string to operate on
;             : OLD = substring to replace
;             : NEW = replacement substring
;
; Outputs     : OUTPUT = INPUT string with all occurrences of OLD
;                         replaced by NEW
;
; Keywords    : COUNT = number of matches
;               FOLD = set to ignore case
;               FIRST = set to replace first occurrence only
;               NO_COPY = set to not make new copy of INPUT
;
; History     : 23-Feb-2022, Zarro (ADNET)
;                6-Jun-2026, Zarro (Retired) - added FIRST and FOLD
;-

function str_repv,input,old,new,verbose=verbose,count=count,no_copy=no_copy,rest=rest,_extra=extra,first=first

rest=''
err=''
count=0
no_copy=keyword_set(no_copy)
verbose=keyword_set(verbose)
first=keyword_set(first)

if ~isa(input,/string) then begin
 if n_elements(input) ne 0 then return,input else return,''
endif

if n_params() ne 3 then return,input
if ~isa(old,/string,/scalar) then return,input
if ~isa(new,/string,/scalar) then return,input
if old eq new then return,input

;-- input = 'xxxoldxxxxxoldxxxx'
;-- output= 'xxxnewxxxxxxnewxxxx'

;-- if requesting first occurrence then must match in reverse

if first then begin
 einput=str_reverse(input,no_copy=no_copy)
 eold=str_reverse(old)
 enew=str_reverse(new)
endif else begin
 if no_copy then einput=temporary(input) else einput=input
 eold=old
 enew=new
endelse

;-- escape REGEX characters in OLD

eold=str_escape(eold)
chk=where(stregex(einput,eold,/bool,_extra=extra),count)
if count eq 0 then return,input

reg='(.*)('+eold+')(.*)'
chk=stregex(einput,reg,/extract,/sub,_extra=extra)
found=where(chk[2,*] ne '',fcount)
if fcount eq 0 then return,input

output=temporary(einput)
rest1=reform(chk[1,found],fcount)
rest2=reform(chk[3,found],fcount)
rest=rest1

;-- recurse until all matches found and replaced

if ~first then begin
 chk1=where(stregex(rest1,eold,/bool,_extra=extra),count1)
 if (count1 gt 0) then begin
  repeat begin
   if verbose then mprint,'recursing...'
   rest1=str_repv(rest1,eold,enew,verbose=verbose,/no_copy,rest=rest,_extra=extra)
   chk1=where(stregex(rest,eold,/bool,_extra=extra),count2)
  endrep until (count2 eq 0)
 endif
endif

;-- assemble output

output[found]=temporary(rest1)+enew+temporary(rest2)

if first then output=str_reverse(output,/no_copy)

return,output

end
