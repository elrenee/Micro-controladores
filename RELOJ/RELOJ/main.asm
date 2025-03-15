;
; RELOJ.asm
;
; Created: 9/03/2025 16:54:19
; Author : Barbaritos
;

.include "M328PDEF.inc"
.dseg
.org	SRAM_START
DECHOUR: .byte 1
UHOUR:	 .byte 1
DECMIN:	 .byte 1
UNIMIN:	 .byte 1
DECMES:  .byte 1
UNIMES:  .byte 1
DECDIAS: .byte 1
UNIDIAS: .byte 1
DECHOURALARM: .byte 1
UNHOURALARM:  .byte 1
DECMINALARM: .byte 1
UNIMINALARM: .byte 1



.equ MODES =5 //Reloj, Fecha, Configurar R, configurar F, Alarma
.equ DISPLAYS= 4
.DEF MODE = R17
.DEF DISPLAY= R18




.cseg //lo que sigue es codigo
.org 0x0000
	JMP START
.org PCI0addr
	JMP PBISR



START:
// coonfigurams la pila
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R16, HIGH(RAMEND)
OUT SPH, R16

SETUP:
	Tabla7seg: .DB 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F

	CLR MODE

	LDI R30, 0X00 ;ME AYUDARA PARA CORRER Z DEPENDIENDO EL VALOR QUE QUIERO MOSTRAR

	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1)
	LDI		R16, 0X00
	LDI		R29, 0X00 //SERA DONDE PONDRE EL VALOR QUE QUIERO MOSTRAR EN EL DISPLAY
	LDI		R30, 0X00 ;ME AYUDARA PARA CORRER Z DEPENDIENDO EL VALOR QUE QUIERO MOSTRAR

	//Botones del reloj
	CBI		DDRB, PB0
	CBI		DDRB, PB1
	CBI		DDRB, PB2
	CBI		DDRB, PB3
	SBI		PORTB, PB0
	SBI		PORTB, PB1
	SBI		PORTB, PB2
	SBI		PORTB, PB3




	//CONFIGURACIÓN DE INTERRUPCIONES 
	LDI		R16, (1 << PCINT0) | (1 << PCINT1) | (1 << PCINT2) | (1 << PCINT3) // INTERRUPCIONES DE BOTONES DEL PB0 AL PB3
	STS		PCMSK0, R16
	LDI		R16, (1 << PCIE0)
	STS		PCICR, R16



MAINLOOP:
	CPI		MODE, 0
	BREQ	HORA
	CPI		MODE, 1
	;BREQ	CONF_HORA
	CPI		MODE, 2
	BREQ	FECHA1
	CPI		MODE,3
	;BREQ	CONF_FECHA
	CPI		MODE, 4
	BREQ	ALARMA1
	RJMP	MAINLOOP

FECHA1: 
	JMP FECHA

ALARMA1:
	JMP ALARMA

HORA:
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1)
	CBI		PORTC, 0 
	CBI		PORTC, 1
	CBI		PORTC, 2
	CBI		PORTC, 3
	CALL	DECENAHORA
	SBI		PORTC, 0
	OUT		PORTD, R29
	CALL	UNIHORA
	CBI		PORTC, 0 
	SBI		PORTC, 1
	OUT		PORTD, R29
	CALL	DECENAMIN
	CBI		PORTC, 1 
	SBI		PORTC, 2
	OUT		PORTD, R29
	CALL	UNIDADMIN
	CBI		PORTC, 2
	SBI		PORTC, 3
	OUT		PORTD, R29
	RJMP	MAINLOOP  // NOO SE SI RET O RJMP A HORA DE NUEVO, Y PONER UN COMPARADOR PARA QUE SE EJECUTE RET SOLO SI SE CAMBIO EL MODO 

DECENAHORA:
	LDS R16, DECHOUR  //DECHOUR SOLO LO INCREMENTARE EN LA INTERRUPCION DEL TIMER, SI Y SOLO SI YA PASARON 10 HORAS
	CPSE	R30, R16
	ADIW	Z, 1
	CPSE	R30, R16
	INC		R30
	CP		R30, R16
	BRNE	DECENAHORA
	LPM		R29, Z
	CLR		R30
	RET

