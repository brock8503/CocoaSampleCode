/*
     File: NBodySimulationBase.mm
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

#pragma mark -
#pragma mark Private - Headers

#import <libkern/OSAtomic.h>

#import "CFQueryHardware.h"
#import "GLMVector4.h"

#import "NBodySimulationBase.h"

#pragma mark -
#pragma mark Private - Constants

static const std::string kOptions = "-cl-fast-relaxed-math -cl-mad-enable";

static const GLdouble kScaleYear = 1.8e7;

#pragma mark -
#pragma mark Public - Utilities

void *NBody::Simulation::simulate(void *arg)
{
    NBody::Simulation::Base *pBase = (NBody::Simulation::Base *)arg;
    
    pBase->run();
    
    pthread_exit((void *)pBase->mnMaxIndex);
} // simulate

NBody::Simulation::Base::Base(const size_t& nbodies,
                              const NBody::Simulation::Params& params)
:   m_Pref(20, false),
    m_Updates(20, false)
{
    if(nbodies)
    {
        m_Options = kOptions;
        
        m_ActiveParams = params;
        
        mnBodyCount   = nbodies;
        mnCardinality = mnBodyCount * mnBodyCount;
        mnMaxIndex    = mnBodyCount;
        mnLength      = 4 * mnBodyCount;
        mnSamples     = sizeof(GLfloat);
        mnSize        = mnLength * mnSamples;
        
        mbAcquired  = false;
        mbIsUpdated = true;
        mbKeepAlive = true;
        mbStop      = false;
        mbReload    = false;
        mbPaused    = false;
        
        mpData   = NULL;
        m_Thread = NULL;
        
        m_DeviceName[0] = '\0';
        
        mnMinIndex    = 0;
        mnDeviceCount = 0;
        mnDevices     = 0;
        
        mnPref    = 0.0f;
        mnUpdates = 0.0f;
        
        CF::Query::Hardware hw;
        
        // This number is used to measure relative performance.
        // The baseline is that of multi-core CPU performance
        // and all performance numbers are measured relative
        // to this number. And as such this is not the traditional
        // giga (or tera) flops performance numbers.
        mnDelta = GLdouble(mnCardinality) * hw.scale();
        
        pthread_mutexattr_init(&m_ClockAttrib);
        pthread_mutexattr_settype(&m_ClockAttrib, PTHREAD_MUTEX_RECURSIVE);
        
        pthread_mutex_init(&m_ClockLock, &m_ClockAttrib);
        
        pthread_mutexattr_init(&m_RunAttrib);
        pthread_mutexattr_settype(&m_RunAttrib, PTHREAD_MUTEX_RECURSIVE);
        
        pthread_mutex_init(&m_RunLock, &m_RunAttrib);
    } // if
} // Base

NBody::Simulation::Base::~Base()
{
    pthread_mutexattr_destroy(&m_ClockAttrib);
    pthread_mutex_destroy(&m_ClockLock);
    
    pthread_mutexattr_destroy(&m_RunAttrib);
    pthread_mutex_destroy(&m_RunLock);
    
    if(!m_Options.empty())
    {
        m_Options.clear();
    } // if
    
    GLfloat *pData = data();
    
    if(pData != NULL)
    {
        free(pData);
        
        pData = NULL;
    } // if
} // Destructor

const bool NBody::Simulation::Base::isAcquired() const
{
    return mbAcquired;
} // isAcquired

const bool NBody::Simulation::Base::isPaused() const
{
    return mbPaused;
} // isPaused

const bool NBody::Simulation::Base::isStopped() const
{
    return mbStop;
} // isStopped

void NBody::Simulation::Base::start(const bool& paused)
{
    pause();
    
    pthread_create(&m_Thread, NULL, simulate, this);
    
    if(!paused)
    {
        unpause();
    } // if
} // start

void NBody::Simulation::Base::stop()
{
    pause();
    {
        mbStop = true;
    }
    unpause();
    
    pthread_join(m_Thread, NULL);
    
    mbAcquired = false;
} // stop

void NBody::Simulation::Base::pause()
{
    if(!mbPaused)
    {
        if(mbKeepAlive)
        {
            pthread_mutex_lock(&m_RunLock);
        } // if
        
        mbPaused = true;
    } // if
} // pause

void NBody::Simulation::Base::unpause()
{
    if(mbPaused)
    {
        mbPaused = false;
        
        pthread_mutex_unlock(&m_RunLock);
    } // if
} // unpause

void NBody::Simulation::Base::exit()
{
    mbKeepAlive = false;
} // exit

void NBody::Simulation::Base::resetParams(const NBody::Simulation::Params& params)
{
    pause();
    {
        mnMinIndex     = 0;
        mnMaxIndex     = mnBodyCount;
        m_ActiveParams = params;
        
        m_Pref.erase();
        
        mnPref = 0;
        
        m_Updates.erase();
        
        mnUpdates = 0;
        mbReload  = true;
        mnYear    = 2.755e9;
    }
    unpause();
} // resetParams

void NBody::Simulation::Base::setParams(const NBody::Simulation::Params& params)
{
    m_ActiveParams = params;
    
    mbReload = true;
} // setParams

void NBody::Simulation::Base::setRange(const GLint& min,
                                       const GLint& max)
{
    mnMinIndex = min;
    mnMaxIndex = max;
} // setRange

void NBody::Simulation::Base::invalidate(const bool& v)
{
    mbIsUpdated = v;
} // invalidate

void NBody::Simulation::Base::setData(const GLfloat * const pData)
{
    if(pData != NULL)
    {
        GLfloat *pDataDst = (GLfloat *)calloc(mnLength, mnSamples);
        
        if(pDataDst != NULL)
        {
            std::memcpy(pDataDst, pData, mnSize);
            
            void *pDataSrc = NULL;
            
            do
            {
                pDataSrc = mpData;
            }
            while(!OSAtomicCompareAndSwapPtrBarrier(pDataSrc, pDataDst, &mpData));
            
            free(pDataSrc);
            
            pDataSrc = NULL;
        }// if
    } // if
} // setData

GLfloat *NBody::Simulation::Base::data()
{
    void *pDataSrc = NULL;
    
    do
    {
        pDataSrc = mpData;
    }
    while(!OSAtomicCompareAndSwapPtrBarrier(pDataSrc, NULL, &mpData));
    
    return (GLfloat *)pDataSrc;
} // data

void NBody::Simulation::Base::run()
{
    pthread_mutex_lock(&m_ClockLock);
    {
        initialize(m_Options);
    }
    pthread_mutex_unlock(&m_ClockLock);
    
    while(mbKeepAlive)
    {
        pthread_mutex_lock(&m_RunLock);
        {
            if(mbStop)
            {
                pthread_mutex_unlock(&m_ClockLock);
                pthread_mutex_unlock(&m_RunLock);
                
                return;
            } // if
            
            if (mbReload)
            {
                pthread_mutex_lock(&m_ClockLock);
                {
                    reset();
                }
                pthread_mutex_unlock(&m_ClockLock);
                
                mbReload = false;
            } // if
            
            pthread_mutex_lock(&m_ClockLock);
            {
                m_Pref.start();
                {
                    step();
                }
                m_Pref.stop();
            }
            pthread_mutex_unlock(&m_ClockLock);
        }
        pthread_mutex_unlock(&m_RunLock);
        
        m_Pref.update(mnDelta);
        
        mnPref = m_Pref.persecond();
        
        m_Updates.setStart(m_Pref.getStart());
        m_Updates.setStop(m_Pref.getStop());
        m_Updates.update();
        
        mnUpdates = std::ceil(m_Updates.persecond());
                
        // normalize for NBody::Scale::kTime at 0.4
        mnYear += kScaleYear * m_ActiveParams.mnTimeStamp;
    } // while
    
    pthread_mutex_lock(&m_ClockLock);
    {
        terminate();
    }
    pthread_mutex_unlock(&m_ClockLock);
} // run

const GLdouble& NBody::Simulation::Base::performance() const
{
    return mnPref;
} // performance

const GLdouble& NBody::Simulation::Base::updates() const
{
    return mnUpdates;
} // updates

const GLdouble& NBody::Simulation::Base::year() const
{
    return mnYear;
} // year

const size_t& NBody::Simulation::Base::size() const
{
    return mnSize;
} // size

const NBody::Simulation::String& NBody::Simulation::Base::name() const
{
    return m_DeviceName;
} // name

const size_t& NBody::Simulation::Base::minimum() const
{
    return mnMinIndex;
} // minimum

const size_t& NBody::Simulation::Base::maximum() const
{
    return mnMaxIndex;
} // maximum

const GLuint& NBody::Simulation::Base::devices() const
{
    return mnDevices;
} // devices

