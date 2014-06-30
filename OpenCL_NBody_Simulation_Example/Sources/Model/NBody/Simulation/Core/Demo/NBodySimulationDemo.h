/*
     File: NBodySimulationDemo.h
 Abstract: 
 Baseline NBody demo simulation parameters.
 
  Version: 3.1
 
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

#ifndef _NBODY_DEMO_PARAMETERS_H_
#define _NBODY_DEMO_PARAMETERS_H_

#import <OpenGL/OpenGL.h>

#import "NBodySimulationTypes.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        namespace Demo
        {
            static const Params kParams[] =
            {
                // time step, cluster scale, velocity Scale, softening, damping
                // point size scale, x-rotation, y-rotation , view distance, configuration
                
                { Scale::kTime * 0.25f,    1.0f,     1.0f,     0.025f,   1.0f,
                    0.7f, 66.0f, 137.0f,    30.0f,  eConfigMWM31 },
                
                { Scale::kTime * 0.016f,   1.54f,    8.0f,     Scale::kSoftening * 0.1f,     1.0f,
                    1.0f,   0.0f,    0.0f,  30.0f,  eConfigShell },
                
                { Scale::kTime * 0.0019f,  0.32f,    276.0f,   Scale::kSoftening * 1.0f,     1.0f,
                    0.18f,  90.0f,   0.0f,  9.0f,   eConfigShell },
                
                { Scale::kTime * 0.016f,   0.68f,    20.0f,    Scale::kSoftening * 0.1f,     1.0f,
                    1.2f,   39.0f,   2.0f, 50.0f,  eConfigShell },
                
                { Scale::kTime * 0.0006f,  0.16f,    1000.0f,  Scale::kSoftening * 1.0f,     1.0f,
                    0.15f,  -83.0f,  10.0f, 5.0f,   eConfigShell },
                
                { Scale::kTime * 0.0016f,  0.32f,    272.0f,   Scale::kSoftening * 0.145f,   1.0f,
                    0.1f,   0.0f,    0.0f,  4.15f,  eConfigShell },
                
                { Scale::kTime * 0.016f, 6.04f, 0.0f, Scale::kSoftening * 1.0f, 1.0f,
                    1.0f,   0.0f,    0.0f,  50.0f,  eConfigShell },
            };
            
            static const GLint kParamsCount = sizeof(kParams) / sizeof(Params);
        } // Demo
    } // Simulation
} // NBody

#endif

#endif
