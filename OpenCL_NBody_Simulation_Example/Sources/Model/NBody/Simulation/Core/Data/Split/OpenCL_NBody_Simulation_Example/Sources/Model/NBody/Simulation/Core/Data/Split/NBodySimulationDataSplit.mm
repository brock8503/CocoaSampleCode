/*
     File: NBodySimulationDataSplit.mm
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

#pragma mark -
#pragma mark Private - Headers

#import <iostream>

#import "NBodySimulationDataSplit.h"

#pragma mark -
#pragma mark Private - Namespace

using namespace NBody::Simulation;

#pragma mark -
#pragma mark Private - Constants

static const cl_int kNBodySimDevMemPosErr = -200;
static const cl_int kNBodySimDevMemVelErr = -201;

static const size_t kNBodySimSplitDataMemSize = sizeof(cl_mem);

#pragma mark -
#pragma mark Private - Data Structures

struct NBodySimulationSplitData
{
    GLfloat *mpHost;
    cl_mem   mpDevice;
};

struct Data::Split3D
{
    NBodySimulationSplitData m_Position[3];
    NBodySimulationSplitData m_Velocity[3];
};

#pragma mark -
#pragma mark Private - Utilities - Constructors

Data::Split3DRef Data::Split::create(const size_t& nCount,
                                     const size_t& nSamples)
{
    Data::Split3DRef pSplit = Data::Split3DRef(calloc(1, sizeof(Data::Split3D)));
    
    if(pSplit != NULL)
    {
        pSplit->m_Position[0].mpHost = (GLfloat *)calloc(nCount, nSamples);
        pSplit->m_Position[1].mpHost = (GLfloat *)calloc(nCount, nSamples);
        pSplit->m_Position[2].mpHost = (GLfloat *)calloc(nCount, nSamples);
        
        pSplit->m_Velocity[0].mpHost = (GLfloat *)calloc(nCount, nSamples);
        pSplit->m_Velocity[1].mpHost = (GLfloat *)calloc(nCount, nSamples);
        pSplit->m_Velocity[2].mpHost = (GLfloat *)calloc(nCount, nSamples);
    } // if
    
    return pSplit;
} // create

GLint Data::Split::acquire(const GLuint& nIndex,
                           cl_context pContext)
{
    GLint err = CL_INVALID_CONTEXT;
    
    if(pContext != NULL)
    {
        mpSplit->m_Position[nIndex].mpDevice = clCreateBuffer(pContext,
                                                              mnFlags,
                                                              mnSize,
                                                              mpSplit->m_Position[nIndex].mpHost,
                                                              &err);
        
        if(err != CL_SUCCESS)
        {
            return kNBodySimDevMemPosErr;
        } // if
        
        mpSplit->m_Velocity[nIndex].mpDevice = clCreateBuffer(pContext,
                                                              mnFlags,
                                                              mnSize,
                                                              mpSplit->m_Velocity[nIndex].mpHost,
                                                              &err);
        
        if(err != CL_SUCCESS)
        {
            return kNBodySimDevMemVelErr;
        } // if
    } // if
    
    return err;
} // acquire

#pragma mark -
#pragma mark Public - Constructor

Data::Split::Split(const size_t& nBodies)
{
    mnBodies  = nBodies;
    mnSamples = sizeof(GLfloat);
    mnSize    = mnSamples * mnBodies;
    mnFlags   = cl_mem_flags(CL_MEM_READ_WRITE | CL_MEM_USE_HOST_PTR);
    mpSplit   = create(mnBodies, mnSamples);
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

Data::Split::~Split()
{
    if(mpSplit != NULL)
    {
        GLuint i;
        
        for(i = 0; i < 3; ++i)
        {
            // Host Position
            if(mpSplit->m_Position[i].mpHost != NULL)
            {
                free(mpSplit->m_Position[i].mpHost);
                
                mpSplit->m_Position[i].mpHost = NULL;
            } // if
            
            // Host Velocity
            if(mpSplit->m_Velocity[i].mpHost != NULL)
            {
                free(mpSplit->m_Velocity[i].mpHost);
                
                mpSplit->m_Velocity[i].mpHost = NULL;
            } // if

            // Device Position
            if(mpSplit->m_Position[i].mpDevice != NULL)
            {
                clReleaseMemObject(mpSplit->m_Position[i].mpDevice);
                
                mpSplit->m_Position[i].mpDevice = NULL;
            } // if
            
            // Device Velocity
            if(mpSplit->m_Velocity[i].mpDevice != NULL)
            {
                clReleaseMemObject(mpSplit->m_Velocity[i].mpDevice);
                
                mpSplit->m_Velocity[i].mpDevice = NULL;
            } // if
        } // for
        
        free(mpSplit);
        
        mpSplit = NULL;
    } // if
} // Destructor

#pragma mark -
#pragma mark Public - Accessors

const GLfloat* Data::Split::position(const Coordinates& nCoord) const
{
    return mpSplit->m_Position[nCoord].mpHost;
} // position

const GLfloat* Data::Split::velocity(const Coordinates& nCoord) const
{
    return mpSplit->m_Velocity[nCoord].mpHost;
} // velocity

#pragma mark -
#pragma mark Public - Utilities

GLfloat* Data::Split::position(const Coordinates& nCoord)
{
    return mpSplit->m_Position[nCoord].mpHost;
} // position

GLfloat* Data::Split::velocity(const Coordinates& nCoord)
{
    return mpSplit->m_Velocity[nCoord].mpHost;
} // velocity

GLint Data::Split::acquire(cl_context pContext)
{
    GLint err = CL_INVALID_CONTEXT;
    
    if(pContext != NULL)
    {
        GLuint i;
        
        for(i = 0; i < 3; ++i)
        {
            err = acquire(i, pContext);
            
            if(err != CL_SUCCESS)
            {
                std::cerr
                << ">> ERROR: Failed in acquring device memory at index ["
                << i
                << "]!"
                << std:: endl;
                
                break;
            } // if
        } // for
    } // if
    
    return err;
} // acquire

GLint Data::Split::bind(const cl_uint& nStartIndex,
                        cl_kernel pKernel)
{
    GLint err = CL_INVALID_KERNEL;
    
    if(pKernel != NULL)
    {
        size_t  sizes[6];
        void   *pValues[6];
        
        pValues[0]  = &mpSplit->m_Position[0].mpDevice;
        pValues[1]  = &mpSplit->m_Position[1].mpDevice;
        pValues[2]  = &mpSplit->m_Position[2].mpDevice;
        pValues[3]  = &mpSplit->m_Velocity[0].mpDevice;
        pValues[4]  = &mpSplit->m_Velocity[1].mpDevice;
        pValues[5]  = &mpSplit->m_Velocity[2].mpDevice;
        
        sizes[0]  = kNBodySimSplitDataMemSize;
        sizes[1]  = kNBodySimSplitDataMemSize;
        sizes[2]  = kNBodySimSplitDataMemSize;
        sizes[3]  = kNBodySimSplitDataMemSize;
        sizes[4]  = kNBodySimSplitDataMemSize;
        sizes[5]  = kNBodySimSplitDataMemSize;
        
        cl_uint i;
        
        for(i = 0; i < 6; ++i)
        {
            err = clSetKernelArg(pKernel,
                                 nStartIndex + i,
                                 sizes[i],
                                 pValues[i]);
            
            if(err != CL_SUCCESS)
            {
                return err;
            } // if
        } // for
    } // if
    
    return err;
} // bind
