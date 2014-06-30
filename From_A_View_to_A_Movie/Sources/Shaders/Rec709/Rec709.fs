/*
     File: Rec709.fs
 Abstract: 
 Rec 709 color correction fragment shader.
 
  Version: 1.2
 
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
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

uniform sampler2DRect tex;

uniform float  gamma;
uniform mat3   displayMat;
uniform mat3   rec709MatInv;
uniform mat3   d65CAMat;

float Rec709TransferFunc(const float lRec709)
{
	float nlRec709 = 0.0;
	
	if( lRec709 <= 0.018 )
	{
		nlRec709 = 4.5 * lRec709;
	} // if
	else if( lRec709 > 0.018 )
	{
		nlRec709 = 1.099 * pow(lRec709,0.45) - 0.099;
	} // else if
	
	return( nlRec709 );
} // Rec709TransferFunc

void main( void )
{
	vec4 sample = texture2DRect(tex, gl_TexCoord[0].st);

	vec3 color;
	
	color.r = pow( sample.r, gamma );
	color.g = pow( sample.g, gamma );
	color.b = pow( sample.b, gamma );
			
	vec3 srcCIE;
	
	srcCIE.x = displayMat[0][0] * color.r + displayMat[1][0] * color.g + displayMat[2][0] * color.b;
	srcCIE.y = displayMat[0][1] * color.r + displayMat[1][1] * color.g + displayMat[2][1] * color.b;
	srcCIE.z = displayMat[0][2] * color.r + displayMat[1][2] * color.g + displayMat[2][2] * color.b;
	
	vec3 dstCIE;

	dstCIE.x = d65CAMat[0][0] * srcCIE.x + d65CAMat[0][1] * srcCIE.y + d65CAMat[0][2] * srcCIE.z;
	dstCIE.y = d65CAMat[1][0] * srcCIE.x + d65CAMat[1][1] * srcCIE.y + d65CAMat[1][2] * srcCIE.z;
	dstCIE.z = d65CAMat[2][0] * srcCIE.x + d65CAMat[2][1] * srcCIE.y + d65CAMat[2][2] * srcCIE.z;

	vec3 lRec709;
	
	lRec709.r = rec709MatInv[0][0] * dstCIE.x + rec709MatInv[1][0] * dstCIE.y + rec709MatInv[2][0] * dstCIE.z;
	lRec709.g = rec709MatInv[0][1] * dstCIE.x + rec709MatInv[1][1] * dstCIE.y + rec709MatInv[2][1] * dstCIE.z;
	lRec709.b = rec709MatInv[0][2] * dstCIE.x + rec709MatInv[1][2] * dstCIE.y + rec709MatInv[2][2] * dstCIE.z;

	vec3 nlRec709;
	
	nlRec709.r = Rec709TransferFunc(lRec709.r);
	nlRec709.g = Rec709TransferFunc(lRec709.g);
	nlRec709.b = Rec709TransferFunc(lRec709.b);

	gl_FragColor = vec4( nlRec709, 1.0 );
} // main
