/*
     File: NBodySimulationDataPacked.mm
 Abstract: 
 Utility class for managing cpu bound device and host packed mass and position data.
 
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

#import "NBodySimulationDataPacked.h"

#pragma mark -
#pragma mark Private - Namespace

using namespace NBody::Simulation;

#pragma mark -
#pragma mark Private - Constants

static const size_t kNBodySimPackedDataMemSize = sizeof(cl_mem);

#pragma mark -
#pragma mark Private - Data Structures

struct NBodySimulationPackedData
{
    GLfloat *mpHost;
    cl_mem   mpDevice;
};

struct Data::Packed3D
{
    NBodySimulationPackedData m_Position;
    NBodySimulationPackedData m_Mass;
};

#pragma mark -
#pragma mark Public - Constructor

Data::Packed::Packed(const size_t& nbodies)
{
    mnBodies  = nbodies;
    mnLength  = 4 * mnBodies;
    mnSamples = sizeof(GLfloat);
    mnSize    = mnLength * mnSamples;
    mnFlags   = cl_mem_flags(CL_MEM_READ_WRITE | CL_MEM_USE_HOST_PTR);
    mpPacked  = Data::Packed3DRef(calloc(1, sizeof(Data::Packed3D)));
    
    if(mpPacked != NULL)
    {
        mpPacked->m_Position.mpHost = (GLfloat *)calloc(mnLength, mnSamples);
        mpPacked->m_Mass.mpHost     = (GLfloat *)calloc(mnBodies, mnSamples);
    } // if
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

Data::Packed::~Packed()
{
    if(mpPacked != NULL)
    {
        if(mpPacked->m_Mass.mpHost != NULL)
        {
            free(mpPacked->m_Mass.mpHost);
            
            mpPacked->m_Mass.mpHost = NULL;
        } // if
        
        if(mpPacked->m_Position.mpHost != NULL)
        {
            free(mpPacked->m_Position.mpHost);
            
            mpPacked->m_Position.mpHost = NULL;
        } // if
        
        if(mpPacked->m_Mass.mpDevice != NULL)
        {
            clReleaseMemObject(mpPacked->m_Mass.mpDevice);
            
            mpPacked->m_Mass.mpDevice = NULL;
        } // if
        
        if(mpPacked->m_Position.mpDevice != NULL)
        {
            clReleaseMemObject(mpPacked->m_Position.mpDevice);
            
            mpPacked->m_Position.mpDevice = NULL;
        } // if
        
        free(mpPacked);
        
        mpPacked = NULL;
    } // if
} // Destructor

#pragma mark -
#pragma mark Public - Accessors

const GLfloat* Data::Packed::getMass() const
{
    return mpPacked->m_Mass.mpHost;
} // getMass

const GLfloat* Data::Packed::position() const
{
    return mpPacked->m_Position.mpHost;
} // position

#pragma mark -
#pragma mark Public - Utilities

GLfloat* Data::Packed::mass()
{
    return mpPacked->m_Mass.mpHost;
} // mass

GLfloat* Data::Packed::position()
{
    return mpPacked->m_Position.mpHost;
} // position

GLint Data::Packed::acquire(cl_context pContext)
{
    GLint err = CL_INVALID_CONTEXT;
    
    if(pContext != NULL)
    {
        mpPacked->m_Mass.mpDevice = clCreateBuffer(pContext,
                                                   mnFlags,
                                                   mnSize,
                                                   mpPacked->m_Mass.mpHost,
                                                   &err);
        
        if(err != CL_SUCCESS)
        {
            return -300;
        } // if
        
        mpPacked->m_Position.mpDevice = clCreateBuffer(pContext,
                                                       mnFlags,
                                                       mnSize,
                                                       mpPacked->m_Position.mpHost,
                                                       &err);
        
        if(err != CL_SUCCESS)
        {
            return -301;
        } // if
    } // if
    
    return err;
} // setup

GLint Data::Packed::bind(const cl_uint& nStartIndex,
                         cl_kernel pKernel)
{
    GLint err = CL_INVALID_KERNEL;
    
    if(pKernel != NULL)
    {
        size_t  sizes[2];
        void   *pValues[2];
        
        pValues[0] = &mpPacked->m_Position.mpDevice;
        pValues[1] = &mpPacked->m_Mass.mpDevice;
        
        sizes[0] = kNBodySimPackedDataMemSize;
        sizes[1] = kNBodySimPackedDataMemSize;
        
        GLint i;
        
        for(i = 0; i < 2; ++i)
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

GLint Data::Packed::update(const cl_uint& nIndex,
                           cl_kernel pKernel)
{
    GLint err = CL_INVALID_KERNEL;
    
    if(pKernel != NULL)
    {
        size_t  nSize  = kNBodySimPackedDataMemSize;
        void   *pValue = &mpPacked->m_Position.mpDevice;
        
        err = clSetKernelArg(pKernel, nIndex, nSize, pValue);
        
        if(err != CL_SUCCESS)
        {
            return err;
        } // if
    } // if
    
    return err;
} // bind
