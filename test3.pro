function test3,a,key1=key1,key2=key2

if n_elements(a) eq 0 then a=2

b=a^2

if n_elements(key1) eq 0 then key1=3

key2=key1^2

return,b

end