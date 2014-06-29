/*
     File: NBodySimulationGPU.mm
 Abstract: 
 Utility class for managing gpu bound computes for n-body simulation.
 
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

#import <cmath>
#import <iostream>

#import "GLMSizes.h"

#import "CFIFStream.h"

#import "NBodySimulationRandom.h"
#import "NBodySimulationGPU.h"

#pragma mark -
#pragma mark Private - Constants

static GLuint kWorkItemsX = 256;
static GLuint kWorkItemsY = 1;

static const size_t kKernelParams = 11;
static const size_t kSizeCLMem    = sizeof(cl_mem);

static const char *kIntegrateSystem = "IntegrateSystem";

#pragma mark -
#pragma mark Private - Utilities

static GLint NBodySimulationGPUReadBuffer(cl_command_queue compute_commands,
                                          GLfloat *host_data,
                                          cl_mem device_data,
                                          size_t size,
                                          size_t offset)
{
    return clEnqueueReadBuffer(compute_commands,
                               device_data,
                               CL_TRUE,
                               offset,
                               size,
                               host_data,
                               0,
                               NULL,
                               NULL);
} // NBodySimulationGPUReadBuffer

static GLint NBodySimulationGPUWriteBuffer(cl_command_queue compute_commands,
                                           const GLfloat * const host_data,
                                           cl_mem device_data,
                                           size_t size)
{
    return clEnqueueWriteBuffer(compute_commands,
                                device_data,
                                CL_TRUE,
                                0,
                                size,
                                host_data,
                                0,
                                NULL,
                                NULL);
} // NBodySimulationGPUWriteBuffer

GLint NBody::Simulation::GPU::bind()
{
    GLint err = CL_INVALID_KERNEL;
    
    if(mpKernel != NULL)
    {
        GLuint i = 0;
        
        size_t  sizes[kKernelParams];
        void   *pValues[kKernelParams];
        
        pValues[0]  = &mpDevicePosition[mnWriteIndex];
        pValues[1]  = &mpDeviceVelocity[mnWriteIndex];
        pValues[2]  = &mpDevicePosition[mnReadIndex];
        pValues[3]  = &mpDeviceVelocity[mnReadIndex];
        pValues[4]  = (void *) &m_ActiveParams.mnTimeStamp;
        pValues[5]  = (void *) &m_ActiveParams.mnDamping;
        pValues[6]  = (void *) &m_ActiveParams.mnSoftening;
        pValues[7]  = (void *) &mnBodyCount;
        pValues[8]  = &mnMinIndex;
        pValues[9]  = &mnMaxIndex;
        pValues[10] = NULL;
        
        sizes[0]  = kSizeCLMem;
        sizes[1]  = kSizeCLMem;
        sizes[2]  = kSizeCLMem;
        sizes[3]  = kSizeCLMem;
        sizes[4]  = mnSamples;
        sizes[5]  = mnSamples;
        sizes[6]  = mnSamples;
        sizes[7]  = GLM::Size::kInt;
        sizes[8]  = GLM::Size::kInt;
        sizes[9]  = GLM::Size::kInt;
        sizes[10] = 4 * mnSamples * mnWorkItemX * kWorkItemsY;
        
        for (i = 0; i < kKernelParams; ++i)
        {
            err = clSetKernelArg(mpKernel, i, sizes[i], pValues[i]);
            
            if(err != CL_SUCCESS)
            {
                return err;
            } // if
        } // for
    } // if
    
    return err;
} // restart

GLint NBody::Simulation::GPU::setup(const NBody::Simulation::String& options)
{
    cl_mem_flags stream_flags = CL_MEM_READ_WRITE;
    
    GLuint i = mnDeviceIndex;
    
    GLint err = CL_SUCCESS;
    
    err = clGetDeviceIDs(NULL, CL_DEVICE_TYPE_GPU, 4, mpDevice, &mnDevices);
    
    if(err != CL_SUCCESS)
    {
        return err;
    } // if
    
    std::cout
    << ">> N-body Simulation: Found "
    << mnDevices
    << " devices..."
    << std::endl;
    
    size_t nSize = 0;
    
    char name[1024]   = {0};
    char vendor[1024] = {0};
    
    clGetDeviceInfo(mpDevice[i],
                    CL_DEVICE_NAME,
                    sizeof(name),
                    &name,
                    &nSize);
    
    clGetDeviceInfo(mpDevice[i],
                    CL_DEVICE_VENDOR,
                    sizeof(vendor),
                    &vendor,
                    &nSize);
    
    m_DeviceName = name;
    
    std::cout
    << ">> N-body Simulation: Using Device["
    << i
    << "] = \""
    << m_DeviceName
    << "\""
    << std::endl;
    
    mpDevice[0] = mpDevice[i];
    
    mpContext = clCreateContext(NULL,
                                1,
                                &mpDevice[0],
                                NULL,
                                NULL,
                                &err);
    
    if(err != CL_SUCCESS)
    {
        return err;
    } // if
    
    mpQueue[0] = clCreateCommandQueue(mpContext,
                                      mpDevice[0],
                                      0,
                                      &err);
    
    if(err != CL_SUCCESS)
    {
        return err;
    } // if
    
    CF::IFStreamRef pStream = CF::IFStreamCreate(CFSTR("nbody_gpu"), CFSTR("ocl"));
    
    if(!CF::IFStreamIsValid(pStream))
    {
        return CL_INVALID_VALUE;
    } // if
    
    const char *pBuffer = CF::IFStreamGetBuffer(pStream);
    
    mpProgram = clCreateProgramWithSource(mpContext,
                                          1,
                                          &pBuffer,
                                          NULL,
                                          &err);
    
    if(err != CL_SUCCESS)
    {
        return err;
    } // if
    
    const char *pOptions = !options.empty() ? options.c_str() : NULL;
    
    err = clBuildProgram(mpProgram,
                         mnDeviceCount,
                         mpDevice,
                         pOptions,
                         NULL,
                         NULL);
    
    if(err != CL_SUCCESS)
    {
        size_t length = 0;
        
        char info_log[2000];
        
        for(i = 0; i < mnDeviceCount; ++i)
        {
            clGetProgramBuildInfo(mpProgram,
                                  mpDevice[i],
                                  CL_PROGRAM_BUILD_LOG,
                                  2000,
                                  info_log,
                                  &length);
            
            std::cerr
            << ">> N-body Simulation: Build Log for Device ["
            << i
            << "]:"
            << std::endl
            << info_log
            << std::endl;
        } // for
        
        return err;
    } // if
    
    mpKernel = clCreateKernel(mpProgram,
                              kIntegrateSystem,
                              &err);
    
    if(err != CL_SUCCESS)
    {
        return err;
    } // if
    
    size_t localSize = 0;
    
    for(i = 0; i < mnDeviceCount; ++i)
    {
        err = clGetKernelWorkGroupInfo(mpKernel,
                                       mpDevice[i],
                                       CL_KERNEL_WORK_GROUP_SIZE,
                                       GLM::Size::kULong,
                                       &localSize,
                                       NULL);
        if(err != CL_SUCCESS)
        {
            return err;
        } // if
        
        mnWorkItemX = GLuint((mnWorkItemX <= localSize) ? mnWorkItemX : localSize);
    } // for
    
    bool isInvalidWorkDim = bool(mnBodyCount % mnWorkItemX);
    
    if(isInvalidWorkDim)
    {
        std::cerr
        << ">> N-body Simulation: Number of particlces ["
        << mnBodyCount
        << "] "
        << "must be evenly divisble work group size ["
        << mnWorkItemX
        << "] for device!"
        << std::endl;
        
        return CL_INVALID_WORK_DIMENSION;
    } // if
    
    const size_t size = 4 * GLM::Size::kFloat * mnBodyCount;
    
    mpDevicePosition[0] = clCreateBuffer(mpContext,
                                         stream_flags,
                                         size,
                                         NULL,
                                         &err);
    
    if(err != CL_SUCCESS)
    {
        return -100;
    } // if
    
    mpDevicePosition[1] = clCreateBuffer(mpContext,
                                         stream_flags,
                                         size,
                                         NULL,
                                         &err);
    
    if(err != CL_SUCCESS)
    {
        return -101;
    } // if
    
    mpDeviceVelocity[0] = clCreateBuffer(mpContext,
                                         CL_MEM_READ_WRITE,
                                         size,
                                         NULL,
                                         &err);
    
    if(err != CL_SUCCESS)
    {
        return -102;
    } // if
    
    mpDeviceVelocity[1] = clCreateBuffer(mpContext,
                                         CL_MEM_READ_WRITE,
                                         size,
                                         NULL,
                                         &err);
    
    if(err != CL_SUCCESS)
    {
        return -103;
    } // if
    
    mpBodyRangeParams = clCreateBuffer(mpContext,
                                       CL_MEM_READ_WRITE,
                                       GLM::Size::kInt * 3,
                                       NULL,
                                       &err);
    
    if(err != CL_SUCCESS)
    {
        return -104;
    } // if
    
    bind();
    
    CF::IFStreamRelease(pStream);
    
    return 0;
} // setup

GLint NBody::Simulation::GPU::execute()
{
    GLint err = CL_INVALID_KERNEL;
    
    if(mpKernel != NULL)
    {
        size_t global_dim[2];
        size_t local_dim[2];
        
        local_dim[0]  = mnWorkItemX;
        local_dim[1]  = 1;
        
        global_dim[0] = mnMaxIndex - mnMinIndex;
        global_dim[1] = 1;
        
        void   *values[4];
        size_t  sizes[4];
        GLuint  indices[4];
        
        values[0] = &mpDevicePosition[mnWriteIndex];
        values[1] = &mpDeviceVelocity[mnWriteIndex];
        values[2] = &mpDevicePosition[mnReadIndex];
        values[3] = &mpDeviceVelocity[mnReadIndex];
        
        sizes[0] = kSizeCLMem;
        sizes[1] = kSizeCLMem;
        sizes[2] = kSizeCLMem;
        sizes[3] = kSizeCLMem;
        
        indices[0] = 0;
        indices[1] = 1;
        indices[2] = 2;
        indices[3] = 3;
        
        GLuint i;
        
        for (i = 0; i < 4; ++i)
        {
            err = clSetKernelArg(mpKernel, indices[i], sizes[i], values[i]);
            
            if(err != CL_SUCCESS)
            {
                return err;
            } // if
        } // for
        
        for(i = 0; i < mnDeviceCount; ++i)
        {
            if(mpQueue[i] != NULL)
            {
                err = clEnqueueNDRangeKernel(mpQueue[i],
                                             mpKernel,
                                             2,
                                             NULL,
                                             global_dim,
                                             local_dim,
                                             0,
                                             NULL,
                                             NULL);
                
                if(err != CL_SUCCESS)
                {
                    return err;
                } // if
            } // if
        } // for
    } // if
    
    return err;
} // execute

GLint NBody::Simulation::GPU::restart()
{
    GLint err = CL_INVALID_KERNEL;
    
    if(mpKernel != NULL)
    {
        NBody::Simulation::Data::Random rand(mnBodyCount, m_ActiveParams);
        
        if(rand(mpHostPosition, mpHostVelocity))
        {
            const size_t size = 4 * GLM::Size::kFloat * mnBodyCount;
            
            GLuint i = 0;
            
            for(i = 0; i < mnDeviceCount; ++i)
            {
                if(mpQueue[i] != NULL)
                {
                    err = clEnqueueWriteBuffer(mpQueue[i],
                                               mpDevicePosition[mnReadIndex],
                                               CL_TRUE,
                                               0,
                                               size,
                                               mpHostPosition,
                                               0,
                                               NULL,
                                               NULL);
                    
                    if(err != CL_SUCCESS)
                    {
                        return err;
                    } // if
                    
                    err = clEnqueueWriteBuffer(mpQueue[i],
                                               mpDeviceVelocity[mnReadIndex],
                                               CL_TRUE,
                                               0,
                                               size,
                                               mpHostVelocity,
                                               0,
                                               NULL,
                                               NULL);
                    
                    if(err != CL_SUCCESS)
                    {
                        return err;
                    } // if
                } // if
            } // for
            
            bind();
        } // if
    } // if
    
    return err;
} // restart

#pragma mark -
#pragma mark Public - Constructor

NBody::Simulation::GPU::GPU(const size_t& nbodies,
                            const NBody::Simulation::Params& params,
                            const GLuint& index)
: NBody::Simulation::Base(nbodies, params)
{
    mnDeviceCount = 1;
    mnDeviceIndex = index;
    mnWorkItemX   = kWorkItemsX;
    mbTerminated  = false;
    mnReadIndex   = 0;
    mnWriteIndex  = 0;
    
    mpHostPosition = NULL;
    mpHostVelocity = NULL;
    
    mpContext  = NULL;
    mpProgram  = NULL;
    mpKernel   = NULL;
    mpBodyRangeParams = NULL;
    
    mpDevice[0] = NULL;
    mpDevice[1] = NULL;
    
    mpQueue[0] = NULL;
    mpQueue[1] = NULL;
    
    mpDevicePosition[0] = NULL;
    mpDevicePosition[1] = NULL;
    
    mpDeviceVelocity[0] = NULL;
    mpDeviceVelocity[1] = NULL;
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

NBody::Simulation::GPU::~GPU()
{
    stop();
    
    terminate();
} // Destructor

#pragma mark -
#pragma mark Public - Utilities

void NBody::Simulation::GPU::initialize(const NBody::Simulation::String& options)
{
    if(!mbTerminated)
    {
        mnReadIndex  = 0;
        mnWriteIndex = 1;
        
        mpHostPosition = (GLfloat *) calloc(mnLength, mnSamples);
        mpHostVelocity = (GLfloat *) calloc(mnLength, mnSamples);
        
        GLint err = setup(options);
        
        mbAcquired = err == CL_SUCCESS;
        
        if(!mbAcquired)
        {
            std::cerr
            << ">> N-body Simulation["
            << err
            << "]: Failed setting up gpu compute device!"
            << std::endl;
        } // if
    } // if
} // initialize

GLint NBody::Simulation::GPU::reset()
{
    GLint err = restart();
    
    if(err != CL_SUCCESS)
    {
        std::cerr
        << ">> N-body Simulation["
        << err
        << "]: Failed resetting devices!"
        << std::endl;
    } // if
    
    return err;
} // reset

void NBody::Simulation::GPU::step()
{
    if(!isPaused() || !isStopped())
    {
        GLint err = execute();
        
        if(err != CL_SUCCESS)
        {
            std::cerr
            << ">> N-body Simulation["
            << err
            << "]: Failed executing gpu bound kernel!"
            << std::endl;
        } // if
        
        GLuint i  = 0;
        
        if(mbIsUpdated)
        {
            for (i = 0; i < mnDeviceCount; ++i)
            {
                NBodySimulationGPUReadBuffer(mpQueue[i],
                                             mpHostPosition,
                                             mpDevicePosition[mnWriteIndex],
                                             mnSize,
                                             0);
                
                setData(mpHostPosition);
            } // for
        } // if
        
        std::swap(mnReadIndex, mnWriteIndex);
    } // if
} // step

void NBody::Simulation::GPU::terminate()
{
    if(!mbTerminated)
    {
        GLuint i = 0;
        
        for(i = 0; i < mnDeviceCount; ++i)
        {
            if(mpQueue[i] != NULL)
            {
                clFinish(mpQueue[i]);
            } // if
        } // for
        
        if(mpDevicePosition[0] != NULL)
        {
            clReleaseMemObject(mpDevicePosition[0]);
            
            mpDevicePosition[0] = NULL;
        } // if
        
        if(mpDevicePosition[1] != NULL)
        {
            clReleaseMemObject(mpDevicePosition[1]);
            
            mpDevicePosition[1] = NULL;
        } // if
        
        if(mpDeviceVelocity[0] != NULL)
        {
            clReleaseMemObject(mpDeviceVelocity[0]);
            
            mpDeviceVelocity[0] = NULL;
        } // if
        
        if(mpDeviceVelocity[1] != NULL)
        {
            clReleaseMemObject(mpDeviceVelocity[1]);
            
            mpDeviceVelocity[1] = NULL;
        } // if
        
        if(mpBodyRangeParams != NULL)
        {
            clReleaseMemObject(mpBodyRangeParams);
            
            mpBodyRangeParams = NULL;
        } // if
        
        if(mpKernel != NULL)
        {
            clReleaseKernel(mpKernel);
            
            mpKernel = NULL;
        } // if
        
        if(mpProgram != NULL)
        {
            clReleaseProgram(mpProgram);
            
            mpProgram = NULL;
        } // if
        
        if(mpContext != NULL)
        {
            clReleaseContext(mpContext);
            
            mpContext = NULL;
        } // if
        
        for(i = 0; i < mnDeviceCount; ++i)
        {
            if(mpQueue[i] != NULL)
            {
                clReleaseCommandQueue(mpQueue[i]);
                
                mpQueue[i] = NULL;
            } // if
        } // for
        
        if(mpHostPosition != NULL)
        {
            free(mpHostPosition);
            
            mpHostPosition = NULL;
        } // if
        
       if(mpHostVelocity != NULL)
        {
            free(mpHostVelocity);
            
            mpHostVelocity = NULL;
        } // if

        mbTerminated = true;
    } // if
} // terminate

#pragma mark -
#pragma mark Public - Accessors

GLint NBody::Simulation::GPU::positionInRange(GLfloat *pDst)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pDst != NULL)
    {
        size_t data_offset_in_floats = mnMinIndex * 4;
        size_t data_offset_bytes     = data_offset_in_floats * mnSamples;
        size_t data_size_in_floats   = (mnMaxIndex - mnMinIndex) * 4;
        size_t data_size_bytes       = data_size_in_floats * mnSamples;
        
        GLuint i = 0;
        
        GLfloat *host_data = pDst + data_offset_in_floats;
        
        for(i = 0; i < mnDeviceCount; ++i)
        {
            err = NBodySimulationGPUReadBuffer(mpQueue[i],
                                               host_data,
                                               mpDevicePosition[mnReadIndex],
                                               data_size_bytes,
                                               data_offset_bytes);
            if(err != CL_SUCCESS)
            {
                return err;
            } // if
        } // for
    } // if
    
    return err;
} // positionInRange

GLint NBody::Simulation::GPU::position(GLfloat *pDst)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pDst != NULL)
    {
        size_t i;
        
        for(i = 0; i < mnDeviceCount; ++i)
        {
            err = NBodySimulationGPUReadBuffer(mpQueue[i],
                                               pDst,
                                               mpDevicePosition[mnReadIndex],
                                               mnSize,
                                               0);
            
            if(err != CL_SUCCESS)
            {
                break;
            } // if
        } // for
    } // if
    
    return err;
} // position

GLint NBody::Simulation::GPU::setPosition(const GLfloat * const pSrc)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pSrc != NULL)
    {
        size_t i;
        
        for (i = 0; i < mnDeviceCount; ++i)
        {
            err = NBodySimulationGPUWriteBuffer(mpQueue[i],
                                                pSrc,
                                                mpDevicePosition[mnReadIndex],
                                                mnSize);
            
            if(err != CL_SUCCESS)
            {
                break;
            } // if
        } // for
    } // if
    
    return err;
} // setPosition

GLint NBody::Simulation::GPU::velocity(GLfloat *pDst)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pDst != NULL)
    {
        size_t i;
        
        for (i = 0; i < mnDeviceCount; ++i)
        {
            err = NBodySimulationGPUReadBuffer(mpQueue[i],
                                               pDst,
                                               mpDeviceVelocity[mnReadIndex],
                                               mnSize,
                                               0);
            
            if(err != CL_SUCCESS)
            {
                break;
            } // if
        } // for
    } // if
    
    return err;
} // velocity

GLint NBody::Simulation::GPU::setVelocity(const GLfloat * const pSrc)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pSrc != NULL)
    {
        size_t i;
        
        for (i = 0; i < mnDeviceCount; ++i)
        {
            err = NBodySimulationGPUWriteBuffer(mpQueue[i],
                                                pSrc,
                                                mpDeviceVelocity[mnReadIndex],
                                                mnSize);
            
            if(err != CL_SUCCESS)
            {
                break;
            } // if
        } // for
    } // if
    
    return err;
} // setVelocity
