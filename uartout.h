#ifndef UARTOUT_H
#define UARTOUT_H

#include <stdio.h>
#include <avr/io.h>
#include <avr/power.h>

#ifndef UARTOUT_BAUD
	#define UARTOUT_BAUD 57600
#endif

// Allow code to work regardless of what the UART registers are named
#if defined(UCSRA)
	#define UN(name,...) name##__VA_ARGS__
#elif defined(UCSR0A)
	#define UN(name,...) name##0##__VA_ARGS__
#elif defined(UCSR1A)
	#define UN(name,...) name##1##__VA_ARGS__
#endif

// Write character to UART, waiting if it's busy sending one already
static void uartout_write( char c )
{
	loop_until_bit_is_set( UN(UCSR,A), UN(UDRE) );
	UN(UDR) = c;
}

// FILE output device for use with stdio code
static int uartout_putchar( char c, FILE* s )
{
	(void) s;
	uartout_write( c );
	return 0;
}

// Trivial overhead if you aren't using stdio
static FILE uartout = FDEV_SETUP_STREAM( uartout_putchar, NULL, _FDEV_SETUP_WRITE );

#define BAUD UARTOUT_BAUD
#define BAUD_TOL 5
#include <util/setbaud.h>

// Sets baud rate. Returns &uartout for convenient assignment to stdout.
static FILE* uartout_init( void )
{
	#ifdef power_usart_enable
		power_usart_enable();
	#endif
	#ifdef power_usart0_enable
		power_usart0_enable();
	#endif
	#ifdef power_usart1_enable
		power_usart1_enable();
	#endif
	
	#if USE_2X
		UN(UCSR,A) = 1<<UN(U2X);
	#else
		UN(UCSR,A) = 0;
	#endif
	UN(UBRR,H) = UBRRH_VALUE;
	UN(UBRR,L) = UBRRL_VALUE;
	UN(UCSR,B) = 1<<UN(TXEN); // transmit-only
	#ifdef URSEL
		UN(UCSR,C) = 1<<URSEL | 1<<UN(UCSZ,1) | 1<<UN(UCSZ,0);
	#else
		UN(UCSR,C) =            1<<UN(UCSZ,1) | 1<<UN(UCSZ,0);
	#endif
	
	return &uartout;
}
#undef BAUD

#undef UN

#endif
