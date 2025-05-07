/*
 * Proyecto.c
 *
 * Created: 28/04/2025 16:41:35
 * Author : René González
 */ 

/****************************************/// Encabezado (Libraries)#define F_CPU 16000000#include <avr/io.h>#include <avr/interrupt.h>#include <avr/eeprom.h>#include <util/delay.h>#include "ADC/ADClib.h"#include "PWM1/PWM.h"volatile int contador=0;uint16_t conversion1=0;uint16_t servo1=0;uint16_t conversion2=0;uint16_t servo2=0;uint16_t conversion3=0;uint16_t servo3=0;uint16_t conversion4=0;uint16_t servo4=0;volatile int modo=1; //Modo manual, guardado, adafuit./****************************************/// Function prototypesvoid setup();/****************************************/// Main Functionint main(){		setup();	while (1)
	{
		switch(modo)
		{
			case 1:
				movservo1(servo1);
				movservo2(servo2);
				movservo3(servo3);
				movservo4(servo4);
				break;
			case 2:
				if (!(PINC & (1 << PINC1)))
				{
					_delay_ms(50); 
					if (!(PINC & (1 << PINC1))) 
					{
						//Si si se apacho el de guardar, guardamos
						
					}
				}
				break;
		}
	}}/****************************************/// NON-Interrupt subroutinesvoid setup(){	cli();	DDRC=0;	PORTC=0; //Puerto c como entrada, estaran los ADC´s	PORTC |= (1 << PORTC2);// PUll up en pc2	PCICR |= (1<<PCIE1);	PCMSK1 |= (1<<PCINT10); //PINCHANGE PC2	initADC();	initPWM();	initPWM2();	ADCSRA|=(1<<ADSC);	sei();}/**************************************/// Interrupt routinesISR(PCINT1_vect){	if (!(PINC & (1 << PORTC2)))
	{ 
		_delay_ms(50); // Anti-rebote (Preguntar a pedro)
		if (!(PINC & (1 << PORTC2))) 
		{
			modo++;
			if (modo > 2) modo = 1; // Reiniciar si supera el número de modos
		}
	}
}ISR(ADC_vect){	switch (modo)	{		case 1:			contador++;			if (contador==1)			{				conversion1= ADCH;				ADMUX &= ~((1<<MUX2)|(1<<MUX1)|(1<<MUX0));				ADMUX|= (1<<MUX2)|(1<<MUX0); //La proxima lectura sera en el ADC 5				servo1=1200+(conversion1*14.12);				ADCSRA |=(1<<ADSC);			}			else if (contador==2)
			{
				conversion2=ADCH;
				ADMUX &= ~((1<<MUX2)|(1<<MUX1)|(1<<MUX0));
				ADMUX |= (1<<MUX2); //Para ADC 4
				servo2= 1200+(conversion2*14.12);
				ADCSRA |= (1<<ADSC);
			}			else if (contador==3)
			{
				conversion3=ADCH;
				ADMUX &= ~((1<<MUX2)|(1<<MUX1)|(1<<MUX0));
				ADMUX |= (1<<MUX1)|(1<<MUX0);//Para adc 3
				servo3 = 9.08+(conversion3*0.106);
				ADCSRA|= (1<<ADSC);
			}			else if(contador==4)			{				conversion4=ADCH;				ADMUX &= ~((1<<MUX2)|(1<<MUX1)|(1<<MUX0));				ADMUX |= (1<<MUX2)|(1<<MUX1); //Proxima lectura en el adc 6.				servo4= 9.08+(conversion4*0.106);				ADCSRA|= (1<<ADSC);				contador=0;			}			break;		default:			break;	}}