;******************
;Autor: Eduardo Solano Jaime
;******************
;Título: Proyecto Final
;Frecuencia: 4 MHz
;Fecha:	20-nov-20
;Descripción: Mano robótica que identifique entre pelotas blancas y negras para depositarlas
;			  en su contenedor correspondiente.
;******************

.include "m16adef.inc"     
   
;******************
;Registros (aquí pueden definirse)
;.def temporal=r19
.def temp=r17

;Palabras claves (aquí pueden definirse)
;.equ LCD_DAT=DDRC

;******************

.org 0x0000
;Comienza el vector de interrupciones.
jmp RESET ; Reset Handler
jmp EXT_INT0 ; IRQ0 Handler
jmp EXT_INT1 ; IRQ1 Handler
jmp TIM2_COMP ; Timer2 Compare Handler
jmp TIM2_OVF ; Timer2 Overflow Handler
jmp TIM1_CAPT ; Timer1 Capture Handler
jmp TIM1_COMPA ; Timer1 CompareA Handler
jmp TIM1_COMPB ; Timer1 CompareB Handler
jmp TIM1_OVF ; Timer1 Overflow Handler
jmp TIM0_OVF ; Timer0 Overflow Handler
jmp SPI_STC ; SPI Transfer Complete Handler
jmp USART_RXC ; USART RX Complete Handler
jmp USART_UDRE ; UDR Empty Handler
jmp USART_TXC ; USART TX Complete Handler
jmp ADC_COMP ; ADC Conversion Complete Handler
jmp EE_RDY ; EEPROM Ready Handler
jmp ANA_COMP ; Analog Comparator Handler
jmp TWSI ; Two-wire Serial Interface Handler
jmp EXT_INT2 ; IRQ2 Handler
jmp TIM0_COMP ; Timer0 Compare Handler
jmp SPM_RDY ; Store Program Memory Ready Handler
; Termina el vector de interrupciones.

;******************
;Aquí comenzará el programa
;******************
Reset:
;Primero inicializamos el stack pointer...
ldi r16, high(RAMEND)
out SPH, r16
ldi r16, low(RAMEND)
out SPL, r16 
sei 		;habilitar esta línea se utilizarán interrupciones

;******************
;No olvides configurar al inicio los puertos que utilizarás
;También debes configurar si habrá o no pull ups en las entradas
;Para las salidas deberás indicar cuál es la salida inicial
;Los registros que vayas a utilizar inicializalos si es necesario
;******************
;Ideas para utilizar la librería del LCD
;Recordar que la rutina de inicialización puede modificarse según haga falta
;rcall INI_LCD ;esta función se encarga de inicializar el LCD
;ldi VAR, (aquí debe la instrucción que se ejecutará)
;rcall WR_INS
;ldi VAR, (aquí debe ir la letra o caracter)
;rcall WR_DAT
;******************
rcall ini_lcd
clr r16
out ddra, r16
ser r16
out ddrb, r16
out ddrd, r16
out porta, r16
clr r16
out portb, r16
out portd, r16

out tcnt0, r16
out tcnt2, r16
ldi r16, 0b0110_1100
out tccr0, r16
ldi r16, 0b0110_1110
out tccr2, r16
ldi r16, 21
out ocr0, r16
ldi r16, 16
out ocr2, r16
rcall delay1s
rcall delay_cuartosec

inicio:
// Posiciones iniciales
// servo1 a 90° (en medio) y servo2 a ~90° (recto)
rcall borrar_lcd
inicio_msj1:
	ldi zh, high(acomodando_arriba*2)
	ldi zl, low(acomodando_arriba*2)
	add zl, r17
	adc zh, r18
	lpm
	mov VAR, r0
	rcall WR_DAT
	inc r17
	cpi r17, 16
		brne inicio_msj1
ldi var, 0b1100_0000
rcall wr_ins
clr r17
inicio_msj2:
	ldi zh, high(acomodando_abajo*2)
	ldi zl, low(acomodando_abajo*2)
	add zl, r17
	adc zh, r18
	lpm
	mov VAR, r0
	rcall WR_DAT
	inc r17
	cpi r17, 16
		brne inicio_msj2
