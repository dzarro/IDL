;+
; Project     : VSO
;
; Name        : STR_TOARR
;
; Purpose     : Convert string with CR's or LF's into an array of separated lines
;
; Category    : utility string
;
; Syntax      : IDL> output=str_toarr(input)
;
; Inputs      : INPUT = scalar string to convert
;               
; Outputs     : OUTPUT = array of strings  
;
; History     : 11-September-2025 Zarro (Consultant/Retired) - written
;              
;-

function str_toarr,iarray

if ~is_string(iarray) then return,''
if n_elements(iarray) eq 1 then return,byte2arr(byte(iarray)) else return,iarray

;return,byte2str(byte(iarray),newline=13,skip=2) else return,''

end