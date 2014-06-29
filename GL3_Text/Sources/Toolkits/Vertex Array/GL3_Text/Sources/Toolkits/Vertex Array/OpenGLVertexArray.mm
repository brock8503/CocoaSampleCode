/*
     File: OpenGLVertexArray.mm
 Abstract: 
 Utility toolkit for vao management and generation.
 
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

// STL container types
#import <string>
#import <map>

// GLKit Math
#import <GLKit/GLKMath.h>

// OpenGL core profile
#import <OpenGL/gl3.h>

// OpenGL vertices private type
#import "OpenGLVertices.h"

// OpenGL VAO header
#import "OpenGLVertexArray.h"

#pragma mark -
#pragma mark Private - Constants

static const GLuint kSzFloat = sizeof(GLfloat);
static const GLuint kSzUInt  = sizeof(GLuint);

#pragma mark -
#pragma mark Private - Data Structures

// Name associated with an attribute or a binding point
typedef std::string  GLname;

// Interleaved array
struct GLVertexArray
{
	GLuint mnVAO;
	GLuint mnBID;
	GLuint mnPID;
	GLuint mnCount;
	
	std::map<GLname, GLuint>  m_Attributes;
}; // GLVertexArray

typedef struct GLVertexArray  GLVertexArray;

#pragma mark -
#pragma mark Private - Utilities - Buffers

// Get a pointer into a buffer at an offset
static inline const GLchar *GLBufferGetOffset(const GLsizeiptr nOffset)
{
	return( (const GLchar *)NULL + nOffset );
} // GLBufferGetOffset

// Create a buffer
static GLuint GLBufferCreate(const GLenum nTarget,
                             const GLenum nUsage,
                             const GLsizeiptr nSize,
                             const GLfloat * const pArray)
{
    GLuint nBID = 0;
    
    glGenBuffers(1, &nBID);
    
    if( nBID )
    {
        glBindBuffer(nTarget, nBID);
        glBufferData(nTarget, nSize, pArray, nUsage);
        glBindBuffer(nTarget, 0);
    } // if
    
    return nBID;
} // GLBufferCreate

#pragma mark -
#pragma mark Private - Utilities - Arrays

// Enable a generic vertex attribute
static BOOL GLVertexAttributeArrayEnable(const GLint nSize,
                                         const GLchar * const pName,
										 const GLsizei nStride,
										 const GLvoid *pOffset,
										 GLVertexArrayRef pVertexArray)
{
    BOOL bSuccess = pName != NULL;
    
    if( bSuccess )
    {
		glUseProgram(pVertexArray->mnPID);
		
        const GLint nAttribLoc = glGetAttribLocation(pVertexArray->mnPID, pName);
        		
		pVertexArray->m_Attributes[pName] = nAttribLoc;
		
        glVertexAttribPointer(nAttribLoc, nSize, GL_FLOAT, GL_FALSE, nStride, pOffset);
        glEnableVertexAttribArray(nAttribLoc);
    } // if
    
    return bSuccess;
} // GLVertexAttributeArrayEnable

// Create an array buffer
static inline GLuint GLArrayBufferCreate(const GLuint nCount,
                                         const GLuint nSPP,
                                         const GLfloat * const pArray)
{
    GLsizeiptr nSize = nSPP * nCount;
    
    return GLBufferCreate(GL_ARRAY_BUFFER, GL_STATIC_DRAW, nSize, pArray);
} // GLArrayBufferCreate

// Bind an array buffer
static inline void GLArrayBufferBind(const GLuint nBID)
{
    glBindBuffer(GL_ARRAY_BUFFER,nBID);
} // GLArrayBufferCreate

#pragma mark -
#pragma mark Private - Utilities - Vertices

// Get a float array from a STL vector representing a 2D object
static inline const GLfloat * GLArrayGetPointer(const GLArrayRef pArray)
{
	return( (const GLfloat *)&pArray->m_Vertices[0] );
} // GLArrayGetPointer

#pragma mark -
#pragma mark Private - Utilities - Vertex Array

// Create a buffer for vertices of a triangle fan
static void GLVertexArrayEnable(const GLchar * const pPosition,
								const GLchar * const pTexCoord,
								const GLchar * const pColor,
								const GLArrayRef pArray,
								GLVertexArrayRef pVertexArray)
{
	GLsizei nStride = sizeof(GLVertex);
	
	pVertexArray->mnBID = GLArrayBufferCreate(pVertexArray->mnCount, nStride, GLArrayGetPointer(pArray));
	
	GLsizeiptr nOffsetTexCoord = sizeof(GLKVector2);
	GLsizeiptr nOffsetColor    = 2 * nOffsetTexCoord;
	
	GLArrayBufferBind(pVertexArray->mnBID);
	
	if( pPosition != NULL )
	{
		GLVertexAttributeArrayEnable(2, pPosition, nStride, GLBufferGetOffset(0), pVertexArray);
	} // if
	
	if( pTexCoord != NULL )
	{
		GLVertexAttributeArrayEnable(2, pTexCoord, nStride, GLBufferGetOffset(nOffsetTexCoord), pVertexArray);
	} // if
	
	if( pColor != NULL )
	{
		GLVertexAttributeArrayEnable(4, pColor, nStride, GLBufferGetOffset(nOffsetColor), pVertexArray);
	} // if
} // GLVertexArrayEnable

// Create a buffer for vertices of a triangle fan
static void GLVertexArrayEnable(const GLchar * const pPosition,
								const GLchar * const pNormal,
								const GLchar * const pTexCoord,
								const GLchar * const pColor,
								const GLArrayRef pArray,
								GLVertexArrayRef pVertexArray)
{
	GLsizei nStride = sizeof(GLVertex);
	
	pVertexArray->mnBID = GLArrayBufferCreate(pVertexArray->mnCount, nStride, GLArrayGetPointer(pArray));
	
	GLsizeiptr nOffsetNormals  = sizeof(GLKVector3);
	GLsizeiptr nOffsetTexCoord = 2 * nOffsetNormals;
	GLsizeiptr nOffsetColor    = 3 * nOffsetNormals;
	
	GLArrayBufferBind(pVertexArray->mnBID);
	
	if( pPosition != NULL )
	{
		GLVertexAttributeArrayEnable(3, pPosition, nStride, GLBufferGetOffset(0), pVertexArray);
	} // if
	
	if( pNormal != NULL )
	{
		GLVertexAttributeArrayEnable(3, pNormal, nStride, GLBufferGetOffset(nOffsetNormals), pVertexArray);
	} // if
	
	if( pTexCoord != NULL )
	{
		GLVertexAttributeArrayEnable(3, pTexCoord, nStride, GLBufferGetOffset(nOffsetTexCoord), pVertexArray);
	} // if
	
	if( pColor != NULL )
	{
		GLVertexAttributeArrayEnable(4, pColor, nStride, GLBufferGetOffset(nOffsetColor), pVertexArray);
	} // if
} // GLVertexArrayEnable

// Get the cached attribute location
static inline GLuint GLVertexArrayGetAttribute(const GLname &rName,
											   GLVertexArrayRef pVertexArray)
{
	return pVertexArray->m_Attributes[rName];
} // GLVertexArrayGetLocation

#pragma mark -
#pragma mark Public - Constructors

// Create a vao, representing a 2D object, using vertices, colors,
// and texture coordinates
GLVertexArrayRef GLVertexArrayCreate(const GLuint nProgramID,
									 const GLuint nCount,
									 const GLchar * const pPosition,
									 const GLchar * const pTexCoord,
									 const GLchar * const pColor,
									 const GLArrayRef pArray)
{
	GLVertexArrayRef pVertexArray = NULL;
	
    if( nProgramID && pArray )
    {
		pVertexArray = new GLVertexArray;
		
		if( pVertexArray != NULL )
		{
			pVertexArray->mnPID   = nProgramID;
			pVertexArray->mnCount = nCount;
			
			glGenVertexArrays(1, &pVertexArray->mnVAO);
			
			if( pVertexArray->mnVAO )
			{
				glBindVertexArray(pVertexArray->mnVAO);
				
				GLVertexArrayEnable(pPosition,
									pTexCoord,
									pColor,
									pArray,
									pVertexArray);
			} // if
		} // if
    } // if
	
	return pVertexArray;
} // GLVertexArrayCreate

// Create a vao, representing a 3D object, using vertices, normals,
// colors, and texture coordinates
GLVertexArrayRef GLVertexArrayCreate(const GLuint nProgramID,
									 const GLuint nCount,
									 const GLchar * const pPosition,
									 const GLchar * const pNormal,
									 const GLchar * const pTexCoord,
									 const GLchar * const pColor,
									 const GLArrayRef pArray)
{
	GLVertexArrayRef pVertexArray = NULL;
	
    if( nProgramID && pArray )
    {
		pVertexArray = new GLVertexArray;
		
		if( pVertexArray != NULL )
		{
			pVertexArray->mnPID   = nProgramID;
			pVertexArray->mnCount = nCount;
			
			glGenVertexArrays(1, &pVertexArray->mnVAO);
			
			if( pVertexArray->mnVAO )
			{
				glBindVertexArray(pVertexArray->mnVAO);
				
				GLVertexArrayEnable(pPosition,
									pNormal,
									pTexCoord,
									pColor,
									pArray,
									pVertexArray);
			} // if
		} // if
    } // if
	
	return pVertexArray;
} // GLVertexArrayCreate

#pragma mark -
#pragma mark Public - Destructor

// Delete the VAO opaque data reference
void GLVertexArrayDelete(GLVertexArrayRef pVertexArray)
{
	if( pVertexArray != NULL )
	{
		pVertexArray->m_Attributes.clear();
		
        glDeleteBuffers(1, &pVertexArray->mnBID);
        glDeleteVertexArrays(1, &pVertexArray->mnVAO);

		delete pVertexArray;
		
		pVertexArray = NULL;
	} // if
} // GLVertexArrayDelete

#pragma mark -
#pragma mark Public - Accessors

// Get VBO id
const GLuint GLVertexArrayGetBuffer(const GLVertexArrayRef pVertexArray)
{
	return pVertexArray->mnBID;
} // GLVertexArrayGetBuffer

// Get VAO id
const GLuint GLVertexArrayGetVAO(const GLVertexArrayRef pVertexArray)
{
	return pVertexArray->mnVAO;
} // GLVertexArrayGetVAO

// Get the named attribute location
const GLuint GLVertexArrayGetLocation(const GLchar * const pName,
									  const GLVertexArrayRef pVertexArray)
{
	return GLVertexArrayGetAttribute(pName, pVertexArray);
} // GLVertexArrayGetLocation

// Create VAO representing a quad
GLVertexArrayRef GLVertexArrayCreateQuad(const GLuint nProgramID,
										 const GLchar * const pVertex,
										 const GLchar * const pColor,
										 const GLfloat * const pColors,
										 const GLchar * const pTexCoords)
{
	GLVertexArrayRef pVertexArray = NULL;
	
	GLArrayRef pVertices = GLArrayCreateQuad(NULL, NULL, pColors);
	
	if( pVertices != NULL )
	{
		pVertexArray = GLVertexArrayCreate(nProgramID,
										   4,
										   pVertex,
										   pTexCoords,
										   pColor,
										   pVertices);
		
		GLArrayDelete(pVertices);
	} // if
	
	return pVertexArray;
} // GLVertexArrayCreateQuad

// Create VAO representing a quad
GLVertexArrayRef GLVertexArrayCreateQuad(const GLuint nProgramID,
										 const GLchar * const pColor,
										 const GLfloat * const pColors,
										 const GLchar * const pTexCoords)
{
	GLVertexArrayRef pVertexArray = NULL;
	
	GLArrayRef pVertices = GLArrayCreateQuad(NULL, NULL, pColors);
	
	if( pVertices != NULL )
	{
		pVertexArray = GLVertexArrayCreate(nProgramID,
										   4,
										   NULL,
										   pTexCoords,
										   pColor,
										   pVertices);
		
		GLArrayDelete(pVertices);
	} // if
	
	return pVertexArray;
} // GLVertexArrayCreateQuad