rcall delay1s
ldi r16, 21
out ocr0, r16
rcall delay1s
ldi r16, 14
out ocr2, r16
rcall delay_cuartosec
ldi r16, 13
out ocr2, r16
rcall delay_cuartosec
ldi r16, 12
out ocr2, r16
rcall delay_cuartosec
ldi r16, 11
out ocr2, r16
rcall delay_cuartosec
ldi r16, 10
out ocr2, r16
rcall delay_cuartosec
ldi r16, 9
out ocr2, r16
rcall delay1s
rcall borrar_lcd
boton_msj1:
	ldi zh, high(iniciar_arriba*2)
	ldi zl, low(iniciar_arriba*2)
	add zl, r17
	adc zh, r18
	lpm
	mov VAR, r0
	rcall WR_DAT
	inc r17
	cpi r17, 14
		brne boton_msj1
ldi var, 0b1100_0000
rcall wr_ins
clr r17
boton_msj2:
	ldi zh, high(iniciar_abajo*2)
	ldi zl, low(iniciar_abajo*2)
	add zl, r17
	adc zh, r18
	lpm
	mov VAR, r0
	rcall WR_DAT
	inc r17
	cpi r17, 14
		brne boton_msj2
boton:
sbis pina, 0
	breq rtr
rjmp boton
rtr:
rcall t0_15m
traba: sbis pina, 0
	breq traba
rcall t0_15m

cerrar:
rcall borrar_lcd
cerrar_msj1:
	ldi zh, high(cerrando*2)
	ldi zl, low(cerrando*2)
	add zl, r17
	adc zh, r18
	lpm
	mov VAR, r0
	rcall WR_DAT
	inc r17
	cpi r17, 16
		brne cerrar_msj1
rcall delay1s
rcall delay1s
clr r16
// motor de pasos cierra la pinza
ldi temp, 0b000_0001
rcall cl
rcall delay1s

rcall subir
nop
nop
nop
sbic pina, 7
	breq negro
sbis pina, 7
	breq blanco

blanco:
//mover servo1 a derecha
rcall borrar_lcd
blanco_msj1:
	ldi zh, high(blanco_msj*2)
	ldi zl, low(blanco_msj*2)
	add zl, r17
	adc zh, r18
	lpm
	mov VAR, r0
	rcall WR_DAT
	inc r17
	cpi r17, 14
		brne blanco_msj1
rcall delay1s
rcall delay1s
ldi r16, 16
out ocr0, r16
rcall delay1s
rcall bajar
rjmp soltar

negro:
//mover servo1 a izq
rcall borrar_lcd
negro_msj1:
	ldi zh, high(negro_msj*2)
	ldi zl, low(negro_msj*2)
	add zl, r17
	adc zh, r18
	lpm
	mov VAR, r0
	rcall WR_DAT
	inc r17
	cpi r17, 12
		brne negro_msj1
rcall delay1s
rcall delay1s
ldi r16, 25
out ocr0, r16
rcall delay1s
rcall bajar

soltar:
clr r16
rcall borrar_lcd
soltando_msj1:
	ldi zh, high(soltando*2)
	ldi zl, low(soltando*2)
	add zl, r17
	adc zh, r18
	lpm
	mov VAR, r0
	rcall WR_DAT
	inc r17
	cpi r17, 16
		brne soltando_msj1
rcall delay1s
rcall delay1s
//motor de pasos abre la pinza
clr r16
ldi temp, 0b000_1000
op: cpi temp, 0b0000_0001
	breq rorforzado
	ror temp
	out portd, temp
	inc r16
	rcall t0_15m
	cpi r16, 180 //numero necesario para apretar
		brne op
rcall delay1s

rcall subir

rjmp inicio


cl: cpi temp, 0b0000_1000
	breq rolforzado
	bclr 0
	rol temp
	out portd, temp
	inc r16
	rcall t0_15m
	cpi r16, 180 //numero necesario para soltar
		brne cl
rcall delay1s
ret

rorforzado:
ldi temp, 0b000_1000
out portd, temp
rcall t0_15m
rjmp op

rolforzado:
ldi temp, 0b000_0001
out portd, temp
rcall t0_15m
rjmp cl

