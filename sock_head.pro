;+
; Project     : VSO
;
; Name        : SOCK_HEAD
;
; Purpose     : Wrapper around IDLnetURL object to send HEAD request
;
; Category    : utility system sockets
;
; Syntax      : IDL> header=sock_head(url)
;
; Inputs      : URL = remote URL file name to check
;
; Outputs     : HEADER = response header 
;
; Keywords    : CODE = HTTP status code
;             : HOST_ONLY = only check host (not full path)
;             : SIZE = number of bytes in return content
;             : PATH = input URL is a path
;             : NO_ACCEPT = add "Accept: none" (for testing)
;
; History     : 24-Aug-2011, Zarro (ADNET) - written
;                6-Feb-2013, Zarro (ADNET)
;               - added call to new HTTP_CONTENT function
;               19-Jun-2013, Zarro (ADNET) - renamed to sock_head
;               23-Sep-2014, Zarro (ADNET) - stripped down
;               2-Nov-2014, Zarro (ADNET) - skip callback if no path
;               4-Feb-2015, Zarro (ADNET) 
;               - added check for FTP success code
;               10-Feb-2015, Zarro (ADNET) 
;               - pass input URL directly to IDLnetURL2 to parse
;                 PROXY keyword properties in one place
;               21-Feb-2015, Zarro (ADNET)
;               - added separate check for FTP response headers
;               28-March-2106, Zarro (ADNET)
;               - added "Accept: none" keyword to inhibit download
;               16-Sep-2016, Zarro (ADNET)
;               - added call to URL_FIX to support HTTPS
;               30-Jan-2017, Zarro (ADNET)
;               - added RESPONSE_CODE keyword
;               8-Feb-2017, Zarro (ADNET)
;               - fixed bug with extra '/' added to path
;               11-Nov-2018, Zarro (ADNET)
;               - corrected false-positive debug error message
;               15-Jan-2019, Zarro (ADNET)
;               - removed CLOSE CONNECTION call
;               24-Sep-2019, Zarro (ADNET)
;               - initialized response code
;               3-Oct-2019, Zarro (ADNET)
;               - added call to SOCK_ERROR
;               11-July-2025, Zarro (Cosultant/Retired)
;               - Added browser and redirect checks
;-

function sock_head_callback, status, progress, data  

;-- since we only need the response header, we just read
;   the first set of bytes until a non-zero response code is reached

if exist(data) then begin
 help,status
 mprint,'progress[0] '+trim(progress[0])
 mprint,'progress[1] '+trim(progress[1])
 mprint,'progress[2] '+trim(progress[2])
endif

if (progress[0] eq 1) && (progress[2] gt 0) then return,0

return,1

end

;-----------------------------------------------------------------------------
  
function sock_head,url,_ref_extra=extra,host_only=host_only,browser=browser,location=location,$
               path=path,debug=debug,no_accept=no_accept,headers=headers,used_browser=used_browser,$
			   no_redirect=no_redirect,verbose=verbose,code=code
			   
location=''
code=0
used_browser=0b
verbose=keyword_set(verbose)

if ~is_url(url,_extra=extra,verbose=verbose,/scalar,err=err) then return,''

durl=url_fix(url,_extra=extra)
stc=url_parse(durl)
url_path=stc.path

if keyword_set(host_only) then begin
 url_path='' 
 stc.path=''
 durl=url_join(stc)
endif

if keyword_set(path) then if ~stregex(url_path,'\/$',/bool) then url_path=url_path+'/'

;-- initialize object 

if is_string(headers) then sheaders=headers
if keyword_set(no_accept) then begin
 if is_string(sheaders) then sheaders=[sheaders,'Accept: none'] else sheaders='Accept: none'
endif
 
ourl=obj_new('idlneturl2',durl,url_path=url_path,_extra=extra,debug=debug,headers=sheaders,browser=browser,verbose=verbose) 
       
if is_string(url_path) && (url_path ne '/') then begin
 ourl->setproperty,callback_data=data,callback_function='sock_head_callback'
endif

;-- have to use a catch since canceling the callback triggers it

error=0
catch, error
if (error ne 0) then begin
 if keyword_set(debug) then mprint,err_state()
 catch,/cancel
 message,/reset
 goto, bail
endif

result=oUrl->Get(/string)  

bail: 

if obj_valid(ourl) then begin
 sock_message,ourl,location=location,code=code,resp_array=resp_array,_extra=extra,verbose=verbose
 obj_destroy,ourl
endif

if (code eq 403) && ~keyword_set(browser) then begin
 if verbose then mprint,'Retrying in browser mode...'
 resp_array=sock_head(durl,_extra=extra,host_only=host_only,code=code,ocation=location,verbose=verbose,$
               path=path,debug=debug,no_accept=no_accept,headers=headers,/browser)
 used_browser=1b
endif

if is_url(location) && ~keyword_set(no_redirect) then begin
 if verbose then mprint,'Redirecting to '+location+'...'
 resp_array=sock_head(location,_extra=extra,host_only=host_only,code=code,/no_redirect,verbose=verbose,$
               path=path,debug=debug,no_accept=no_accept,headers=headers,used_browser=used_browser)
endif

return,resp_array
end  
