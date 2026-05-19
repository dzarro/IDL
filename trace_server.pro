;+
; Project     : HESSI
;
; Name        : TRACE_SERVER
;
; Purpose     : return available TRACE data server
;
; Category    : synoptic sockets
;
; Inputs      : None
;
; Outputs     : SERVER = TRACE data server name
;
; Keywords    : NETWORK = returns 1 if network to that server is up
;               PATH = path to data
;               LEVEL = 0 or 1 for processing level [def = 0]
;
; History     : 2-Jan-2022, Zarro (ADNET/GSFC) - written
;               9-May-2026 - Zarro (Retired) - changed FLEVEL to LEVEL
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function trace_server,_ref_extra=extra, path=path,network=network,verbose=verbose,$
                      level=level,err=err

err=''
verbose=keyword_set(verbose)  
if ~is_number(level) then level=0 else level=0 > fix(level) < 1
if level eq 1 then begin   
 servers=['https://umbra.nascom.nasa.gov','https://www.lmsal.com']
 paths=['/trace_lev1','/solarsoft/trace/level1']
endif else begin
 servers=['https://umbra.nascom.nasa.gov']
 paths=['/trace00']  
endelse

;-- find first available server

for i=0,n_elements(servers)-1 do begin
 server=servers[i]
 path=paths[i]
 url=server+path
 network=have_network(url,_extra=extra,verbose=verbose,/full_path)
 if network then break
endfor

if ~network then err='Network connection currently unavailable.'
mprint,err,/info

if verbose then mprint,'Searching '+server+' for Level '+trim(level)+' files.'
return,server

end
