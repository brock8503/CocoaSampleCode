/*
     File: NBodySimulationFacade.h
 Abstract: 
 A facade for managing cpu or gpu bound simulators, along with their labeled-button.
 
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

#ifndef _NBODY_SIMULATION_FACADE_H_
#define _NBODY_SIMULATION_FACADE_H_

#import "NBodySimulationBase.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        class Facade
        {
        public:
            Facade(const Types& nType,
                   const size_t& nCount,
                   const Params& rParams);
            
            virtual ~Facade();
            
            void start(const bool& paused=true);
            void stop();
            
            void pause();
            void unpause();
                        
            GLfloat* data();
            
            Base* simulator();

            void resetParams(const Params& params);
            
            void invalidate(const bool& doInvalidate = true);
            
            void button(const bool& selected,
                        const CGPoint& position,
                        const CGRect& bounds);

            const bool isCPUSingleCore() const;
            const bool isCPUMultiCore()  const;
            const bool isGPUPrimary()    const;
            const bool isGPUSecondary()  const;
            
            const bool isActive()   const;
            const bool isAcquired() const;
            const bool isPaused()   const;
            const bool isStopped()  const;
            
            const GLdouble  performance() const;
            const GLdouble  updates()     const;
            const GLdouble  year()        const;
            const size_t    size()        const;
            const String&   label()       const;
            
            void positionInRange(GLfloat *pDst);
            
            void position(GLfloat *pDst);
            void velocity(GLfloat *pDst);
            
            void setRange(const GLint& min,
                          const GLint& max);
            
            void setParams(const Params& params);
            
            void setData(const GLfloat * const pData);
            
            void setPosition(const GLfloat * const pSrc);
            void setVelocity(const GLfloat * const pSrc);
            
        private:
            // Acquire a label for the gpu bound simulator
            void setLabel(const GLint& nDevIndex,
                          const GLuint& nDevices,
                          const String& rDevice);

            // GPU bound compute
            Base* create(const GLint& nDevIndex,
                         const size_t& nCount,
                         const Params& rParams);
            
            // CPU bound compute
            Base* create(const bool& bIsThreaded,
                         const size_t& nCount,
                         const String& rLabel,
                         const Params& rParams);
            
        private:
            bool     mbIsGPU;
            String   m_Label;
            Base    *mpSimulator;
            Button  *mpButton;
            Types    mnType;
        }; // Facade
    } // Simulation
} // NBody

#endif

#endif
