/*
     File: NBodySimulationBase.h
 Abstract: 
 Utility base class defining interface for the derived classes, as well as,
 performing thread and mutex mangement, and managment of meter arrays.
 
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

#ifndef _NBODY_SIMULATION_BASE_H_
#define _NBODY_SIMULATION_BASE_H_

#import <string>

#import <pthread.h>

#import <OpenGL/OpenGL.h>

#import "NBodyConstants.h"

#import "NBodySimulationTypes.h"

#import "HUDMeterTimer.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        class Base
        {
        public:
            Base(const size_t& nbodies,
                 const Params& params);
            
            virtual ~Base();
            
            virtual void initialize(const String& options) = 0;
            
            virtual GLint reset()     = 0;
            virtual void  step()      = 0;
            virtual void  terminate() = 0;
            
            virtual GLint positionInRange(GLfloat *pDst) = 0;
            
            virtual GLint position(GLfloat *pDst) = 0;
            virtual GLint velocity(GLfloat *pDst) = 0;
            
            virtual GLint setPosition(const GLfloat * const pSrc) = 0;
            virtual GLint setVelocity(const GLfloat * const pSrc) = 0;
                        
            void start(const bool& paused=true);
            void stop();
            
            void pause();
            void unpause();
            
            void exit();
            
            const bool isAcquired() const;
            const bool isPaused()   const;
            const bool isStopped()  const;
            
            const GLdouble&  performance() const;
            const GLdouble&  updates()     const;
            const GLdouble&  year()        const;
            const size_t&    size()        const;
            const size_t&    minimum()     const;
            const size_t&    maximum()     const;
            const String&    name()        const;
            const GLuint&    devices()     const;
            
            void resetParams(const Params& params);
            void setParams(const Params& params);
            
            void setRange(const GLint& min,
                          const GLint& max);
                          
            void invalidate(const bool& v = true);
            
            void setData(const GLfloat * const pData);
            
            GLfloat *data();
            
        private:
            
            void run();
            
            friend void *simulate(void *arg);
            
        protected:
            
            bool     mbAcquired;
            bool     mbIsUpdated;
            GLuint   mnDeviceCount;
            GLuint   mnDevices;
            size_t   mnLength;
            size_t   mnSamples;
            size_t   mnSize;
            size_t   mnBodyCount;
            size_t   mnMinIndex;
            size_t	 mnMaxIndex;
            String   m_DeviceName;
            Params   m_ActiveParams;
            
        private:
            
            bool  mbStop;
            bool  mbReload;
            bool  mbPaused;
            bool  mbKeepAlive;
            
            String              m_Options;
            
            void * volatile     mpData;
            
            pthread_t           m_Thread;
            pthread_mutex_t     m_RunLock;
            pthread_mutexattr_t m_RunAttrib;
            pthread_mutex_t     m_ClockLock;
            pthread_mutexattr_t m_ClockAttrib;
            
            HUD::Meter::Timer   m_Pref;
            GLdouble            mnPref;
            
            HUD::Meter::Timer   m_Updates;
            GLdouble            mnUpdates;
            
            GLdouble            mnYear;
            GLdouble            mnFreq;
            GLdouble            mnDelta;
            size_t              mnCardinality;
        }; // Base
    } // Simulation
} // NBody

#endif

#endif
