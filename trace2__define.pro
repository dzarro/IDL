;+
; Project     : TRACE2
;
; Name        : TRACE2__DEFINE
;
; Purpose     : Wrapper object to read Level 0 TRACE images
;
; Category    : Ancillary GBO Synoptic Objects
;
; Syntax      : IDL> c=obj_new('trace2')
;
; History     : 1-Jan-2009 - Zarro (ADNET) - written
;               9-May-2026 - Zarro (Retired) - switched from Level 1 to Level 0
;
; Contact     : dzarro@solar.stanford.edu
;-

function trace2::init,_ref_extra=extra

return,self->trace::init(_extra=extra)

end

;------------------------------------------------------------------------------

function trace2::search,tstart,tend,_ref_extra=extra

return,self->trace::search(tstart,tend,flevel=0,_extra=extra)

end

;------------------------------------------------------------------------------

pro trace2__define,void                 

void={trace2,inherits trace}

return & end

