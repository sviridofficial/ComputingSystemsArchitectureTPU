.386
.model flat, stdcall
option casemap:none 
include includes\msvcrt.inc
includelib includes\msvcrt.lib
.data
constA dd 5
y1 dd 0
y2 dd 0
xResult db "x= %d ", 0
a_out db "a = %d", 10, 13, 0
y_out db "y = %d ", 0
yh_out db "y = %08X", 10, 13, 0
y1_out db "y1 = %d ", 0
y2_out db "y2 = %d ", 0
.data?
answer dd ?
.code
start:
invoke crt_printf, offset a_out, constA 
mov ebx,0 ; ebx=0
cycl:
cmp ebx, 16 
je return 
jmp body
body:
cmp ebx,3 
jge else_if_y1
mov eax,4 
sub eax,ebx 
mov dword ptr [y1], eax 
jmp end_if_y1
else_if_y1:
mov eax,constA 
add eax, ebx 
mov dword ptr [y1], eax 
end_if_y1:
mov eax,ebx 
test eax,1
jnz nechet 
jz chet 
chet:
mov dword ptr [y2], 2 
jmp result
nechet:
mov eax,constA 
add eax,2 
mov dword ptr [y2], eax 
jmp result
result:
mov eax, y1
add eax, y2
mov dword ptr [answer], eax
invoke crt_printf, offset xResult, ebx
invoke crt_printf, offset y1_out, y1
invoke crt_printf, offset y2_out, y2
invoke crt_printf, offset y_out, answer
invoke crt_printf, offset yh_out, answer
inc ebx ;x++
jmp cycl; повтор цикла
return:
ret ; выход
end start