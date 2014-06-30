/*
     File: GLUQuery.mm
 Abstract: 
 Utility class for querying OpenGL for vendor, version, and renderer.
 
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

#import <OpenGL/gl.h>

#import "GLUQuery.h"

#pragma mark -
#pragma mark Private - Enumerated Types

enum GLUQueryStrings
{
    eGLUQueryRenderer = 0,
    eGLUQueryVendor,
    GLUQueryVersion,
    eGLUQueryInfo
};

typedef enum GLUQueryStrings GLUQueryStrings;

enum GLUQueryVendors
{
    eGLUQueryIsAMD = 0,
    eGLUQueryIsATI,
    eGLUQueryIsNVidia,
    eGLUQueryIsIntel
};

typedef enum GLUQueryVendors GLUQueryVendors;

#pragma mark -
#pragma mark Private - Utilities

GLstring GLU::Query::createString(const GLenum& name)
{
	const char *pString = (const char *)glGetString(name);
	
    return GLstring(pString);
} // createString

const bool GLU::Query::match(const GLuint& i, const GLuint& j) const
{
    return std::regex_match(m_String[i], m_Regex[j]);
} // match

const bool GLU::Query::match(const GLstring& expr) const
{
    GLregex regex(expr);
    
    return std::regex_match(m_String[eGLUQueryRenderer], regex);
} // match

#pragma mark -
#pragma mark Public - Constructor

GLU::Query::Query()
{
    m_String[eGLUQueryRenderer] = createString(GL_RENDERER);
    m_String[eGLUQueryVendor]   = createString(GL_VENDOR);
    m_String[GLUQueryVersion]   = createString(GL_VERSION);
    
    m_String[eGLUQueryInfo] =
    m_String[eGLUQueryRenderer] + "\n"
    +   m_String[eGLUQueryVendor]   + "\n"
    +   m_String[GLUQueryVersion];
    
    m_Regex[eGLUQueryIsAMD]    = GLregex("AMD|amd");
    m_Regex[eGLUQueryIsATI]    = GLregex("ATI|ati");
    m_Regex[eGLUQueryIsNVidia] = GLregex("NVIDIA|nVidia|NVidia|nvidia");
    m_Regex[eGLUQueryIsIntel]  = GLregex("Intel|intel|INTEL");
    
    m_Flag[eGLUQueryIsAMD]    = match(eGLUQueryVendor, eGLUQueryIsAMD);
    m_Flag[eGLUQueryIsATI]    = match(eGLUQueryVendor, eGLUQueryIsATI);
    m_Flag[eGLUQueryIsNVidia] = match(eGLUQueryVendor, eGLUQueryIsNVidia);
    m_Flag[eGLUQueryIsIntel]  = match(eGLUQueryVendor, eGLUQueryIsIntel);
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

GLU::Query::~Query()
{
    m_String[eGLUQueryRenderer].clear();
    m_String[eGLUQueryVendor].clear();
    m_String[GLUQueryVersion].clear();
    m_String[eGLUQueryInfo].clear();
} // Destructor

#pragma mark -
#pragma mark Public - Accessors

const GLstring& GLU::Query::info() const
{
    return m_String[eGLUQueryInfo];
} // info

const GLstring& GLU::Query::renderer() const
{
    return m_String[eGLUQueryRenderer];
} // renderer

const GLstring& GLU::Query::vendor() const
{
    return m_String[eGLUQueryVendor];
} // vendor

const GLstring& GLU::Query::version() const
{
    return m_String[GLUQueryVersion];
} // version

#pragma mark -
#pragma mark Public - Queries

const bool& GLU::Query::isAMD() const
{
    return m_Flag[eGLUQueryIsAMD];
} // isAMD

const bool& GLU::Query::isATI() const
{
    return m_Flag[eGLUQueryIsATI];
} // isATI

const bool& GLU::Query::isNVidia() const
{
    return m_Flag[eGLUQueryIsNVidia];
} // isNVidia

const bool& GLU::Query::isIntel() const
{
    return m_Flag[eGLUQueryIsIntel];
} // isIntel

const bool GLU::Query::match(GLstring& rKey) const
{
    bool bSuccess = !rKey.empty();
    
    if(bSuccess)
    {
        std::size_t found = m_String[eGLUQueryRenderer].find(rKey);
        
        bSuccess = found != std::string::npos;
    } // if
    
    return bSuccess;
} // match

const bool GLU::Query::match(GLstrings& rKeys) const
{
    bool bSuccess = !rKeys.empty();
    
    if(bSuccess)
    {
        GLstring expr;
        
        size_t i;
        size_t iMax = rKeys.size() - 1;
        
        for(i = 0; i < iMax; ++i)
        {
            expr += rKeys[i] + "|";
        } // for
        
        expr += rKeys[iMax];
        
        bSuccess = match(expr);
    } // if
    
    return bSuccess;
} // isFound

