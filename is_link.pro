;+
; Project     : VSO
;
; Name        : IS_LINK
;
; Purpose     : Check if input file or directory is a link 
;
; Category    : utility system 
;
; Syntax      : IDL> chk=is_link(item)
;
; Inputs      : ITEM = string scalar or array of names to check
;
; Outputs     : CHK = byte scalar or array of items that are linked
;
; Keywords    : DIRECTORY = limit check to directory
;               FILE = limit check to file
;
; History     : 17 November 2025 Zarro (Consultant/Retired) - written
;
; Contact     : dzarro@solar.stanford.edu
;-

function is_link,item,directory=directory,file=file

if is_blank(item) then return,0b
np=n_elements(item)
if np eq 1 then out=0b else out=bytarr(np)
if is_windows() then return,out

info=file_info(item)

case 1 of
 keyword_set(directory): chk=where(info.exists and info.directory and info.symlink and info.dangling_symlink,count)
 keyword_set(file): chk=where(info.exists and info.regular and info.symlink and info.dangling_symlink,count)
 else:chk=where(info.exists and info.symlink and info.dangling_symlink,count)
endcase

if count gt 0 then out[chk]=1b
if np eq 1 then out=out[0]

return,out
end