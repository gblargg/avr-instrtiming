Atmega AVR Instruction Timing Tester
====================================
Verifies how many clock cycles instructions take. Tests a good portion of the instruction set. Tested on a few atmega8 chips.

Prints out table of times measured and comments on ones that mismatch table. When run on hardware this can be saved to correct.h to calibrate program. Mismatch shows address to look up in main.lss, to find which instruction failed.

Note that some chips have different timings, so you may need to calibrate it before testing your simulator or whatever.


Limitations
-----------
* Included timings in correct.h are for atmega8 and other mid-range chips. Smaller/larger chips differ on some instructions; to calibrate run it on one of them and save output to correct.h.
* Doesn't test instructions not on atmega8
* Doesn't test all instructions


Design
------
* Uses TCNT1L with no prescaling to time instructions.

* Runs branch instructions taken and not taken, and checks both timings.


Instructions tested
-------------------
lpm
lpm     r,Z
lpm     r,Z+

lds     r,k
ld      r,X
ld      r,X+
ld      r,-X
ld      r,Y
ld      r,Y+
ld      r,-Y
ldd     r,Y+q
ld      r,Z
ld      r,Z+
ld      r,-Z
ldd     r,Z+q

sts     k,r
st      X,r
st      X+,r
st      -X,r
st      Y,r
st      Y+,r
st      -Y,r
std     Y+q,r
st      Z,r
st      Z+,r
st      -Z,r
std     Z+q,r

push    r
pop     r

nop
swap    r
neg     r
dec     r
inc     r
com     r
asr     r
lsr     r
ror     r

mov     r,r
movw    r,r
cp      r,r
cpc     r,r
add     r,r
adc     r,r
sub     r,r
sbc     r,r
and     r,r
or      r,r
eor     r,r

ldi     r,K
cpi     r,K
subi    r,K
sbci    r,K
andi    r,K
ori     r,K
adiw    r,K
sbiw    r,K

mul     r,r
muls    r,r
mulsu   r,r
fmul    r,r
fmuls   r,r
fmulsu  r,r

bclr    b
bset    b
bld     r,b
bst     r,b
cbi     p,b
sbi     p,b
in      r,A
out     A,r

sbic    A,b
sbis    A,b
sbrc    r,b
sbrs    r,b
cpse    r,r
brbc    b,k
brbs    b,k

rjmp    k
rcall   k
ijmp
icall
ret
reti

-- 
Shay Green <gblargg@gmail.com>
