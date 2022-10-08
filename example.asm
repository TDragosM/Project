.586
.model flat, stdcall , c 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Exemplu proiect desenare",0
area_width EQU 310
area_height EQU 480
area DD 0


; loseMsg DEFB "Mai incearca!\n",0
; winMsg  DEFB "Victorie\n",0

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

button_x1 equ 20
button_x2 equ 50
button_x3 equ 80
button_x4 equ 110
button_x5 equ 140
button_x6 equ 170
button_x7 equ 200
button_x8 equ 230
button_x9 equ 260

button_y1 equ 90
button_y2 equ 120
button_y3 equ 150
button_y4 equ 180
button_y5 equ 210
button_y6 equ 240
button_y7 equ 270
button_y8 equ 300
button_y9 equ 330

button_size equ 30

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc



matrice dd 81 dup('0')

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

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

line_horizontal macro x , y , len, color
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

line_vertical macro x , y , len, color
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
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
	; mov eax, [ebp+arg3]
	; mov ebx, area_width
	; mul ebx
	; add eax, [ebp+arg2]
	; shl eax, 2
	; add eax, area
	; mov dword ptr[eax], 0FF0000h
	; mov dword ptr[eax+4], 0FF0000h
	; mov dword ptr[eax-4], 0FF0000h
	; mov dword ptr[eax+4*area_width], 0FF0000h
	; mov dword ptr[eax-4*area_width], 0FF0000h
	;line_vertical [ebp+arg2], [ebp+arg3], 30, 0FFh
	; mov eax, [ebp+arg2]
	; cmp eax, button_x1
	; jl button_fail
	; cmp eax, button_x9
	; jg button_fail
	; mov eax, [ebp+arg3]
	; cmp eax, button_y1
	; jl button_fail
	; cmp eax, button_y9
	; jg button_fail

a1:
   mov eax, [ebp+arg2]
	cmp eax, button_x1
	jl button_fail
	cmp eax, button_x1+button_size
	jg a2
	mov eax, [ebp+arg3]
	cmp eax, button_y1
	jl button_fail
	cmp eax, button_y1+button_size
	jg b1
	make_text_macro matrice[0] ,area, button_x1+10 ,button_y1+5
a2:
mov eax, [ebp+arg2]
	cmp eax, button_x2
	jl button_fail
	cmp eax, button_x2+button_size
	jg a3
	mov eax, [ebp+arg3]
	cmp eax, button_y1
	jl button_fail
	cmp eax, button_y1+button_size
	jg b2
	make_text_macro matrice[1*4] ,area, button_x2+10 ,button_y1+5
a3:
mov eax, [ebp+arg2]
	cmp eax, button_x3
	jl button_fail
	cmp eax, button_x3+button_size
	jg a4
	mov eax, [ebp+arg3]
	cmp eax, button_y1
	jl button_fail
	cmp eax, button_y1+button_size
	jg b3
	make_text_macro matrice[2*4] ,area, button_x3+10 ,button_y1+5
a4:
mov eax, [ebp+arg2]
	cmp eax, button_x4
	jl button_fail
	cmp eax, button_x4+button_size
	jg a5
	mov eax, [ebp+arg3]
	cmp eax, button_y1
	jl button_fail
	cmp eax, button_y1+button_size
	jg b4
	make_text_macro matrice[3*4] ,area, button_x4+10 ,button_y1+5
a5:
mov eax, [ebp+arg2]
	cmp eax, button_x5
	jl button_fail
	cmp eax, button_x5+button_size
	jg a6
	mov eax, [ebp+arg3]
	cmp eax, button_y1
	jl button_fail
	cmp eax, button_y1+button_size
	jg b5
	make_text_macro matrice[4*4] ,area, button_x5+10 ,button_y1+5
a6:
mov eax, [ebp+arg2]
	cmp eax, button_x6
	jl button_fail
	cmp eax, button_x6+button_size
	jg a7
	mov eax, [ebp+arg3]
	cmp eax, button_y1
	jl button_fail
	cmp eax, button_y1+button_size
	jg b6
	make_text_macro matrice[5*4],area, button_x6+10 ,button_y1+5
a7:
mov eax, [ebp+arg2]
	cmp eax, button_x7
	jl button_fail
	cmp eax, button_x7+button_size
	jg a8
	mov eax, [ebp+arg3]
	cmp eax, button_y1
	jl button_fail
	cmp eax, button_y1+button_size
	jg b7
	make_text_macro matrice[6*4] ,area, button_x7+10 ,button_y1+5
a8:
mov eax, [ebp+arg2]
	cmp eax, button_x8
	jl button_fail
	cmp eax, button_x8+button_size
	jg a9
	mov eax, [ebp+arg3]
	cmp eax, button_y1
	jl button_fail
	cmp eax, button_y1+button_size
	jg b8
	make_text_macro matrice[7*4] ,area, button_x8+10 ,button_y1+5
a9:
mov eax, [ebp+arg2]
	cmp eax, button_x9
	jl button_fail
	cmp eax, button_x9+button_size
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, button_y1
	jl button_fail
	cmp eax, button_y1+button_size
	jg b9
	make_text_macro matrice[8*4] ,area, button_x9+10 ,button_y1+5
b1:
   mov eax, [ebp+arg2]
	cmp eax, button_x1
	jl button_fail
	cmp eax, button_x1+button_size
	jg b2
	mov eax, [ebp+arg3]
	cmp eax, button_y2
	jl button_fail
	cmp eax, button_y2+button_size
	jg c1
	make_text_macro matrice[9*4] ,area, button_x1+10 ,button_y2+5
b2:
mov eax, [ebp+arg2]
	cmp eax, button_x2
	jl button_fail
	cmp eax, button_x2+button_size
	jg b3
	mov eax, [ebp+arg3]
	cmp eax, button_y2
	jl button_fail
	cmp eax, button_y2+button_size
	jg c2
	make_text_macro matrice[10*4] ,area, button_x2+10 ,button_y2+5
b3:
mov eax, [ebp+arg2]
	cmp eax, button_x3
	jl button_fail
	cmp eax, button_x3+button_size
	jg b4
	mov eax, [ebp+arg3]
	cmp eax, button_y2
	jl button_fail
	cmp eax, button_y2+button_size
	jg c3
	make_text_macro matrice[11*4] ,area, button_x3+10 ,button_y2+5
