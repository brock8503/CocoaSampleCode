/*
     File: NBodySimulationDataMediator.mm
 Abstract: 
 Utility class for managing cpu bound device and host memories.
 
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
#import "GLMVector3.h"

#import "NBodySimulationRandom.h"
#import "NBodySimulationDataMediator.h"

#pragma mark -
#pragma mark Private - Namespace

using namespace NBody::Simulation;

#pragma mark -
#pragma mark Public - Constructor

Data::Mediator::Mediator(const size_t& nbodies)
{
    mnBodies     = nbodies;
    mnReadIndex  = 0;
    mnWriteIndex = 1;
    mpPacked     = new Data::Packed(mnBodies);
    mpSplit[0]   = new Data::Split(mnBodies);
    mpSplit[1]   = new Data::Split(mnBodies);
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

Data::Mediator::~Mediator()
{
    if(mpPacked != NULL)
    {
        delete mpPacked;
        
        mpPacked = NULL;
    } // if
    
    if(mpSplit[0] != NULL)
    {
        delete mpSplit[0];
        
        mpSplit[0] = NULL;
    } // if
    
    if(mpSplit[1] != NULL)
    {
        delete mpSplit[1];
        
        mpSplit[1] = NULL;
    } // if
} // Destructor

#pragma mark -
#pragma mark Public - Utilities

void Data::Mediator::swap()
{
    std::swap(mnReadIndex, mnWriteIndex);
} // step

GLint Data::Mediator::acquire(cl_context pContext)
{
    GLint err = mpSplit[0]->acquire(pContext);
    
    if(err == CL_SUCCESS)
    {
        err = mpSplit[1]->acquire(pContext);
        
        if(err == CL_SUCCESS)
        {
            err = mpPacked->acquire(pContext);
        } // if
    } // if
    
    return err;
} // setup

GLint Data::Mediator::bind(cl_kernel pKernel)
{
    GLint err = mpSplit[mnWriteIndex]->bind(0, pKernel);
    
    if(err == CL_SUCCESS)
    {
        err = mpSplit[mnReadIndex]->bind(6, pKernel);
        
        if(err == CL_SUCCESS)
        {
            err = mpPacked->bind(12, pKernel);
        } // if
    } // if
    
    return err;
} // bind

GLint Data::Mediator::update(cl_kernel pKernel)
{
    GLint err = mpSplit[mnWriteIndex]->bind(0, pKernel);
    
    if(err == CL_SUCCESS)
    {
        err = mpSplit[mnReadIndex]->bind(6, pKernel);
        
        if(err == CL_SUCCESS)
        {
            err = mpPacked->update(12, pKernel);
        } // if
    } // if
    
    return err;
} // bind

void Data::Mediator::reset(const NBody::Simulation::Params& rParams)
{
    Data::Random rand(mnBodies, rParams);
    
    rand(mpSplit[mnReadIndex], mpPacked);
} // reset

#pragma mark -
#pragma mark Public - Accessors

const GLfloat* Data::Mediator::position() const
{
    return mpPacked->position();
} // position

GLint Data::Mediator::positionInRange(const size_t& nMin,
                                      const size_t& nMax,
                                      GLfloat *pDst)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pDst != NULL)
    {
        size_t offset = nMin * 4;
        
        pDst += offset;
        
        GLfloat *pPackedPosition = mpPacked->position();
        
        size_t i;
        size_t j;
        
        for(i = nMin; i < nMax; ++i)
        {
            j = 4 * i;
            
            pDst[j]   = pPackedPosition[j];
            pDst[j+1] = pPackedPosition[j+1];
            pDst[j+2] = pPackedPosition[j+2];
            pDst[j+3] = pPackedPosition[j+3];
        } // for
        
        err = CL_SUCCESS;
    } // if
    
    return err;
} // positionInRange

GLint Data::Mediator::position(const size_t& nMax,
                               GLfloat *pDst)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pDst != NULL)
    {
        GLfloat *pPosition = mpPacked->position();
        
        GLuint i;
        GLuint j;
        
        for(i = 0; i < nMax; ++i)
        {
            j = 4 * i;
            
            pDst[j]   = pPosition[j];
            pDst[j+1] = pPosition[j+1];
            pDst[j+2] = pPosition[j+2];
            pDst[j+3] = pPosition[j+3];
        } // for
        
        err = CL_SUCCESS;
    } // if
    
    return err;
} // position

GLint Data::Mediator::setPosition(const GLfloat * const pSrc)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pSrc != NULL)
    {
        GLfloat *pPosition  = mpPacked->position();
        GLfloat *pPositionX = mpSplit[mnReadIndex]->position(Data::eCoordinateX);
        GLfloat *pPositionY = mpSplit[mnReadIndex]->position(Data::eCoordinateY);
        GLfloat *pPositionZ = mpSplit[mnReadIndex]->position(Data::eCoordinateZ);
        
        GLuint i;
        GLuint j;
        
        for(i = 0; i < mnBodies; ++i)
        {
            j = 4 * i;
            
            pPosition[j]   = pSrc[j];
            pPosition[j+1] = pSrc[j+1];
            pPosition[j+2] = pSrc[j+2];
            
            pPositionX[i] = pPosition[j];
            pPositionY[i] = pPosition[j+1];
            pPositionZ[i] = pPosition[j+2];
        } // for
        
        err = CL_SUCCESS;
    } // if
    
    return err;
} // setPosition

GLint Data::Mediator::velocity(GLfloat *pDest)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pDest != NULL)
    {
        const GLfloat *pVelocityX = mpSplit[mnReadIndex]->velocity(Data::eCoordinateX);
        const GLfloat *pVelocityY = mpSplit[mnReadIndex]->velocity(Data::eCoordinateY);
        const GLfloat *pVelocityZ = mpSplit[mnReadIndex]->velocity(Data::eCoordinateZ);
        
        GLuint i;
        GLuint j;
        
        for(i = 0; i < mnBodies; ++i)
        {
            j = 4 * i;
            
            pDest[j]   = pVelocityX[i];
            pDest[j+1] = pVelocityY[i];
            pDest[j+2] = pVelocityZ[i];
        } // for
        
        err = CL_SUCCESS;
    } // if
    
    return err;
} // velocity

GLint Data::Mediator::setVelocity(const GLfloat * const pSrc)
{
    GLint err = CL_INVALID_VALUE;
    
    if(pSrc != NULL)
    {
        GLfloat *pVelocityX = mpSplit[mnReadIndex]->velocity(Data::eCoordinateX);
        GLfloat *pVelocityY = mpSplit[mnReadIndex]->velocity(Data::eCoordinateY);
        GLfloat *pVelocityZ = mpSplit[mnReadIndex]->velocity(Data::eCoordinateZ);
        
        GLuint i;
        GLuint j;
        
        for(i = 0; i < mnBodies; ++i)
        {
            j = 4 * i;
            
            pVelocityX[i] = pSrc[j];
            pVelocityY[i] = pSrc[j+1];
            pVelocityZ[i] = pSrc[j+2];
        } // for
        
        err = CL_SUCCESS;
    } // if
    
    return err;
} // setVelocity
