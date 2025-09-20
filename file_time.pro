;+
; Project     : VSO
;                  
; Name        : FILE_TIME
;               
; Purpose     : Get access and modification file times using FILE_INFO
;                             
; Category    : system utility 
;               
; Syntax      : IDL> time=file_time(file)
;
; Inputs:     : FILE = file name
;
; Outputs     : TIME = file modification time
;
; Keywords    : /ACCESS = return access time
;               /UTC = return time in UTC [def is local]
;               /TAI = return time TAI format
;               /HTTP = return time in HTTP time format
;               
; History     : Written, 15-Nov-2014, Zarro (ADNET)
;               8-Mar-2019, Zarro (ADNET)
;                - removed FILE_TEST
;              20-Mar-2019, Zarro (ADNET)
;                - added FILE_MODTIME
;               6-May-2020, Zarro (ADNET)
;                - corrected bug with converting to UTC when using TAI
;               8-Sep-2025, Zarro (Retired)
;                - added HTTP keyword
;
; Contact     : dzarro@solar.stanford.edu
;-    

function file_time,file,time,access=access,creation=creation,$
               err=err,_extra=extra,tai=tai,utc=utc,http=http

forward_function file_modtime

if (n_elements(file) ne 1) || is_blank(file) then begin
 err='Input must be scalar string.'
 mprint,err
 return,''
endif

chk=file_search(file,count=fcount,/fully_qualify,/expand_envir)
if fcount ne 1 then begin
 err='Input not found.' 
 mprint,err & return,''
endif

dfile=chk[0]
creation=keyword_set(creation)
access=keyword_set(access)
utc=keyword_set(utc) || keyword_set(http)

if access || creation then begin
 stc=file_info(dfile)
 if access then dtime=stc.atime else dtime=stc.ctime
endif else begin
 if since_version('8.5.1') then dtime=file_modtime(dfile) else begin
  stc=file_info(dfile)
  dtime=stc.mtime
 endelse
endelse 
time=systim(0,dtime,utc=utc)

;-- convert to TAI

case 1 of 
 keyword_set(tai)  : time=anytim2tai(time)
 keyword_set(http) : begin
  day=utc2dow(time,/abb)
  time=day+', '+str_replace(time,'-',' ')+' GMT'
 end
 else: nothing=1
endcase

return,time & end
