;+
; Project     : VSO
;
; Name        : IS_HASH
;
; Purpose     : check if input is a valid HASH object
;
; Category    : objects, utility
;
; Syntax      : IDL> valid=is_hash(input,ordered=ordered)
;
; Inputs      : INPUT = variable to check
;
; Outputs     : OUTPUT = 1/0
;
; Keywords    : ORDERED = 1 ordered HASH
;
; History     : 11-August-2017 Zarro (ADNET)   - written
;                8-October-2019, Zarro (ADNET) - added check for vector input           
;                2-September-2025, Zarro (Consultant/Retired) - added ORDERED keyword
;
; Contact     : dzarro@solar.stanford.edu
;-

function is_hash,input,ordered=ordered

ordered=0b
if ~is_object(input) then return,0b

error=0
catch, error
if (error ne 0) then begin
 catch,/cancel
 message,/reset
 chk=strupcase(obj_class(input[0]))
 ordered=chk eq 'ORDEREDHASH'
 return,((chk eq 'HASH') || ordered)
endif


chk=strupcase(obj_class(input)) 
ordered=chk eq 'ORDEREDHASH'

return, ((chk eq 'HASH') || ordered)
end
