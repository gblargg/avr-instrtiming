#include <avr/sleep.h>
#include <avr/pgmspace.h>
#include <avr/interrupt.h>

#include "uartout.h"

typedef unsigned char byte;

static PROGMEM const char times [] = {
	#include "correct.h"
};

extern void instrs( void );
extern void instrs_end( void );
extern unsigned char test_instr( unsigned, byte flags );

int main( void )
{
	// Route stdout to UART
	stdout = uartout_init();
	
	cli();
	
	printf( "// Starting\n" );
	DDRB = 0;
	
	TCCR1A = 0;
	TCCR1B = 1<<CS10; // clock rate
	TCNT1  = 0;
	OCR1A  = 0;
	OCR1B  = 0;
	TIMSK  = 0;
	
	char failed = 0;
	
	const char* p = times;
	unsigned addr = (unsigned) &instrs;
	byte overhead = test_instr( addr, 0 );
	addr += 2;
	while ( addr < (unsigned) &instrs_end )
	{
		byte phase; // toggles bits so all branches are timed taken and not taken
		for ( phase = 2; phase--; )
		{
			byte cyc = test_instr( addr, (phase ? 0xFF : 0) ) - overhead;
			printf( "%d,", cyc );
		
			byte correct = pgm_read_byte( p++ );
			if ( cyc != correct )
			{
				printf( " // +0x%03x mismatch; table shows %d\n", addr*2, correct );
				failed = 1;
			}
		}
		printf( "\n" );
		
		addr += 2;
		if ( pgm_read_word( addr*2+2 ) == 0 )
			// prev instr was a skip which uses four slots, so skip the last two
			addr += 2;
	}
	
	if ( !failed )
		printf( "// Passed\n" );
	else
		printf( "// Failed\n" );

	return 0;
}
