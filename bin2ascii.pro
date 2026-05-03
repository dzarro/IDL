pro bin2ascii,bfile,afile,err=err

if is_blank(bfile) || is_blank(afile) then begin
 err='Missing input/output filenames.'
 pr_syntax,'bin2ascii,"binary filename","ascii filename"'
 return
endif

barr=file_stream(bfile,err=err)
if is_string(err) then return

aarr=idl_base64(barr)
openw,lun,afile,/get_lun
printf,lun,aarr
close_lun,lun

return & end
