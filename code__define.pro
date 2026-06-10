
function code::init,program,_ref_extra=extra

self.code=ptr_new('',/all)

if is_string(program) then self->load,program,_extra=extra

return,1

end

;------------------------------------------------------
;--  compile program in memory

pro code::compile,_ref_extra=extra,err=err

err=''
code=self->getprop(/code,err=err)
if is_string(err) then return
compile,code,_extra=extra,err=err

return & end

;---------------------------------------------------------
;-- load program into memory

pro code::load,program,_ref_extra=extra

p=prog_type(program,_extra=extra,code=code)

if (p gt 0) && is_string(code) then *self.code=code

return & end

;---------------------------------------------------------
;-- inject source code into program

pro code::inject,source,line,err=err,_ref_extra=extra

err=''
code=self->getprop(/code,err=err)

if is_blank(code) then begin
 err='No program loaded.'
 mprint,err,_extra=extra
 return
endif

if is_blank(source) then begin
 err='Injected source code must be non-blank string.'
 mprint,err,_extra=extra
 return
endif

if ~is_number(line) then begin
 err='Input line number must be numeric.'
 mprint,err,_extra=extra
 return
endif

np=n_elements(code)
if abs(line) ge np then begin
 err='Line number exceeds program size.'
 mprint,err,_extra=extra
 return
endif

if n_elements(source) eq 1 then begin
 scode='"'+source+'"'
 scode='s=execute('+scode+')'
endif else scode=source

;-- insert code and compile new source code

new_code=[code[0:line-1],scode,code[line:np-1]]
compile,new_code,err=err,_extra=extra

return & end

;--------------------------------------------------------
;-- replace string text in program with new text

pro code::replace,old,new,err=err,_ref_extra=extra

err=''

code=self->getprop(/code,err=err)
if is_blank(code) then begin
 err='No program loaded.'
 mprint,err,_extra=extra
 return
endif

if ~scalar_string(old) || ~scalar_string(new) then begin
 err='Old and new strings must be scalar non-blank values.
 mprint,err,_extra=extra
 return
endif

new_code=str_repv(code,old,new,/fold,count=count)

if count eq 0 then begin
 mprint,'Nothing to replace.',_extra=extra
 return
endif

compile,new_code,err=err,_extra=extra

return & end

;---------------------------------------------------------
pro code::cleanup

ptr_free,self.code
         
return
end
      
;------------------------------------------------------------

pro code__define                 

void={code, code:ptr_new(), inherits gen}

return & end
