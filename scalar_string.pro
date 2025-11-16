;+
; Project     : VSO
;
; Name        : SCALAR_STRING
;
; Purpose     : Check if input is a scalar string 
;
; Category    : utility system 
;
; Syntax      : IDL> chk=scalar_string(item)
;
; Inputs      : ITEM = string to check
;
; Outputs     : 1/0 = if is/not scalar string
;
; Keywords    : ALLOW_BLANK = allow blank input string
;               ERR = error message
;             
; History     : 17 November 2025 Zarro (Consultant/Retired) 
;
; Contact     : dzarro@solar.stanford.edu
;-

function scalar_string,input,allow_blank=allow_blank,err=err

err=''
chk=is_string(input,blank=allow_blank,/scalar)

if ~chk then begin
 if keyword_set(allow_blank) then err='Non-scalar string input expected' else err='Non-scalar non-blank string input expected'
endif

return,chk

end