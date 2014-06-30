/*
     File: GLUProgram.mm
 Abstract: 
 Utility method for creating an OpenGL program object.
 
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

#import <iostream>

#import <OpenGL/gl.h>

#import "CFIFStream.h"

#import "GLUProgram.h"

#pragma mark -
#pragma mark Private - Utilities - Shaders

static GLstring GLUShaderSourceCreate(GLenum target,
                                      CFStringRef pName)
{
    CFStringRef pExt = NULL;
    GLstring    shader;
    
    switch(target)
    {
        case GL_VERTEX_SHADER:
            pExt   = CFSTR("vsh");
            shader = "vertex";
            break;
            
        case GL_GEOMETRY_SHADER_EXT:
            pExt   = CFSTR("gsh");
            shader = "geometry";
            break;
            
        case GL_FRAGMENT_SHADER:
            pExt   = CFSTR("fsh");
            shader = "fragment";
            break;
            
        default:
            break;
    } // switch
    
    CF::IFStreamRef pStream = CF::IFStreamCreate(pName, pExt);
    
    std::string source;
    
    if(!CF::IFStreamIsValid(pStream))
    {
        std::cerr
        << ">> ERROR: Failed acquiring "
        << shader
        << " shader source!"
        << std::endl;
    } // if
    else
    {
        source = CF::IFStreamGetBuffer(pStream);
    } // if
    
    CF::IFStreamRelease(pStream);
    
    return source;
} // GLUShaderSourceCreate

static GLsources GLUShaderSourcesCreate(const GLtargets& targets,
                                        CFStringRef pName)
{
    GLsources sources;
    
    for(auto& target:targets)
    {
        GLstring source = GLUShaderSourceCreate(target, pName);
        
        if(!source.empty())
        {
            sources.emplace(target, source);
        } // if
    } // for
    
    return sources;
} // GLUShaderSourcesCreate

static void GLUShaderGetInfoLog(const GLuint& nShader)
try
{
    GLint nInfoLogLength = 0;
    
    glGetShaderiv(nShader, GL_INFO_LOG_LENGTH, &nInfoLogLength);
    
    if(nInfoLogLength)
    {
        GLchar *pInfoLog = new GLchar[nInfoLogLength];

        glGetShaderInfoLog(nShader,
                           nInfoLogLength,
                           &nInfoLogLength,
                           pInfoLog);
        std::cerr
        << ">> INFO: OpenGL Shader - Compile log:"
        << std::endl
        << pInfoLog
        << std::endl;
        
        delete [] pInfoLog;
        
        pInfoLog = NULL;
    } // if
} // GLUShaderGetInfoLog
catch(std::bad_alloc& ba)
{
    NSLog(@">> ERROR: Failed allocating memory OpenGL info compile log: \"%s\"", ba.what());
} // catch

static bool GLUShaderValidate(const GLuint& nShader,
                              const std::string& source)
{
    GLint nIsCompiled = 0;
    
    glGetShaderiv(nShader, GL_COMPILE_STATUS, &nIsCompiled);
    
    if(!nIsCompiled)
    {
        if(!source.empty())
        {
            std::cerr
            << ">> WARNING: OpenGL Shader - Failed to compile shader!"
            << std::endl
            << source
            << std::endl;
        } // if
        
        std::cerr
        << ">> WARNING: OpenGL Shader - Deleted shader object with id = "
        << nShader
        << std::endl;
        
        glDeleteShader(nShader);
    } // if
    
	return nIsCompiled != 0;
} // GLUShaderValidate

static GLuint GLUShaderCreate(GLenum target,
                              GLstring source)
{
    GLuint nShader = 0;
    
    if(!source.empty())
    {
        nShader = glCreateShader(target);
        
        if(nShader)
        {
            const char *pSource = source.c_str();
            
            glShaderSource(nShader, 1, &pSource, NULL);
            glCompileShader(nShader);
            
            GLUShaderGetInfoLog(nShader);
        } // if
        
        if(!GLUShaderValidate(nShader, source))
		{
			nShader = 0;
		} // if
    } // if
    
    return nShader;
} // GLUShaderCreate

#pragma mark -
#pragma mark Private - Utilities - Programs

static void GLUProgramGetInfoLog(const GLuint& nProgram)
try
{
    GLint nInfoLogLength = 0;
    
    glGetProgramiv(nProgram, GL_INFO_LOG_LENGTH, &nInfoLogLength);
    
    if(nInfoLogLength)
    {
        GLchar *pInfoLog = new GLchar[nInfoLogLength];
        
        glGetProgramInfoLog(nProgram,
                            nInfoLogLength,
                            &nInfoLogLength,
                            pInfoLog);
        
        std::cerr
        << ">> INFO: OpenGL Program - Link log:"
        << std::endl
        << pInfoLog
        << std::endl;
        
        delete [] pInfoLog;
        
        pInfoLog = NULL;
    } // if
} // try
catch(std::bad_alloc& ba)
{
    NSLog(@">> ERROR: Failed allocating memory OpenGL info link log: \"%s\"", ba.what());
} // catch

static bool GLUProgramValidate(const GLuint& nProgram)
{
    GLint nIsLinked = 0;
    
    glGetProgramiv(nProgram, GL_LINK_STATUS, &nIsLinked);
    
    if(!nIsLinked)
    {
        std::cerr
        << ">> WARNING: OpenGL Shader - Deleted program object with id = "
        << nProgram
        << std::endl;
        
        glDeleteProgram(nProgram);
    } // if
    
	return nIsLinked != 0;
} // GLUProgramValidate

static GLshaders GLUProgramCreateShaders(GLuint nProgram,
                                         const GLsources& sources)
{
    GLuint nShader = 0;
    
    GLshaders shaders;
    
    for(auto& source:sources)
    {
        nShader = GLUShaderCreate(source.first, source.second);
        
        if(nShader)
        {
            glAttachShader(nProgram, nShader);
            
            shaders.push_back(nShader);
        } // if
    } // for
    
    return shaders;
} // GLUProgramCreateShaders

static void GLUProgramDeleteShaders(GLshaders& shaders)
{
    for(auto& shader:shaders)
    {
        if(shader)
        {
            glDeleteShader(shader);
        } // if
    } // for
} // GLUProgramDeleteShaders
        
static bool GLUProgramHasGeometryShader(const GLsources& sources)
{
    GLsources::const_iterator pGeom = sources.find(GL_GEOMETRY_SHADER_EXT);
    
    return pGeom != sources.end();
} // GLUProgramHasGeometryShader
        
static GLuint GLUProgramCreate(const GLsources& sources,
                               const GLenum&   nInType,
                               const GLenum&   nOutType,
                               const GLsizei&  nOutVert)
{
    GLuint nProgram = 0;
    
    if(!sources.empty())
    {
        nProgram = glCreateProgram();
        
        if(nProgram)
        {
            GLshaders shaders = GLUProgramCreateShaders(nProgram, sources);
            
            if(GLUProgramHasGeometryShader(sources))
            {
                glProgramParameteriEXT(nProgram, GL_GEOMETRY_INPUT_TYPE_EXT, nInType);
                glProgramParameteriEXT(nProgram, GL_GEOMETRY_OUTPUT_TYPE_EXT, nOutType);
                glProgramParameteriEXT(nProgram, GL_GEOMETRY_VERTICES_OUT_EXT, nOutVert);
            } // if

            glLinkProgram(nProgram);
            
            GLUProgramDeleteShaders(shaders);
            
            GLUProgramGetInfoLog(nProgram);
            
            if(!GLUProgramValidate(nProgram))
            {
                nProgram = 0;
            } // if
        } // if
    } // if
    
    return nProgram;
} // GLUProgramCreate

#pragma mark -
#pragma mark Public - Interfaces

GLU::Program::Program(CFStringRef pName)
{
    if(pName != NULL)
    {
        GLtargets targets = {GL_VERTEX_SHADER, GL_FRAGMENT_SHADER};
        mnInType  = 0;
        mnOutType = 0;
        mnOutVert = 0;
        m_Sources = GLUShaderSourcesCreate(targets, pName);
        mnProgram = GLUProgramCreate(m_Sources, mnInType, mnOutType, mnOutVert);
    } // if
} // Program

GLU::Program::Program(CFStringRef     pName,
                      const GLenum&   nInType,
                      const GLenum&   nOutType,
                      const GLsizei&  nOutVert)
{
    if(pName != NULL)
    {
        GLtargets targets = {GL_VERTEX_SHADER, GL_FRAGMENT_SHADER, GL_GEOMETRY_SHADER_EXT};
        
        mnInType  = nInType;
        mnOutType = nOutType;
        mnOutVert = nOutVert;
        m_Sources = GLUShaderSourcesCreate(targets, pName);
        mnProgram = GLUProgramCreate(m_Sources, mnInType, mnOutType, mnOutVert);
    } // if
} // Program

GLU::Program::Program(const GLU::Program& rProgram)
{
    if(!rProgram.m_Sources.empty())
    {
        mnInType  = rProgram.mnInType;
        mnOutType = rProgram.mnOutType;
        mnOutVert = rProgram.mnOutVert;
        m_Sources = rProgram.m_Sources;
        mnProgram = GLUProgramCreate(m_Sources, mnInType, mnOutType, mnOutVert);
    } // if
} // Copy Constructor

GLU::Program::~Program()
{
    if(mnProgram)
    {
        glDeleteProgram(mnProgram);
        
        mnProgram = 0;
    } // if
    
    if(!m_Sources.empty())
    {
        for(auto& source:m_Sources)
        {
            if(!source.second.empty())
            {
                source.second.clear();
            } // if
        } // for
        
        m_Sources.clear();
    } // if
} // Program

GLU::Program& GLU::Program::operator=(const GLU::Program& rProgram)
{
    if((this != &rProgram) && (!rProgram.m_Sources.empty()))
    {
        if(mnProgram)
        {
            glDeleteProgram(mnProgram);
            
            mnProgram = 0;
        } // if
        
        mnInType  = rProgram.mnInType;
        mnOutType = rProgram.mnOutType;
        mnOutVert = rProgram.mnOutVert;
        m_Sources = rProgram.m_Sources;
        mnProgram = GLUProgramCreate(m_Sources, mnInType, mnOutType, mnOutVert);
    } // if

    return *this;
} // Operator =
        
const GLuint& GLU::Program::program() const
{
    return mnProgram;
} // program

void GLU::Program::enable()
{
    glUseProgram(mnProgram);
} // enable

void GLU::Program::disable()
{
    glUseProgram(0);
} // disable

