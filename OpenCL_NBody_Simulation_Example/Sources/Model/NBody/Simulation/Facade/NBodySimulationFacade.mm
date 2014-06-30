/*
     File: NBodySimulationFacade.mm
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

#pragma mark -
#pragma mark Private - Headers

#import <cstdio>

#import <sys/types.h>
#import <sys/sysctl.h>

#import "GLMVector4.h"

#import "CFQueryHardware.h"

#import "NBodySimulationCPU.h"
#import "NBodySimulationGPU.h"
#import "NBodySimulationFacade.h"

#pragma mark -
#pragma mark Private - Accessors

// Acquire a label for the gpu bound simulator
void NBody::Simulation::Facade::setLabel(const GLint& nDevIndex,
                                         const GLuint& nDevices,
                                         const NBody::Simulation::String& rDevice)
{
    CF::Query::Hardware hw;
    
    std::string model = hw.model();
    std::size_t found = model.find("MacPro");
    std::string label = nDevIndex ? "Secondary" : "Primary";
    
    bool isMacPro  = found != std::string::npos;
    bool isDualGPU = nDevices == 2;
    
    if(isMacPro && isDualGPU && nDevIndex)
    {
        label = "Primary + " + label;
    } // if
    
    m_Label = "SIM: " + label + " " + rDevice;
} // setLabel

#pragma mark -
#pragma mark Private - Constructors

NBody::Simulation::Base *NBody::Simulation::Facade::create(const GLint& nDevIndex,
                                                           const size_t& nCount,
                                                           const NBody::Simulation::Params& rParams)
{
    NBody::Simulation::Base *pSimulator = new NBody::Simulation::GPU(nCount, rParams, nDevIndex);
    
    if(pSimulator != NULL)
    {
        size_t spin = 0;
        
        pSimulator->start();
        
        while(!pSimulator->isAcquired())
        {
            spin++;
        } // while

        mbIsGPU = true;

        setLabel(nDevIndex,
                 pSimulator->devices(),
                 pSimulator->name());
    } // if
    
    return pSimulator;
} // create

NBody::Simulation::Base *NBody::Simulation::Facade::create(const bool& bIsThreaded,
                                                           const size_t& nCount,
                                                           const NBody::Simulation::String& rLabel,
                                                           const NBody::Simulation::Params& rParams)
{
    NBody::Simulation::Base *pSimulator = new NBody::Simulation::CPU(nCount, rParams, true, bIsThreaded);
    
    if(pSimulator != NULL)
    {
        pSimulator->start();
        
        mbIsGPU = false;
        m_Label = "SIM: " + rLabel;
    } // if
    
    return pSimulator;
} // create

#pragma mark -
#pragma mark Public - Constructor

NBody::Simulation::Facade::Facade(const NBody::Simulation::Types& nType,
                                  const size_t& nCount,
                                  const Params& rParams)
{
    mnType   = nType;
    m_Label  = "";
    mpButton = NULL;
    
    switch(mnType)
    {
        case NBody::Simulation::eComputeCPUSingle:
            mpSimulator = create(false, nCount, "Vector Single Core CPU", rParams);
            break;
            
        case NBody::Simulation::eComputeCPUMulti:
            mpSimulator = create(true, nCount, "Vector Multi Core CPU", rParams);
            break;
            
        case NBody::Simulation::eComputeGPUSecondary:
            mpSimulator = create(1, nCount, rParams);
            break;
            
        case NBody::Simulation::eComputeGPUPrimary:
        default:
            mpSimulator = create(0, nCount, rParams);
            break;
    } // switch
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

NBody::Simulation::Facade::~Facade()
{
    if(mpSimulator != NULL)
    {
        mpSimulator->exit();
        
        delete mpSimulator;
        
        mpSimulator = NULL;
    } // if
    
    if(mpButton != NULL)
    {
        delete mpButton;
        
        mpButton = NULL;
    } // if
    
    m_Label.clear();
} // Destructor

#pragma mark -
#pragma mark Public - Utilities - Button

void NBody::Simulation::Facade::button(const bool& selected,
                                       const CGPoint& position,
                                       const CGRect& bounds)
{
    if(mpButton == NULL)
    {
        mpButton = new HUD::Button::Image(bounds,
                                          24.0f,
                                          false,
                                          m_Label);
    } // if

    mpButton->draw(selected, position, bounds);
} // button

#pragma mark -
#pragma mark Public - Utilities - Simulator

void NBody::Simulation::Facade::pause()
{
    mpSimulator->pause();
} // pause

void NBody::Simulation::Facade::unpause()
{
    mpSimulator->unpause();
} // unpause

void NBody::Simulation::Facade::resetParams(const NBody::Simulation::Params& params)
{
    mpSimulator->resetParams(params);
} // resetParams

void NBody::Simulation::Facade::invalidate(const bool& doInvalidate)
{
    mpSimulator->invalidate(doInvalidate);
} // invalidate

GLfloat *NBody::Simulation::Facade::data()
{
    return mpSimulator->data();
} // data

NBody::Simulation::Base* NBody::Simulation::Facade::simulator()
{
    return mpSimulator;
} // simulator

#pragma mark -
#pragma mark Public - Accessors - Quaries

const bool NBody::Simulation::Facade::isActive() const
{
    return mpSimulator != NULL;
} // isActive

const bool NBody::Simulation::Facade::isAcquired() const
{
    return mpSimulator->isAcquired();
} // isAcquired

const bool NBody::Simulation::Facade::isPaused() const
{
    return mpSimulator->isPaused();
} // isPaused

const bool NBody::Simulation::Facade::isStopped() const
{
    return mpSimulator->isStopped();
} // isStopped

// Is single core cpu simulator active?
const bool NBody::Simulation::Facade::isCPUSingleCore() const
{
    return mnType == NBody::Simulation::eComputeCPUSingle;
} // isCPUSingleCore

// Is multi-core cpu simulator active?
const bool NBody::Simulation::Facade::isCPUMultiCore() const
{
    return mnType == NBody::Simulation::eComputeCPUMulti;
} // isCPUMultiCore

// Is primary gpu simulator active?
const bool NBody::Simulation::Facade::isGPUPrimary() const
{
    return mnType == NBody::Simulation::eComputeGPUPrimary;
} // isGPUPrimary

// Is secondary (or offline) gpu simulator active?
const bool NBody::Simulation::Facade::isGPUSecondary() const
{
    return mnType == NBody::Simulation::eComputeGPUSecondary;
} // isGPUSecondary

#pragma mark -
#pragma mark Public - Accessors - Getters

void NBody::Simulation::Facade::positionInRange(GLfloat *pDst)
{
    mpSimulator->positionInRange(pDst);
} // positionInRange

void NBody::Simulation::Facade::position(GLfloat *pDst)
{
    mpSimulator->position(pDst);
} // position

void NBody::Simulation::Facade::velocity(GLfloat *pDst)
{
    mpSimulator->velocity(pDst);
} // velocity

const GLdouble NBody::Simulation::Facade::performance() const
{
    return mpSimulator->performance();
} // performance

const GLdouble NBody::Simulation::Facade::updates() const
{
    return mpSimulator->updates();
} // updates

const GLdouble NBody::Simulation::Facade::year() const
{
    return mpSimulator->year();
} // year

const size_t NBody::Simulation::Facade::size() const
{
    return mpSimulator->size();
} // size

const NBody::Simulation::String& NBody::Simulation::Facade::label() const
{
    return m_Label;
} // label

#pragma mark -
#pragma mark Public - Accessors - Setters

void NBody::Simulation::Facade::setRange(const GLint& min,
                                         const GLint& max)
{
    mpSimulator->setRange(min, max);
} // setRange

void NBody::Simulation::Facade::setParams(const NBody::Simulation::Params& params)
{
    mpSimulator->setParams(params);
} // setParams

void NBody::Simulation::Facade::setData(const GLfloat * const pData)
{
    mpSimulator->setData(pData);
} // setData

void NBody::Simulation::Facade::setPosition(const GLfloat * const pSrc)
{
    mpSimulator->setPosition(pSrc);
} // setPosition

void NBody::Simulation::Facade::setVelocity(const GLfloat * const pSrc)
{
    mpSimulator->setVelocity(pSrc);
} // setVelocity
