pro wrapper,_ref_extra=extra,program=program

mprint,'In wrapper',_extra=extra

if is_string(program) then begin
 type=prog_type(program)
 case 1 of
  type eq 1: call_procedure,program,_extra=extra
  type eq 2: out=call_function(program,_extra=extra)
  else: mprint,'Unknown program type',_extra=extra
 endcase
endif


return
end
 