b4:
mov eax, [ebp+arg2]
	cmp eax, button_x4
	jl button_fail
	cmp eax, button_x4+button_size
	jg b5
	mov eax, [ebp+arg3]
	cmp eax, button_y2
	jl button_fail
	cmp eax, button_y2+button_size
	jg c4
	make_text_macro matrice[12*4] ,area, button_x4+10 ,button_y2+5
b5:
mov eax, [ebp+arg2]
	cmp eax, button_x5
	jl button_fail
	cmp eax, button_x5+button_size
	jg b6
	mov eax, [ebp+arg3]
	cmp eax, button_y2
	jl button_fail
	cmp eax, button_y2+button_size
	jg c5
	make_text_macro matrice[13*4] ,area, button_x5+10 ,button_y2+5
b6:
mov eax, [ebp+arg2]
	cmp eax, button_x6
	jl button_fail
	cmp eax, button_x6+button_size
	jg b7
	mov eax, [ebp+arg3]
	cmp eax, button_y2
	jl button_fail
	cmp eax, button_y2+button_size
	jg c6
	make_text_macro matrice[14*4] ,area, button_x6+10 ,button_y2+5
b7:
mov eax, [ebp+arg2]
	cmp eax, button_x7
	jl button_fail
	cmp eax, button_x7+button_size
	jg b8
	mov eax, [ebp+arg3]
	cmp eax, button_y2
	jl button_fail
	cmp eax, button_y2+button_size
	jg c7
	make_text_macro matrice[15*4] ,area, button_x7+10 ,button_y2+5
b8:
mov eax, [ebp+arg2]
	cmp eax, button_x8
	jl button_fail
	cmp eax, button_x8+button_size
	jg b9
	mov eax, [ebp+arg3]
	cmp eax, button_y2
	jl button_fail
	cmp eax, button_y2+button_size
	jg c8
	make_text_macro matrice[16*4] ,area, button_x8+10 ,button_y2+5
b9:
mov eax, [ebp+arg2]
	cmp eax, button_x9
	jl button_fail
	cmp eax, button_x9+button_size
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, button_y2
	jl button_fail
	cmp eax, button_y2+button_size
	jg c9
	make_text_macro matrice[17*4] ,area, button_x9+10 ,button_y2+5
c1:
   mov eax, [ebp+arg2]
	cmp eax, button_x1
	jl button_fail
	cmp eax, button_x1+button_size
	jg c2
	mov eax, [ebp+arg3]
	cmp eax, button_y3
	jl button_fail
	cmp eax, button_y3+button_size
	jg d1
	make_text_macro matrice[18*4] ,area, button_x1+10 ,button_y3+5
c2:
mov eax, [ebp+arg2]
	cmp eax, button_x2
	jl button_fail
	cmp eax, button_x2+button_size
	jg c3
	mov eax, [ebp+arg3]
	cmp eax, button_y3
	jl button_fail
	cmp eax, button_y3+button_size
	jg d2
	make_text_macro matrice[19*4] ,area, button_x2+10 ,button_y3+5
c3:
mov eax, [ebp+arg2]
	cmp eax, button_x3
	jl button_fail
	cmp eax, button_x3+button_size
	jg c4
	mov eax, [ebp+arg3]
	cmp eax, button_y3
	jl button_fail
	cmp eax, button_y3+button_size
	jg d3
	make_text_macro matrice[20*4] ,area, button_x3+10 ,button_y3+5
c4:
mov eax, [ebp+arg2]
	cmp eax, button_x4
	jl button_fail
	cmp eax, button_x4+button_size
	jg c5
	mov eax, [ebp+arg3]
	cmp eax, button_y3
	jl button_fail
	cmp eax, button_y3+button_size
	jg d4
	make_text_macro matrice[21*4] ,area, button_x4+10 ,button_y3+5
c5:
mov eax, [ebp+arg2]
	cmp eax, button_x5
	jl button_fail
	cmp eax, button_x5+button_size
	jg c6
	mov eax, [ebp+arg3]
	cmp eax, button_y3
	jl button_fail
	cmp eax, button_y3+button_size
	jg d5
	make_text_macro matrice[22*4] ,area, button_x5+10 ,button_y3+5
c6:
mov eax, [ebp+arg2]
	cmp eax, button_x6
	jl button_fail
	cmp eax, button_x6+button_size
	jg c7
	mov eax, [ebp+arg3]
	cmp eax, button_y3
	jl button_fail
	cmp eax, button_y3+button_size
	jg d6
	make_text_macro matrice[23*4] ,area, button_x6+10 ,button_y3+5
c7:
mov eax, [ebp+arg2]
	cmp eax, button_x7
	jl button_fail
	cmp eax, button_x7+button_size
	jg c8
	mov eax, [ebp+arg3]
	cmp eax, button_y3
	jl button_fail
	cmp eax, button_y3+button_size
	jg d7
	make_text_macro matrice[24*4] ,area, button_x7+10 ,button_y3+5
c8:
mov eax, [ebp+arg2]
	cmp eax, button_x8
	jl button_fail
	cmp eax, button_x8+button_size
	jg c9
	mov eax, [ebp+arg3]
	cmp eax, button_y3
	jl button_fail
	cmp eax, button_y3+button_size
	jg d8
	make_text_macro matrice[25*4] ,area, button_x8+10 ,button_y3+5
c9:
mov eax, [ebp+arg2]
	cmp eax, button_x9
	jl button_fail
	cmp eax, button_x9+button_size
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, button_y3
	jl button_fail
	cmp eax, button_y3+button_size
	jg d9
	make_text_macro matrice[26*4] ,area, button_x9+10 ,button_y3+5
d1:
   mov eax, [ebp+arg2]
	cmp eax, button_x1
	jl button_fail
	cmp eax, button_x1+button_size
	jg d2
	mov eax, [ebp+arg3]
	cmp eax, button_y4
	jl button_fail
	cmp eax, button_y4+button_size
	jg e1
	make_text_macro matrice[27*4] ,area, button_x1+10 ,button_y4+5