subir:
rcall borrar_lcd
subiendo_msj1:
	ldi zh, high(subiendo*2)
	ldi zl, low(subiendo*2)
	add zl, r17
	adc zh, r18
	lpm
	mov VAR, r0
	rcall WR_DAT
	inc r17
	cpi r17, 12
		brne subiendo_msj1
rcall delay1s
rcall delay1s
//servo2 sube
ldi r16, 13  // encontrar valores exactos
out ocr2, r16
rcall delay1s
ret

bajar:
rcall borrar_lcd
bajando_msj1:
	ldi zh, high(bajando*2)
	ldi zl, low(bajando*2)
	add zl, r17
	adc zh, r18
	lpm
	mov VAR, r0
	rcall WR_DAT
	inc r17
	cpi r17, 7
		brne bajando_msj1
rcall delay1s
rcall delay1s
//servo 2 baja
ldi r16, 12 // encontrar valores exactos
out ocr2, r16
rcall delay_cuartosec
ldi r16, 11
out ocr2, r16
rcall delay_cuartosec
ldi r16, 10 
out ocr2, r16
rcall delay_cuartosec
ldi r16, 9 
out ocr2, r16
rcall delay_cuartosec
ldi r16, 8 
out ocr2, r16
rcall delay1s
ret

borrar_lcd:
ldi r16, 1
rcall wr_ins
ldi r16, 0b1000_0000
rcall wr_ins
clr r17
clr r18
ret

;******************
;Aquí están las rutinas para el manejo de las interrupciones concretas
;******************
EXT_INT0: ; IRQ0 Handler
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti
EXT_INT1: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; IRQ1 Handler
TIM2_COMP: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; Timer2 Compare Handler
TIM2_OVF: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; Timer2 Overflow Handler
TIM1_CAPT: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; Timer1 Capture Handler
TIM1_COMPA: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; Timer1 CompareA Handler
TIM1_COMPB: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; Timer1 CompareB Handler
TIM1_OVF: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; Timer1 Overflow Handler
TIM0_OVF: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; Timer0 Overflow Handler
SPI_STC: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; SPI Transfer Complete Handler
USART_RXC: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; USART RX Complete Handler
USART_UDRE: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; UDR Empty Handler
USART_TXC: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; USART TX Complete Handler
ADC_COMP: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; ADC Conversion Complete Handler
EE_RDY: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; EEPROM Ready Handler
ANA_COMP: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; Analog Comparator Handler
TWSI: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; Two-wire Serial Interface Handler
EXT_INT2: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; IRQ2 Handler
TIM0_COMP: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti
SPM_RDY: 
	in R16, SREG
	push R16

	pop R16
	out SREG, R16
reti ; Store Program Memory Ready Handler


;**********************************************************************************************
;ESTA LIBRERA SE UTILIZA PARA EL LCD
;Esta libreria funciona a una frecuencia de ____________
;FUNCIONES:
;   - INI_LCD sirve para inicializar el LCD
;   - WR_INS para escribir una instruccion en el LCD.  Antes debe de cargarse en VAR la instrucción a escribir
;   - WR_DAT para escribir un dato en el LCD.  Antes debe de cargarse en VAR el dato a escribir
;REGISTROS
;   - Se emplea el registro R16, R17 y R18
;PUERTOS
;   - Se emplea el puerto D (pines 5 6 y 7 para RS, RW y E respectivamente)
;   - Se emplea el puerto C para la conexión a D0..D7
;   - Estos puertos pueden modificarse en la definición de variables
;************************************************************************************************************************
;Definición de variables
.def VAR3 = r20
.def VAR2=r19
.def VAR= r16
.equ DDR_DAT=DDRC
.equ PORT_DAT=PORTC
.equ PIN_DAT=PINC
.equ DDR_CTR=DDRD 
.equ PORT_CTR=PORTD
.equ PIN_RS=4
.equ PIN_RW=5
.equ PIN_E=6

