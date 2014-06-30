/*
     File: NBodySimulationVisualizer.h
 Abstract: 
A Visualizer mediator object for managing of rendering n-bodies to an OpenGL view.
 
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

#ifndef _NBODY_SIMULATION_VISUALIZER_H_
#define _NBODY_SIMULATION_VISUALIZER_H_

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

#import "GLUGaussian.h"
#import "GLUProgram.h"
#import "GLUTexture.h"

#import "NBodySimulationTypes.h"

#ifdef __cplusplus

namespace NBody
{
    namespace Simulation
    {
        class Visualizer
        {
        public:
            Visualizer(const GLuint& nBodies);
            
            virtual ~Visualizer();
            
            void reset(const GLuint& nDemo);
            
            void draw(const GLfloat *pPosition);
            
            const bool isValid() const;
            
            void stopRotation();
            void toggleRotation();
            
            void toggleEarthView();

            void setFrame(const CGSize& rFrame);

            void setIsResetting(const bool& bReset);
            void setShowEarthView(const bool& bShowView);
            
            void setRotation(const CGPoint& rRotation);
            void setRotationChange(const GLfloat& nDelta);
            void setRotationSpeed(const GLfloat& nSpeed);
            
            void setTimeScale(const GLfloat& nScale);
            
            void setStarSize(const GLfloat& nSize);
            void setStarScale(const GLfloat& nScale);
            
            void setViewDistance(const GLfloat& nDistance);
            void setViewRotation(const CGPoint& rRotation);
            void setViewTime(const GLfloat& nTime);
            void setViewZoom(const GLfloat& nZoom);
            void setViewZoomSpeed(const GLfloat& nSpeed);
            
            bool setParams(const GLuint& nParamCount,
                           const Params * const pParams);
            
        private:
            bool buffer(const GLuint& nCount);
            bool textures(CFStringRef pName, CFStringRef pExt, const GLint& nTexRes = 32);
            bool program(CFStringRef pName);
            
            bool acquire(const GLuint& nCount);
            
            Params *parameters(const GLuint& nParamCount, const Params * const pParamsSrc);

            void lookAt(const GLfloat *pPosition);
            void prespective();

            void render(const GLfloat *pPosition);
            void update();
            
            void advance(const GLuint& nDemo);

        private:
            bool           m_Flag[4];
            CGPoint        m_ViewRotation;
            CGPoint        m_Rotation;
            CGSize         m_Frame;
            GLsizei        m_Bounds[2];
            GLfloat        m_Property[9];
            GLuint         m_Graphic[5];
            GLuint         mnActiveDemo;
            GLuint         mnParamCount;
            Params        *mpParams;
            GLU::Program  *mpProgram;
            GLU::Gaussian *mpGausssian;
            GLU::Texture  *mpTexture;
       }; // Visualizer
    } // SImulation
} // NBody

#endif

#endif
