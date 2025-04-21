/*
 * manual.c
 *
 * Created: 20/04/2025 17:10:33
 *  Author: Barbaritos
 */ 
#include "manual.h"
void initTMR()
{
	TCCR0A=0;//modo normal
	TCCR0B=0;
	TCCR0B |= (1<<CS00); //| (1<<CS00);//Prescaler de 64
	TIMSK0 |= (1<<TOIE0); //Interrupciones de overflow timer0	
}