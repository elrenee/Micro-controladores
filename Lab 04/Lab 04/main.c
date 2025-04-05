 /*ejemploen_C.c * * Created:29/03/2025  * Author: René David González * Description: Laboratorio 04, programación de microcontroladores. Convertidor de señales analogas y digitales. *//****************************************/// Encabezado (Libraries)#define F_CPU 16000000#include <avr/io.h>#include <avr/interrupt.h>uint8_t contador=0;uint8_t botonesPC = 0;uint8_t unidades=0;uint8_t decenas=0;uint8_t conversion=0;int	lista7seg[] ={0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0X79, 0x71};/****************************************/// Function prototypesvoid setup();void initimr0();void initadmux();/****************************************/// Main Function

int main(void)
{
	setup();
	while (1)
	{
		PORTC	|= (1<<PORTC0);
		PORTD	= contador;
		PORTC	&= ~(1<< PORTC0);
		PORTC	|=(1<< PORTC2);
		PORTD	= lista7seg[unidades];
		PORTC	&= ~(1<< PORTC2);
		PORTC	|= (1<<PORTC1);
		PORTD	= lista7seg[decenas];
		PORTC	&= ~(1<<PORTC1) ;
	}
}

/****************************************/// NON-Interrupt subroutinesvoid setup(){	cli();	DDRD = 0XFF;	PORTD = 0X00;// PUERTO D COMO SALIDA, 0V EN CADA PIN 		DDRC |= (1<<PORTC4)|(0<<PORTC3)|(1<<PORTC2)|(1<<PORTC1)|(1<<PORTC0);//Pines 0, 1, 2 y 4 del Puerto C COMO SALIDA, Pin 3 como entrada.	PORTC= 0x00; 		DDRB = 0x00;	PORTB = 0xFF;		PCMSK0 = (1<< PCINT0) | (1<< PCINT1);	PCICR = (1<< PCIE0); //interruptions habilitadas en el puerto B		//configuramos el Convertidor de analogo a digital. 	initadmux();	initimr0();		ADCSRA |= (1<<ADSC); //Iniciamos la Conversión	sei();}void initimr0(){	CLKPR = (1<<CLKPCE) ;	CLKPR = (1<<CS01)|(1<<CS00);	TCCR0A=0;	TCCR0B |= (1<<CS02);	TCNT0 = 158;}void initadmux(){	ADMUX=0;	ADMUX |= (1<< REFS0) | (1<<ADLAR) | (1<<MUX1) | (1<<MUX0);//Referencia de 5v, Ajustado a la izq, Canal 3 de ADC	ADCSRA= 0;	ADCSRA |= (1<< ADPS1)|(1<< ADPS0)|(1<<ADATE) |(1<< ADIE)| (1<< ADEN);//Prescalers, Autotrigger, Interrupciónes habilitadas, ADC Enable.	ADCSRB =0; //Modo free running.}/**************************************/// Interrupt routinesISR(PCINT0_vect){		botonesPC = PINB;	TIFR0	|= (1 << TOV0);	TCNT0=158;	TIMSK0= (1<<TOIE0);}ISR(TIMER0_OVF_vect){	TIMSK0=0;	uint8_t botonest0 = PINB;	if (botonesPC == botonest0)	{		uint8_t temporal = botonest0 & (0b00000001);		if(temporal != 0b00000001)		{			contador++;		}		temporal = botonest0 & (0b00000010);		if(temporal != 0b00000010)		{			contador--;		}	}}ISR(ADC_vect){	conversion= ADCH;	unidades= conversion & 0x0F;	decenas = (conversion & 0xF0)>>4;		if (conversion>contador)	{		//Encender led	}	else if (conversion<contador)	{		//apagar led	}}