d2:
mov eax, [ebp+arg2]
	cmp eax, button_x2
	jl button_fail
	cmp eax, button_x2+button_size
	jg d3
	mov eax, [ebp+arg3]
	cmp eax, button_y4
	jl button_fail
	cmp eax, button_y4+button_size
	jg e2
	make_text_macro matrice[28*4] ,area, button_x2+10 ,button_y4+5
d3:
mov eax, [ebp+arg2]
	cmp eax, button_x3
	jl button_fail
	cmp eax, button_x3+button_size
	jg d4
	mov eax, [ebp+arg3]
	cmp eax, button_y4
	jl button_fail
	cmp eax, button_y4+button_size
	jg e3
	make_text_macro matrice[29*4] ,area, button_x3+10 ,button_y4+5
d4:
mov eax, [ebp+arg2]
	cmp eax, button_x4
	jl button_fail
	cmp eax, button_x4+button_size
	jg d5
	mov eax, [ebp+arg3]
	cmp eax, button_y4
	jl button_fail
	cmp eax, button_y4+button_size
	jg e4
	make_text_macro matrice[30*4] ,area, button_x4+10 ,button_y4+5
d5:
mov eax, [ebp+arg2]
	cmp eax, button_x5
	jl button_fail
	cmp eax, button_x5+button_size
	jg d6
	mov eax, [ebp+arg3]
	cmp eax, button_y4
	jl button_fail
	cmp eax, button_y4+button_size
	jg e5
	make_text_macro matrice[31*4] ,area, button_x5+10 ,button_y4+5
d6:
mov eax, [ebp+arg2]
	cmp eax, button_x6
	jl button_fail
	cmp eax, button_x6+button_size
	jg d7
	mov eax, [ebp+arg3]
	cmp eax, button_y4
	jl button_fail
	cmp eax, button_y4+button_size
	jg e6
	make_text_macro matrice[32*4] ,area, button_x6+10 ,button_y4+5
d7:
mov eax, [ebp+arg2]
	cmp eax, button_x7
	jl button_fail
	cmp eax, button_x7+button_size
	jg d8
	mov eax, [ebp+arg3]
	cmp eax, button_y4
	jl button_fail
	cmp eax, button_y4+button_size
	jg e7
	make_text_macro matrice[33*4] ,area, button_x7+10 ,button_y4+5
d8:
mov eax, [ebp+arg2]
	cmp eax, button_x8
	jl button_fail
	cmp eax, button_x8+button_size
	jg d9
	mov eax, [ebp+arg3]
	cmp eax, button_y4
	jl button_fail
	cmp eax, button_y4+button_size
	jg e8
	make_text_macro matrice[34*4] ,area, button_x8+10 ,button_y4+5
d9:
mov eax, [ebp+arg2]
	cmp eax, button_x9
	jl button_fail
	cmp eax, button_x9+button_size
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, button_y4
	jl button_fail
	cmp eax, button_y4+button_size
	jg e9
	make_text_macro matrice[35*4] ,area, button_x9+10 ,button_y4+5
e1:
   mov eax, [ebp+arg2]
	cmp eax, button_x1
	jl button_fail
	cmp eax, button_x1+button_size
	jg e2
	mov eax, [ebp+arg3]
	cmp eax, button_y5
	jl button_fail
	cmp eax, button_y5+button_size
	jg f1
	make_text_macro matrice[36*4] ,area, button_x1+10 ,button_y5+5
e2:
mov eax, [ebp+arg2]
	cmp eax, button_x2
	jl button_fail
	cmp eax, button_x2+button_size
	jg e3
	mov eax, [ebp+arg3]
	cmp eax, button_y5
	jl button_fail
	cmp eax, button_y5+button_size
	jg f2
	make_text_macro matrice[37*4] ,area, button_x2+10 ,button_y5+5
e3:
mov eax, [ebp+arg2]
	cmp eax, button_x3
	jl button_fail
	cmp eax, button_x3+button_size
	jg e4
	mov eax, [ebp+arg3]
	cmp eax, button_y5
	jl button_fail
	cmp eax, button_y5+button_size
	jg f3
	make_text_macro matrice[38*4] ,area, button_x3+10 ,button_y5+5
e4:
mov eax, [ebp+arg2]
	cmp eax, button_x4
	jl button_fail
	cmp eax, button_x4+button_size
	jg e5
	mov eax, [ebp+arg3]
	cmp eax, button_y5
	jl button_fail
	cmp eax, button_y5+button_size
	jg f4
	make_text_macro matrice[39*4] ,area, button_x4+10 ,button_y5+5
e5:
mov eax, [ebp+arg2]
	cmp eax, button_x5
	jl button_fail
	cmp eax, button_x5+button_size
	jg e6
	mov eax, [ebp+arg3]
	cmp eax, button_y5
	jl button_fail
	cmp eax, button_y5+button_size
	jg f5
	make_text_macro matrice[40*4] ,area, button_x5+10 ,button_y5+5
e6:
mov eax, [ebp+arg2]
	cmp eax, button_x6
	jl button_fail
	cmp eax, button_x6+button_size
	jg e7
	mov eax, [ebp+arg3]
	cmp eax, button_y5
	jl button_fail
	cmp eax, button_y5+button_size
	jg f6
	make_text_macro matrice[41*4] ,area, button_x6+10 ,button_y5+5
e7:
mov eax, [ebp+arg2]
	cmp eax, button_x7
	jl button_fail
	cmp eax, button_x7+button_size
	jg e8
	mov eax, [ebp+arg3]
	cmp eax, button_y5
	jl button_fail
	cmp eax, button_y5+button_size
	jg f7
	make_text_macro matrice[42*4] ,area, button_x7+10 ,button_y5+5
e8:
mov eax, [ebp+arg2]
	cmp eax, button_x8
	jl button_fail
	cmp eax, button_x8+button_size
	jg e9
	mov eax, [ebp+arg3]
	cmp eax, button_y5
	jl button_fail
	cmp eax, button_y5+button_size
	jg f8
	make_text_macro matrice[43*4] ,area, button_x8+10 ,button_y5+5
