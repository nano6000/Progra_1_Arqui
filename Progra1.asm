section .bss

;---------------manejo del tablero-----------------
seleccion resb 1					;Seleccion del tablero elegido
largoAnchoMax resb 1				;Largo y ancho maximo del tablero seleccionado
									;Esto para evitar que el usuario seleccione una fila
									;o columna fuera de la matriz 

despVertical_t resb 2					;desplazamiento vertical del tablero elegido
despHorizontal_t resb 2					;desplazamiento horizontal del tablero elegido
;---------------dibujo de lineas-------------------
direccion resb 1
columna resb 4
fila resb 4

;-------------control de jugadores-----------------
jugador1 resw 5
jugador2 resw 5
jugador3 resw 5
jugador4 resw 5

section .data

tablero TIMES 1876 db 0
lenTablero dw 1
;despVertical_t db 0						;desplazamiento vertical del tablero elegido
;despHorizontal_t db 0					;desplazamiento horizontal del tablero elegido


despVertical_s equ 0x36				;desplazamiento base para dibujar una linea vertical en tablero pequeno
despHorizontal_s equ 0x1B			;desplazamiento base para dibujar una linea horizontal en tablero pequeno

despVertical_m equ 0x5E 			;desplazamiento base para dibujar una linea vertical en tablero mediano
despHorizontal_m equ 0x2F			;desplazamiento base para dibujar una linea horizontal en tablero mediano

despVertical_l equ 0x86				;desplazamiento base para dibujar una linea vertical en tablero grande
despHorizontal_l equ 0x43			;desplazamiento base para dibujar una linea horizontal en tablero grande

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

msj3 db 'Linea vertical seleccionada! Digite - en el espacio de la fila si desea cambiar la direccion',10,'Ingrese primero la columna correspondiente en la que desea dibujar la linea (0~[n-1]), luego ingrese la fila correspondiente en la que desea dibujar la linea (1~[n-1]):',10,'>'
lenMsj3 equ $-msj3

msj4 db 'Linea horizontal seleccionada! Digite - en el espacio de la fila si desea cambiar la direccion',10,'Ingrese primero la columna correspondiente en la que desea dibujar la linea (0~[n-2]), luego ingrese la fila correspondiente en la que desea dibujar la linea (0~[n-1]):',10,'>'
lenMsj4 equ $-msj4

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
	mov word [lenTablero],cx
	
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
	;inc ecx
	mov word [lenTablero],cx
	
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
	mov word dx,[lenTablero]
	;inc dx
	mov ecx,tablero
	add cx,word [despHorizontal_t]				;Desplazamiento para ocultar la primera fila nula
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
	cmp al,0x32			;Verifica si selecciono una linea Horizontal
	je dibujar_horizontal
	cmp al,0x31
	jne dibujo_linea

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
	mov edx,5			;cantidad de bytes a leer
	int 0x80
	
	mov byte al,[columna+1]
	cmp al,0xa					;verifica que el caracter no sea un enter
	je enter_vertical_c
	cmp al,0x30					;verifica que el caracter no sea menor al valor ascii de 0
	jb dibujo_linea
	cmp al,0x39					;verifica que el caracter no sea mayor al valor ascii de 9
	ja dibujo_linea
	jmp mayor_diez_vertical_c
enter_vertical_c:							;Caso si es enter
	mov byte al,[columna]
	jmp continua_vertical_c
mayor_diez_vertical_c:			;Caso si el numero introducido es mayor que 10
	add al,0x0A
continua_vertical_c:
	mov byte [columna],al
	;cmp al,0x30
	mov bl,[largoAnchoMax]			;obtiene el maximo valor posible de la columna
	dec bl
	xor bl,0x30
	cmp al,0x30						;verifica si el usuario quiere cambiar la direccion de la linea
	;je dibujo_linea	
	jb dibujar_vertical				;verifica si el usuario ingreso un caracter diferente a los numericos
	;xor bl,0x30
	cmp bl,al
	jb dibujar_vertical
	
	;--------- lee la fila, para linea vertical----------
	mov eax,3			;read
	mov ebx,0			;stdin
	mov ecx,fila		;direccion de buffer
	mov edx,5			;cantidad de bytes a leer
	int 0x80
	
	mov byte al,[fila+1]
	cmp al,0xa					;verifica que el caracter no sea un enter
	je enter_vertical_f
	cmp al,0x30					;verifica que el caracter no sea menor al valor ascii de 0
	jb dibujo_linea
	cmp al,0x39					;verifica que el caracter no sea mayor al valor ascii de 9
	ja dibujo_linea
	jmp mayor_diez_vertical_f
enter_vertical_f:							;Caso si es enter
	mov byte al,[fila]
	jmp continua_vertical_f
mayor_diez_vertical_f:			;Caso si el numero introducido es mayor que 10
	add al,0x0A
