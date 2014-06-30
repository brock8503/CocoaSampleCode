/*
     File: NBodySimulationMediator.h
 Abstract: 
 A mediator object for managing cpu and gpu bound simulators, along with their labeled-buttons.
 
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

#ifndef _OpenCL_NBody_Simulation_Mediator_H_
#define _OpenCL_NBody_Simulation_Mediator_H_

#import "GLMVector3.h"

#import "NBodySimulationFacade.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        class Mediator
        {
        public:
            // Construct a mediator object for GPUs, or CPU and CPUs
            Mediator(const Params& rParams,
                     const bool& bGPUOnly = true,
                     const GLuint& nCount = Bodies::kCount);
            
            // Delete alll simulators
            virtual ~Mediator();
        
            // Select the current simulator to use
            void select(const GLuint& index);

            // Select the current simulator to use
            void select(const Types& type);
                        
            // Get the current simulator
            Facade* simulator();
            
            // Reset all the gpu bound simulators
            void reset();
            
            // void update position data
            void update();

            // Pause the current active simulator
            void pause();
            
            // unpause the current active simulator
            void unpause();
            
            // Set the button for the current simulator object
            void button(const bool& selected,
                        const CGPoint& position,
                        const CGRect& bounds);
            
            // Accessor Methods for the active simulator
            const GLdouble  performance() const;
            const GLdouble  updates()     const;
            
            // Get the total number of simulators
            const GLuint getCount() const;
            
            // Get position data
            const GLfloat* position() const;
            
            // Active simulator query
            const bool isCPUSingleCore() const;
            const bool isCPUMultiCore()  const;
            const bool isGPUPrimary()    const;
            const bool isGPUSecondary()  const;
            
            // Check to see if position was acquired
            const bool hasPosition() const;
                       
        private:
             // Acquire all simulators
            void acquire(const Params& rParams);
            
            // Initialize all instance variables to their default values
            void setDefaults(const size_t& nBodies);
            
            // Set the defaults for simulator compute
            void setCompute(const bool& bGPUOnly);

            // Set the current active n-body parameters
            void setParams(const Params& rParams);
            
        private:
            bool     mbCPUs;
            size_t   mnBodies;
            size_t   mnSize;
            GLuint   mnCount;
            GLuint   mnGPUs;
            GLfloat *mpPosition;
            Types    mnActive;
            Params   m_Params;
            Facade  *mpSimulators[eComputeMax];
            Facade  *mpActive;
        }; // Mediator
    } // Simulation
} // NBody

#endif

#endif
