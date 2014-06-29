/*
     File: NBodyMeters.h
 Abstract: 
 Mediator object for managing multiple hud objects for n-body simulators.
 
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

#ifndef _NBODY_METERS_H_
#define _NBODY_METERS_H_

#import <string>

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

#import "HUDMeterImage.h"
#import "HUDMeterTimer.h"

#ifdef __cplusplus

namespace NBody
{
    enum MeterType
    {
        eNBodyMeterPerf = 0,
        eNBodyMeterUpdates,
        eNBodyMeterFrames,
        eNBodyMeterAll,
        eNBodyMeterMax
    };
    
    typedef enum MeterType MeterType;
    
    typedef HUD::Meter::Timer Timer;
    typedef HUD::Meter::Image Meter;
    
    class Meters
    {
    public:
        Meters(const GLsizei& nLength);
        
        virtual ~Meters();
        
        void update();
        void draw();
        
        bool finalize();
        
        void toggle(const MeterType& nType = eNBodyMeterAll);
        
        void setLabel(const MeterType& nType, const std::string& rLabel);
        void setSize(const MeterType& nType, const size_t& nSize);
        void setValue(const MeterType& nType, const GLfloat& nValue);
        
        void setFrame(const CGSize& rFrame);
        void setPosition(const GLfloat& nPosition);
        void setSpeed(const GLfloat& nSpeed);
        
    private:
        bool          mbStart;
        bool          m_IsVisible[eNBodyMeterMax];
        GLsizei       m_Bound[2];
        CGSize        m_Frame;
        GLfloat       mnPosition;
        GLfloat       mnSpeed;
        Timer        *mpTimer;
        Meter        *mpMeter[eNBodyMeterAll];
        std::string   m_Label[eNBodyMeterAll];
        size_t        m_Size[eNBodyMeterAll];
        GLdouble      m_Value[eNBodyMeterAll];
    }; // Meters
} // NBody

#endif

#endif