e9:
mov eax, [ebp+arg2]
	cmp eax, button_x9
	jl button_fail
	cmp eax, button_x9+button_size
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, button_y5
	jl button_fail
	cmp eax, button_y5+button_size
	jg f9
	make_text_macro matrice[44*4] ,area, button_x9+10 ,button_y5+5
f1:
   mov eax, [ebp+arg2]
	cmp eax, button_x1
	jl button_fail
	cmp eax, button_x1+button_size
	jg f2
	mov eax, [ebp+arg3]
	cmp eax, button_y6
	jl button_fail
	cmp eax, button_y6+button_size
	jg g1
	make_text_macro matrice[45*4] ,area, button_x1+10 ,button_y6+5
f2:
mov eax, [ebp+arg2]
	cmp eax, button_x2
	jl button_fail
	cmp eax, button_x2+button_size
	jg f3
	mov eax, [ebp+arg3]
	cmp eax, button_y6
	jl button_fail
	cmp eax, button_y6+button_size
	jg g2
	make_text_macro matrice[46*4] ,area, button_x2+10 ,button_y6+5
f3:
mov eax, [ebp+arg2]
	cmp eax, button_x3
	jl button_fail
	cmp eax, button_x3+button_size
	jg f4
	mov eax, [ebp+arg3]
	cmp eax, button_y6
	jl button_fail
	cmp eax, button_y6+button_size
	jg g3
	make_text_macro matrice[47*4] ,area, button_x3+10 ,button_y6+5
f4:
mov eax, [ebp+arg2]
	cmp eax, button_x4
	jl button_fail
	cmp eax, button_x4+button_size
	jg f5
	mov eax, [ebp+arg3]
	cmp eax, button_y6
	jl button_fail
	cmp eax, button_y6+button_size
	jg g4
	make_text_macro matrice[48*4] ,area, button_x4+10 ,button_y6+5
f5:
mov eax, [ebp+arg2]
	cmp eax, button_x5
	jl button_fail
	cmp eax, button_x5+button_size
	jg f6
	mov eax, [ebp+arg3]
	cmp eax, button_y6
	jl button_fail
	cmp eax, button_y6+button_size
	jg g5
	make_text_macro matrice[49*4] ,area, button_x5+10 ,button_y6+5
f6:
mov eax, [ebp+arg2]
	cmp eax, button_x6
	jl button_fail
	cmp eax, button_x6+button_size
	jg f7
	mov eax, [ebp+arg3]
	cmp eax, button_y6
	jl button_fail
	cmp eax, button_y6+button_size
	jg g6
	make_text_macro matrice[50*4] ,area, button_x6+10 ,button_y6+5
f7:
mov eax, [ebp+arg2]
	cmp eax, button_x7
	jl button_fail
	cmp eax, button_x7+button_size
	jg f8
	mov eax, [ebp+arg3]
	cmp eax, button_y6
	jl button_fail
	cmp eax, button_y6+button_size
	jg g7
	make_text_macro matrice[51*4] ,area, button_x7+10 ,button_y6+5
f8:
mov eax, [ebp+arg2]
	cmp eax, button_x8
	jl button_fail
	cmp eax, button_x8+button_size
	jg f9
	mov eax, [ebp+arg3]
	cmp eax, button_y6
	jl button_fail
	cmp eax, button_y6+button_size
	jg g8
	make_text_macro matrice[52*4] ,area, button_x8+10 ,button_y6+5
f9:
mov eax, [ebp+arg2]
	cmp eax, button_x9
	jl button_fail
	cmp eax, button_x9+button_size
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, button_y6
	jl button_fail
	cmp eax, button_y6+button_size
	jg g9
	make_text_macro matrice[53*4] ,area, button_x9+10 ,button_y6+5
g1:
   mov eax, [ebp+arg2]
	cmp eax, button_x1
	jl button_fail
	cmp eax, button_x1+button_size
	jg g2
	mov eax, [ebp+arg3]
	cmp eax, button_y7
	jl button_fail
	cmp eax, button_y7+button_size
	jg h1
	make_text_macro matrice[54*4] ,area, button_x1+10 ,button_y7+5
g2:
mov eax, [ebp+arg2]
	cmp eax, button_x2
	jl button_fail
	cmp eax, button_x2+button_size
	jg g3
	mov eax, [ebp+arg3]
	cmp eax, button_y7
	jl button_fail
	cmp eax, button_y7+button_size
	jg h2
	make_text_macro matrice[55*4] ,area, button_x2+10 ,button_y7+5
g3:
mov eax, [ebp+arg2]
	cmp eax, button_x3
	jl button_fail
	cmp eax, button_x3+button_size
	jg g4
	mov eax, [ebp+arg3]
	cmp eax, button_y7
	jl button_fail
	cmp eax, button_y7+button_size
	jg h3
	make_text_macro matrice[56*4] ,area, button_x3+10 ,button_y7+5
g4:
mov eax, [ebp+arg2]
	cmp eax, button_x4
	jl button_fail
	cmp eax, button_x4+button_size
	jg g5
	mov eax, [ebp+arg3]
	cmp eax, button_y7
	jl button_fail
	cmp eax, button_y7+button_size
	jg h4
	make_text_macro matrice[57*4] ,area, button_x4+10 ,button_y7+5
g5:
mov eax, [ebp+arg2]
	cmp eax, button_x5
	jl button_fail
	cmp eax, button_x5+button_size
	jg g6
	mov eax, [ebp+arg3]
	cmp eax, button_y7
	jl button_fail
	cmp eax, button_y7+button_size
	jg h5
	make_text_macro matrice[58*4] ,area, button_x5+10 ,button_y7+5
g6:
mov eax, [ebp+arg2]
	cmp eax, button_x6
	jl button_fail
	cmp eax, button_x6+button_size
	jg g7
	mov eax, [ebp+arg3]
	cmp eax, button_y7
	jl button_fail
	cmp eax, button_y7+button_size
	jg h6
	make_text_macro matrice[59*4] ,area, button_x6+10 ,button_y7+5
g7:
mov eax, [ebp+arg2]
	cmp eax, button_x7
	jl button_fail
	cmp eax, button_x7+button_size
	jg g8
	mov eax, [ebp+arg3]
	cmp eax, button_y7
	jl button_fail
	cmp eax, button_y7+button_size
	jg h7
	make_text_macro matrice[60*4] ,area, button_x7+10 ,button_y7+5
