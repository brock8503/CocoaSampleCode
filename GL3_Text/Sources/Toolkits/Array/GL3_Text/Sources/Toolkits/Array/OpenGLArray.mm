/*
     File: OpenGLArray.mm
 Abstract: 
 Utility toolkit for interleaved array management.
 
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

// OpenGL vertices private type
#import "OpenGLVertices.h"

// OpenGL array header
#import "OpenGLArray.h"

#pragma mark -
#pragma mark Private - Utilities - Vertices

// Append a to a vertex, positions, texture coordinates, and colors
static void GLVertexPushback(const GLuint nIndex,
							 const GLfloat * const pPositions,
							 const GLfloat * const pTexCoords,
							 const GLfloat * const pColors,
							 GLArrayRef pArray)
{
	const GLfloat *positions = pPositions + nIndex * 2;
	const GLfloat *texcoords = pTexCoords + nIndex * 2;
	const GLfloat *colors    = pColors    + nIndex * 4;
	
	GLKVector2 vPositions = GLKVector2Make( positions[0], positions[1] );
	GLKVector2 vTexCoords = GLKVector2Make( texcoords[0], texcoords[1] );
	GLKVector4 vColors    = GLKVector4Make(    colors[0],    colors[1], colors[2], colors[3] );
	
	pArray->m_Vertices.push_back(GLVertex(vPositions, vTexCoords, vColors));
} //GLVertexPushback

// Append a to a vertex, positions, texture coordinates, and colors
static void GLVertexPushback(const GLuint nIndex,
							 const GLfloat * const pPositions,
							 const GLfloat * const pNormals,
							 const GLfloat * const pTexCoords,
							 const GLfloat * const pColors,
							 GLArrayRef pArray)
{
	const GLfloat *positions = pPositions + nIndex * 3;
	const GLfloat *texcoords = pTexCoords + nIndex * 3;
	const GLfloat *colors    = pColors    + nIndex * 4;
	
	GLKVector3 vPositions = GLKVector3Make( positions[0], positions[1], positions[2] );
	GLKVector3 vTexCoords = GLKVector3Make( texcoords[0], texcoords[1], texcoords[2] );
	GLKVector4 vColors    = GLKVector4Make(    colors[0],    colors[1],    colors[2], colors[3] );
	
	if( pNormals != NULL )
	{
		const GLfloat *normals = pNormals + nIndex * 3;
		
		GLKVector3 vNormals = GLKVector3Make(normals[0], normals[1], normals[2]);
		
		pArray->m_Vertices.push_back(GLVertex(vPositions, vNormals, vTexCoords, vColors));
	} // if
	else
	{
		pArray->m_Vertices.push_back(GLVertex(vPositions, vTexCoords, vColors));
	} // else
} //GLVertexPushback

#pragma mark -
#pragma mark Public - Constructors

// Create an interleaved array for 2D objects
GLArrayRef GLArrayCreate(const GLuint nCount,
						 const GLfloat * const pPositions,
						 const GLfloat * const pTexCoords,
						 const GLfloat * const pColors)
{
	GLArrayRef	pArray = new GLArray;
	
	if( pArray != NULL )
	{
		GLuint i;
		
		for( i = 0; i < nCount; ++i )
		{
			GLVertexPushback(i, pPositions, pTexCoords, pColors, pArray);
		} // for
		
		pArray->mnDim = 2;
		
		pArray->mnCount[0] = 2;		// positions
		pArray->mnCount[1] = 0;		// normals
		pArray->mnCount[2] = 2;		// texture coordinates
		pArray->mnCount[3] = 4;		// colors
	} // if
	
	return pArray;
} // GLArrayCreate

// Create an interleaved vector for 3D objects
GLArrayRef GLArrayCreate(const GLuint nCount,
						 const GLfloat * const pPositions,
						 const GLfloat * const pNormals,
						 const GLfloat * const pTexCoords,
						 const GLfloat * const pColors)
{
	GLArrayRef	pArray = new GLArray;
	
	if( pArray != NULL )
	{
		GLuint i;
		
		for( i = 0; i < nCount; ++i )
		{
			GLVertexPushback(i, pPositions, pNormals, pTexCoords, pColors, pArray);
		} // for
		
		pArray->mnDim = 3;
		
		pArray->mnCount[0] = 3;						// positions
		pArray->mnCount[1] = (pNormals) ? 3 : 0;	// normals
		pArray->mnCount[2] = 3;						// texture coordinates
		pArray->mnCount[3] = 4;						// colors
	} // if
	
	return pArray;
} // GLVerticesCreate

// Create an interleaved vector for a quad 2D object
GLArrayRef GLArrayCreateQuad(const GLfloat * const pPositionsSrc,
							 const GLfloat * const pTexCoordsSrc,
							 const GLfloat * const pColorsSrc)
{
	// Default positions
	const GLfloat positions[8] =
	{
		-1.0, -1.0,
		1.0, -1.0,
		1.0,  1.0,
		-1.0,  1.0
	};
	
	const GLfloat *pPositionsDst = NULL;
	
	if( pPositionsSrc != NULL )
	{
		pPositionsDst = pPositionsSrc;
	} // if
	else
	{
		pPositionsDst = positions;
	} // else
	
	// Default positions
	const GLfloat texCoords[8] =
	{
		0.0, 0.0,
		1.0, 0.0,
		1.0, 1.0,
		0.0, 1.0
	};
	
	const GLfloat *texCoordsDst = NULL;
	
	if( pTexCoordsSrc != NULL )
	{
		texCoordsDst = pTexCoordsSrc;
	} // if
	else
	{
		texCoordsDst = texCoords;
	} // else
	
	// Default white color
	const GLfloat colors[16] =
	{
		1.0f, 1.0f, 1.0f, 1.0f,
		1.0f, 1.0f, 1.0f, 1.0f,
		1.0f, 1.0f, 1.0f, 1.0f,
		1.0f, 1.0f, 1.0f, 1.0f
	};
	
	const GLfloat *pColorsDst = NULL;
	
	if( pColorsSrc != NULL )
	{
		pColorsDst = pColorsSrc;
	} // if
	else
	{
		pColorsDst = colors;
	} // else
	
	return GLArrayCreate(4, pPositionsDst, texCoordsDst, pColorsDst);
} // GLArrayCreateQuad

#pragma mark -
#pragma mark Public - Desturctor

// Delete 2D/3D interleaved vector
void GLArrayDelete(GLArrayRef pArray)
{
	if( pArray != NULL )
	{
		pArray->m_Vertices.clear();
		
		delete pArray;
		
		pArray = NULL;
	} // if
} // GLArrayDelete

#pragma mark -
#pragma mark Public - Accessors

// The vertex count
const GLuint GLArrayGetCount(const GLArrayRef pArray)
{
	return pArray->m_Vertices.size();
} // GLArrayGetCount

// Accessors for 2D positions in an interleaved array
const GLKVector2 GLArrayGetPosition2D(const GLuint nIndex,
									  const GLArrayRef pArray)
{
	GLKVector2 position;
	
	if( pArray->mnDim == 2 )
	{
		position = pArray->m_Vertices[nIndex].m_Vertex2D.m_Positions;
	} // if
	else
	{
		GLKVector3 position3D = (pArray->mnCount[1])
		? pArray->m_Vertices[nIndex].m_Vertex3D.m_v3D_2.m_Positions
		: pArray->m_Vertices[nIndex].m_Vertex3D.m_v3D_1.m_Positions;
		
		position.x = position3D.x;
		position.y = position3D.y;
	} // else
	
	return position;
} // GLArrayGetPosition2D

// Accessors for 2D texture coordinates in an interleaved array
const GLKVector2 GLArrayGetTexCoords2D(const GLuint nIndex,
									   const GLArrayRef pArray)
{
	GLKVector2 texcoords;
	
	if( pArray->mnDim == 2 )
	{
		texcoords = pArray->m_Vertices[nIndex].m_Vertex2D.m_Texcoords;
	} // if
	else
	{
		GLKVector3 texcoords3D = (pArray->mnCount[1])
		? pArray->m_Vertices[nIndex].m_Vertex3D.m_v3D_2.m_Texcoords
		: pArray->m_Vertices[nIndex].m_Vertex3D.m_v3D_1.m_Texcoords;
		
		texcoords.x = texcoords3D.x;
		texcoords.y = texcoords3D.y;
	} // else
	
	return texcoords;
} // GLArrayGetTexCoords2D

// Accessors for 3D position in an interleaved array
const GLKVector3 GLArrayGetPosition3D(const GLuint nIndex,
									  const GLArrayRef pArray)
{
	GLKVector3 position;
	
	if( pArray->mnDim == 3 )
	{
		position = (pArray->mnCount[1])
		? pArray->m_Vertices[nIndex].m_Vertex3D.m_v3D_2.m_Positions
		: pArray->m_Vertices[nIndex].m_Vertex3D.m_v3D_1.m_Positions;
	} // if
	else
	{
		GLKVector2 position2D = pArray->m_Vertices[nIndex].m_Vertex2D.m_Positions;
		
		position.x = position2D.x;
		position.y = position2D.y;
		position.z = 0.0f;
	} // else
	
	return position;
} // GLArrayGetPosition3D

// Accessors for 3D normals in an interleaved array
const GLKVector3 GLArrayGetNormals3D(const GLuint nIndex,
									 const GLArrayRef pArray)
{
	GLKVector3 normals = GLKVector3Make(-1.0f,-1.0f,-1.0f);
	
	if( (pArray->mnDim == 3) && (pArray->mnCount[1] == 3) )
	{
		normals = pArray->m_Vertices[nIndex].m_Vertex3D.m_v3D_2.m_Normals;
	} // if
	
	return normals;
} // GLArrayGetNormals3D

// Accessors for 3D texture coordinates in an interleaved array
const GLKVector3 GLArrayGetTexCoords3D(const GLuint nIndex,
									   const GLArrayRef pArray)
{
	GLKVector3 texcoords;
	
	if( pArray->mnDim == 3 )
	{
		texcoords = (pArray->mnCount[1])
		? pArray->m_Vertices[nIndex].m_Vertex3D.m_v3D_2.m_Texcoords
		: pArray->m_Vertices[nIndex].m_Vertex3D.m_v3D_1.m_Texcoords;
	} // if
	else
	{
		GLKVector2 texcoords2D = pArray->m_Vertices[nIndex].m_Vertex2D.m_Texcoords;
		
		texcoords.x = texcoords2D.x;
		texcoords.y = texcoords2D.y;
		texcoords.z = 0.0f;
	} // else
	
	return texcoords;
} // GLArrayGetTexCoords3D

// Accessors for vertex color in an interleaved array
const GLKVector4 GLArrayGetColors(const GLuint nIndex,
								  const GLArrayRef pArray)
{
	GLKVector4 colors;
	
	if( pArray->mnDim == 2 )
	{
		colors = pArray->m_Vertices[nIndex].m_Vertex2D.m_Colors;
	} // if
	else
	{
		colors = (pArray->mnCount[1])
		? pArray->m_Vertices[nIndex].m_Vertex3D.m_v3D_2.m_Colors
		: pArray->m_Vertices[nIndex].m_Vertex3D.m_v3D_1.m_Colors;
	} // else
	
	return colors;
} // GLArrayGetColors
