/*
     File: OpenGLShaders.mm
 Abstract: 
 GLSL shader utility toolkit.
 
  Version: 1.0
 
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

#pragma mark -
#pragma mark Headers

// OpenGL core profile
#import <OpenGL/gl3.h>

// String copy utilities
#import "CFStringCopy.h"

// OpenGL string utilities
#import "OpenGLString.h"

// OpenGL file stream utilities
#import "OpenGLIFStream.h"

// OpenGL utilities header
#import "OpenGLShaders.h"

#pragma mark -
#pragma mark Private - Utilities - GLSL

// Compile a shader from source string
static void GLShaderCompileFromSource(GLuint nShader,
									  const GLsource &rShaderSource)
{
    GLint nInfoLogLength = 0;
    
    if( !rShaderSource.empty() )
    {
		const GLchar *pShaderSource = rShaderSource.c_str();
		
        glShaderSource(nShader, 1, &pShaderSource, NULL);
        glCompileShader(nShader);
        
        glGetShaderiv(nShader, GL_INFO_LOG_LENGTH, &nInfoLogLength);
        
        if( nInfoLogLength > 0 )
        {
            GLchar *pInfoLog =  new GLchar[nInfoLogLength];
            
            if( pInfoLog != NULL )
            {
                glGetShaderInfoLog(nShader,
                                   nInfoLogLength,
                                   &nInfoLogLength,
                                   pInfoLog);
                
                NSLog(@">> INFO: OpenGL Shader - Shader compile log:\n%s\n", pInfoLog);
                
                delete [] pInfoLog;
                
                pInfoLog = NULL;
            } // if
        } // if
    } // if
} // GLShaderCompileFromSource

// Validate a compiled shader
static BOOL GLShaderValidate(const GLuint nShader,
							 const GLsource &rShaderSource)
{
    GLint nIsCompiled = 0;
    
    glGetShaderiv(nShader, GL_COMPILE_STATUS, &nIsCompiled);
    
    if( nIsCompiled == 0 )
    {
        if( !rShaderSource.empty() )
        {
            NSLog(@">> WARNING: OpenGL Shader - Failed to compile shader!\n%s\n", rShaderSource.c_str());
        } // if
        
        NSLog(@">> WARNING: OpenGL Shader - Deleted shader object with id = %d", nShader);
        
        glDeleteShader(nShader);
    } // if
    
	return nIsCompiled != 0;
} // GLShaderValidate

// Create, and validate, a shader from a source string
static GLuint GLShaderCreate(const GLsource  &rShaderSource,
							 const GLenum nShaderType)
{
    GLuint nShader = glCreateShader(nShaderType);
    
    if( nShader )
    {
        GLShaderCompileFromSource(nShader, rShaderSource);
        
		if( !GLShaderValidate(nShader, rShaderSource) )
		{
			nShader = 0;
		} // if
    } // if
    
	return nShader;
} // GLShaderCreate

// Create a program object and attach shaders
static GLuint GLProgramCreateWithShaders(const GLobjects &rShaders)
{
	GLuint nPID = glCreateProgram();
	
	if( nPID )
	{
		// Attach the vertex shader
		glAttachShader(nPID, rShaders[0]);
		
		// Attach the fragment shader
		glAttachShader(nPID, rShaders[1]);
		
		// Attach the optional geometry shader
		if( rShaders.size() > 2 )
		{
			glAttachShader(nPID, rShaders[2]);
		} // if
	} // if
	
	return nPID;
} // GLProgramCreateWithShaders

// Function pointer definition for location binding
typedef void (*GLBindLocsFuncPtr)(GLuint nPID, GLuint nIndex, const GLchar *pName);

// Bind locations using an OpenGL function
static bool GLBindLocations(const GLuint nPID,
							GLlocations  &rLocations,
							GLBindLocsFuncPtr GLBindLocs)
{
	bool bSuccess = !rLocations.empty();
	
	if( bSuccess )
	{
		std::map<GLuint, std::string>::iterator pIter;
		std::map<GLuint, std::string>::iterator pIterBegin = rLocations.begin();
		std::map<GLuint, std::string>::iterator pIterEnd   = rLocations.end();
		
		// Vertex shader inputs
		for( pIter = pIterBegin; pIter != pIterEnd; ++pIter)
		{
			GLBindLocs(nPID, pIter->first, pIter->second.c_str());
		} // for
	} // if
	
	return bSuccess;
} // GLBindLocations

// Bind generic vertex attribute locations
static inline bool GLBindAttributes(const GLuint nPID,
									GLlocations  &rAttributes)
{
	return GLBindLocations(nPID, rAttributes, glBindAttribLocation);
} // GLBindAttributes

// Bind fragment data locations
static inline bool GLBindFragments(const GLuint nPID,
								   GLlocations  &rFragments)
{
	return GLBindLocations(nPID, rFragments, glBindFragDataLocation);
} // GLBindFragments

#pragma mark -
#pragma mark Private - Utilities - Locations

// Applier function for converting a CFDictionary to a STL map
static void GLLocationsApplyFunction(const void *pKey,
                                     const void *pValue,
                                     void *pContext)
{
    if( pKey && pValue )
    {
        GLuint key = 0;
        
        if( CFNumberGetValue(CFNumberRef(pKey), kCFNumberSInt32Type, &key) )
        {
            GLstring     value = CFStringCreateStringCopy(CFStringRef(pValue));
            GLlocations *pLocs = (GLlocations *)pContext;
            
            pLocs->insert( GLlocation(GLuint(key),value) );
        } // if
    } // if
} // GLLocationsApplyFunction

#pragma mark -
#pragma mark Public - Utilities - Containers

// Create an associative array (a.k.a. map) from key-value pairs
GLlocations GLLocationsCreate(const GLuint nCount,
							  const GLuint *pKeys,
							  const GLchar **hValues)
{
	GLlocations locs;
	
    if( (nCount > 0) && (pKeys != NULL) && (hValues != NULL) )
    {
        GLuint i;
        
        const GLchar *pValue = NULL;
        
        // Insert the key-value pair into an associative array
        for(i = 0; i < nCount; ++i)
        {
            pValue = hValues[i];
            
            if( pValue != NULL )
            {
                locs[pKeys[i]] = pValue;
            } // if
        } // for
    } // if
	
	return locs;
} // GLLocationsCreate

// Create an associative array (a.k.a. map) from key-value pairs
GLlocations GLLocationsCreate(const GLuints    &rKeys,
                              const GLstrings  &rValues)
{
	GLlocations locs;
	
	GLuint iMax = rKeys.size();
	GLuint jMax = rValues.size();
    
    if( iMax > jMax )
    {
        iMax = jMax;
    } // if
    
    if( iMax )
    {
        GLuint i;
        
        // Insert the key-value pair into an associative array
        for(i = 0; i < iMax; ++i)
        {
            locs[rKeys[i]] = rValues[i];
        } // for
    } // if
	
	return locs;
} // GLLocationsCreate

// Create an associative array (a.k.a. map) from key-value pairs
GLlocations GLLocationsCreate(CFArrayRef pKeys,
                              CFArrayRef pValues)
{
	GLlocations locs;
	
    if( pKeys && pValues )
    {
        GLuint iMax = CFArrayGetCount(pKeys);
        GLuint jMax = CFArrayGetCount(pValues);
        
        if( iMax > jMax )
        {
            iMax = jMax;
        } // if
        
        if( iMax )
        {
            GLuint i;
            
            CFStringRef pValue = NULL;
            CFNumberRef pKey   = NULL;
            
            GLuint key = 0;
            
            bool bSuccess = false;
            
            // Insert the key-value pair into an associative array
            for(i = 0; i < iMax; ++i)
            {
				pKey = CFNumberRef(CFArrayGetValueAtIndex(pKeys, i));
				
				if( pKey != NULL )
				{
					pValue = CFStringRef(CFArrayGetValueAtIndex(pValues, i));
					
					bSuccess = pValue != NULL;
					
					bSuccess = bSuccess && CFNumberGetValue(pKey, kCFNumberSInt32Type, &key);
					
					if( bSuccess )
					{
						locs[GLuint(key)] = CFStringCreateStringCopy(pValue);
					} // ikf
				} // if
            } // for
        } // if
    } // if
	
	return locs;
} // GLLocationsCreate

// Create an associative array (a.k.a. map) from key-value pairs
GLlocations GLLocationsCreate(CFDictionaryRef pLocations)
{
	GLlocations locs;
    
    if( pLocations != NULL )
    {
        GLuint nCount = CFDictionaryGetCount(pLocations);
        
        if( nCount )
        {
            CFDictionaryApplyFunction(pLocations,GLLocationsApplyFunction,&locs);
        } // if
    } // if
    
	return locs;
} // GLLocationsCreate

// Delete locations
void GLLocationsDelete(GLlocations &rLocations)
{
	if( !rLocations.empty() )
	{
		rLocations.clear();
	} // if
} // GLLocationsDelete

#pragma mark -
#pragma mark Public - Utilities - Shaders

// Compile vertex and fragment shaders, with/without optional geometry shader
GLobjects GLShadersCreate(const GLchar * const pVertex,
                          const GLchar * const pFragment,
                          const GLchar * const pGeometry)
{
	GLobjects objects;
	
	if( (pVertex != NULL) &&  (pFragment != NULL ) )
	{
		// Compile the mandatory vertex and fragment shaders
		
		// Create a vertex shader
		GLuint shaderID = GLShaderCreate(pVertex, GL_VERTEX_SHADER);
		
		bool bSuccess = bool(shaderID);
		
		if( bSuccess )
		{
			// Insert vertex shader id into the vector
			objects.push_back(shaderID);
			
			// Create a fragment shader
			shaderID = GLShaderCreate(pFragment, GL_FRAGMENT_SHADER);
			
			bSuccess = bool(shaderID);
			
			if( bSuccess )
			{
				// Insert fragment shader id into the vector
				objects.push_back(shaderID);
				
				// If optional geometry shader stage is required
				if( pGeometry != NULL )
				{
					shaderID = GLShaderCreate(pGeometry, GL_GEOMETRY_SHADER);
					
					bSuccess = bool(shaderID);
					
					if( bSuccess )
					{
						// Insert optional geometry shader id into the vector
						objects.push_back(shaderID);
					} // if
				} // if
			} // if
		} // if
		
		if( !bSuccess )
		{
			GLShadersDelete(objects);
		} // if
	} // if
	
	return objects;
} // GLShadersCreate

// Compile vertex and fragment shaders
GLobjects GLShadersCreate(CFStringRef pVertex,
                          CFStringRef pFragment)
{
	GLchar *vertex   = CFStringCreateBufferCopy(pVertex);
	GLchar *fragment = CFStringCreateBufferCopy(pFragment);

    GLobjects objects = GLShadersCreate(vertex, fragment, NULL);
    
    if( vertex != NULL )
    {
        free(vertex);
    } // if
    
    if( fragment != NULL )
    {
        free(fragment);
    } // if
    
    return objects;
} // GLShadersCreate

// Compile vertex and fragment shaders, with/without optional
// geometry shader
GLobjects GLShadersCreate(CFStringRef pVertex,
                          CFStringRef pFragment,
                          CFStringRef pGeometry)
{
	GLchar *vertex   = CFStringCreateBufferCopy(pVertex);
	GLchar *fragment = CFStringCreateBufferCopy(pFragment);
	GLchar *geometry = CFStringCreateBufferCopy(pGeometry);
	
    GLobjects objects = GLShadersCreate(vertex, fragment, geometry);
    
    if( vertex != NULL )
    {
        free(vertex);
    } // if
    
    if( fragment != NULL )
    {
        free(fragment);
    } // if
    
    if( geometry != NULL )
    {
        free(geometry);
    } // if
    
    return objects;
} // GLShadersCreate


// Compile vertex and fragment shaders
GLobjects GLShadersCreate(const GLchar * const pVertex,
						  const GLchar * const pFragment)
{
    return GLShadersCreate(pVertex,
                           pFragment,
                           NULL);
} // GLShadersCreate


// Compile vertex and fragment shaders
GLobjects GLShadersCreate(const GLsource &rVertex,
						  const GLsource &rFragment)
{
    return GLShadersCreate(rVertex.c_str(),
                           rFragment.c_str(),
                           NULL);
}

// Compile vertex and fragment shaders, with/without optional
// geometry shader
GLobjects GLShadersCreate(const GLsource &rVertex,
						  const GLsource &rFragment,
						  const GLsource &rGeometry)
{
    return GLShadersCreate(rVertex.c_str(),
                           rFragment.c_str(),
                           rGeometry.c_str());
} // GLShadersCreate

// Compile vertex and fragment shaders at a pathname
GLobjects GLShadersCreateAtPath(const GLchar * const pVertex,
                                const GLchar * const pFragment)
{
    GLobjects objects;
    
    GLIFStreamRef vertex   = GLIFStreamCreate(pVertex);
    GLIFStreamRef fragment = GLIFStreamCreate(pFragment);
    
    if( (vertex != NULL) && (fragment != NULL) )
    {
        objects = GLShadersCreate(GLIFStreamGetBuffer(vertex),
                                  GLIFStreamGetBuffer(fragment),
                                  NULL);
        
        GLIFStreamDelete(vertex);
        GLIFStreamDelete(fragment);
    } // if
    
    return objects;
} // GLShadersCreateAtPath

// Compile vertex and fragment shaders, with/without optional geometry shader
// geometry shader at a pathname
GLobjects GLShadersCreateAtPath(const GLchar * const pVertex,
                                const GLchar * const pFragment,
                                const GLchar * const pGeometry)
{
    GLobjects objects;
    
    GLIFStreamRef vertex   = GLIFStreamCreate(pVertex);
    GLIFStreamRef fragment = GLIFStreamCreate(pFragment);
    
    if( (vertex != NULL) && (fragment != NULL) )
    {
        GLIFStreamRef geometry = GLIFStreamCreate(pGeometry);
       
        objects = GLShadersCreate(GLIFStreamGetBuffer(vertex),
                                  GLIFStreamGetBuffer(fragment),
                                  GLIFStreamGetBuffer(geometry));
        
        GLIFStreamDelete(vertex);
        GLIFStreamDelete(fragment);
        GLIFStreamDelete(geometry);
    } // if
    
    return objects;
} // GLShadersCreateAtPath
// Compile vertex and fragment shaders at a pathname
GLobjects GLShadersCreateAtPath(const GLpathname &rVertex,
                                const GLpathname &rFragment)
{
    GLobjects objects;
    
    GLIFStreamRef vertex   = GLIFStreamCreate(rVertex);
    GLIFStreamRef fragment = GLIFStreamCreate(rFragment);
    
    if( (vertex != NULL) && (fragment != NULL) )
    {
        objects = GLShadersCreate(GLIFStreamGetBuffer(vertex),
                                  GLIFStreamGetBuffer(fragment),
                                  NULL);
        
        GLIFStreamDelete(vertex);
        GLIFStreamDelete(fragment);
    } // if
    
    return objects;
} // GLShadersCreateAtPath

// Compile vertex and fragment shaders, with/without optional geometry shader
// geometry shader at a pathname
GLobjects GLShadersCreateAtPath(const GLpathname &rVertex,
                                const GLpathname &rFragment,
                                const GLpathname &rGeometry)
{
    GLobjects objects;
    
    GLIFStreamRef vertex   = GLIFStreamCreate(rVertex);
    GLIFStreamRef fragment = GLIFStreamCreate(rFragment);
    
    if( (vertex != NULL) && (fragment != NULL) )
    {
        GLIFStreamRef geometry = GLIFStreamCreate(rGeometry);
        
        objects = GLShadersCreate(GLIFStreamGetBuffer(vertex),
                                  GLIFStreamGetBuffer(fragment),
                                  GLIFStreamGetBuffer(geometry));
        
        GLIFStreamDelete(vertex);
        GLIFStreamDelete(fragment);
        GLIFStreamDelete(geometry);
    } // if
    
    return objects;
} // GLShadersCreateAtPath

// Compile vertex and fragment shaders at a pathname
GLobjects GLShadersCreateAtPath(CFStringRef pVertex,
                                CFStringRef pFragment)
{
    GLobjects objects;
    
    GLIFStreamRef vertex   = GLIFStreamCreate(pVertex);
    GLIFStreamRef fragment = GLIFStreamCreate(pFragment);
    
    if( (vertex != NULL) && (fragment != NULL) )
    {
        objects = GLShadersCreate(GLIFStreamGetBuffer(vertex),
                                  GLIFStreamGetBuffer(fragment),
                                  NULL);
        
        GLIFStreamDelete(vertex);
        GLIFStreamDelete(fragment);
    } // if
    
    return objects;
} // GLShadersCreateAtPath

// Compile vertex and fragment shaders, with/without optional geometry shader
// geometry shader at a pathname
GLobjects GLShadersCreateAtPath(CFStringRef pVertex,
                                CFStringRef pFragment,
                                CFStringRef pGeometry)
{
    GLobjects objects;
    
    GLIFStreamRef vertex   = GLIFStreamCreate(pVertex);
    GLIFStreamRef fragment = GLIFStreamCreate(pFragment);
    
    if( (vertex != NULL) && (fragment != NULL) )
    {
        GLIFStreamRef geometry = GLIFStreamCreate(pGeometry);
        
        objects = GLShadersCreate(GLIFStreamGetBuffer(vertex),
                                  GLIFStreamGetBuffer(fragment),
                                  GLIFStreamGetBuffer(geometry));
        
        GLIFStreamDelete(vertex);
        GLIFStreamDelete(fragment);
        GLIFStreamDelete(geometry);
    } // if
    
    return objects;
} // GLShadersCreateAtPath

// Delete all the shaders
void GLShadersDelete(GLobjects &rObjects)
{
	if( !rObjects.empty() )
	{
		GLuint i;
		GLuint iMax = rObjects.size();
		
		for(i = 0; i < iMax; ++i)
		{
			glDeleteShader(rObjects[i]);
		} // if
		
		rObjects.clear();
	} // if
} // GLShadersDelete

#pragma mark -
#pragma mark Public - Utilities - Program Object

// Create a program object from shaders (that may include an optional geometry shader)
GLuint GLProgramCreate(const GLobjects &rShaders,
					   GLlocations  &rAttributes,
					   GLlocations  &rFragments)
{
	// Create the program object
	GLuint nPID = GLProgramCreateWithShaders(rShaders);
	
	if( nPID )
	{
		// Bind attribute locations
		GLBindAttributes(nPID, rAttributes);
		
		// Bind fragment data locations
		GLBindFragments(nPID, rFragments);
		
		// Link to the program object
		glLinkProgram(nPID);
	} // if
    
    return nPID;
} // GLProgramCreate
