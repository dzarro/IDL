
function snap_dir,dir,times=times,sizes=sizes,exclude_files=exclude_files,count=count

count=0 & times=0L & sizes=0L

if ~is_dir(dir) then return,''
ldir=local_name(dir)

files=file_search(concat_dir(dir,'*'), /fully_qualify,/test_regular,/expand_environment,/match_initial_dot,/nosort,count=count)
if count eq 0 then return,''

if is_string(exclude_files) then begin
 ofiles=str_remove(file_basename(files),exclude_files,count=rcount,index=index)
 if rcount eq 0 then return,''
 if rcount lt count then files=files[index]
endif

info=file_info(files)
sizes=info.size
times=info.mtime
snap=strcompress(files+'|'+string(times)+'|'+string(sizes),/remove_all)

return,snap
end