;************************************************************************************************************************
INI_LCD:	
	rcall DECLARA_PUERTOS
    rcall T0_15m			 
	ldi VAR,0b00111000		;Function Set - Inicializa el LCD
	rcall WR_INS_INI		
	rcall T0_4m1
	ldi VAR,0b00111000		;Function Set - Inicializa elLCD
	rcall WR_INS_INI		
	rcall T0_100u			
	ldi VAR,0b00111000		;Function Set - Inicializa elLCD
	rcall WR_INS_INI		
	rcall T0_100u			
	ldi VAR,0b00111000		;Function Set - Define 2 líneas, 5x8 char font
	rcall WR_INS_INI		
	rcall T0_100u
	ldi VAR, 0b00001000		;Apaga el display
	rcall WR_INS
	ldi VAR, 0b00000001		;Limpia el display
    rcall WR_INS
	//*******************************************************************************************************************
	//---------------------------------------------CONTROL DE MODO --------------------------------------------------
	//MODO INCREMENTO SIN SHIFT
	ldi VAR, 0b00000110		;Entry Mode Set - Display clear, increment, without display shift
	rcall WR_INS	
	//MODO DECREMENTO SIN SHIFT
	//ldi VAR, 0b00000100		;Entry Mode Set - Display clear, increment, without display shift
	//rcall WR_INS
	//MODO INCREMENTO CON SHIFT
	//ldi VAR, 0b00000111		;Entry Mode Set - Display clear, increment, display shift
	//rcall WR_INS
	//MODO DECREMENTO CON SHIFT
	//ldi VAR, 0b00000101		;Entry Mode Set - Display clear, increment, display shift
	//rcall WR_INS
	//*******************************************************************************************************************	
	ldi VAR, 0b00001100		;Enciende el display
    rcall WR_INS		
	//*******************************************************************************************************************
	//---------------------------------------------CONTROL DE POSICIÓN --------------------------------------------------
	//PARA INCREMENTO SIN SHIFT
	ldi VAR, 0b1000_0000
	rcall WR_INS
	//PARA DECREMENTO SIN SHIFT
	//ldi VAR, 0b1000_1111
	//rcall WR_INS
	//PARA INCREMENTO CON SHIFT
	//ldi VAR, 0b1000_0100
	//rcall WR_INS
	//PARA DECREMENTO CON SHIFT
	//ldi VAR, 0b1010_0111
	//rcall WR_INS
	//*******************************************************************************************************************
ret
;************************************************************************************************************************
WR_INS: 
	rcall WR_INS_INI
	rcall CHK_FLG			;Espera hasta que la bandera del LCD responde que ya terminó
ret
;************************************************************************************************************************
WR_DAT:			
	out PORT_DAT,VAR 
	sbi PORT_CTR,PIN_RS		;Modo datos
	cbi PORT_CTR,PIN_RW		;Modo escritura
	sbi PORT_CTR,PIN_E		;Habilita E
	rcall T0_10m
	cbi PORT_CTR,PIN_E		;Quita E, regresa a modo normal
	rcall CHK_FLG			;Espera hasta que la bandera del LCD indica que terminó
ret
;************************************************************************************************************************
WR_INS_INI: 
	out PORT_DAT,VAR 
	cbi PORT_CTR,PIN_RS		;Modo instrucciones
	cbi PORT_CTR,PIN_RW		;Modo escritura
   	sbi PORT_CTR,PIN_E		;Habilita E
	rcall T0_10m			
	cbi PORT_CTR,PIN_E		;Quita E, regresa a modo normal
ret
;************************************************************************************************************************
DECLARA_PUERTOS:
	ldi VAR, 0xFF
	out DDR_DAT, VAR		; El puerto donde están conectados D0..D7 se habilita como salida
	out DDR_CTR, VAR		; Todo el puerto en donde estén conectados RS,RW y E se habilita como salida
ret	
;************************************************************************************************************************
CHK_FLG: 
	ldi VAR, 0x00		
	out DDR_DAT, VAR		;Establece el puerto de datos como entrada para poder leer la bandera
	cbi PORT_CTR, PIN_RS		;Modo instrucciones
	sbi PORT_CTR, PIN_RW		;Modo lectura
	RBF:
		sbi PORT_CTR, PIN_E 	;Habilita E
		rcall T0_10m
		cbi PORT_CTR, PIN_E	;Quita E, regresa a modo normal
	   	sbic PIN_DAT, 7		
		;sbis o sbic cambian según se trate de la vida real (C) o de poteus (S)
	   	rjmp RBF		;Repite el ciclo hasta que la bandera de ocupado(pin7)=1
	CONTINUA:	
	cbi PORT_CTR, PIN_RS		;Limpia RS
	cbi PORT_CTR, PIN_RW		;Limpia RW
		
 	ldi VAR, 0xFF   	
	out DDR_DAT, VAR		;Regresa el puerto de datos a su configuración como puerto de salida
