/*
     File: OpenGLViewCaptureBase.m
 Abstract: 
 Base utility toolkit for capturing a frame from a view.
 
  Version: 1.2
 
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

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#import "OpenGLRec709Shader.h"

#import "OpenGLViewTexture.h"
#import "OpenGLPBOPack.h"
#import "OpenGLVBOQuad.h"

#import "OpenGLTextureSourceTypes.h"
#import "OpenGLViewCaptureBase.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Function Pointers Definition

//---------------------------------------------------------------------------

typedef void (*OpenGLRenderFuncPtr)(OpenGLViewCaptureBaseDataRef pViewRecorderBase, OpenGLVBOQuad *pViewQuad);

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structures

//---------------------------------------------------------------------------

struct OpenGLViewCaptureBaseData
{
	GLuint                mpProgram;		// Shader object
	GLuint                mnName;			// Texture name
	GLenum                mnTarget;			// Texture target
	NSRect                m_Frame;          // Image frame
	GLvoid               *mpImage;			// Image pixels
	OpenGLViewTexture    *mpViewTexture;
	OpenGLVBOQuad        *mpViewQuad;
	OpenGLRec709Shader   *mpRec709;
    OpenGLRenderFuncPtr   glRender;
};

typedef struct OpenGLViewCaptureBaseData   OpenGLViewCaptureBaseData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Function Pointers Implementations

//---------------------------------------------------------------------------

static void glRenderOnly(OpenGLViewCaptureBaseDataRef pViewRecorderBase,
						 OpenGLVBOQuad *pViewQuad)
{
	// Enable the texture target
	
	glEnable( pViewRecorderBase->mnTarget );
	
	// Bind to the texture
	
	glBindTexture(pViewRecorderBase->mnTarget,
				  pViewRecorderBase->mnName);
	
	// Bind the texture to a quad
	
	[pViewQuad bind];
	
	// Unbind the texture target
	
	glBindTexture( pViewRecorderBase->mnTarget, 0 );
	
	// Disable the texture target
	
	glDisable( pViewRecorderBase->mnTarget );
} // glRenderOnly

//---------------------------------------------------------------------------

static void glRenderUsingRec709Shader(OpenGLViewCaptureBaseDataRef pViewRecorderBase,
									  OpenGLVBOQuad *pViewQuad)
{
	// Enable the texture target
	
	glEnable( pViewRecorderBase->mnTarget );
	
	// Enable the color correction shader
	
	glUseProgram( pViewRecorderBase->mpProgram );
	
	// Bind to the texture
	
	glBindTexture(pViewRecorderBase->mnTarget,
				  pViewRecorderBase->mnName);
	
	// Bind the texture to a quad
	
	[pViewQuad bind];
	
	// Unbind the texture target
	
	glBindTexture( pViewRecorderBase->mnTarget, 0 );
	
	// Disable the color correction shader
	
	glUseProgram(0);
	
	// Disable the texture target
	
	glDisable( pViewRecorderBase->mnTarget );
} // glRenderUsingRec709Shader

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@implementation OpenGLViewCaptureBase

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Initializations

//---------------------------------------------------------------------------

- (void) newOpenGLViewTexture
{
	NSRect bounds = NSMakeRect(0.0f,
							   0.0f,
							   mpViewCaptureBase->m_Frame.size.width,
							   mpViewCaptureBase->m_Frame.size.height);
	
	mpViewCaptureBase->mpViewTexture = [[OpenGLViewTexture alloc] initViewTextureWithBounds:&bounds
																					   hint:GL_STORAGE_CACHED_APPLE
																					 buffer:GL_FRONT];
	
	if( mpViewCaptureBase->mpViewTexture )
	{
		mpViewCaptureBase->mnName   = [mpViewCaptureBase->mpViewTexture name];
		mpViewCaptureBase->mnTarget = [mpViewCaptureBase->mpViewTexture target];
	} // if
	else
	{
		NSLog( @">> ERROR: OpenGL View Capture Base - Failure Instantiating a view texture object!" );
	} // else
} // newOpenGLViewTexture

//---------------------------------------------------------------------------

- (void) newOpenGLRec709Shader
{
	if( mpViewCaptureBase->mpRec709 == nil )
	{
		mpViewCaptureBase->mpRec709 = [[OpenGLRec709Shader alloc] initRec709ShaderWithBounds:&mpViewCaptureBase->m_Frame];
		
		if( mpViewCaptureBase->mpRec709 )
		{
			mpViewCaptureBase->mpProgram = [mpViewCaptureBase->mpRec709 programObject];
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL View Capture Base - Failure Instantiating Rec 709 Shader (color correction filter)!" );
		} // else
	} // if
} // newOpenGLRec709Shader

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Designated Initializer

//---------------------------------------------------------------------------

- (id) initViewCaptureBaseWithFrame:(const NSRect *)theFrame
{
	self = [super initFBOWithSize:&theFrame->size];
	
	if( self )
	{
		mpViewCaptureBase = (OpenGLViewCaptureBaseDataRef)calloc(1, sizeof(OpenGLViewCaptureBaseData));
		
		if( mpViewCaptureBase != NULL )
		{
			mpViewCaptureBase->mpViewQuad = [[OpenGLVBOQuad alloc] initVBOQuadWithSize:&theFrame->size];
			
			mpViewCaptureBase->glRender = &glRenderOnly;
			
			mpViewCaptureBase->m_Frame = *theFrame;
			
			[self newOpenGLViewTexture];
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL View Capture Base - Failure Allocating Memory For Attributes!" );
		} // else
	} // if
	
	return( self );
} // initViewRecorderBaseWithFrame

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Dealloc all the Resources

//---------------------------------------------------------------------------

- (void) cleanUpCaptureBase
{
	if( mpViewCaptureBase != NULL )
	{
		if( mpViewCaptureBase->mpViewTexture )
		{
			[mpViewCaptureBase->mpViewTexture release];
			
			mpViewCaptureBase->mpViewTexture = nil;
		} // if
		
		if ( mpViewCaptureBase->mpViewQuad )
		{
			[mpViewCaptureBase->mpViewQuad release];
			
			mpViewCaptureBase->mpViewQuad = nil;
		} // if
		
		if( mpViewCaptureBase->mpRec709 )
		{
			[mpViewCaptureBase->mpRec709 release];
			
			mpViewCaptureBase->mpRec709 = nil;
		} // if
		
		free( mpViewCaptureBase );
		
		mpViewCaptureBase = NULL;
	} // if
} // cleanUpCaptureBase

//---------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpCaptureBase];
	
    [super dealloc];
} // dealloc

//---------------------------------------------------------------------------

- (void) setBounds:(const NSRect *)theBounds
{
	if(		( theBounds->size.width  != mpViewCaptureBase->m_Frame.size.width  )
	   ||	( theBounds->size.height != mpViewCaptureBase->m_Frame.size.height ) )
	{
		// FBO (its texture and readback PBO) size changed
		
		[self setSize:&theBounds->size];
		
		// VBO size changed
		
		[mpViewCaptureBase->mpViewQuad setSize:&theBounds->size];
		
		// Setup the bounds for the new texture
		
		NSRect textureBounds = NSMakeRect(0.0f,
										  0.0f,
										  theBounds->size.width,
										  theBounds->size.height);
		
		// Texture (used for view capture) bounds changed
		
		[mpViewCaptureBase->mpViewTexture setBounds:&textureBounds];
		
		// If texture bounds change, so will its ID
		
		mpViewCaptureBase->mnName = [mpViewCaptureBase->mpViewTexture name];
		
		// Set the new frame size
		
		mpViewCaptureBase->m_Frame = *theBounds;
		
	} // if
} // setBounds

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Frame Capture Utilities

//---------------------------------------------------------------------------

- (void) disableColorCorrection
{
	mpViewCaptureBase->glRender = &glRenderOnly;
} // disableColorCorrection

//---------------------------------------------------------------------------

- (void) enableColorCorrection
{
	[self newOpenGLRec709Shader];
	
	mpViewCaptureBase->glRender = &glRenderUsingRec709Shader;
} // enableColorCorrection

//---------------------------------------------------------------------------

- (void) render
{
	mpViewCaptureBase->glRender( mpViewCaptureBase, mpViewCaptureBase->mpViewQuad );
} // render

//---------------------------------------------------------------------------
//
// Readback and get the pixels from the fbo.  One can use the pixels from
// here to generate a QuickTime movie frame.
//
//---------------------------------------------------------------------------

- (GLvoid *) readback
{
	// Get a texture from the back buffer
	
	[mpViewCaptureBase->mpViewTexture readback];
	
	// Update the fbo with the new texture using our render method
	// and with/without the rec 709 color correction unit (filter).
	
	[self update];
	
	// Readback and get the pixels from the fbo.  One can use
	// the pixels from here to generate a QuickTime movie frame.
	
	mpViewCaptureBase->mpImage = [super readback];
	
	return( mpViewCaptureBase->mpImage );
} // readback

//---------------------------------------------------------------------------

- (GLvoid) writeToBuffer:(GLvoid *)theBuffer
{
	// Get a texture from the read buffer
	
	[mpViewCaptureBase->mpViewTexture readback];
	
	// Update the fbo with the new texture using our render method
	// and with/without the rec 709 color correction unit (filter).
	
	[self update];
	
	// Readback and copy the pixels from the fbo.  One can use
	// the pixels from here to generate a QuickTime movie frame.
	
	[self copyToBuffer:theBuffer];
} // captureFrameCopy

//---------------------------------------------------------------------------

- (GLvoid) writeToPixelBuffer:(CVPixelBufferRef)thePixelBuffer
{
	// Get a texture from the back buffer
	
	[mpViewCaptureBase->mpViewTexture readback];
	
	// Update the fbo with the new texture using our render method
	// and with/without the rec 709 color correction unit (filter).
	
	[self update];
	
	// Readback and copy the pixels from the fbo.  One can use
	// the pixels from here to generate a QuickTime movie frame.
	
	[self copyToPixelBuffer:thePixelBuffer];
} // writeToPixelBuffer

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
