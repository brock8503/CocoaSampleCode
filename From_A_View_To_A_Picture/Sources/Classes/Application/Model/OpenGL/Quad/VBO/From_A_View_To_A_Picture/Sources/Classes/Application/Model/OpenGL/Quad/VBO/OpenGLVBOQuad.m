//---------------------------------------------------------------------------
//
//	File: OpenGLVBOQuad.m
//
//  Abstract: Utility toolkit for handling a quad VBO
// 			 
//  Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
//  Computer, Inc. ("Apple") in consideration of your agreement to the
//  following terms, and your use, installation, modification or
//  redistribution of this Apple software constitutes acceptance of these
//  terms.  If you do not agree with these terms, please do not use,
//  install, modify or redistribute this Apple software.
//  
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Apple grants you a personal, non-exclusive
//  license, under Apple's copyrights in this original Apple software (the
//  "Apple Software"), to use, reproduce, modify and redistribute the Apple
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Apple Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software. 
//  Neither the name, trademarks, service marks or logos of Apple Computer,
//  Inc. may be used to endorse or promote products derived from the Apple
//  Software without specific prior written permission from Apple.  Except
//  as expressly stated in this notice, no other rights or licenses, express
//  or implied, are granted by Apple herein, including but not limited to
//  any patent rights that may be infringed by your derivative works or by
//  other works in which the Apple Software may be incorporated.
//  
//  The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
//  MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
//  THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
//  OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//  
//  IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
//  MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
//  AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
//  STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
// 
//  Copyright (c) 2008-2009, 2012 Apple Inc., All rights reserved.
//
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#import "OpenGLVBOQuad.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structures

//---------------------------------------------------------------------------

struct OpenGLVBOQuadData
{
	GLuint    name;			// buffer identifier
	GLuint    count;		// vertex count
	GLuint    size;			// size of vertices or texture coordinates
	GLsizei   stride;		// vbo stride
	GLuint    capacity;		// is vertex size + texture coordinate size
	GLenum    target;		// vbo target
	GLenum    usage;		// vbo usage
	GLenum    type;			// vbo type
	GLenum    mode;			// vbo mode
	GLfloat  *data;			// vbo data
	GLfloat   width;		// quad width
	GLfloat   height;		// quad height
};

typedef struct OpenGLVBOQuadData  OpenGLVBOQuadData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@implementation OpenGLVBOQuad

//---------------------------------------------------------------------------

- (void) initVBOQuad:(const NSSize *)theSize
{
	mpVBOQuad->count    = 4;
	mpVBOQuad->size     = 8 * sizeof(GLfloat);
	mpVBOQuad->capacity = 2 * mpVBOQuad->size;
	mpVBOQuad->target   = GL_ARRAY_BUFFER;
	mpVBOQuad->usage    = GL_STATIC_DRAW;
	mpVBOQuad->type     = GL_FLOAT;
	mpVBOQuad->mode     = GL_QUADS;
	mpVBOQuad->stride   = 0;
	mpVBOQuad->data     = NULL;
	mpVBOQuad->width    = theSize->width;
	mpVBOQuad->height   = theSize->height;
} // initVBOQuad

//---------------------------------------------------------------------------

- (void) newVBOQuad:(const GLfloat *)theVertices
		  texCoords:(const GLfloat *)theTexCoords
{
	glGenBuffers(1, &mpVBOQuad->name);
	
	if( mpVBOQuad->name )
	{
		glBindBuffer(mpVBOQuad->target,
					 mpVBOQuad->name);
		
		glBufferData(mpVBOQuad->target, mpVBOQuad->capacity, NULL, mpVBOQuad->usage);
		glBufferSubData(mpVBOQuad->target, 0, mpVBOQuad->size, theVertices);
		glBufferSubData(mpVBOQuad->target, mpVBOQuad->size, mpVBOQuad->size, theTexCoords);
		
		glBindBuffer(mpVBOQuad->target, 0);
	} // if
} // newVBOQuad

//---------------------------------------------------------------------------
//
// Initialize
//
//---------------------------------------------------------------------------

- (id) init
{
	self = [super init];
	
	if( self )
	{
		mpVBOQuad = (OpenGLVBOQuadDataRef)calloc(1,sizeof(OpenGLVBOQuadData));
		
		if( mpVBOQuad != NULL )
		{
			GLfloat data[8] = { 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };
			NSSize  size    = NSMakeSize( 0.0f, 0.0f );
			
			[self initVBOQuad:&size];
			
			[self newVBOQuad:data 
				   texCoords:data];			
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL VBO Quad - Failure Allocating Memory For Attributes!" );
			NSLog( @">>                          From the default initializer." );
		}  // else
	} // if
	
	return( self );
} // init

//---------------------------------------------------------------------------

- (id) initVBOQuadWithSize:(const NSSize *)theSize
{
	self = [super init];
	
	if( self )
	{
		mpVBOQuad = (OpenGLVBOQuadDataRef)calloc(1, sizeof(OpenGLVBOQuadData));
		
		if( mpVBOQuad != NULL )
		{
			if( theSize != NULL )
			{
				GLfloat vertices[8]  = { 0.0f, 0.0f, theSize->width, 0.0f, theSize->width, theSize->height, 0.0f, theSize->height };
				GLfloat texCoords[8] = { 0.0f, theSize->height, theSize->width, theSize->height, theSize->width, 0.0f, 0.0f, 0.0f };
				
				[self initVBOQuad:theSize];
				
				[self newVBOQuad:vertices 
					   texCoords:texCoords];		
			} // if
			else
			{
				GLfloat data[8] = { 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f };
				NSSize  size    = NSMakeSize( 0.0f, 0.0f );
				
				[self initVBOQuad:&size];
				
				[self newVBOQuad:data 
					   texCoords:data];			
			} // else
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL VBO Quad - Failure Allocating Memory For Attributes!" );
			NSLog( @">>                          From the designated initializer using size." );
		}  // else
	} // if
	
	return( self );
} // initVBOWithSize

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Delete VBO

