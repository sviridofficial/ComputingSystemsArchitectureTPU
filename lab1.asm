.386
.model flat,stdcall
option casemap:none

	include includes\kernel32.inc
	include includes\user32.inc
	includelib includes\kernel32.lib
	includelib includes\user32.lib
	include includes\masm32.inc
	
BSIZE equ 15

a equ 10
b equ 11
var_c equ 12
d equ 13
e equ 14
f equ 15
g equ 16
h equ 17
k equ 18
m equ 19

.data
	ifmt db "%d", 0; 
	buf db BSIZE dup(?); 
	ans dd ?; 
	stdout dd ?
	cWritten dd ?
.code
	start:
		mov eax,0
		mov eax, a-b+var_c-d+e+f+g-h+k+m
		mov ans,eax	
		
		invoke GetStdHandle, -11 ; 
		mov ebp, offset ans
		mov esi, 0
		mov ebx,[ebp][esi]
		mov stdout,eax ; 
		invoke wsprintf, ADDR buf, ADDR ifmt, ans
		invoke WriteConsoleA, stdout, ADDR buf, BSIZE,
		ADDR cWritten, 0
		invoke ExitProcess,0
	end start




