;+
; Project     : VSO
;
; Name        : IS_LIST
;
; Purpose     : check if input is a valid LIST object
;
; Category    : objects, utility
;
; Syntax      : IDL> valid=is_list(input)
;
; Inputs      : INPUT = variable to check
;
; Outputs     : OUTPUT = 1/0
;
; History     : 11-August-2017 Zarro (ADNET) - written
;               11-November-2020, Zarro (ADNET) - switched to checking OBJ_CLASS
;               4-October-2025, Zarro (Consultant/Retired) - added check for vector input      
;
; Contact     : dzarro@solar.stanford.edu
;-

function is_list,input

if ~is_object(input) then return,0b

catch, error
if (error ne 0) then begin
 catch,/cancel
 message,/reset
 return,strupcase(obj_class(input[0])) eq 'LIST'
endif

return,strupcase(obj_class(input)) eq 'LIST'

end
 