g8:
mov eax, [ebp+arg2]
	cmp eax, button_x8
	jl button_fail
	cmp eax, button_x8+button_size
	jg g9
	mov eax, [ebp+arg3]
	cmp eax, button_y7
	jl button_fail
	cmp eax, button_y7+button_size
	jg h8
	make_text_macro matrice[61*4] ,area, button_x8+10 ,button_y7+5
g9: ;;click aici si crapa , ideal mereu pun bomba aici
mov eax, [ebp+arg2]
	cmp eax, button_x9
	jl button_fail
	cmp eax, button_x9+button_size
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, button_y7
	jl button_fail
	cmp eax, button_y7+button_size
	jg h9
	make_text_macro matrice[62*4] ,area, button_x9+10 ,button_y7+5
h1:
   mov eax, [ebp+arg2]
	cmp eax, button_x1
	jl button_fail
	cmp eax, button_x1+button_size
	jg h2
	mov eax, [ebp+arg3]
	cmp eax, button_y8
	jl button_fail
	cmp eax, button_y8+button_size
	jg i1
	make_text_macro matrice[63*4] ,area, button_x1+10 ,button_y8+5
h2:
mov eax, [ebp+arg2]
	cmp eax, button_x2
	jl button_fail
	cmp eax, button_x2+button_size
	jg h3
	mov eax, [ebp+arg3]
	cmp eax, button_y8
	jl button_fail
	cmp eax, button_y8+button_size
	jg i2
	make_text_macro matrice[64*4] ,area, button_x2+10 ,button_y8+5
h3:
mov eax, [ebp+arg2]
	cmp eax, button_x3
	jl button_fail
	cmp eax, button_x3+button_size
	jg h4
	mov eax, [ebp+arg3]
	cmp eax, button_y8
	jl button_fail
	cmp eax, button_y8+button_size
	jg i3
	make_text_macro matrice[65*4] ,area, button_x3+10 ,button_y8+5
h4:
mov eax, [ebp+arg2]
	cmp eax, button_x4
	jl button_fail
	cmp eax, button_x4+button_size
	jg h5
	mov eax, [ebp+arg3]
	cmp eax, button_y8
	jl button_fail
	cmp eax, button_y8+button_size
	jg i4
	make_text_macro matrice[66*4] ,area, button_x4+10 ,button_y8+5
h5:
mov eax, [ebp+arg2]
	cmp eax, button_x5
	jl button_fail
	cmp eax, button_x5+button_size
	jg e6
	mov eax, [ebp+arg3]
	cmp eax, button_y8
	jl button_fail
	cmp eax, button_y8+button_size
	jg i5
	make_text_macro matrice[67*4] ,area, button_x5+10 ,button_y8+5
h6:
mov eax, [ebp+arg2]
	cmp eax, button_x6
	jl button_fail
	cmp eax, button_x6+button_size
	jg h7
	mov eax, [ebp+arg3]
	cmp eax, button_y8
	jl button_fail
	cmp eax, button_y8+button_size
	jg i6
	make_text_macro matrice[68*4] ,area, button_x6+10 ,button_y8+5
h7:
mov eax, [ebp+arg2]
	cmp eax, button_x7
	jl button_fail
	cmp eax, button_x7+button_size
	jg h8
	mov eax, [ebp+arg3]
	cmp eax, button_y8
	jl button_fail
	cmp eax, button_y8+button_size
	jg i7
	make_text_macro matrice[69*4] ,area, button_x7+10 ,button_y8+5
h8:
mov eax, [ebp+arg2]
	cmp eax, button_x8
	jl button_fail
	cmp eax, button_x8+button_size
	jg h9
	mov eax, [ebp+arg3]
	cmp eax, button_y8
	jl button_fail
	cmp eax, button_y8+button_size
	jg i8
	make_text_macro matrice[70*4] ,area, button_x8+10 ,button_y8+5
h9:
mov eax, [ebp+arg2]
	cmp eax, button_x9
	jl button_fail
	cmp eax, button_x9+button_size
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, button_y8
	jl button_fail
	cmp eax, button_y8+button_size
	jg i9
	make_text_macro matrice[71*4] ,area, button_x9+10 ,button_y8+5
i1:
   mov eax, [ebp+arg2]
	cmp eax, button_x1
	jl button_fail
	cmp eax, button_x1+button_size
	jg i2
	mov eax, [ebp+arg3]
	cmp eax, button_y9
	jl button_fail
	cmp eax, button_y9+button_size
	jg button_fail
	make_text_macro matrice[72*4],area, button_x1+10 ,button_y9+5
i2:
mov eax, [ebp+arg2]
	cmp eax, button_x2
	jl button_fail
	cmp eax, button_x2+button_size
	jg i3
	mov eax, [ebp+arg3]
	cmp eax, button_y9
	jl button_fail
	cmp eax, button_y9+button_size
	jg button_fail
	make_text_macro matrice[73*4] ,area, button_x2+10 ,button_y9+5
i3:
mov eax, [ebp+arg2]
	cmp eax, button_x3
	jl button_fail
	cmp eax, button_x3+button_size
	jg i4
	mov eax, [ebp+arg3]
	cmp eax, button_y9
	jl button_fail
	cmp eax, button_y9+button_size
	jg button_fail
	make_text_macro matrice[74*4] ,area, button_x3+10 ,button_y9+5
i4:
mov eax, [ebp+arg2]
	cmp eax, button_x4
	jl button_fail
	cmp eax, button_x4+button_size
	jg i5
	mov eax, [ebp+arg3]
	cmp eax, button_y9
	jl button_fail
	cmp eax, button_y9+button_size
	jg button_fail
	make_text_macro matrice[75*4] ,area, button_x4+10 ,button_y9+5
i5:
mov eax, [ebp+arg2]
	cmp eax, button_x5
	jl button_fail
	cmp eax, button_x5+button_size
	jg i6
	mov eax, [ebp+arg3]
	cmp eax, button_y9
	jl button_fail
	cmp eax, button_y9+button_size
	jg button_fail
	make_text_macro matrice[76*4] ,area, button_x5+10 ,button_y9+5
