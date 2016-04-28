section .bss

;---------------manejo del tablero-----------------
seleccion resb 1					;Seleccion del tablero elegido
largoAnchoMax resb 1				;Largo y ancho maximo del tablero seleccionado
									;Esto para evitar que el usuario seleccione una fila
									;o columna fuera de la matriz
lenTablero resw 1 

despVertical_t resw 1					;desplazamiento vertical del tablero elegido
despHorizontal_t resw 1					;desplazamiento horizontal del tablero elegido

;---------------dibujo de lineas-------------------
direccion resb 1
columna resb 1
fila resb 1

;-------------control de jugadores-----------------
jugador1 resw 5
jugador2 resw 5
jugador3 resw 5
jugador4 resw 5

section .data

tablero TIMES 1876 db 0

despVertical_s equ 0x36				;desplazamiento base para dibujar una linea vertical en tablero pequeno
despHorizontal_s equ 0x1C			;desplazamiento base para dibujar una linea horizontal en tablero pequeno

despVertical_m equ 0x5E 			;desplazamiento base para dibujar una linea vertical en tablero mediano
despHorizontal_m equ 0x30			;desplazamiento base para dibujar una linea horizontal en tablero mediano

despVertical_l equ 0x86				;desplazamiento base para dibujar una linea vertical en tablero grande
despHorizontal_l equ 0x44			;desplazamiento base para dibujar una linea horizontal en tablero grande

vertical db '|'
horizontal TIMES 4 db '-' 
  
;---------------------------------------------------------------------------------------------------------
;			Matriz pequena
;---------------------------------------------------------------------------------------------------------
matrizSmall TIMES 6 db '                          ',10,'*    *    *    *    *    *',10
lenSmall equ $-matrizSmall-27

;---------------------------------------------------------------------------------------------------------
;			Matriz media
;---------------------------------------------------------------------------------------------------------
matrizMedium TIMES 10 db '                                              ',10,'*    *    *    *    *    *    *    *    *    *',10
lenMedium equ $-matrizMedium-47

;---------------------------------------------------------------------------------------------------------
;			Matriz grande
;---------------------------------------------------------------------------------------------------------
matrizLarge TIMES 14 db '                                                                  ',10,'*    *    *    *    *    *    *    *    *    *    *    *    *    *',10
lenLarge equ $-matrizLarge-67

;---------------------------------------------------------------------------------------------------------
;			Mensajes
;---------------------------------------------------------------------------------------------------------
msj1 db 'Seleccione el tamano del tablero:',10,'1: Pequeno (2 jugadores, 6x6)',10,'2: Mediano (3 jugadores, 10x10)',10,'3: Grande (4 jugadores, 14x14)',10,'>'
lenMsj1 equ $-msj1

msj2 db 'Indique la direccion de la linea a dibujar:',10,'1: Vertical',10,'2: Horizontal',10,'>'
lenMsj2 equ $-msj2

msj3 db 'Linea vertical seleccionada! Digite 0 en el espacio de la fila si desea cambiar la direccion',10,'Ingrese primero la columna correspondiente en la que desea dibujar la linea (1~[n-1]), luego ingrese la fila correspondiente en la que desea dibujar la linea (1~[n-1]):',10,'>'
lenMsj3 equ $-msj3

section .text
	global _start

_start:
seleccion_tablero:
;------------Imprime el msj de seleccion de tablero---------------------
	mov edx,lenMsj1
	mov ecx,msj1
	mov ebx,1
	mov eax,4
	int 0x80

;------------lee la seleccion del tamano del tablero--------------------
	mov eax,3			;read
	mov ebx,0			;stdin
	mov ecx,seleccion	;direccion de buffer
	mov edx,2			;cantidad de bytes a leer
	int 0x80

;--------------escoge el tablero segun la eleccion----------------------
;----------------Copia el tablero a utilizar----------------------------
copiar_tablero:
	mov al,[seleccion]
	xor ecx,ecx								;Limpia el ecx para usarlo como contador
	cmp al,0x31								;31h = 1 --> tablero pequeno
	jz copiar_small
	cmp al,0x32								;32h = 2 --> tablero mediano
	jz copiar_medium
	cmp al,0x33								;33h = 3 --> tablero grande
	jnz seleccion_tablero
	
copiar_large:
	xor ah,ah
	mov al,byte [matrizLarge+ecx]			;copia X posicion del tablero en la parte baja del registro ax
	mov [tablero+ecx],al
	inc ecx									;incrementa el contador
	cmp ecx,1876
	jnz copiar_large
	
	mov al,despHorizontal_l
	mov [despHorizontal_t],al				;Copiamos el desplazamiento horizontal del tablero seleccionado
	mov al,despVertical_l
	mov [despVertical_t],al					;Copiamos el desplazamiento vertical del tablero seleccionado
	mov byte [largoAnchoMax],0xE			;Copiamos el largo y ancho maximo del tablero seleccionado
	sub ecx,67
	mov [lenTablero],ecx
	
	jmp imprimir
