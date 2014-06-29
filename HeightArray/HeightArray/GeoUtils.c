/*
     File: GeoUtils.c
 Abstract: Utilities for generating height maps.
  Version: 1.3
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#include "GeoUtils.h"

static unsigned int randseed, m_lo, m_hi;
// ---------------------------------------------------------------------
// seed 32 bit RANROT-B PRNG
// ---------------------------------------------------------------------
static inline void rands(int seed){ randseed = m_lo = seed; m_hi = ~seed; }

// ---------------------------------------------------------------------
// get 32 bits of noise
// ---------------------------------------------------------------------
static inline int randi(void) { m_hi = (m_hi<<16) + (m_hi>>16); m_hi += m_lo; m_lo += m_hi; return m_hi; }

// ---------------------------------------------------------------------
// get random float in range [-x..x]
// ---------------------------------------------------------------------
static inline float randf(float x) { return (x * randi() / (float)0x7FFFFFFF); }

float *GenHeightMap(int wide, int deep, int seed)
{
    int i, ni, mi, pmi;
    int j, nj, mj, pmj;
    int w = wide;
    int d = deep;
    float noiseRange = (float)w * 0.5f;
    float r = 0.5;
    float *h = malloc(wide * deep * sizeof(float));
    float *map = calloc(1, wide * deep * sizeof(float) * 6);
    rands(seed);
    h[0] = randf(noiseRange);
    while(w > 0)
    {
    	// diamond midpoint displacement
        for (i = 0; i < wide; i += w)
        {
            for (j = 0; j < deep; j += d)
            {
                ni = (i + w) % wide;
                nj = (j + d) % deep;
                mi = (i + w / 2);
                mj = (j + d / 2);
                h[mi + wide * mj] = 
				(h[i  +  j * wide] + 
				 h[ni +  j * wide] + 
				 h[i  + nj * wide] + 
				 h[ni + nj * wide]) * 0.25f + randf(noiseRange);
            }
        }
        
		// square midpoint displacement
        for (i = 0; i < wide; i += w)
        {
            for (j = 0; j < deep; j += d)
            {
                ni = (i + w) % wide;
                nj = (j + d) % deep;
                mi = (i + w / 2);
                mj = (j + d / 2);
                pmi = (i - w / 2 + wide) % wide;
                pmj = (j - d / 2 + deep) % deep;
                h[mi + j * wide] = 
				(h[i  + j   * wide] + 
				 h[ni + j   * wide] + 
				 h[mi + pmj * wide] + 
				 h[mi + mj  * wide]) * 0.25f + randf(noiseRange);
                h[i + mj * wide] = 
				(h[i   + j  * wide] + 
				 h[i   + nj * wide] + 
				 h[pmi + mj * wide] + 
				 h[mi  + mj * wide]) * 0.25f +  randf(noiseRange);
            }
        }
		
        // fractal recursion
        w >>= 1;
        d >>= 1;
        noiseRange *= r;
    }
    
    // gen positions
    for (j = 0; j < deep; j++)
	{
    	for (i = 0; i < wide; i++)
    	{
    		int i0 = j*wide+i;
    		float h0 = h[i0];
			
    		map[i0*6 + 0] = i*2-wide;
    		map[i0*6 + 1] = j*2-deep;
    		map[i0*6 + 2] = h0;
			
 			// gen normals
 			if (j < deep-1 && i < wide-1)
 			{
 				int ih =  j   *wide+i+1;
 				int iv = (j+1)*wide+i;
 				int id = (j+1)*wide+i+1;
 				float dh, dv;
				
 				// add cross product of first tri
 				dh = h[ih]-h0;
 				dv = h[iv]-h0;
   				map[i0*6 + 3] += dh;
    			map[i0*6 + 4] += dv;
    			map[i0*6 + 5] += 1;
   				map[ih*6 + 3] += dh;
    			map[ih*6 + 4] += dv;
    			map[ih*6 + 5] += 1;
   				map[iv*6 + 3] += dh;
    			map[iv*6 + 4] += dv;
    			map[iv*6 + 5] += 1;
				
 				// add cross product of second tri
 				dh = h[id]-h[iv];
 				dv = h[id]-h[ih];
   				map[id*6 + 3] += dh;
    			map[id*6 + 4] += dv;
    			map[id*6 + 5] += 10;
   				map[ih*6 + 3] += dh;
    			map[ih*6 + 4] += dv;
    			map[ih*6 + 5] += 1;
   				map[iv*6 + 3] += dh;
    			map[iv*6 + 4] += dv;
    			map[iv*6 + 5] += 1;
 			} 
 		}
    }
    free(h);
    return map;
}
