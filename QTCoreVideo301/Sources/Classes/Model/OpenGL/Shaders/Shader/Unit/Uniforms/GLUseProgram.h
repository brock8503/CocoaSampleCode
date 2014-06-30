/*
     File: GLUseProgram.h
 Abstract: 
 A facade for either glUseProgram or logging an error if the program object is not valid.
 
  Version: 2.0
 
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
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#ifndef _OPENGL_IS_PROGRAM_H_
#define _OPENGL_IS_PROGRAM_H_

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

#ifdef __cplusplus

namespace GL
{
    namespace Program
    {
        namespace Use
        {
            class Interface
            {
            public:
                virtual ~Interface(){};
                
                virtual const GLuint program() const = 0;
                
                virtual void enable()  = 0;
                virtual void disable() = 0;
            }; // Interface
            
            class Error : public Interface
            {
            public:
                Error(const GLuint nProgram)
                {
                    mnProgram = nProgram;
                } // Constructor
                
                virtual ~Error(){};
                
                const GLuint program() const
                {
                    return mnProgram;
                } // GetProgram

                void enable()
                {
                    NSLog(@">> [OpenGL] WARNING: Can't enable the program object 0x%x!",mnProgram);
                } // enable
                
                void disable()
                {
                    NSLog(@">> [OpenGL] WARNING: Can't disable the program object 0x%x!",mnProgram);
                } // disable
                
            private:
                GLuint mnProgram;
            }; // Log
            
            class Impl : public Interface
            {
            public:
                Impl(const GLuint nProgram)
                {
                    mnProgram = nProgram;
                } // Constructor
                
                virtual ~Impl(){};
                                
                const GLuint program() const
                {
                    return mnProgram;
                } // GetProgram
                
                void enable()
                {
                    glUseProgram(mnProgram);
                } // enable
                
                void disable()
                {
                    glUseProgram(0);
                } // disable
                
            private:
                GLuint mnProgram;
            }; // Use
            
            class Facade
            {
            public:
                Facade(const GLuint nProgram)
                {
                    mbIsProgram = glIsProgram(nProgram);

                    if(mbIsProgram)
                    {
                        mpInterface = new Impl(nProgram);
                    } // if
                    else
                    {
                        mpInterface = new Error(nProgram);
                    } // else
                } // Constructor
                
                virtual ~Facade()
                {
                    delete mpInterface;
                } // destructor
                
                const GLuint program() const
                {
                    return mpInterface->program();
                } // program
                
                const bool isProgram() const
                {
                    return mbIsProgram;
                } // isProgram
                
                void enable()
                {
                    mpInterface->enable();
                } // enable
                
                void disable()
                {
                    mpInterface->disable();
                } // disable
                
            private:
                bool       mbIsProgram;
                Interface *mpInterface;
            }; // Facade
        } // Use
    } // Program
} // OpenCL

#endif

#endif
