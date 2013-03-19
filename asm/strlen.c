/*
 * Copyright (C) 2010-2013 David Schor
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, 
 * and/or sell copies of the Software, and to permit persons to whom the 
 * Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
 * IN THE SOFTWARE.
 *
 *
 *
 * Synopsis:
 *              size_t strlen(const char *s);
 *
 * Description:
 *              The strlen function computes the length of the string pointed
 *              to by s.
 *
 * Returns:
 *              The strlen function returns the number of characters that precede
 *              the terminating null character. 
 *
 */
#include <stddef.h>
size_t __fastcall strlen(const char *s)
{
    __asm {
        ; our character pointer goes in edx
            mov edx, s
        
        ; clear xmm0
            pxor xmm0, xmm0
            
        ; start at -16 so we could do the loop more efficiently by
        ; starting at zero.
            mov eax, -16
        ;
        ; Requires SSE4.2. (So anything pre-late-09 is out iirc)
        ;
        ; I am pretty sure (99%) that PcmpIstrI actually runs faster
        ; on all unaligned memory faster than you could do with SSE2
        ; plus the overhead of aligning the initial block. This
        ; presumption might prove to be false when it comes to smaller
        ; string sizes.
        ;
        l:
            ; move to the next 16 bytes
            add eax, 16
            
            ; xmm0 is 16 bytes worth of zeros that we set earlier
            ; 
            ; Imm8 is an encoded bitfield that controls the operation
            ; of the PcmpIstrI. In our case, we just want an unaligned
            ; single byte indevidual comparision.
            ;
            ; The full list of modes and their bits can be found in
            ; section 5.3.1.1, Source Data Format, of the SSE 4 
            ; instruction set reference.
            ;
            ; Imm8[1:0] = 00 = Both 128-bit sources are treated as
            ;                  packed, unsigned bytes.
            ;
            ; Imm8[3:2] = 10 = "Equal each" mode.
            ;
            ; Grab the next octaword from [edx + offset] and compare
            ; against our null vecter.
            ;
            ; ZFlag – Set if any byte/word of xmm2/mem128 is null, reset otherwise
            ;
            PcmpIstrI xmm0, oword ptr[edx + eax], 1000b
            
            ; If we didn't encounter a null byte, just keep going
            jnz l
            
            ; The generated index is held in the counter register so
            ; just add it to eax and we have the total length.
            ; total length = 
            ;                +  counted_blocks (of 16 bytes)
            ;                   index of NULL byte found
            add eax, ecx
    }
}
/* EOF */