continua_vertical_f:
	mov byte [fila],al
	mov bl,[largoAnchoMax]
	dec bl
	cmp al,'-'						;0x30 = 0
	je dibujo_linea
	jb dibujar_vertical
	xor bl,0x30
	cmp bl,al
	jb dibujar_vertical
	;------------Calcula el desplazamiento---------------
	;mov eax,tablero
	xor ebx,ebx
	xor eax,eax
	xor ecx,ecx
	
	mov cl,5						;Mueve un 5 para calcular el desplazamieto horizontal
	mov al,[columna]				;Mueve a la parte baja del registro ax el valor introducido por el usuario
	xor al,0x30						;Convierte el valor introducido por el usuario a ascii
	mul cl							;Multiplica el valor introducido por 5
	mov ebx,eax						;Guarda el valor obtenido en el ebx	
	
	xor eax,eax
	mov al,[fila]					;Mueve a la parte baja del registro ax el valor introducido por el usuario
	xor al,0x30						;Convierte el valor introducido por el usuario a ascii
	mul byte [despVertical_t]		;Multiplica el valor introducido por el desplazamiento correspondiente
	
	add ebx,eax						;Suma el desplazamiento vertical y el horizontal para obtener el desplazamiento total
	xor eax,eax
	xor ecx,ecx
	mov eax,tablero					;Copia la direccion del tablero en el registro
	mov cl,[vertical]				;Mueve el caracter | al registro
	mov [eax+ebx],cl				;Escribe el caracter en la posicion de memoria del tablero
									;mas el desplazamiento calculado
	jmp imprimir
	
dibujar_horizontal:
	mov edx,lenMsj4
	mov ecx,msj4
	mov ebx,1
	mov eax,4
	int 0x80
	
	;--------- lee la columna, para linea horizontal-------
	mov eax,3			;read
	mov ebx,0			;stdin
	mov ecx,columna		;direccion de buffer
	mov edx,5			;cantidad de bytes a leer
	int 0x80
	
	mov byte al,[columna+1]
	cmp al,0xa					;verifica que el caracter no sea un enter
	je enter_horizontal_c
	cmp al,0x30					;verifica que el caracter no sea menor al valor ascii de 0
	jb dibujo_linea
	cmp al,0x39					;verifica que el caracter no sea mayor al valor ascii de 9
	ja dibujo_linea
	jmp mayor_diez_horizontal_c
enter_horizontal_c:							;Caso si es enter
	mov byte al,[columna]
	jmp continua_horizontal_c
mayor_diez_horizontal_c:			;Caso si el numero introducido es mayor que 10
	add al,0x0A
continua_horizontal_c:
	mov byte [columna],al
	;cmp al,0x30
	mov bl,[largoAnchoMax]			;obtiene el maximo valor posible de la columna
	dec bl
	xor bl,0x30
	cmp al,0x30						;verifica si el usuario quiere cambiar la direccion de la linea
	;je dibujo_linea	
	jb dibujar_horizontal				;verifica si el usuario ingreso un caracter diferente a los numericos
	xor bl,0x30
	cmp al,bl
	jb dibujar_horizontal
	
	;--------- lee la fila, para linea horizontal----------
	mov eax,3			;read
	mov ebx,0			;stdin
	mov ecx,fila		;direccion de buffer
	mov edx,5			;cantidad de bytes a leer
	int 0x80
	
	mov byte al,[fila+1]
	cmp al,0xa					;verifica que el caracter no sea un enter
	je enter_horizontal_f
	cmp al,0x30					;verifica que el caracter no sea menor al valor ascii de 0
	jb dibujo_linea
	cmp al,0x39					;verifica que el caracter no sea mayor al valor ascii de 9
	ja dibujo_linea
	jmp mayor_diez_horizontal_f
enter_horizontal_f:							;Caso si es enter
	mov byte al,[fila]
	jmp continua_horizontal_f
mayor_diez_horizontal_f:			;Caso si el numero introducido es mayor que 10
	add al,0x0A
continua_horizontal_f:
	mov byte [fila],al
	mov bl,[largoAnchoMax]
	dec bl
	cmp al,'-'						;0x30 = 0
	je dibujo_linea
	jb dibujar_horizontal
	xor bl,0x30
	cmp bl,al
	jb dibujar_horizontal
	
	;------------Calcula el desplazamiento---------------
pausa:
	;mov eax,tablero
	xor ebx,ebx
	xor eax,eax
	xor ecx,ecx
	
	mov cl,5						;Mueve un 5 para calcular el desplazamieto horizontal
	mov al,[columna]				;Mueve a la parte baja del registro ax el valor introducido por el usuario
	xor al,0x30						;Convierte el valor introducido por el usuario a ascii
	mul cl							;Multiplica el valor introducido por 5
	mov ebx,eax						;Guarda el valor obtenido en el ebx	
	
	xor eax,eax
	mov al,[fila]					;Mueve a la parte baja del registro ax el valor introducido por el usuario
	xor al,0x30						;Convierte el valor introducido por el usuario a ascii
	mul byte [despVertical_t]		;Multiplica el valor introducido por el desplazamiento correspondiente
	add word ax,[despHorizontal_t]
	inc al
	
	add ebx,eax						;Suma el desplazamiento vertical y el horizontal para obtener el desplazamiento total
	xor eax,eax
	xor ecx,ecx
	mov eax,tablero					;Copia la direccion del tablero en el registro
	;add ax,word [despHorizontal_t]
	mov ecx,[horizontal]				;Mueve el caracter | al registro
	mov [eax+ebx],ecx				;Escribe el caracter en la posicion de memoria del tablero
									;mas el desplazamiento calculado
	jmp imprimir
	
salir:
	mov ebx,0
	mov eax,1
	int 0x80
	
	