UNIHORA:
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1) //RESETEAMOS HACCIA DONDE ESTA APUNTANDO Z 
	LDS		R16, UHOUR
	CPSE	R30, R16
	ADIW	Z, 1
	CPSE	R30, R16
	INC		R30
	CP		R30, R16
	BRNE	UNIHORA
	LPM		R29, Z
	CLR		R30
	RET

DECENAMIN:
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1) // RESETEAMOS A DONDE APUNTA Z
	LDS	R16, DECMIN
	CPSE	R30, R16
	ADIW	Z, 1
	CPSE	R30, R16
	INC		R30
	CP		R30, R16
	BRNE	DECENAMIN
	LPM		R29, Z
	CLR		R30
	RET 


UNIDADMIN:
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1)// RESETEAMOS A DONDE APUNTA Z
	LDS	R16, UNIMIN
	CPSE	R30, R16
	ADIW	Z, 1
	CPSE	R30, R16
	INC		R30
	CP		R30, R16
	BRNE	UNIDADMIN
	LPM		R29, Z
	CLR		R30
	RET 


//SEGUNDO MODO, CONFIGURACIÓN DE LA HORA 



// TERCER MODO, MOSTRAR LA FECHA EN LOS DISPLAYS!!!!!!
FECHA:
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1)
	CBI		PORTC, 0
	CBI		PORTC, 1
	CBI		PORTC, 2
	CBI		PORTC, 3
	CALL	DECENAMES
	SBI		PORTC, 0
	OUT		PORTC, R29
	CALL	UNIDADMES
	CBI		PORTC, 0
	SBI		PORTC, 1
	OUT		PORTC, R29
	CALL	DECENADIAS 
	CBI		PORTC, 1
	SBI		PORTC, 2
	OUT		PORTC, R29
	CALL	UNIDADDIAS
	CBI		PORTC, 2
	SBI		PORTC, 3
	OUT		PORTC, R29
	RJMP	MAINLOOP //NO SE SI RET O RJMP A FECHA 


DECENAMES:
	LDS R16, DECMES
	CPSE	R30, R16
	ADIW	Z, 1
	CPSE	R30, R16
	INC		R30
	CP		R30, R16
	BRNE	DECENAMES 
	LPM		R29, Z
	CLR		R30
	RET

UNIDADMES:
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1)
	LDS	R16, UNIMES
	CPSE	R30, R16
	ADIW	Z, 1
	CPSE	R30, R16
	INC		R30
	CP		R30, R16
	BRNE	UNIDADMES 
	LPM		R29, Z
	CLR		R30
	RET


DECENADIAS:
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1)
	LDS	R16, DECDIAS
	CPSE	R30, R16
	ADIW	Z, 1
	CPSE	R30, R16
	INC		R30
	CP		R30, R16
	BRNE	DECENADIAS 
	LPM		R29, Z
	CLR		R30
	RET

UNIDADDIAS:
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1)
	LDS	R16, UNIDIAS
	CPSE	R30, R16
	ADIW	Z, 1 
	CPSE	R30, R16
	INC		R30
	CP		R30, R16 
	BRNE	UNIDADDIAS
	LPM		R29, Z
	CLR		R30
	RET 


