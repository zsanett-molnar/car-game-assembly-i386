.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc
include macro.inc
include masina.inc
includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "GTA",0
area_width EQU 345
area_height EQU 590
area DD 0
mesaj_eroare DB "Dreptunghi in afara matricii de pixeli", 10, 0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
arg5 EQU 24
COLOR_RED EQU 0FF0000h

symbol_width EQU 10
symbol_height EQU 20

masina_latime EQU 60
masina_inaltime EQU 80
include digits.inc
include letters.inc
include masina.inc

;buton1:
button1_x EQU 1
button1_y EQU 1

button2_x EQU 110
button2_y EQU 1

button3_x EQU 225
button3_y EQU 1  

button_latime EQU 105
button_lungime EQU 550

masina_utilizator_x EQU 140 
masina_utilizator_y EQU 500

masina1_x EQU 28
masina1_y EQU 3
masina2_x EQU 130
masina2_y EQU 3
masina3_x EQU 250
masina3_y EQU 3

;buton1 : 1,1 latime 150, 220 
;buton2: 110, 1 latime 150 , 220
;buton2: 225, 1 latime 150, 220 

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp




make_masina proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'W'
	sub eax, 'W'
	lea esi, masina
	jmp draw_masina
	

	
draw_masina:
	mov ebx, masina_latime
	mul ebx
	mov ebx, masina_inaltime
	mul ebx
	add esi, eax
	mov ecx, masina_inaltime
	
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, masina_inaltime
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, masina_latime
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	cmp byte ptr [esi], 1
	je simbol_pixel_rosu
	cmp byte ptr [esi], 2
	je simbol_pixel_visiniu
	cmp byte ptr [esi], 3
	je simbol_pixel_albastru
	cmp byte ptr [esi], 4
	je simbol_pixel_negru
	
	
simbol_pixel_alb:
	mov dword ptr [edi], 0a9a5a4h
	jmp simbol_pixel_next
	
simbol_pixel_rosu:
	mov dword ptr [edi], 0FF0000h
	jmp simbol_pixel_next

simbol_pixel_visiniu:
	mov dword ptr [edi], 08B0000h
	jmp simbol_pixel_next

simbol_pixel_albastru:
	mov dword ptr [edi], 000008Bh
	jmp simbol_pixel_next
	
simbol_pixel_negru:
	mov dword ptr [edi], 0000000h
	jmp simbol_pixel_next
	
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_masina endp

make_masina_macro macro masina_x, masina_y, x, y
	push y
	push x
	push masina_y
	push masina_x
	call make_masina
	add esp, 16
endm



line_horizontal macro x, y, len, color
local bucla_line
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len
bucla_line:
	mov dword ptr[eax], color
	add eax, 4
	loop bucla_line
endm
	
line_vertical macro x, y, len, color
local bucla_line
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, len
bucla_line:
	mov dword ptr[eax], color
	add eax, area_width * 4
	loop bucla_line
endm




; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm
	

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0a9a5a4h
	push area
	call memset
	add esp, 12

initializare_joc:
	
	
	line_vertical 108, 0, area_height,  0ffffffh 
	line_vertical 220, 0, area_height,  0ffffffh
	;apel5 draw_rectangle, masina_utilizator_x, masina_utilizator_y, 50, 60, 0FF69B4h
	make_masina_macro macro 140, 500, 60, 80
	
jmp afisare_litere
	
evt_click:
	
buton1:
	mov eax, [ebp+arg2]
	cmp eax, button1_x
	jl button_fail
	cmp eax, button1_x + button_latime
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, button1_y
	jl button_fail
	cmp eax, button1_y + button_lungime
	jg button_fail
	;s-a dat click in buton
	;desenare in stanga
	; apel5 draw_rectangle, masina_utilizator_x, masina_utilizator_y, 50, 60, 0a9a5a4h
	; apel5 draw_rectangle, 25, 500, 50, 60, 0FF69B4h
	
; buton2:
	; mov eax, [ebp+arg2]
	; cmp eax, button1_x
	; jl buton1
	; cmp eax, button1_x + button_latime
	; jg buton2
	; mov eax, [ebp+arg3]
	; cmp eax, button1_y
	; jl button_fail
	; cmp eax, button1_y + button_lungime
	; jg button_fail
	;s-a dat click in buton
	;desenare in stanga
	; apel5 draw_rectangle, masina_utilizator_x, masina_utilizator_y, 50, 60, 0a9a5a4h
	; apel5 draw_rectangle, masina_utilizator_x - 115 , masina_utilizator_y, 50, 60, 0FF69B4h
	; jmp evt_click
	
	

	
	
	jmp evt_timer
	
button_fail : 

	
	
evt_timer:
	inc counter

afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	;scriem un mesaj
	
	
	
	

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