i6:
mov eax, [ebp+arg2]
	cmp eax, button_x6
	jl button_fail
	cmp eax, button_x6+button_size
	jg i7
	mov eax, [ebp+arg3]
	cmp eax, button_y9
	jl button_fail
	cmp eax, button_y9+button_size
	jg button_fail
	make_text_macro matrice[77*4] ,area, button_x6+10 ,button_y9+5
i7:
mov eax, [ebp+arg2]
	cmp eax, button_x7
	jl button_fail
	cmp eax, button_x7+button_size
	jg i8
	mov eax, [ebp+arg3]
	cmp eax, button_y9
	jl button_fail
	cmp eax, button_y9+button_size
	jg button_fail
	make_text_macro matrice[78*4] ,area, button_x7+10 ,button_y9+5
i8:
mov eax, [ebp+arg2]
	cmp eax, button_x8
	jl button_fail
	cmp eax, button_x8+button_size
	jg i9
	mov eax, [ebp+arg3]
	cmp eax, button_y9
	jl button_fail
	cmp eax, button_y9+button_size
	jg button_fail
	make_text_macro matrice[79*4] ,area, button_x8+10 ,button_y9+5
i9:
mov eax, [ebp+arg2]
	cmp eax, button_x9
	jl button_fail
	cmp eax, button_x9+button_size
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, button_y9
	jl button_fail
	cmp eax, button_y9+button_size
	jg button_fail
	make_text_macro matrice[80*4] ,area, button_x9+10 ,button_y9+5
	
button_fail:

	jmp afisare_litere
	

	
evt_timer:
	inc counter
	
