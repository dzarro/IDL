function routine_info2,routine,_extra=extra,err=err

;-- trap errors

err=''
error=0
catch,error
if (error ne 0)  then begin
 err=err_state()
 mprint,err
 catch,/cancel
 message,/reset
 error=0
 return,null()
endif

return,routine_info(routine,_extra=extra)

end