//---------------------------------------------------------------------------

- (void) cleanUpVBOQuad
{
	if( mpVBOQuad != NULL )
	{
		if( mpVBOQuad->name )
		{
			glDeleteBuffers( 1, &mpVBOQuad->name );
		} // if
		
		free( mpVBOQuad );
		
		mpVBOQuad = NULL;
	} // if
} // cleanUpVBOQuad

//---------------------------------------------------------------------------

- (void) dealloc 
{
	[self cleanUpVBOQuad];

    [super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark VBO Update

//---------------------------------------------------------------------------

- (void) setFrame:(const NSRect *)theFrame
{
	if( theFrame != NULL )
	{
		mpVBOQuad->width  = theFrame->origin.x + theFrame->size.width;
		mpVBOQuad->height = theFrame->origin.y + theFrame->size.height;

		glBindBuffer(mpVBOQuad->target, 
					 mpVBOQuad->name);
		
		glBufferData(mpVBOQuad->target, 
					 mpVBOQuad->capacity, 
					 NULL,
					 mpVBOQuad->usage);
		
		mpVBOQuad->data = (GLfloat *)glMapBuffer(mpVBOQuad->target, 
												  GL_READ_WRITE);
		
		if( mpVBOQuad->data != NULL )
		{
			// Vertices
			
			mpVBOQuad->data[0] = theFrame->origin.x;
			mpVBOQuad->data[1] = theFrame->origin.y;
			mpVBOQuad->data[2] = theFrame->origin.x;
			mpVBOQuad->data[3] = mpVBOQuad->height;
			mpVBOQuad->data[4] = mpVBOQuad->width;
			mpVBOQuad->data[5] = mpVBOQuad->height,
			mpVBOQuad->data[6] = mpVBOQuad->width;
			mpVBOQuad->data[7] = theFrame->origin.y;

			// Texture coordinates
			
			mpVBOQuad->data[8]  = 0.0f;
			mpVBOQuad->data[9]  = 0.0f;
			mpVBOQuad->data[10] = 0.0f;
			mpVBOQuad->data[11] = theFrame->size.height;
			mpVBOQuad->data[12] = theFrame->size.width;
			mpVBOQuad->data[13] = theFrame->size.height,
			mpVBOQuad->data[14] = theFrame->size.width;
			mpVBOQuad->data[15] = 0.0f;

			glUnmapBuffer(mpVBOQuad->target);
		} // if
		
		glBindBuffer(mpVBOQuad->target, 0);
	} // if
} // setFrame

//---------------------------------------------------------------------------

- (void) setSize:(const NSSize *)theSize
{
	if( theSize != NULL )
	{
		GLfloat vertices[8]  = { 0.0f, 0.0f, theSize->width, 0.0f, theSize->width, theSize->height, 0.0f, theSize->height };
		GLfloat texCoords[8] = { 0.0f, theSize->height, theSize->width, theSize->height, theSize->width, 0.0f, 0.0f, 0.0f };

		mpVBOQuad->width  = theSize->width;
		mpVBOQuad->height = theSize->height;

		glBindBuffer(mpVBOQuad->target, 
					 mpVBOQuad->name);
		
		glBufferData(mpVBOQuad->target, 
					 mpVBOQuad->capacity, 
					 NULL, 
					 mpVBOQuad->usage);
		
		mpVBOQuad->data = (GLfloat *)glMapBuffer(mpVBOQuad->target, 
												  GL_READ_WRITE);
		
		if( mpVBOQuad->data != NULL )
		{
			// Vertices
			
			mpVBOQuad->data[0] = vertices[0];
			mpVBOQuad->data[1] = vertices[1];
			mpVBOQuad->data[2] = vertices[2];
			mpVBOQuad->data[3] = vertices[3];
			mpVBOQuad->data[4] = vertices[4];
			mpVBOQuad->data[5] = vertices[5],
			mpVBOQuad->data[6] = vertices[6];
			mpVBOQuad->data[7] = vertices[7];
			
			// Texture coordinates
			
			mpVBOQuad->data[8]  = texCoords[0];
			mpVBOQuad->data[9]  = texCoords[1];
			mpVBOQuad->data[10] = texCoords[2];
			mpVBOQuad->data[11] = texCoords[3];
			mpVBOQuad->data[12] = texCoords[4];
			mpVBOQuad->data[13] = texCoords[5],
			mpVBOQuad->data[14] = texCoords[6];
			mpVBOQuad->data[15] = texCoords[7];
			
			glUnmapBuffer(mpVBOQuad->target);
		} // if
		
		glBindBuffer(mpVBOQuad->target, 0);
	} // if
} // setSize

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark VBO Draw

//---------------------------------------------------------------------------
//
// Draw a quad using texture & vertex coordinates
//
//---------------------------------------------------------------------------

- (void) bind
{
	glBindBuffer(mpVBOQuad->target, mpVBOQuad->name);
	
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glTexCoordPointer(2, mpVBOQuad->type, mpVBOQuad->stride, BUFFER_OFFSET(mpVBOQuad->size));
	glVertexPointer(2, mpVBOQuad->type, mpVBOQuad->stride, BUFFER_OFFSET(0));
	
	glDrawArrays(mpVBOQuad->mode, 0, mpVBOQuad->count);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);

	glBindBuffer(mpVBOQuad->target, 0);
} // bind

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
