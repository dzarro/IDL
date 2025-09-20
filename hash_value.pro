
function hash_value,item,key,found=found,fold_case=fold_case,verbose=verbose,sitem=sitem

found=0b 
fold_case=keyword_set(fold_case)
verbose=keyword_set(verbose)
if ~is_hash(item) || is_blank(key) then return,null()

;-- check for key at top-level

ekey=strtrim(key,2)
ikey=strlowcase(ekey) & ukey=strupcase(ekey)
case 1 of
 item->haskey(ekey) : value=item[ekey] 
 item->haskey(ukey) && fold_case : value=item[ukey]
 item->haskey(ikey) && fold_case : value=item[ikey]
 else: found=0b
endcase

;-- if found then we are done

if n_elements(value) ne 0 then begin
 found=1b & return,value
endif

;-- if not found, then check keys at next level 

keys=item->keys()
np=n_elements(keys)
for i=0,np-1 do begin
 sitem=item[keys[i]]
 if verbose then begin 
   mprint,'Checking '+keys[i]
   help,i,sitem
 endif
 
 if is_hash(sitem) then begin
  value=hash_value(sitem,key,found=found,fold_case=fold_case,verbose=verbose)
  if found then return,value
 endif
 
 if is_list(sitem) then begin
  nl=n_elements(sitem)
  for k=0,nl-1 do begin
   litem=sitem[k] 
   if is_hash(litem) then begin
    dvalue=hash_value(litem,key,found=found,fold_case=fold_case,verbose=verbose)
    if found then begin
	 if exist(value) then value=[value,dvalue] else value=dvalue
	endif
   endif
  endfor
  if exist(value) then return,value
 endif
  
endfor

;-- if here, then no luck finding match

return,null()

end
 
   
