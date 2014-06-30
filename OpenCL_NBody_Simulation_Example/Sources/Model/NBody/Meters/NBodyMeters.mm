/*
     File: NBodyMeters.mm
 Abstract: 
 Mediator object for managing multiple hud objects for n-body simulators.
 
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

#import <OpenGL/gl.h>

#import "GLMConstants.h"
#import "GLUTransforms.h"

#import "NBodyMeters.h"

#pragma mark -
#pragma mark Private - Constants

static const GLfloat kDefaultSpeed = 0.06f;

#pragma mark -
#pragma mark Private - Utilities

NBody::Meters::Meters(const GLsizei& nLength)
{
    if(nLength)
    {
        mbStart    = false;
        mnPosition = 0.0f;
        mnSpeed    = kDefaultSpeed;
        
        mpTimer = NULL;
        
        m_IsVisible[eNBodyMeterPerf]    = true;
        m_IsVisible[eNBodyMeterUpdates] = false;
        m_IsVisible[eNBodyMeterFrames]  = false;
        m_IsVisible[eNBodyMeterAll]     = true;

        mpMeter[eNBodyMeterPerf]    = NULL;
        mpMeter[eNBodyMeterUpdates] = NULL;
        mpMeter[eNBodyMeterFrames]  = NULL;
        
        m_Label[eNBodyMeterPerf]    = "";
        m_Label[eNBodyMeterUpdates] = "";
        m_Label[eNBodyMeterFrames]  = "";
        
        m_Size[eNBodyMeterPerf]    = 0;
        m_Size[eNBodyMeterUpdates] = 0;
        m_Size[eNBodyMeterFrames]  = 0;
        
        m_Value[eNBodyMeterPerf]    = 0.0f;
        m_Value[eNBodyMeterUpdates] = 0.0f;
        m_Value[eNBodyMeterFrames]  = 0.0f;
        
        m_Bound[0] = nLength;
        m_Bound[1] = nLength;
        
        m_Frame.width  = 0.0f;
        m_Frame.height = 0.0f;
    } // if
} // Constructor

NBody::Meters::~Meters()
{
    GLuint i;
    
    for(i = eNBodyMeterPerf; i < eNBodyMeterAll; ++i)
    {
        if(mpMeter[i] != NULL)
        {
            delete mpMeter[i];
            
            mpMeter[i] = NULL;
        } // if
        
        if(!m_Label[i].empty())
        {
            m_Label[i].clear();
        } // if
    } // for
    
    if(mpTimer != NULL)
    {
        delete mpTimer;
        
        mpTimer = NULL;
    } // if
} // Destructor

void NBody::Meters::update()
{
    if(!mbStart)
    {
        mpTimer->start();
        
        mbStart = true;
    } // if
    else
    {
        mpTimer->stop();
        mpTimer->update();
        
        mpMeter[eNBodyMeterFrames]->setTarget(mpTimer->persecond());
        
        mpTimer->reset();
        
        mpMeter[eNBodyMeterFrames]->update();
    } // else
} // update

void NBody::Meters::toggle(const NBody::MeterType& nType)
{
    m_IsVisible[nType] = !m_IsVisible[nType];
} // toggle

void NBody::Meters::setValue(const NBody::MeterType& nType,
                             const GLfloat& nValue)
{
    m_Value[nType] = nValue;
    
    mpMeter[nType]->setTarget(m_Value[nType]);
    mpMeter[nType]->update();
} // setValue

void NBody::Meters::setLabel(const NBody::MeterType& nType,
                             const std::string& rLabel)
{
    if(!rLabel.empty())
    {
        m_Label[nType] = rLabel;
    } // if
} // setLabel

void NBody::Meters::setSize(const NBody::MeterType& nType,
                            const size_t& nSize)
{
    m_Size[nType] = nSize;
} // setSize

void NBody::Meters::setFrame(const CGSize& rFrame)
{
    if((rFrame.width > 0.0f) && (rFrame.height > 0.0f))
    {
        m_Frame = rFrame;
    } // if
} // setFrame

void NBody::Meters::setPosition(const GLfloat& nPosition)
{
    if(m_IsVisible[eNBodyMeterAll])
    {
        if(mnPosition <= (GLM::kHalfPi_f - mnSpeed))
        {
            mnPosition += mnSpeed;
        } // if
    } // if
    else if(mnPosition > 0.0f)
    {
        mnPosition -= mnSpeed;
    } // else if
} // setPosition

void NBody::Meters::setSpeed(const GLfloat& nSpeed)
{
    mnSpeed = nSpeed;
} // setSpeed

void NBody::Meters::draw(void)
{
    glMatrixMode(GL_PROJECTION);
    
    GLU::Ortho(0.0f, m_Frame.width, 0.0f, m_Frame.height, -1.0f, 1.0f);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glPushMatrix();
    {
        glTranslatef(0.0f, 416.0f - std::sinf(mnPosition) * 416.0f, 0.0f);
        
        if(m_IsVisible[eNBodyMeterFrames])
        {
            mpMeter[eNBodyMeterFrames]->draw(208.0f, m_Frame.height - 160.0f);
        } // if
        
        if(m_IsVisible[eNBodyMeterUpdates])
        {
            mpMeter[eNBodyMeterUpdates]->draw(0.5f * m_Frame.width, m_Frame.height - 160.0f);
        } // if
        
        if(m_IsVisible[eNBodyMeterPerf])
        {
            mpMeter[eNBodyMeterPerf]->draw(m_Frame.width - 208.0f, m_Frame.height - 160.0f);
        } // if
    }
    glPopMatrix();
} // render

bool NBody::Meters::finalize(void)
{
    try
    {
        mpTimer = new HUD::Meter::Timer(20, false);
    } // try
    catch(std::bad_alloc& ba)
    {
        NSLog(@">> ERROR: Failed acquiring a hi-res timer for the meters: \"%s\"", ba.what());
        
        return false;
    } // catch
    
    GLuint i;
    
    for(i = eNBodyMeterPerf; i < eNBodyMeterAll; ++i)
    {
        try
        {
            mpMeter[i] = new HUD::Meter::Image(m_Bound[0],
                                               m_Bound[1],
                                               m_Size[i],
                                               m_Label[i]);
        } // try
        catch(std::bad_alloc& ba)
        {
            NSLog(@">> ERROR: Failed acquiring a meter[%d] object: \"%s\"", i, ba.what());
            
            return false;
        } // catch
    } // for
    
    return true;
} // finalize
