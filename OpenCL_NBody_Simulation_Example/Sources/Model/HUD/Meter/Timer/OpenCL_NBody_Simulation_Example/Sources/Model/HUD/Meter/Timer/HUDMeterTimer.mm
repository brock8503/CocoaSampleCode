/*
     File: HUDMeterTimer.mm
 Abstract: 
 Utility class for manging a high-resolution timer for a hud meter.
 
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

#pragma mark -
#pragma mark Private - Headers

#import <mach/mach_time.h>
#import <unistd.h>

#import "HUDMeterTimer.h"

#pragma mark -
#pragma mark Private - Constants

double_t HUD::Meter::TimeScale::kSeconds      = 1.0e-9;
double_t HUD::Meter::TimeScale::kMilliSeconds = 1.0e-6;
double_t HUD::Meter::TimeScale::kMicroSeconds = 1.0e-3;
double_t HUD::Meter::TimeScale::kNanoSeconds  = 1.0f;

#pragma mark -
#pragma mark Public - Meter - Timer

HUD::Meter::Timer::Timer(const size_t& size,
                         const bool& doAscend,
                         const GLdouble& scale)
{
    mach_timebase_info_data_t timebase;
    
    kern_return_t result = mach_timebase_info(&timebase);
    
    if(result == KERN_SUCCESS)
    {
        mnAspect = double_t(timebase.numer) / double_t(timebase.denom);
        mnScale  = scale;
        mnRes    = mnAspect * mnScale;
    } // if

    mnSize     = (size > 20) ? size : 20;
    mbAscend   = doAscend;
    mnIndex    = 0;
    mnCount    = 0;
    mnStart    = 0;
    mnStop     = 0;
    mnDuration = 0.0f;
    
    m_Vector.resize(mnSize);
    
    m_Vector = 0.0f;
} // Constructor

HUD::Meter::Timer::Timer(const HUD::Meter::Timer::Timer& timer)
{
    mnAspect   = timer.mnAspect;
    mnScale    = timer.mnScale;
    mnRes      = timer.mnRes;
    mnDuration = timer.mnDuration;
    m_Vector   = timer.m_Vector;
    mnSize     = timer.mnSize;
    mnStart    = timer.mnStart;
    mnStop     = timer.mnStop;
    mnCount    = timer.mnCount;
    mnIndex    = timer.mnIndex;
    mbAscend   = timer.mbAscend;
} // Copy Constructor

HUD::Meter::Timer::~Timer()
{
    mnAspect   = 0.0f;
    mnScale    = 0.0f;
    mnRes      = 0.0f;
    mnDuration = 0.0f;
    m_Vector   = 0.0f;
    mnSize     = 0;
    mnStart    = 0;
    mnStop     = 0;
    mnCount    = 0;
    mnIndex    = 0;
    mbAscend   = 0;
} // Destructor

HUD::Meter::Timer& HUD::Meter::Timer::operator=(const HUD::Meter::Timer& timer)
{
 	if(this != &timer)
    {
        mnAspect   = timer.mnAspect;
        mnScale    = timer.mnScale;
        mnRes      = timer.mnRes;
        mnDuration = timer.mnDuration;
        m_Vector   = timer.m_Vector;
        mnSize     = timer.mnSize;
        mnStart    = timer.mnStart;
        mnStop     = timer.mnStop;
        mnCount    = timer.mnCount;
        mnIndex    = timer.mnIndex;
        mbAscend   = timer.mbAscend;
    } // if
    
    return *this;
} // Assignment Operator

bool HUD::Meter::Timer::resize(const size_t& size)
{
    bool bSuccess = (size != mnSize) && (size > 20);
    
    if(bSuccess)
    {
        mnSize = size;
        
        m_Vector.resize(mnSize);
    } // if
    
    return bSuccess;
} // resize

void HUD::Meter::Timer::setScale(const GLdouble& scale)
{
    if(scale > GLdouble(0))
    {
        mnScale = scale;
        mnRes   = mnAspect * mnScale;
    } // if
} // setScale

void HUD::Meter::Timer::setStart(const HUD::Meter::Time& time)
{
    mnStart = time;
} // setStart

void HUD::Meter::Timer::setStop(const HUD::Meter::Time& time)
{
    mnStop = time;
} // setStop

const HUD::Meter::Time& HUD::Meter::Timer::getStart() const
{
    return mnStart;
} // getStart

const HUD::Meter::Time& HUD::Meter::Timer::getStop()  const
{
    return mnStop;
} // getStop

const HUD::Meter::Duration& HUD::Meter::Timer::getDuration() const
{
    return mnDuration;
} // getDuration

void HUD::Meter::Timer::erase()
{
    m_Vector = 0.0f;
    mnCount  = 0;
} // erase

void HUD::Meter::Timer::update(const GLdouble& dx)
{
    GLdouble dt = mnRes * GLdouble(mnStop - mnStart);
    
    ++mnCount;
    
    m_Vector[mnIndex] = dx / dt;
    
    mnIndex = (mnIndex + 1) % mnSize;
} // update

const GLdouble HUD::Meter::Timer::persecond() const
{
    GLdouble nSize   = GLdouble(mnSize);
    GLdouble nMin    = GLdouble(std::min(mnCount, mnSize));
    GLdouble nMetric = mbAscend ? nSize : nMin;
    GLdouble nSum    = m_Vector.sum();
    
    return nSum / nMetric;
} // persecond

void HUD::Meter::Timer::start()
{
    mnStart = mach_absolute_time();
} // start

void HUD::Meter::Timer::stop()
{
    mnStop = mach_absolute_time();
} // stop

void HUD::Meter::Timer::reset()
{
    mnStart = mnStop;
} // reset

