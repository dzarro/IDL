;+
; Project     : VSO
;
; Name        : BUFF2ARR
;
; Purpose     : Convert a buffer byte array into a string array
;
; Category    : utility string
;
; Syntax      : IDL> ostring=byte2arr(ibyte)
;
; Inputs      : IBYTE = byte array
;               
; Outputs     : OSTRING = string array equivalent
;
; Keywords    : COUNT = # elements in OSTRING
;
; History     : 11-September-2025 Zarro (Consultant/Retired) - written           
;-

function buff2arr,ibyte,count=count

count=0
if ~is_byte(ibyte) then return,''

istring=string(ibyte)
temp=get_temp_file()
openw,lun,temp,/get_lun
printf,lun,istring
free_lun,lun

ostring=rd_ascii(temp)
count=n_elements(ostring)

file_delete,temp
return,ostring
end
