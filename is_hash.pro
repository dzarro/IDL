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
; History     : 11-August-2017 Zarro (ADNET) - written
;                8-October-2019, Zarro (ADNET)
;                 -added check for vector input
;                22-November-2020, Zarro (ADNET)
;                2-September-2025, Zarro (Retired)
;
; Contact     : dzarro@solar.stanford.edu
;-

function is_hash,input

ordered=0b
if ~is_object(input) then return,0b

chk=strupcase(obj_class(input)) 
ordered=chk eq 'ORDEREDHASH'

return, ((chk eq 'HASH') || ordered)
end
