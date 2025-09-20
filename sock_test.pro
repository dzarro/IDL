

;-- read file into byte array to send to socket

openr,lun,'test.xml',/get_lun
bsize=(fstat(lun)).size
data=bytarr(bsize,/nozero)
readu,lun,data
free_lun,lun

;-- open socket 

socket,slun,'127.0.0.1',8500,/get_lun,error=error,/rawio

;-- check for any errors

print,error

;-- write file to socket and close it

writeu,slun,data,transfer_count=count
free_lun,slun

;-- check that write transfer count matches file byte size. They should match if write was successful

help,count,bsize

end