copiar_medium:
	xor ah,ah
	mov al,byte [matrizMedium+ecx]			;copia X posicion del tablero en la parte baja del registro ax
	mov [tablero+ecx],al
	inc ecx									;incrementa el contador
	cmp ecx,940
	jnz copiar_medium
	
	mov al,despHorizontal_m
	mov [despHorizontal_t],al				;Copiamos el desplazamiento horizontal del tablero seleccionado
	mov al,despVertical_m
	mov [despVertical_t],al					;Copiamos el desplazamiento vertical del tablero seleccionado
	mov byte [largoAnchoMax],0xA			;Copiamos el largo y ancho maximo del tablero seleccionado
	sub ecx,47
	mov [lenTablero],ecx
	
	jmp imprimir
copiar_small:
	xor ah,ah
	mov al,byte [matrizSmall+ecx]			;copia X posicion del tablero en la parte baja del registro ax
	mov [tablero+ecx],al
	inc ecx									;incrementa el contador
	cmp ecx,324
	jnz copiar_small
	
	mov al,despHorizontal_s
	mov [despHorizontal_t],al				;Copiamos el desplazamiento horizontal del tablero seleccionado
	mov al,despVertical_s
	mov [despVertical_t],al					;Copiamos el desplazamiento vertical del tablero seleccionado
	mov byte [largoAnchoMax],0x6					;Copiamos el largo y ancho maximo del tablero seleccionado
	sub ecx,27
	mov [lenTablero],ecx

;---------------------Imprime el tablero--------------------------------
imprimir:
	mov edx,[lenTablero]
	mov ecx,tablero			
	add ecx,[despHorizontal_t]				;Desplazamiento para ocultar la primera fila nula
	dec ecx
	mov ebx,1
	mov eax,4
	int 0x80
	
	mov ax,[tablero]
	;jmp salir
	
dibujo_linea:
	mov edx,lenMsj2
	mov ecx,msj2
	mov ebx,1
	mov eax,4
	int 0x80
	
	mov eax,3			;read
	mov ebx,0			;stdin
	mov ecx,direccion	;direccion de buffer
	mov edx,2			;cantidad de bytes a leer
	int 0x80
	
	mov al,[direccion]
	cmp al,2			;Verifica si selecciono una linea Horizontal
	jz dibujar_horizontal

dibujar_vertical:
	mov edx,lenMsj3
	mov ecx,msj3
	mov ebx,1
	mov eax,4
	int 0x80
	
	;--------- lee la columna, para linea vertical-------
	mov eax,3			;read
	mov ebx,0			;stdin
	mov ecx,columna		;direccion de buffer
	mov edx,2			;cantidad de bytes a leer
	int 0x80
	
	mov al,[columna]
	mov bl,[largoAnchoMax]			;obtiene el maximo valor posible de la columna
	dec bl
	cmp al,0x30						;verifica si el usuario quiere cambiar la direccion de la linea
	;je dibujo_linea	
	jb dibujar_vertical				;verifica si el usuario ingreso un caracter diferente a los numericos
	cmp al,bl
	jb dibujar_vertical
	
	;--------- lee la fila, para linea vertical----------
	mov eax,3			;read
	mov ebx,0			;stdin
	mov ecx,fila		;direccion de buffer
	mov edx,1			;cantidad de bytes a leer
	int 0x80
	
	mov al,[fila]
	mov bl,[largoAnchoMax]
	dec bl
	cmp al,0x30						;0x30 = 0
	je dibujo_linea
	jb dibujar_vertical
	cmp al,bl
	jb dibujar_vertical
	
	;------------Calcula el desplazamiento---------------
	;mov eax,tablero
	xor ebx,ebx
	xor eax,eax
	xor ecx,ecx
	mov cl,5
	mov al,[columna]
	xor al,0x30
	mul cl
pausa1:
	mov ebx,eax
	xor eax,eax
	mov al,[fila]
pausa3:
	xor al,0x30
pausa4:
	mul byte [despVertical_t]
	add ebx,eax
pausa2:
	
	xor eax,eax
	xor ecx,ecx
	mov eax,tablero
	mov ecx,[vertical]
	mov [eax+ebx],ecx
	
	jmp imprimir
	
dibujar_horizontal:
	;mov edx,lenMsj4
	;mov ecx,msj4
	mov ebx,1
	mov eax,4
	int 0x80
	
	mov eax,3			;read
	mov ebx,0			;stdin
	mov ecx,direccion	;direccion de buffer
	mov edx,1			;cantidad de bytes a leer
	int 0x80
	
salir:
	mov ebx,0
	mov eax,1
	int 0x80
	
	







