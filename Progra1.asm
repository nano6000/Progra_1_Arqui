section .bss

matriz resw 1
lenMatriz resb 1

section .data

desp_vertical equ 0x36
desp_horizontal equ 0x1C

vertical db '|'
horizontal TIMES 4 db '-' 
  
matrizSmall TIMES 6 db '                          ',10,'*    *    *    *    *    *',10
lenSmall equ $-matrizSmall-27

section .text
	global _start

_start:
	mov eax,matrizSmall
	mov [matriz],eax
escribir_vertical:
	mov eax,matriz
	mov bl,[vertical]
	mov [eax+desp_vertical],ebx
escribir_horizontal:
	mov eax,matriz
	mov ebx,[horizontal]
	mov [eax+desp_horizontal],ebx			
imprimir_tablero:
	mov edx,lenSmall
	mov ecx,[matriz+27]			;Desplazamiento de 27 para ocultar la primera fila nula
	mov ebx,1
	mov eax,4
	int 0x80
	
salir:
	mov ebx,0
	mov eax,1
	int 0x80