//CUARTO MODO,  ALARMA. 
ALARMA: 
	//4 CONTADORES, Y CUANDO EL TIMER INCREMENTE MINUTO, DECENA DE MIN, HORA Y DECENA DE HORA, A SU VEZ COMPARARÁ SI ES IGUAL A LOS CONTADORES DE ES EL 
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1)
	CBI		PORTC, 0 
	CBI		PORTC, 1
	CBI		PORTC, 2
	CBI		PORTC, 3
	CALL	DECENAHORALARMA
	SBI		PORTC, 0
	OUT		PORTD, R29
	CALL	UNIHORALARMA
	CBI		PORTC, 0 
	SBI		PORTC, 1
	OUT		PORTD, R29
	CALL	DECENAMINALARMA
	CBI		PORTC, 1 
	SBI		PORTC, 2
	OUT		PORTD, R29
	CALL	UNIDADMINALARMA
	CBI		PORTC, 2
	SBI		PORTC, 3
	OUT		PORTD, R29
	RJMP	MAINLOOP  // NOO SE SI RET O RJMP A HORA DE NUEVO, Y PONER UN COMPARADOR PARA QUE SE EJECUTE RET SOLO SI SE CAMBIO EL MODO 

DECENAHORALARMA:
	LDS	R16, DECHOURALARM  //DECHOUR SOLO LO INCREMENTARE EN LA INTERRUPCION DEL TIMER, SI Y SOLO SI YA PASARON 10 HORAS
	CPSE	R30, R16
	ADIW	Z, 1
	CPSE	R30, R16
	INC		R30
	CP		R30, R16
	BRNE	DECENAHORALARMA
	LPM		R29, Z
	CLR		R30
	RET

UNIHORALARMA:
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1) //RESETEAMOS HACCIA DONDE ESTA APUNTANDO Z 
	LDS	R16, UNHOURALARM
	CPSE	R30, R16
	ADIW	Z, 1
	CPSE	R30, R16
	INC		R30
	CP		R30, R16
	BRNE	UNIHORALARMA
	LPM		R29, Z
	CLR		R30
	RET

DECENAMINALARMA:
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1) // RESETEAMOS A DONDE APUNTA Z
	LDS	R16, DECMINALARM
	CPSE	R30, R16
	ADIW	Z, 1
	CPSE	R30, R16
	INC		R30
	CP		R30, R16
	BRNE	DECENAMINALARMA
	LPM		R29, Z
	CLR		R30
	RET 


UNIDADMINALARMA:
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1)// RESETEAMOS A DONDE APUNTA Z
	LDS		R16, UNIMINALARM
	CPSE	R30, R16
	ADIW	Z, 1
	CPSE	R30, R16
	INC		R30
	CP		R30, R16
	BRNE	UNIDADMINALARMA
	LPM		R29, Z
	CLR		R30
	RET 

//iNTERRUPCION DEL BOTON

PBISR:
	PUSH	R16
	IN		R16, SREG
	PUSH	R16


	//VEAMOS SI FUE EL DE MODO
	SBIS	PINB, PB0  //Con configuración pull up saltara la siguiente linea a menos que se haya apachado PB0
	INC		MODE

	//VEMOS SI YA ESTABAMOS EN EL ULTIMO MODO
	LDI		R16, MODES
	CPSE	MODE, R16
	RJMP	PC+2
	CLR		MODE

	//VEMOS EN QUE MODO ESTAMOS 
	CPI		MODE, 0
	BREQ	MODE0
	CPI		MODE, 1
	BREQ	MODE1 //CONFIGURAR HORA



MODE0:
	JMP SALIR_ISR

MODE1:
	//LDS dECENAS , UNIDADES, DECENAS 2 Y UNIDADES 2 EN REGISTROS PARA SOLO INC O DEC 
	LDS		R20, DECHOUR
	LDS		R21, UHOUR
	LDS		R22, DECMIN
	LDS		R23, UNIMIN

	//VEAMOS SI SE APACHO EL DE CAMBIAR DISPLAY 
	SBIS	PINB, PB1
	INC		DISPLAY
	
	//vEMOS SI ESTABAMOS EN EL ULTIMO DISPLAY 
	LDI		R16, DISPLAYS 
	CPSE	DISPLAY, R16 
	RJMP	PC+2
	CLR		DISPLAY 

	//VEAMOS EN QUE DISPLAY FUE 
	CPI		DISPLAY, 0
	BREQ	DISPLAY0

DISPLAY0:
	SBIS	PINB, PB2
	INC		R20
	SBIS	PINB, PB3
	DEC		R20
