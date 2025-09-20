;+
; Project     : VSO
;
; Name        : SOCK_SENDVAR
;
; Purpose     : Send variable to an open socket
;
; Category    : sockets
;
; Inputs      : LUN = socket logical unit number
;               NAME = string name of variable
;               VALUE = variable value
;
; Outputs     : None
;
; Keywords    : ERR = error string
;               FILE = name is a filename string
;               COMMAND = name is a command string
;               HELP = return help on name
;               GET = get variable with name 
;               STATUS = get IDL bridge status
;               MAIN_LEVEL = send variable to main level on server
;               COMPESSED = data is compressed
;               JSON = send name and value as JSON object
;               OUT_DIR = output directory on SERVER to upload file
;
; History     : 22-Nov-2015, Zarro (ADNET) - written
;               8-Sep-2025, Zarro (Retired) - added OUT_DIR
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

pro sock_sendvar,lun,name,value,err=err,verbose=verbose,file=file,command=command,$
            compressed=compressed,help=help,print=print,get=get,session=session,$
            nowait=nowait,status=status,main_level=main_level,json=json,out_dir=out_dir,_extra=extra

err=''
if ~is_number(lun) then begin
 err='Socket unit number not entered.'
 mprint,err
 pr_syntax,'sock_sendvar,socket_lun,variable_name,variable_value'
 return
endif

if ~is_socket(lun) then begin
 err='Client-Server not connected.'
 mprint,err
 return
endif

verbose=keyword_set(verbose)
command=keyword_set(command)
file=keyword_set(file) || file_test2(name)
if is_blank(out_dir) then out_dir=''
help=keyword_set(help)
print=keyword_set(print)
get=keyword_set(get)
nowait=keyword_set(nowait)
status=keyword_set(status)
main_level=keyword_set(main_level)
json=keyword_set(json)

if ~status && is_blank(name) then begin
 err='Data or File name not entered.'
 mprint,err
 return
endif

if is_blank(session) then session=session_id()

case 1 of
 status: begin
  format='status'
  value=''
 end
 file: begin
  format='file' 
  if ~file_test2(name) then begin
   err='File not found: "'+name+'"'
   mprint,err
   return
  endif
  value=name
 end
 command: begin
  format='command'
  value=name
 end
 help: begin
  format='help'
  value=name
 end
 print: begin
  format='print'
  value=name
 end
 get: begin
  format='get'
  value=''
 end  
 else: format='data'
endcase

if n_elements(value) eq 0 then begin
 err='Unrecognized input value.'
 mprint,err
 return
endif

;-- convert value into a byte stream

compressed=byte(keyword_set(compressed))
if file then begin
 type=1
 bdata=file_stream(value,compress=compressed,err=err,bsize=bsize,osize=dimensions)
 help,compressed,bdata,bsize,dimensions
endif else bdata=data_stream(value,type=type,dimensions=dimensions,err=err,bsize=bsize)

if is_string(err) then return

;-- create header with byte stream parameters
 
if keyword_set(json) then begin
 header={action:'execute',command:name}
endif else begin
 header={name:name,format:format,compressed:compressed,bsize:bsize,type:type,dimensions:dimensions,$
        session:session,nowait:nowait,verbose:verbose,main_level:main_level,out_dir:out_dir}
endelse
jheader=json_serialize(header,/lower)
hdata=data_stream(jheader,bsize=hsize)


if 1 then begin
 case 1 of 
  file: begin
   mprint,'Sending file "'+name+'"'
   if is_string(out_dir) then mprint,'To server directory "'+out_dir+'"'
  end
  command: mprint,'Sending command "'+name+'"'
  get: mprint,'Requesting variable "'+name+'"'
  status: mprint,'Requesting status'
  else: mprint,'Sending variable "'+name+'"'
 endcase
endif

;-- send the header and data

if keyword_set(json) then writeu,lun,jheader else begin
 writeu,lun,hsize
 writeu,lun,hdata
 sock_writeb,lun,bdata,err=err,verbose=verbose
endelse
flush,lun
destroy,bdata

return & end
