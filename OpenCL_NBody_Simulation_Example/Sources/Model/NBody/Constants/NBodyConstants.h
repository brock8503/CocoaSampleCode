/*
     File: NBodyConstants.h
 Abstract: 
 Common constant for NBody simulation.
 
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

#ifndef _NBODY_CONSTANTS_H_
#define _NBODY_CONSTANTS_H_

#import <OpenGL/OpenGL.h>

#ifdef __cplusplus

namespace NBody
{
    namespace Mouse
    {
        namespace Button
        {
            const GLuint kLeft = 0;
            const GLuint kDown = 1;
            const GLuint kUp   = 0;
        }; // Button
        
        namespace Wheel
        {
            const GLuint kDown = -1;
            const GLuint kUp   =  1;
        }; // Whell
    }; // Mouse

    namespace Button
    {
        const GLfloat kWidth   = 1000.0f;
        const GLfloat kHeight  = 48.0f;
        const GLfloat kSpacing = 32.0f;
    }; // Button
    
    namespace Scale
    {
        const GLfloat kTime      = 0.4f;
        const GLfloat kSoftening = 1.0f;
    }; // Scale
    
    namespace Window
    {
        const GLfloat kWidth  = 800.0f;
        const GLfloat kHeight = 500.0f;
    }; // Defaults

    namespace Bodies
    {
        const GLuint  kCountMax = 32768;
        const GLuint  kCountMin = kCountMax / 4;
        const GLuint  kCount    = kCountMax;
    }; // Defaults

    namespace Star
    {
        const GLfloat kSize  = 4.0f;
        const GLfloat kScale = 1.0f;
    }; // Defaults

    namespace Defaults
    {
        const GLfloat kSpeed           = 0.06f;
        const GLfloat kRotationDelta   = 0.06f;
        const GLfloat kScrollZoomSpeed = 0.5f;
        const GLfloat kViewDistance    = 30.0f;
        const GLuint  kMeterSize       = 300;
    }; // Defaults
    
    enum Config
    {
        eConfigRandom = 0,
        eConfigShell,
        eConfigExpand,
        eConfigMWM31,
        eConfigCount
    }; // Config
}; // NBody

#endif

#endif
