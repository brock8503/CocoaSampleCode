/*
     File: NBodySimulationDataSplit.h
 Abstract: 
 Utility class for managing cpu bound device and host split position and velocity data.
 
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

#ifndef _NBODY_SIMULATION_SPLIT_DATA_H_
#define _NBODY_SIMULATION_SPLIT_DATA_H_

#import <vector>

#import <OpenCL/OpenCL.h>

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        namespace Data
        {
            enum Coordinates
            {
                eCoordinateX = 0,
                eCoordinateY,
                eCoordinateZ
            };
            
            typedef struct Split3D  *Split3DRef;
            
            class Split
            {
            public:
                Split(const size_t& nBodies);
                
                virtual ~Split();
                
                GLint acquire(cl_context pContext);
                
                GLint bind(const cl_uint& nStartIndex,
                           cl_kernel pKernel);
                
                GLfloat* position(const Coordinates& nCoord);
                GLfloat* velocity(const Coordinates& nCoord);
                
                const GLfloat* position(const Coordinates& nCoord) const;
                const GLfloat* velocity(const Coordinates& nCoord) const;
                
            private:
                GLint acquire(const GLuint& nIndex,
                              cl_context pContext);

                Split3DRef  create(const size_t& nCount,
                                   const size_t& nSamples);
                
            private:
                size_t        mnBodies;
                size_t        mnSamples;
                size_t        mnSize;
                cl_mem_flags  mnFlags;
                Split3DRef    mpSplit;
            }; // Split
        } // Data
    } // Simulation
} // NBody

#endif

#endif
