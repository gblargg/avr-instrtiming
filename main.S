#define __SFR_OFFSET 0
#include <avr/io.h>

; Something that acts like read-write RAM in the 0x20-0x3F range
TESTPORT = PORTB

	.section .bss

	; Scratch area for ST X+ etc. instructions to write to
	.skip 16
xyz_temp:
	.skip 16
	
	.section .text

	.global test_instr
	; r1:r0 clobbered by mul instructions
	; r18 register instrs use
	; r19 0 (for cpse)
	; r21:r20 SP
	; r22 phase
	; r23 unused
	; r24 duration return value
	; r25 start time
	; X/Y/Z = xyz_temp for store instrs, taken for branch instrs
test_instr:
	; Save registers
	push r28
	push r29
	in	r20,SPL
	in	r21,SPH
	
	; Put return address for when timing RET
	ldi	r30,lo8(pm(instr_done))
	ldi r31,hi8(pm(instr_done))
	push r30
	push r31
	
	; Instr address
	push r24
	push r25
	
	; X, Y, Z set for ld/st instructions
	ldi	r26,lo8(xyz_temp)
	ldi r27,hi8(xyz_temp)
	movw r28,r26
	movw r30,r26
	
	; For branches set up Z for ijmp etc.
	subi r24,lo8(pm(branches))
	sbci r25,hi8(pm(branches))
	brlo 1f
	ldi	r30,lo8(pm(taken))
	ldi r31,hi8(pm(taken))	
1:
	; Registers examined by instructions
	ldi r19,0
	mov r18,r22
	out	TESTPORT,r18
	out	SREG,r22
	
	; Run instruction once, timed with timer
	in	r25,TCNT1
	ret
instr_done:
	in	r24,TCNT1
	sub r24,r25
	
	; Restore registers
	out	SPL,r20
	out	SPH,r21
	pop r29
	pop r28
	clr r1	; clobbered by mul
	
	ret
	
	.global instrs
instrs:
	; Testing program gives 4 bytes for each instruction: 2 for instruction, 2 for rjmp instr_done.
	; It also allows a 4-byte instruction: 4 for instruction, 2 for rjmp instr_done, 2 for nop at end

#define op(...) \
	__VA_ARGS__ $\
	rjmp instr_done
	
#define op32(...) \
	__VA_ARGS__ $\
	rjmp instr_done $\
	nop
	
	op(rjmp instr_done) ; 0-cycle instr for calibration
	
	op(lpm)
	op(lpm r18,Z)
	op(lpm r18,Z+)
	
	op32(lds r18,1)
	op(ld r18,X)
	op(ld r18,X+)
	op(ld r18,-X)
	op(ld r18,Y)
	op(ld r18,Y+)
	op(ld r18,-Y)
	op(ldd r18,Y+1)
	op(ld r18,Z)
	op(ld r18,Z+)
	op(ld r18,-Z)
	op(ldd r18,Z+1)
	
	op32(sts 1,r18)
	op(st X,r18)
	op(st X+,r18)
	op(st -X,r18)
	op(st Y,r18)
	op(st Y+,r18)
	op(st -Y,r18)
	op(std Y+1,r18)
	op(st Z,r18)
	op(st Z+,r18)
	op(st -Z,r18)
	op(std Z+1,r18)
	
	op(push r18)
	op(pop r18)
	
	op(nop)
	op(swap r18)
	op(neg r18)
	op(dec r18)
	op(inc r18)
	op(com r18)
	op(asr r18)
	op(ror r18)

	op(mov r24,r24)
	op(movw r24,r24)
	op(cp r18,r18)
	op(cpc r18,r18)
	op(add r18,r18)
	op(adc r18,r18)
	op(sub r18,r18)
	op(sbc r18,r18)
	op(and r18,r18)
	op(or r18,r18)
	op(eor r18,r18)
	
	op(ldi r18,0)
	op(cpi r18,0)
	op(subi r18,0)
	op(sbci r18,0)
	op(andi r18,0)
	op(ori r18,0)
	op(adiw r30,0)
	op(sbiw r30,0)
	
	op(mul r18,r18)
	op(muls r18,r18)
	op(mulsu r18,r18)
	op(fmul r18,r18)
	op(fmuls r18,r18)
	op(fmulsu r18,r18)
	
	op(bclr 0)
	op(bset 0)
	op(bld r18,0)
	op(bst r18,0)
	op(cbi TESTPORT,0)
	op(sbi TESTPORT,0)
	op(in r18,TESTPORT)
	op(out TESTPORT,r18)

branches:

#define op_skip(...) \
	__VA_ARGS__ $\
	rjmp instr_done $\
	rjmp instr_done $\
	nop

	op_skip(sbic TESTPORT,0)
	op_skip(sbis TESTPORT,0)
	op_skip(sbrc r18,0)
	op_skip(sbrs r18,0)
	op_skip(cpse r18,r19)

#define op_br(o) \
	op(o 0,taken) $\
	op(o 1,taken) $\
	op(o 2,taken) $\
	op(o 3,taken) $\
	op(o 4,taken) $\
	op(o 5,taken) $\
	op(o 6,taken) $\
	op(o 7,taken)
	
	op_br(brbc)
	op_br(brbs)
	
	op(rjmp taken)
	op(rcall taken)
	op(ijmp)
	op(icall)
	
	rjmp .
	ret
	
	rjmp .
	reti
	
	cpse r18,r19
	lds r18,0	; 32-bit instruction (second word is a nop, so tester treats it like another instruction)
	rjmp instr_done
	
	.global instrs_end
instrs_end:
	
taken:
	; We DO NOT want to jump directly to instr_done from branches
	; because that would change timing. This way, taken or not, there's
	; always an rjmp after the branch.
	rjmp instr_done
