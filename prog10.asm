.386
.model flat, stdcall
option casemap :none
include includes\kernel32.inc
include includes\msvcrt.inc
include includes\windows.inc
include includes\macros\macros.asm
includelib includes\masm32.lib
includelib includes\kernel32.lib
includelib includes\msvcrt.lib

BSIZE equ 4
.data
	rez dd 0
	mn_dec dd 10d
	mn_div dd 10d
	
	soob_err db "Division by zero!"
	
	soob_a db "Enter a: "
	a dd ?
	soob_b db "Enter b: "
	b dd ?
	soob_c db "Enter c: "
	@c dd ?
	soob_d db "Enter d: "
	d dd ?
	soob_e db "Enter e: "
	e dd ?
	soob_f db "Enter f: "
	f dd ?
	soob_g db "Enter g: "
	g dd ?
	soob_h db "Enter h: "
	h dd ?
	soob_k db "Enter k: "
	k dd ?
	soob_m db "Enter m: "
	m dd ?
	cifri dd 0
	stdout dd ?
	stdin dd ?
	
	cdkey dd ?
	
	soob_rez db "(ab+cd+e/f+gh)/(k+m)= "
	perenos db 0ah, 0dh, 0
	
	buffer_key_1 db ?
	buffer_key_2 db ?
	
	soob_1 db ?
