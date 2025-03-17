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
	BREQ	CONF_HORA1
	CPI		MODE, 2
	BREQ	FECHA1
	CPI		MODE,3
	;BREQ	CONF_FECHA
	CPI		MODE, 4
	BREQ	ALARMA1
	RJMP	MAINLOOP

CONF_HORA1:
	JMP CONF_HORA
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
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1) //RESETEAMOS HACCIA DONDE ESTA APUNTANDO Z 
	CALL	UNIHORA
	CBI		PORTC, 0 
	SBI		PORTC, 1
	OUT		PORTD, R29
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1) //RESETEAMOS HACCIA DONDE ESTA APUNTANDO Z 
	CALL	DECENAMIN
	CBI		PORTC, 1 
	SBI		PORTC, 2
	OUT		PORTD, R29
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1) //RESETEAMOS HACCIA DONDE ESTA APUNTANDO Z 
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

//*************************************************
//************************************************
//****SEGUNDO MODO, CONFIGURACIÓN DE LA HORA*****
//************************************************
//************************************************* 
CONF_HORA:
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1) //RESETEAMOS HACCIA DONDE ESTA APUNTANDO Z 
	CBI		PORTC, 0
	CBI		PORTC, 1
	CBI		PORTC, 2
	CBI		PORTC, 3
	CPI		DISPLAY, 0X00
	BREQ	MOSTRARDISP0
	CPI		DISPLAY, 0X01
	BREQ	MOSTRARDISP1
	CPI		DISPLAY, 0X02
	BREQ	MOSTRARDISP2
	CPI		DISPLAY, 0X03
	BREQ	MOSTRARDISP3

MOSTRARDISP0:
	SBI		PORTC, 0 
	CALL	DECENAHORA
	OUT		PORTD, R29
	RJMP	MAINLOOP
MOSTRARDISP1:
	SBI		PORTC, 1
	CALL	UNIHORA
	OUT		PORTD, R29
	RJMP	MAINLOOP
MOSTRARDISP2:
	SBI		PORTC, 2
	CALL	DECENAMIN
	OUT		PORTD, R29
	RJMP	MAINLOOP
MOSTRARDISP3:
	SBI		PORTC, 3
	CALL	UNIDADMIN
	OUT		PORTD, R29
	RJMP	MAINLOOP


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
	CPI		DISPLAY, 0X00
	BREQ	MOSTRARDECHALARM
	CPI		DISPLAY, 0X01
	BREQ	MOSTRARUNIHALARM
	CPI		DISPLAY, 0X02
	BREQ	MOSTRARDECMALARM
	CPI		DISPLAY, 0X03
	BREQ	MOSTRARUNIMALARM

MOSTRARDECHALARM:
	SBI		PORTC, 0
	CALL	DECENAHORALARMA
	OUT		PORTD, R29
	RJMP	MAINLOOP
MOSTRARUNIHALARM:
	SBI		PORTC, 1	
	CALL	UNIHORALARMA
	OUT		PORTD, R29
	RJMP	MAINLOOP
MOSTRARDECMALARM:
	SBI		PORTC, 2
	CALL	DECENAMINALARMA
	OUT		PORTD, R29
	RJMP	MAINLOOP
MOSTRARUNIMALARM:
	SBI		PORTC, 3
	CALL	UNIDADMINALARMA
	OUT		PORTD, R29
	RJMP	MAINLOOP 


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
	CPI		MODE, 2
	BREQ	MODETWO
	CPI		MODE, 3
	BREQ	MODETRES

MODETWO:
	JMP MODE2
MODETRES:
	JMP	MODE3
MODE0:
	JMP SALIR_ISR_CH

MODE1://CONFIGURAR HORA
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
	CPI		DISPLAY, 1
	BREQ	DISPLAY1
	CPI		DISPLAY, 2
	BREQ	DISPLAY2
	CPI		DISPLAY, 3
	BREQ	DISPLAY3

DISPLAY0:
	LDI		R21, 0x03
	LDI		R22, 0XFF
	LDS		R20, DECHOUR
	SBIS	PINB, PB2
	INC		R20
	CPSE	R20, R21
	RJMP	PC+2
	CLR		R20
	SBIS	PINB, PB3
	DEC		R20
	CPSE	R20, R22
	RJMP	PC+2
	LDI		R20, 0X02
	STS		DECHOUR, R20
	JMP		SALIR_ISR_CH
