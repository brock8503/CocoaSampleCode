/*
     File: NBodyEngine.h
 Abstract: 
 These methods performs an NBody simulation which calculates a gravity field
 and corresponding velocity and acceleration contributions accumulated
 by each body in the system from every other body.  This example
 also shows how to mitigate computation between all available devices
 including CPU and GPU devices, as well as a hybrid combination of both,
 using separate threads for each simulator.
 
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

#ifndef _NBODY_ENGINE_H_
#define _NBODY_ENGINE_H_

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

#import "NBodyMeters.h"

#import "NBodySimulationMediator.h"
#import "NBodySimulationVisualizer.h"

#ifdef __cplusplus

namespace NBody
{
    class Engine
    {
    public:
        Engine(const GLfloat& nStarScale,
               const GLuint& nActiveDemo = 1);
        
        virtual ~Engine();
        
        bool finalize(const GLuint& nBodies = NBody::Bodies::kCount);
        
        void draw();
        
        void resize(const CGRect& frame);
        
        void scroll(const GLfloat& nDelta);
        
        void click(const GLint& nState,
                   const CGPoint& point);
        
        void move(const CGPoint& point);
        
        void run(const GLubyte& nCommand);

        void setActiveDemo(const GLuint& nActiveDemo);
        void setFrame(const CGRect& rFrame);
        
        void setToReduce(const bool& bReduce);
        void setUseGPU(const bool& bIsGPUOnly);
        
        void setShowHUD(const bool& bShow);
        void setShowDock(const bool& bShow);
        
        void setClearColor(const GLfloat& nColor);
        void setDockSpeed(const GLfloat& nSpeed);
        void setViewDistance(const GLfloat& nDistance);
        
    private:
        void setDemo(const GLubyte& nCommand);

        void sync(const bool& doSync);
        bool simulators(const GLuint& nBodies);
        bool hud(const GLsizei& nLength);
        
        void reset(const GLuint& index);
        
        void restart();

        void renderStars();
        void renderMeters();
        void renderDock();
        void renderHUD();
        void render();

        void nextSimulator();
        void nextDemo();
        
        void swapVisualizer();
        void swapSimulators();

    private:
        bool mbWaitingForData;
        bool mbShowHUD;
        bool mbShowDock;
        bool mbIsRotating;
        bool mbReduce;
        bool mbIsGPUOnly;
        
        Meters *mpMeters;
        
        Simulation::Mediator   *mpMediator;
        Simulation::Visualizer *mpVisualizer;
        Simulation::Params      m_ActiveParams;
        
        GLuint    mnSimulatorIndex;
        GLuint    mnSimulatorCount;
        GLuint    mnBodies;
        GLuint    mnActiveDemo;
        GLdouble  mnViewDistance;
        GLfloat   mnHudPosition;
        GLfloat   mnClearColor;
        GLfloat   mnStarScale;
        GLfloat   mnDockSpeed;
        GLsizei   mnWidowWidth;
        GLsizei   mnWidowHeight;
        
        CGSize    m_FrameSz;
        CGPoint   m_MousePt;
        CGPoint   m_DockPt;
        CGPoint   m_RotationPt;
        CGRect    m_ButtonRt;
    }; // Engine
} // NBody

#endif

#endif
