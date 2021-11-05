.386
.model flat, stdcall
option casemap :none
include includes\windows.inc
include includes\masm32.inc
include includes\kernel32.inc
include includes\macros\macros.asm
includelib includes\masm32.lib
includelib includes\kernel32.lib
include includes\msvcrt.inc
includelib includes\msvcrt.lib
BSIZE equ 8
maxBitCount equ 8
maxBitCount_1 equ 16
.data
crnt_digit_number db 0;
msg db 10,"Program result = ",0
ifmt db "%d",0;
enter_in db 10,13," ",0
final_rez sdword ?
rez db 0 
b dw 0000000000000000b 
stdout DWORD ? 
stdin DWORD ? 
count_read DWORD ? 
buffer_key_2 db BSIZE dup (0)
.data?
buffer_key_1 db BSIZE dup (?)
.code
start:
invoke AllocConsole 
invoke GetStdHandle, STD_INPUT_HANDLE 
mov stdin,eax 
invoke GetStdHandle, STD_OUTPUT_HANDLE 
mov stdout,eax 
@1:
invoke ReadConsoleInput, stdin, ADDR buffer_key_1, BSIZE, ADDR count_read 
cmp crnt_digit_number, maxBitCount;
je @2
cmp [buffer_key_1+04d], 1h 
jne @1 
cmp [buffer_key_1+14d], 0 
je @1
cmp [buffer_key_1+14d], 0dh
je @2 
cmp [buffer_key_1+14d], 30h 
jl @1 
cmp [buffer_key_1+14d], 31h 
ja @1
invoke WriteConsole, stdout, ADDR [buffer_key_1+14d], 1, 0, 0 
mov al, rez 
shl al,1
mov rez, al
xor al, al 
mov al, [buffer_key_1+14d] 
sub al, 30h
add rez, al 
add crnt_digit_number,1;
jmp @1
@2:
mov al, rez
mov cl,1
rol al, cl
not al
Cbw
shl ax, 2
mov b, ax
invoke crt_printf, offset msg
mov crnt_digit_number,0
cycle_for:
shl b,1;
JC CF_1
JMP CF_0
CF_1: 
invoke crt_printf, offset ifmt, 1
JMP DEFALUT
CF_0: 
invoke crt_printf, offset ifmt, 0
JMP DEFALUT
DEFALUT:
inc crnt_digit_number
cmp crnt_digit_number, maxBitCount_1
jne cycle_for
invoke crt_printf, offset enter_in;, 1 ;
exit
end start