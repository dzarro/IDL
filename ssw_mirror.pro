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
; History     : 13 February 2020 Zarro (ADNET) - written
;               13 November 2025 Zarro (Consultant/Retired) - fixed bug with restoring from common
;
; Contact     : dzarro@solar.stanford.edu
;-

pro ssw_mirror,target,err=err,_ref_extra=extra,restore_mods=restore_mods,run=run

common ssw_mirror,latest_version,sav_m,sav_target

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
otarget=target

if ~exist(latest_version) && have_proc('restore_mods') && keyword_set(restore) then begin
 restore_mods
endif

if keyword_set(run) then begin
 if obj_valid(sav_m) && is_string(sav_target) then begin
  if sav_target eq target then m=sav_m else mprint,'Ignoring last scan as target changed from before /run.'
 endif 
endif else begin
 if obj_valid(sav_m) then obj_destroy,sav_m
endelse

if ~obj_valid(m) then m=obj_new('mirror',_extra=extra)
 
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
 m->mirror,_extra=extra,err=err,/recurse,run=run
endif else m->mirror,target,_extra=extra,err=err,run=run

if keyword_set(run) then begin
 if obj_valid(sav_m) then obj_destroy,sav_m 
endif else begin
 sav_m=obj_clone(m) & sav_target=otarget
endelse

obj_destroy,m

return & end
