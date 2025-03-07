;
; Prelab_03.asm
;
; Created: 16/02/2025 16:49:10
; Author : Barbaritos
;
.include "M328PDEF.inc"

.cseg //lo que sigue es codigo
.org 0x0000
	JMP PILA
.org	PCI0addr //mascara de puerto B 
	JMP INTERRUPCION
.org	OVF0addr
	JMP INCREMENTAR10MS
PILA:
// coonfigurams la pila
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R16, HIGH(RAMEND)
OUT SPH, R16
//configuramos el MCU
SETUP:
	LDI R16, (1<< CLKPCE)
	STS CLKPR, R16 //HABILITE CAMBIOS DEL PRESCALER
	LDI R16, 0b00000101
	STS CLKPR, R16 //nUESTRO TIMER TRABAJARA A 0.5MHZ

	CALL START_TIMR0

	Tabla7seg: .DB 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F

	CLI

	LDI R16, 0XFF
	OUT PORTC, R16 //pUERTO C COMO SALIDA
	LDI R16, 0X00
	OUT PORTC, R16 //0V EN LOS PINES DE NUESTRA SALIDA

	OUT PORTB, R16 //PUERTO B COMO ENTRADA 
	LDI R16, 0XFF
	OUT PORTB, R16 //PULLUP HABILITADOS EN EL PUERTO B 

	LDI R16, (1<< PCIE0)
	STS PCICR, R16 //REGISTRO DE INTERRUPCIONES, HABILITADO PARA EL PUERTO B

	LDI R16, (1<< PCINT0) | (1<< PCINT1)
	STS PCMSK0, R16  //MASCARA PARA EL PUERTO B EN EL BIT 0 Y 1


	LDI R16, (1<< TOIE0)
	STS TIMSK0, R16

	SEI //ENCENDEMOS TODAS LAS INTERRUPCIONES GLOBALES 
	LDI R17, 0XFF //ESTADO ANTIGUO DE LOS BOTONES 
	LDI R19, 0X00
	LDI		ZL, LOW(Tabla7seg<<1)
	LDI		ZH, HIGH(Tabla7seg<<1)


MAIN:
	LPM R20, Z
	OUT PORTD, R19
	OUT PORTC, R18
	RJMP MAIN




INCREMENTAR10MS:
	INC R19
	CPI R19, 0X64
	BREQ CONT
	RETI

CONT:
	ADIW Z,1 
	RETI

INTERRUPCION:
	PUSH R16
	IN R16, SREG
	PUSH R16

	IN R16, PINB 

	SBRS	R17, PB0 // SI EL ESTADO ANTERIOR ERA 1
	SBRC	R16, PB0 //Y EL ESTADO ACTUAL ES 0  
	INC		R18


	SBRC	R17, PB0 //SI EL ESTADO ANTERIOR ERA 0
	SBRS	R16, PB0 // Y EL ESTADO ACTUAL ES 1
	INC		R18 //FLANCO DE SUBIDA 


	;MISMA LOGICA CON EL PCINT1 (BIT1)
	SBRS	R17, PB1
	SBRC	R16, PB1
	DEC		R18

	SBRC	R17, PB1
	SBRS	R16, PB1
	DEC		R18
	MOV		R17, R16 //NUESTRO ESTADO ACTUAL SERA EL NUEVO ESTADO VIEJO.

	POP		R16
	OUT		SREG, R16
	POP		R16

	RETI


START_TIMR0:
	LDI		R16, 0b00000011 //PRESCALER QUE QUEREMOS =64 PARA 10MS
	OUT		TCCR0B, R16 //LE CARGAMOS ESE PRESCALER DE 0 A 64
	LDI		R16, 178
	OUT		TCNT0, R16
	RET