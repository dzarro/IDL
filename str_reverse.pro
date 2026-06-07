;+
; Project     : SDAC
;                  
; Name        : STR_REVERSE
;               
; Purpose     : Reverse string elements
;                             
; Category    : strings utility 
;               
; Syntax      : IDL> out_string = str_reverse(in_string)
;
; Inputs:     : IN_STRING = input string (scalar or array)
;              
; Outputs     : OUT_STRING = IN_STRING with elements reversed
;
; Keywords    : NO_COPY = set to discard IN_STRING
;                          
; History     : 4-Jun-2026, Zarro (Retired) - written
;               
; Contact     : dzarro@solar.stanford.edu
;-

function str_reverse,in_string,no_copy=no_copy

if ~isa(in_string,/string) then return,''

no_copy=keyword_set(no_copy)

if no_copy then begin
 temp=byte(temporary(in_string))
 temp=reverse(temporary(temp))
 return,string(temporary(temp))
endif else return,string(reverse(byte(in_string)))

end