.code
start:
	invoke GetStdHandle, STD_INPUT_HANDLE
	mov stdin, eax
	
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	mov stdout, eax
	
	lea esi, [soob_a]
	call @enter
	mov a, eax
	
	lea esi, [soob_b]
	call @enter
	mov b, eax
	
	lea esi, [soob_c]
	call @enter
	call zero
	mov @c, eax
	
	lea esi, [soob_d]
	call @enter
	mov d, eax
	
	lea esi, [soob_e]
	call @enter
	mov e, eax
	
	lea esi, [soob_f]
	call @enter
	call zero
	mov f, eax
	
	lea esi, [soob_g]
	call @enter
	mov g, eax
	
	lea esi, [soob_h]
	call @enter
	mov h, eax
	
	lea esi, [soob_k]
	call @enter
	mov k, eax
	
	lea esi, [soob_m]
	call @enter
	mov m, eax
	
	invoke WriteConsole, stdout, offset soob_rez, 21d, 0, 0
	
	mov eax, a
	mov ebx, b
	mul ebx ; ab
	mov a, eax
	
	mov eax, @c
	mov ebx, d
	mul ebx ; сd
	mov @c, eax
	
	mov eax, e
	mov ebx, f
	div ebx; e/f
	mov e, eax
	
	mov eax, g
	mov ebx, h
	mul ebx ; gh
	mov g, eax
	
	mov eax, k
	add eax, m; k+m
	mov k, eax 
	
	mov eax, a
	add eax, @c
	add eax, e
	add eax, g
	mov ebx, k
	div ebx
	

	
	call @out
	
	exit
	
	
	
	@enter proc
		
		lea edi, [soob_1]
		mov ecx, 9d
		rep movsb
		invoke WriteConsole, stdout, offset [soob_1], 9d, 0, 0
	
		@1:
			cmp cifri,4
		    je @2
			invoke ReadConsoleInput, stdin, offset [buffer_key_1], BSIZE, offset cdkey ; читаем все из консоли в буфер buffer_key_1

			cmp [buffer_key_1+10d], 0dh ; проверяется нажатие клавиши Enter
			je @2 ; если ENTER нажата, то выходим из цикла ввода
			
			cmp [buffer_key_1+14d], 0 ; если ничего не введено, то идем опять на опрос консоли
			je @1
			
			cmp [buffer_key_1+14d], 30h ; Если введеный код меньше кода цифры то на начало ввода
			jl @1 ; проверка если введеный код меньше кода цифры
			
			cmp [buffer_key_1+14d], 3Ah ; Если введеный код больше кода цифр, то опять на ввод
			jnc @1  ; проверка переноса - его не будет если код больше кода цифры

			cmp [buffer_key_1+04d], 1h ; Если нажата клавиша - именно нажата!!!
			jne @1 ; условие - если не равно 1, то клавиша не нажата (может мышка, а может событие какое-то) - идти на опрос консоли
			
			invoke WriteConsole, stdout, offset [buffer_key_1+14d], 1, 0, 0 ; вывести символ нажатой клавиши (будут только цифры)
			
			mov eax, rez ; считываем формируемое число
			mul mn_dec; если введена еще одна цифра, то значить увеличиваем порядок на 10
			mov rez, eax ; сохраняем формируемое число
			
			xor eax, eax ; обнуляем регистр eax
			mov al, [buffer_key_1+14d] ; в самый младший байт регистра eax записываем код введеной цифры
			sub al, 30h ; преобразуем из кода в цифру
			add rez, eax ; прибавляем к формируемому числу
			inc cifri
			jmp @1
			
		@2:
			cmp cifri, 1
			    je @1
		    cmp cifri, 0
			    je @1
			mov [buffer_key_1+10d], 00h
			invoke ReadConsoleInput, stdin, offset [buffer_key_1], BSIZE, offset cdkey ; чистка буфера клавиатуры (читаем от туда все что есть)	
					
			invoke WriteConsole, stdout, offset [perenos], 2d, 0, 0 ; перейти на новую строку
			mov cifri, 0
			mov eax, rez
			mov rez, 0
			ret
	@enter endp

	@out proc
		xor ecx, ecx ; подготовка счетчика - обнуление
		xor edx, edx ; будет использоввн для приведения значения к размерности чисел
	
	@3:	
		mov ebx, mn_div
		div ebx 	; деление числа на 10, чтобы представить его в десятичной системе счиления
					; будет браться остаток от деления и к нему прибавляться 30h, чтобы найти ASCII- код числа для вывода на экран
					; при делении первый остаток от деления дает нам правую цифру, которая должна быть выведена поседней
		add edx, 30h	; добавление 30h для нахождения кода числа (преобразвание в букву)
		push edx	; временное сохранение в стеке всех чисел - чтобы их перевернуть - сделать парвильный порядок символов
		xor edx, edx; обнуление edx, так как будет использовать у него только dl для записи только одной цифры
		inc ecx		; увеличение счетчика - сколько цифр- столько раз будет увеличен счетчик
		cmp eax, 0	; если делимое равно нулю (все остатки от деления найдены) то значить все цифры обработыны
		jne @3		; переход на обработку следующей цифры, если в регистре еще есть значение
					; если не равно, то переход
		
		mov edi, 0	; обнуление edi, который будет использоваться как счетчик для доступа к ячейкам
					; памяти куда будут записаны символы выводимых цифр для числа
	@4:	
		pop edx		; чтение ASCII-кода цифры из стека (читается сначала старший разряд, так как он был помещен последним в стек)
		mov [buffer_key_2 + edi], dl ; по адресу буфера вывода сохраняем только один байт, соотвутствующий цифре
		inc edi		; переходим к следующему байту
		dec ecx		; уменьшаем счетчик-количество цифр в числе (был получен в предыдушщем цикле)
		jnz @4		; пока не обработаны все цифры чистаем из стека следующую цифру и ложем в буфер
					; пока не ноль - пока ecx больше нуля
	invoke WriteConsole, stdout, offset [buffer_key_2], 10d , 0, 0
	invoke WriteConsole, stdout, offset [perenos], 2d, 0, 0 ; перейти на новую строку
	ret
	@out endp

	zero proc
		cmp eax, 0
		je @exit
		ret
		
		@exit:
			invoke WriteConsole, stdout, offset [soob_err], 17d, 0, 0
			invoke WriteConsole, stdout, offset [perenos], 2d, 0, 0 ; перейти на новую строку
			exit
	zero endp
end start