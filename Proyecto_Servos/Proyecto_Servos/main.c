/*
 * Proyecto.c
 *
 * Created: 28/04/2025 16:41:35
 * Author : Ren? Gonz?lez
 */ 

/****************************************/// Encabezado (Libraries)#define F_CPU 16000000#include <avr/io.h>#include <avr/interrupt.h>#include <avr/eeprom.h>#include <util/delay.h>#include "ADC/ADClib.h"#include "PWM1/PWM.h"#define NUM_CONFIGS 4
#define CONFIG_SIZE 8typedef struct {
	uint16_t servo1;
	uint16_t servo2;
	uint16_t servo3;
	uint16_t servo4;
} ServoConfig;
volatile uint8_t current_config = 0; //para las 4 posiciones a guardar. volatile int contador=0;uint16_t conversion1=0;uint16_t servo1=0;uint16_t conversion2=0;uint16_t servo2=0;uint16_t conversion3=0;uint16_t servo3=0;uint16_t conversion4=0;uint16_t servo4=0;volatile int modo=1; //Modo manual, guardado, adafuit./****************************************/// Function prototypesvoid setup();void writeEEPROM(uint16_t addr, const void *data, uint8_t len);void saveCurrentConfiguration();/****************************************/// Main Functionint main(){		setup();	while (1)
	{
		switch(modo)
		{
			case 1:
				PORTB |= (1 << PORTB4);
				movservo1(servo1);
				movservo2(servo2);
				movservo3(servo3);
				movservo4(servo4);
				break;
			case 2:
				PORTB &= ~(1 << PORTB4);
				if (!(PINC & (1 << PINC1)))
				{
					_delay_ms(50); 
					if (!(PINC & (1 << PINC1))) 
					{
						//Si si se apacho el de guardar, guardamos
						saveCurrentConfiguration();
						// Esperamos hasta que se suelte el bot?n
						while(!(PINC & (1 << PINC1)));
					}
				}
				break;
		}
	}}/****************************************/// NON-Interrupt subroutinesvoid setup(){	cli();	DDRB |= (1 << DDB4);	DDRC=0;	PORTC=0; //Puerto c como entrada, estaran los ADC?s	PORTC |= (1 << PORTC2);// PUll up en pc2	PCICR |= (1<<PCIE1);	PCMSK1 |= (1<<PCINT10); //PINCHANGE PC2	initADC();	initPWM();	initPWM2();	ADCSRA|=(1<<ADSC);	current_config =0;	sei();}void writeEEPROM(uint16_t addr, const void *data, uint8_t len) 
{
	uint8_t *p = (uint8_t*)data;
	for(uint8_t i = 0; i < len; i++) 
	{
		// Esperar a que termine escritura anterior
		while(EECR & (1 << EEPE));
		
		// Configurar direcci?n y dato
		EEAR = addr + i;
		EEDR = p[i];
		
		// Habilitar escritura
		EECR |= (1 << EEMPE);
		EECR |= (1 << EEPE);
	}
}void saveCurrentConfiguration() 
{
	ServoConfig config;
	// Obtenemos las posiciones actuales
	config.servo1 = servo1;
	config.servo2 = servo2;
	config.servo3 = servo3;
	config.servo4 = servo4;
	// Calcular direcci?n EEPROM
	uint16_t eeprom_addr = current_config * sizeof(ServoConfig);
	//Escribimos en la eeprom
	writeEEPROM(eeprom_addr, &config, sizeof(ServoConfig));
	// Actualizar ?ndice (circular 0-3)
	current_config = (current_config + 1) % NUM_CONFIGS;
}/**************************************/// Interrupt routinesISR(PCINT1_vect){	if (!(PINC & (1 << PORTC2)))
	{ 
		_delay_ms(50); // Anti-rebote (Preguntar a pedro)
		if (!(PINC & (1 << PORTC2))) 
		{
			modo = 3-modo; // Reiniciar si supera el n?mero de modos
			if (modo == 1) // Si acaba de entrar en modo manual
			{
				contador = 0; // Reinicia el contador del ADC
				ADMUX &= ~((1<<MUX2)|(1<<MUX1)|(1<<MUX0)); 
				ADMUX |= (1<<MUX2)|(1<<MUX1);
				ADCSRA |= (1<<ADSC); // Inicia una nueva conversión
			}
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