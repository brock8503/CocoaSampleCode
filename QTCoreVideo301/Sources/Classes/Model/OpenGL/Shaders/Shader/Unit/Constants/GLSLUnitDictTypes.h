/*
     File: GLSLUnitDictTypes.h
 Abstract: 
 Private constants for initializing dictionary uniforms.
 
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

#ifndef _GLSL_UNIT_DICTIONARY_TYPES_H_
#define _GLSL_UNIT_DICTIONARY_TYPES_H_

#ifdef __cplusplus
extern "C" {
#endif
    
    // Uniform Types
    enum GLSLUniformTypes
    {
        kGLSLUniformNone = 0,
        kGLSLUniformSampler1D,
        kGLSLUniformSampler2D,
        kGLSLUniformSampler3D,
        kGLSLUniformSampler2DRect,
        kGLSLUniform1i,
        kGLSLUniform2i,
        kGLSLUniform3i,
        kGLSLUniform4i,
        kGLSLUniform1iv,
        kGLSLUniform2iv,
        kGLSLUniform3iv,
        kGLSLUniform4iv,
        kGLSLUniform1f,
        kGLSLUniform2f,
        kGLSLUniform3f,
        kGLSLUniform4f,
        kGLSLUniform1fv,
        kGLSLUniform2fv,
        kGLSLUniform3fv,
        kGLSLUniform4fv,
        kGLSLUniform2x2fv,
        kGLSLUniform3x3fv,
        kGLSLUniform4x4fv,
        kGLSLUniformMax
    };
    
    typedef enum GLSLUniformTypes GLSLUniformTypes;
    
    // Scalar Types
   enum GLSLUniformScalarTypes
    {
        kGLSLScalar = 1,
        kGLSL2Scalars,
        kGLSL3Scalars,
        kGLSL4Scalars
    };
    
    typedef enum GLSLUniformScalarTypes GLSLUniformScalarTypes;
    
    // Vector Types
    enum GLSLUniformVectorTypes
    {
        kGLSLVector = 1,
        kGLSL2Vector,
        kGLSL3Vector,
        kGLSL4Vector
    };
    
    typedef enum GLSLUniformVectorTypes GLSLUniformVectorTypes;
    
    // Matrix Types
    enum GLSLUniformMatrixTypes
    {
        kGLSL2Matrix = 2,
        kGLSL3Matrix,
        kGLSL4Matrix
    };
    
    typedef enum GLSLUniformMatrixTypes GLSLUniformMatrixTypes;
    
#ifdef __cplusplus
}
#endif

#endif