DISPLAY1:
	LDI		R21, 0X0A
	LDI		R22, 0XFF
	LDS		R20, UHOUR
	SBIS	PINB, PB2
	INC		R20
	CPSE	R20, R21
	RJMP	PC+2
	CLR		R20
	SBIS	PINB, PB3
	DEC		R20
	CPSE	R20, R22
	RJMP	PC+2
	LDI		R20, 0X09
	STS		UHOUR, R20
	JMP		SALIR_ISR_CH
DISPLAY2:
	LDI		R21, 0X06
	LDI		R22, 0XFF
	LDS		R20, DECMIN
	SBIS	PINB, PB2
	INC		R20
	CPSE	R20, R21
	RJMP	PC+2
	CLR		R20
	SBIS	PINB, PB3
	DEC		R20
	CPSE	R20, R22
	RJMP	PC+2
	LDI		R20, 0X05
	STS		DECMIN, R20
	JMP		SALIR_ISR_CH
DISPLAY3:
	LDI		R21, 0X0A
	LDI		R22, 0XFF
	LDS		R20, UNIMIN
	SBIS	PINB, PB2
	INC		R20
	CPSE	R20, R21
	RJMP	PC+2
	CLR		R20
	SBIS	PINB, PB3
	DEC		R20
	CPSE	R20, R22
	RJMP	PC+2
	LDI		R20, 0X09
	STS		UNIMIN, R20
	JMP		SALIR_ISR_CH

MODE2:
	RJMP	SALIR_ISR_CH

MODE3://CONFIGURAR FECHA
	//VEAMOS SI SE APACHO EL DE CAMBIAR DISPLAY 
	SBIS	PINB, PB1
	INC		DISPLAY
	
	//VEMOS SI ESTABAMOS EN EL ULTIMO DISPLAY 
	LDI		R16, DISPLAYS 
	CPSE	DISPLAY, R16 
	RJMP	PC+2
	CLR		DISPLAY 
	//VEAMOS QUE DISPLAY ESTAMOS 
	CPI		DISPLAY, 0
	BREQ	DISPLAYDATE0
	CPI		DISPLAY, 1
	BREQ	DISPLAYDATE1
	CPI		DISPLAY, 2
	BREQ	DISPLAYDATE2
	CPI		DISPLAY, 3
	BREQ	DISPLAYDATE3

DISPLAYDATE0:
	LDI		R21, 0x02
	LDI		R22, 0XFF
	LDS		R20, DECMES
	SBIS	PINB, PB2
	INC		R20
	CPSE	R20, R21
	RJMP	PC+2
	CLR		R20
	SBIS	PINB, PB3
	DEC		R20
	CPSE	R20, R22
	RJMP	PC+2
	LDI		R20, 0X01
	STS		DECMES, R20
	JMP		SALIR_ISR_CH
DISPLAYDATE1:
	LDI		R21, 0X0A
	LDI		R22, 0XFF
	LDS		R20, UNIMES
	SBIS	PINB, PB2
	INC		R20
	CPSE	R20, R21
	RJMP	PC+2
	CLR		R20
	SBIS	PINB, PB3
	DEC		R20
	CPSE	R20, R22
	RJMP	PC+2
	LDI		R20, 0X09
	STS		UNIMES, R20
	JMP		SALIR_ISR_CH
DISPLAYDATE2:
	LDI		R21, 0X04
	LDI		R22, 0XFF
	LDS		R20, DECDIAS
	SBIS	PINB, PB2
	INC		R20
	CPSE	R20, R21
	RJMP	PC+2
	CLR		R20
	SBIS	PINB, PB3
	DEC		R20
	CPSE	R20, R22
	RJMP	PC+2
	LDI		R20, 0X09
	STS		DECDIAS, R20
	JMP		SALIR_ISR_CH
DISPLAYDATE3:
	LDI		R21, 0X0A
	LDI		R22, 0XFF
	LDS		R20, UNIDIAS
	SBIS	PINB, PB2
	INC		R20
	CPSE	R20, R21
	RJMP	PC+2
	CLR		R20
	SBIS	PINB, PB3
	DEC		R20
	CPSE	R20, R22
	RJMP	PC+2
	LDI		R20, 0X09
	STS		UNIDIAS, R20
	JMP		SALIR_ISR_CH


SALIR_ISR_CH:
	POP		R16
	OUT		SREG, R16
	POP		R16
	RETI