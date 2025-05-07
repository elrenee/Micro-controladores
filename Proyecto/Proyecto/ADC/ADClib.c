/*
 * ADClib.c
 *
 * Created: 28/04/2025 16:49:55
 *  Author: Barbaritos
 */ 
#include "ADClib.h"
void initADC()
{
	ADMUX=0;	ADMUX |= (1<< REFS0) | (1<<ADLAR) | (1<<MUX2) | (1<<MUX1);//Referencia de 5v, Ajustado a la izq, Canal 6 de ADC	ADCSRA= 0;	ADCSRA |= (1<<ADPS2)| (1<< ADPS1)|(1<< ADPS0)|(1<< ADIE)| (1<< ADEN);//Prescalers, Interrupciónes habilitadas, ADC Enable.
}