ret
;************************************************************************************************************************
T0_15m:
; ============================= 
;    delay loop generator 
;     60000 cycles:
; ----------------------------- 
; delaying 59994 cycles:
          ldi  R22, $63
WGLOOP0a:  ldi  R23, $C9
WGLOOP1a:  dec  R23
          brne WGLOOP1a
          dec  R22
          brne WGLOOP0a
; ----------------------------- 
; delaying 6 cycles:
          ldi  R22, $02
WGLOOP2a:  dec  R22
          brne WGLOOP2a
; ============================= 

ret
;************************************************************************************************************************
T0_10m:
; ============================= 
;    delay loop generator 
;     40000 cycles:
; ----------------------------- 
; delaying 39999 cycles:
          ldi  R22, $43
WGLOOP0b:  ldi  R23, $C6
WGLOOP1b:  dec  R23
          brne WGLOOP1b
          dec  R22
          brne WGLOOP0b
; ----------------------------- 
; delaying 1 cycle:
          nop
; ============================= 
ret
;************************************************************************************************************************
T0_100u:
; ============================= 
;    delay loop generator 
;     400 cycles:
; ----------------------------- 
; delaying 399 cycles:
          ldi  R22, $85
WGLOOP0c:  dec  R22
          brne WGLOOP0c
; ----------------------------- 
; delaying 1 cycle:
          nop
; ============================= 
 
ret
;************************************************************************************************************************
T0_4m1:
; ============================= 
;    delay loop generator 
;     16400 cycles:
; ----------------------------- 
; delaying 16383 cycles:
          ldi  R22, $2B
WGLOOP0d:  ldi  R23, $7E
WGLOOP1d:  dec  R23
          brne WGLOOP1d
          dec  R22
          brne WGLOOP0d
; ----------------------------- 
; delaying 15 cycles:
          ldi  R22, $05
WGLOOP2d:  dec  R22
          brne WGLOOP2d
; ----------------------------- 
; delaying 2 cycles:
          nop
          nop
; ============================= 
ret

delay1s:
; ============================= 
;    delay loop generator 
;     4000000 cycles:
; ----------------------------- 
; delaying 3999996 cycles:
          ldi  R22, $24
WGLOOP01:  ldi  R23, $BC
WGLOOP11:  ldi  R24, $C4
WGLOOP21:  dec  R24
          brne WGLOOP21
          dec  R23
          brne WGLOOP11
          dec  R22
          brne WGLOOP01
; ----------------------------- 
; delaying 3 cycles:
          ldi  R22, $01
WGLOOP31:  dec  R22
          brne WGLOOP31
; ----------------------------- 
; delaying 1 cycle:
          nop
; ============================= 
ret

delay_cuartosec:
; ============================= 
;    delay loop generator 
;     1000000 cycles:
; ----------------------------- 
; delaying 999999 cycles:
          ldi  R22, $09
WGLOOP02:  ldi  R23, $BC
WGLOOP12:  ldi  R24, $C4
WGLOOP22:  dec  R24
          brne WGLOOP22
          dec  R23
          brne WGLOOP12
          dec  R22
          brne WGLOOP02
; ----------------------------- 
; delaying 1 cycle:
          nop
; ============================= 
ret

acomodando_arriba: .db "Acomodando para " // 16
acomodando_abajo: .db "poder iniciar..." // 16
iniciar_arriba: .db "Presiona boton" // 14
iniciar_abajo: .db "para comenzar!" // 14
cerrando: .db "Cerrando pinza.." // 16
blanco_msj: .db "Color: BLANCO!" // 14
negro_msj: .db "Color: NEGRO! " // 14
subiendo: .db "Subiendo... " // 12
bajando: .db "Bajando..." // 10
soltando: .db "Abriendo pinza.." // 16
