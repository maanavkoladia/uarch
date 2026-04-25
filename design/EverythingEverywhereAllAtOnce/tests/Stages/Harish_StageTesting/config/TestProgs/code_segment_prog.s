.orig x0000
.code

# code here
mov $val, %eax
mov (%eax), %ebx


.orig x0800
.data

val:
.long 0x50000000



.orig x2000
.code 



.orig xfefff
.data 