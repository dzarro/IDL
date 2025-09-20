;+
; Project     : VSO
;
; Name        : STR_EXTRACT
;
; Purpose     : Extract multiple search matches from string using REGEX. 
;               IDL REGEX only returns first match.
;
; Category    : utility string
;
; Syntax      : IDL> output=str_extract(input,regex)
;
; Inputs      : INPUT = scalar string to search
;               
; Outputs     : OUTPUT = array of matches
;
; Keywords    : COUNT = # of matches
;
; History     : 11-September-2025 Zarro (Consultant) - written
;              
;-

function str_extract,input,regex,count=count,_extra=extra

count=0
if is_blank(input) || is_blank(regex) then return,''

error=0
catch,error
if (error ne 0) then begin
 mprint,err_state()
 catch,/cancel
 message,/reset
 return,''
endif

;-- search for first occurrence, remove it, and search for next one

found=''
temp=input[0]
repeat begin
 match=''
 chk=stregex(temp,regex,/sub,/extract)
 if is_string(chk[0]) then begin
  np=n_elements(chk)
  match=chk[np-1]
  root=chk[(np-2) > 0]
  if is_blank(found) then found=match else found=[temporary(found),match]
  pos=strpos(temp,root) & len=strlen(root)
 ; temp=strmid(temp,0,pos)+
  temp=strmid(temp,pos+len,strlen(temp))
 endif
endrep until match eq ''
count=n_elements(found)

return,found
end
