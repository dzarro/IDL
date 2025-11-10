;+
; Project     : VSO
;
; Name        : SSW_MIRROR
;
; Purpose     : Mirror an SSW directory (and its subdirectories) 
;
; Category    : utility system sockets 
;
; Syntax      : IDL> ssw_mirror,target
;
; Inputs      : DIR_NAME = target directory name to mirror. Must have $SSW in name (e.g. $SSW/gen/idl)
;                        = or package file name with keywords (cf. PERL/Mirror)
;
; Outputs     : None
;
; Keywords    : ERR = error string
;               RUN = set to actually execute mirror
;               LOG = summary log
;               VERBOSE = set to print log 
;
; History     : 13 February 2020 Zarro (ADNET)
;
; Contact     : dzarro@solar.stanford.edu
;-

pro ssw_mirror,target,err=err,_ref_extra=extra,no_restore=no_restore

common ssw_mirror,latest_version,sav_m

err=''
ssw=chklog('SSW')
if is_blank(ssw) then begin
 err='$SSW not defined.'
 mprint,err
 return
endif

if is_blank(target) then begin
 err='Enter directory or package name.'
 mprint,err
 return
endif

if ~exist(latest_version) && have_proc('restore_mods') && ~keyword_set(no_restore) then begin
 restore_mods
 latest_version=1
endif

if obj_valid(sav_m) then m=sav_m else m=obj_new('mirror')

if strpos(target,'$SSW') gt -1 then begin
 temp=str_rep(target,'$SSW','')
 temp=str_rep(temp,'\','/')
 if is_blank(temp) then begin
  err='Include name of SSW subdirectory to mirror.'
  mprint,err
  return
 endif
 source=ssw_server()+'/solarsoft'
 source=source+temp
 
 m->set,source=source,target=target
 m->mirror,_extra=extra,err=err,/recurse
endif else m->mirror,target,_extra=extra,err=err

sav_m=m

 
return & end