afisare_litere:
	; afisam valoarea counter-ului curent (sute, zeci si unitati)
	; mov ebx, 10
	; mov eax, counter
	; cifra unitatilor
	; mov edx, 0
	; div ebx
	; add edx, '0'
	make_text_macro edx, area, 30, 10
	; cifra zecilor
	; mov edx, 0
	; div ebx
	; add edx, '0'
	make_text_macro edx, area, 20, 10
	; cifra sutelor
	; mov edx, 0
	; div ebx
	; add edx, '0'
	; make_text_macro edx, area, 10, 10
	
	;scriem un mesaj
	; make_text_macro 'P', area, 110, 100
	; make_text_macro 'R', area, 120, 100
	; make_text_macro 'O', area, 130, 100
	; make_text_macro 'I', area, 140, 100
	; make_text_macro 'E', area, 150, 100
	; make_text_macro 'C', area, 160, 100
	; make_text_macro 'T', area, 170, 100
	
	; make_text_macro 'L', area, 130, 120
	; make_text_macro 'A', area, 140, 120
	
	; make_text_macro 'A', area, 100, 140
	; make_text_macro 'S', area, 110, 140
	; make_text_macro 'A', area, 120, 140
	; make_text_macro 'M', area, 130, 140
	; make_text_macro 'B', area, 140, 140
	; make_text_macro 'L', area, 150, 140
	; make_text_macro 'A', area, 160, 140
	; make_text_macro 'R', area, 170, 140
	; make_text_macro 'E', area, 180, 140

	line_horizontal button_x1 , button_y1, button_size , 0
	line_horizontal button_x2 , button_y1, button_size , 0
	line_horizontal button_x3 , button_y1, button_size , 0
	line_horizontal button_x4 , button_y1, button_size , 0
	line_horizontal button_x5 , button_y1, button_size , 0
	line_horizontal button_x6 , button_y1, button_size , 0
	line_horizontal button_x7 , button_y1, button_size , 0
	line_horizontal button_x8 , button_y1, button_size , 0
	line_horizontal button_x9 , button_y1, button_size , 0
	line_horizontal button_x1 , button_y2, button_size , 0
	line_horizontal button_x2 , button_y2, button_size , 0
	line_horizontal button_x3 , button_y2, button_size , 0
	line_horizontal button_x4 , button_y2, button_size , 0
	line_horizontal button_x5 , button_y2, button_size , 0
	line_horizontal button_x6 , button_y2, button_size , 0
	line_horizontal button_x7 , button_y2, button_size , 0
	line_horizontal button_x8 , button_y2, button_size , 0
	line_horizontal button_x9 , button_y2, button_size , 0
	line_horizontal button_x1 , button_y3, button_size , 0
	line_horizontal button_x2 , button_y3, button_size , 0
	line_horizontal button_x3 , button_y3, button_size , 0
	line_horizontal button_x4 , button_y3, button_size , 0
	line_horizontal button_x5 , button_y3, button_size , 0
	line_horizontal button_x6 , button_y3, button_size , 0
	line_horizontal button_x7 , button_y3, button_size , 0
	line_horizontal button_x8 , button_y3, button_size , 0
	line_horizontal button_x9 , button_y3, button_size , 0
	line_horizontal button_x1 , button_y4, button_size , 0
	line_horizontal button_x2 , button_y4, button_size , 0
	line_horizontal button_x3 , button_y4, button_size , 0
	line_horizontal button_x4 , button_y4, button_size , 0
	line_horizontal button_x5 , button_y4, button_size , 0
	line_horizontal button_x6 , button_y4, button_size , 0
	line_horizontal button_x7 , button_y4, button_size , 0
	line_horizontal button_x8 , button_y4, button_size , 0
	line_horizontal button_x9 , button_y4, button_size , 0
	line_horizontal button_x1 , button_y5, button_size , 0
	line_horizontal button_x2 , button_y5, button_size , 0
	line_horizontal button_x3 , button_y5, button_size , 0
	line_horizontal button_x4 , button_y5, button_size , 0
	line_horizontal button_x5 , button_y5, button_size , 0
	line_horizontal button_x6 , button_y5, button_size , 0
	line_horizontal button_x7 , button_y5, button_size , 0
	line_horizontal button_x8 , button_y5, button_size , 0
	line_horizontal button_x9 , button_y5, button_size , 0
	line_horizontal button_x1 , button_y6, button_size , 0
	line_horizontal button_x2 , button_y6, button_size , 0
	line_horizontal button_x3 , button_y6, button_size , 0
	line_horizontal button_x4 , button_y6, button_size , 0
	line_horizontal button_x5 , button_y6, button_size , 0
	line_horizontal button_x6 , button_y6, button_size , 0
	line_horizontal button_x7 , button_y6, button_size , 0
	line_horizontal button_x8 , button_y6, button_size , 0
	line_horizontal button_x9 , button_y6, button_size , 0
	line_horizontal button_x1 , button_y7, button_size , 0
	line_horizontal button_x2 , button_y7, button_size , 0
	line_horizontal button_x3 , button_y7, button_size , 0
	line_horizontal button_x4 , button_y7, button_size , 0
	line_horizontal button_x5 , button_y7, button_size , 0
	line_horizontal button_x6 , button_y7, button_size , 0
	line_horizontal button_x7 , button_y7, button_size , 0
	line_horizontal button_x8 , button_y7, button_size , 0
	line_horizontal button_x9 , button_y7, button_size , 0
	line_horizontal button_x1 , button_y8, button_size , 0
	line_horizontal button_x2 , button_y8, button_size , 0
	line_horizontal button_x3 , button_y8, button_size , 0
	line_horizontal button_x4 , button_y8, button_size , 0
	line_horizontal button_x5 , button_y8, button_size , 0
	line_horizontal button_x6 , button_y8, button_size , 0
	line_horizontal button_x7 , button_y8, button_size , 0
	line_horizontal button_x8 , button_y8, button_size , 0
	line_horizontal button_x9 , button_y8, button_size , 0
	line_horizontal button_x1 , button_y9, button_size , 0
	line_horizontal button_x2 , button_y9, button_size , 0
	line_horizontal button_x3 , button_y9, button_size , 0
	line_horizontal button_x4 , button_y9, button_size , 0
	line_horizontal button_x5 , button_y9, button_size , 0
	line_horizontal button_x6 , button_y9, button_size , 0
	line_horizontal button_x7 , button_y9, button_size , 0
	line_horizontal button_x8 , button_y9, button_size , 0
	line_horizontal button_x9 , button_y9, button_size , 0
	
    line_horizontal button_x1 , button_y9 + button_size, button_size , 0
	line_horizontal button_x2 , button_y9+ button_size, button_size , 0
	line_horizontal button_x3 , button_y9+button_size, button_size , 0
	line_horizontal button_x4 , button_y9+button_size, button_size , 0
	line_horizontal button_x5 , button_y9+button_size, button_size , 0
	line_horizontal button_x6 , button_y9+button_size, button_size , 0
	line_horizontal button_x7 , button_y9+button_size, button_size , 0
	line_horizontal button_x8 , button_y9+button_size, button_size , 0
	line_horizontal button_x9 , button_y9+button_size, button_size , 0

	line_vertical button_x1 , button_y1, button_size , 0
	line_vertical button_x2 , button_y1, button_size , 0
	line_vertical button_x3 , button_y1, button_size , 0
	line_vertical button_x4 , button_y1, button_size , 0
	line_vertical button_x5 , button_y1, button_size , 0
	line_vertical button_x6 , button_y1, button_size , 0
	line_vertical button_x7 , button_y1, button_size , 0
	line_vertical button_x8 , button_y1, button_size , 0
	line_vertical button_x9 , button_y1, button_size , 0
	line_vertical button_x1 , button_y2, button_size , 0
	line_vertical button_x2 , button_y2, button_size , 0
	line_vertical button_x3 , button_y2, button_size , 0
	line_vertical button_x4 , button_y2, button_size , 0
	line_vertical button_x5 , button_y2, button_size , 0
	line_vertical button_x6 , button_y2, button_size , 0
	line_vertical button_x7 , button_y2, button_size , 0
	line_vertical button_x8 , button_y2, button_size , 0
	line_vertical button_x9 , button_y2, button_size , 0
	line_vertical button_x1 , button_y3, button_size , 0
	line_vertical button_x2 , button_y3, button_size , 0
	line_vertical button_x3 , button_y3, button_size , 0
	line_vertical button_x4 , button_y3, button_size , 0
	line_vertical button_x5 , button_y3, button_size , 0
	line_vertical button_x6 , button_y3, button_size , 0
	line_vertical button_x7 , button_y3, button_size , 0
	line_vertical button_x8 , button_y3, button_size , 0
	line_vertical button_x9 , button_y3, button_size , 0
	line_vertical button_x1 , button_y4, button_size , 0
	line_vertical button_x2 , button_y4, button_size , 0
	line_vertical button_x3 , button_y4, button_size , 0
	line_vertical button_x4 , button_y4, button_size , 0
	line_vertical button_x5 , button_y4, button_size , 0
	line_vertical button_x6 , button_y4, button_size , 0
	line_vertical button_x7 , button_y4, button_size , 0
	line_vertical button_x8 , button_y4, button_size , 0
	line_vertical button_x9 , button_y4, button_size , 0
	line_vertical button_x1 , button_y5, button_size , 0
	line_vertical button_x2 , button_y5, button_size , 0
	line_vertical button_x3 , button_y5, button_size , 0
	line_vertical button_x4 , button_y5, button_size , 0
	line_vertical button_x5 , button_y5, button_size , 0
	line_vertical button_x6 , button_y5, button_size , 0
	line_vertical button_x7 , button_y5, button_size , 0
	line_vertical button_x8 , button_y5, button_size , 0
	line_vertical button_x9 , button_y5, button_size , 0
	line_vertical button_x1 , button_y6, button_size , 0
	line_vertical button_x2 , button_y6, button_size , 0
	line_vertical button_x3 , button_y6, button_size , 0
	line_vertical button_x4 , button_y6, button_size , 0
	line_vertical button_x5 , button_y6, button_size , 0
	line_vertical button_x6 , button_y6, button_size , 0
	line_vertical button_x7 , button_y6, button_size , 0
	line_vertical button_x8 , button_y6, button_size , 0
	line_vertical button_x9 , button_y6, button_size , 0
	line_vertical button_x1 , button_y7, button_size , 0
	line_vertical button_x2 , button_y7, button_size , 0
	line_vertical button_x3 , button_y7, button_size , 0
	line_vertical button_x4 , button_y7, button_size , 0
	line_vertical button_x5 , button_y7, button_size , 0
	line_vertical button_x6 , button_y7, button_size , 0
	line_vertical button_x7 , button_y7, button_size , 0
	line_vertical button_x8 , button_y7, button_size , 0
	line_vertical button_x9 , button_y7, button_size , 0
	line_vertical button_x1 , button_y8, button_size , 0
	line_vertical button_x2 , button_y8, button_size , 0
	line_vertical button_x3 , button_y8, button_size , 0
	line_vertical button_x4 , button_y8, button_size , 0
	line_vertical button_x5 , button_y8, button_size , 0
	line_vertical button_x6 , button_y8, button_size , 0
	line_vertical button_x7 , button_y8, button_size , 0
	line_vertical button_x8 , button_y8, button_size , 0
	line_vertical button_x9 , button_y8, button_size , 0
	line_vertical button_x1 , button_y9, button_size , 0
	line_vertical button_x2 , button_y9, button_size , 0
	line_vertical button_x3 , button_y9, button_size , 0
	line_vertical button_x4 , button_y9, button_size , 0
	line_vertical button_x5 , button_y9, button_size , 0
	line_vertical button_x6 , button_y9, button_size , 0
	line_vertical button_x7 , button_y9, button_size , 0
	line_vertical button_x8 , button_y9, button_size , 0
	line_vertical button_x9 , button_y9, button_size , 0
	
	line_vertical button_x9+button_size , button_y1, button_size , 0
	line_vertical button_x9+button_size , button_y2, button_size , 0
	line_vertical button_x9+button_size , button_y3, button_size , 0
	line_vertical button_x9+button_size , button_y4, button_size , 0
	line_vertical button_x9+button_size , button_y5, button_size , 0
	line_vertical button_x9+button_size , button_y6, button_size , 0
	line_vertical button_x9+button_size , button_y7, button_size , 0
	line_vertical button_x9+button_size , button_y8, button_size , 0
	line_vertical button_x9+button_size , button_y9, button_size , 0


	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:

    gen_bomb1:
rdtsc
rdtsc
rdtsc
mov ecx , 81
mov edx, 0 
div ecx
mov esi , edx
mov matrice[4*esi] , 57

gen_bomb2:
rdtsc
rdtsc
rdtsc
mov ecx , 81
mov edx, 0 
div ecx
mov esi , edx
cmp matrice[4*esi] , 57
je gen_bomb2
mov matrice[4*esi] , 57

gen_bomb3:
rdtsc
rdtsc
rdtsc
mov ecx , 81
mov edx, 0 
div ecx
mov esi , edx
cmp matrice[4*esi] , 57
je gen_bomb3
mov matrice[4*esi] , 57

gen_bomb4:
rdtsc
rdtsc
rdtsc
mov ecx , 81
mov edx, 0 
div ecx
mov esi , edx
cmp matrice[4*esi] , 57
je gen_bomb4
mov matrice[4*esi] , 57

gen_bomb5:
rdtsc
rdtsc
rdtsc
mov ecx , 81
mov edx, 0 
div ecx
mov esi , edx
cmp matrice[4*esi] , 57
je gen_bomb5
mov matrice[4*esi] , 57

gen_bomb6:
rdtsc
rdtsc
rdtsc
mov ecx , 81
mov edx, 0 
div ecx
mov esi , edx
cmp matrice[4*esi] , 57
je gen_bomb6
mov matrice[4*esi] , 57

gen_bomb7:
rdtsc
rdtsc
rdtsc
mov ecx , 81
mov edx, 0 
div ecx
mov esi , edx
cmp matrice[4*esi] , 57
je gen_bomb7
mov matrice[4*esi] , 57

mov esi, 0
jmp cauta_bomba

pre_caut:
inc esi

cauta_bomba:

cmp esi, 81
je program

cmp matrice[esi*4], 57

jne pre_caut
cmp esi, 9
jl primul_rand
cmp esi, 71
jg ultimul_rand

restul_matrice:
ver1:

cmp esi , 17
je ver2
cmp esi , 26
je ver2
cmp esi , 35
je ver2
cmp esi , 44
je ver2
cmp esi , 53
je ver2
cmp esi , 62
je ver2
cmp matrice[esi*4+4], 57
je ver2
inc matrice[esi*4+4]
cmp matrice[esi*4+40] ,57
je ver2
inc matrice[esi*4+40]
cmp matrice[esi*4-32], 57
je ver2
inc matrice[esi*4-32] 


ver2:
cmp esi, 9
je pre_caut
cmp esi, 18
je pre_caut
cmp esi, 27
je pre_caut
cmp esi, 36
je pre_caut
cmp esi, 45
je pre_caut
cmp esi, 54
je pre_caut
cmp esi, 63
cmp matrice[esi*4-4], 57
je pre_caut
inc matrice[esi*4-4]
cmp matrice[esi*4-40] ,57
je ver2
inc matrice[esi*4-40]
cmp matrice[esi*4+32], 57
je ver2
inc matrice[esi*4+32] 


jmp pre_caut

primul_rand:
verif1:
cmp esi, 8
je verif2
cmp matrice[esi*4+4], 57
je verif2
inc matrice[esi*4+4]
cmp matrice[esi*4+40] ,57
je verif2
inc matrice[esi*4+40]
verif2:
cmp esi , 0
je verif3
cmp matrice[esi*4-4], 57
je verif3
inc matrice[esi*4-4]
cmp matrice[esi*4+32], 57
je verif3
inc matrice[esi*4+32]
verif3:
cmp matrice[esi*4+36],57
je pre_caut
inc matrice[esi*4+36]

jmp pre_caut

ultimul_rand:
verific1:
cmp esi, 80
je verific2
cmp matrice[esi*4+4], 57
je verific2
inc matrice[esi*4+4]
cmp matrice[esi*4-32] ,57
je verific2
inc matrice[esi*4-32]

verific2:
cmp esi , 72
je verific3
cmp matrice[esi*4-4], 57
je verific3
inc matrice[esi*4-4]
cmp matrice[esi*4-40], 57
je verific3
inc matrice[esi*4-40]
verific3:
cmp matrice[esi*4-36], 57
je pre_caut
inc matrice[esi*4-36]

jmp pre_caut


program:
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
