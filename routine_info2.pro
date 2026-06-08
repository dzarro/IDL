function routine_info2,routine,_extra=extra,err=err,verbose=verbose

;-- trap errors

err=''
error=0
catch,error
if (error ne 0)  then begin
 err=err_state()
 if keyword_set(verbose) then mprint,err,_extra=extra
 catch,/cancel
 message,/reset
 error=0
 return,null()
endif

return,routine_info(routine,_extra=extra)

end