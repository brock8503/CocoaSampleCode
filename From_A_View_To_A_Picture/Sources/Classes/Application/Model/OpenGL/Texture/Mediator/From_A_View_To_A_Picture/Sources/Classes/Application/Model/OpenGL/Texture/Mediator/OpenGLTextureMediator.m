//---------------------------------------------------------------------------
//
//	File: OpenGLTextureMediator.m
//
//  Abstract: Utility toolkit for managing a texture range or pbo,
//            with a vbo
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

#import "OpenGLTextureRange.h"
#import "OpenGLPBOUnpack.h"
#import "OpenGLVBOQuad.h"

#import "OpenGLTextureMediator.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Enumerated Types

//---------------------------------------------------------------------------

enum OpenGLTextureMediatorUsage
{
	kOpenGLTextureMediatorUseTexture = 0,
	kOpenGLTextureMediatorUsePBO
};

typedef enum OpenGLTextureMediatorUsage OpenGLTextureMediatorUsage;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Function Pointers Definition

//---------------------------------------------------------------------------

typedef void (*OpenGLTexImage2DUpdateFuncPtr)(const GLvoid *theImage, id theObject);

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structure

//---------------------------------------------------------------------------

struct OpenGLTextureMediatorData
{
	NSRect      m_Frame;
	NSUInteger  mnUsage;
	GLenum      mnType;
	GLenum      mnTarget;
	GLuint      mnName;
	id          m_Object;
	
	OpenGLTextureRange  *mpTextureRange;
	OpenGLPBOUnpack     *mpPBOUnpack;
	OpenGLVBOQuad       *mpVBOQuad;
	
	OpenGLTexImage2DUpdateFuncPtr  glTexImage2DUpdate;
};

typedef struct OpenGLTextureMediatorData  OpenGLTextureMediatorData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Function Pointers Implementations

//---------------------------------------------------------------------------

static void glUpdatePBO(const GLvoid *theImage,
						id theObject)
{
	OpenGLPBOUnpack *pbo = (OpenGLPBOUnpack *)theObject;
	
	[pbo update:theImage];
} // glUpdatePBO

//---------------------------------------------------------------------------

static void glUpdateTextureRange(const GLvoid *theImage,
								 id theObject)
{
	OpenGLTextureRange *pTextureRange = (OpenGLTextureRange *)theObject;
	
	[pTextureRange update:theImage];
} // glUpdateTextureRange

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------

@implementation OpenGLTextureMediator

//---------------------------------------------------------------------------
//
// Make sure client goes through designated initializer
//
//---------------------------------------------------------------------------

- (id) init
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
} // init

//---------------------------------------------------------------------------

- (void) initTextureUsage:(const OpenGLTextureUsage)theTextureUsage
{
	switch( theTextureUsage )
	{
		case kOpenGLTextureUsePBOStreamDraw:
			
			mpTextureMediator->mnType  = GL_STREAM_DRAW;
			mpTextureMediator->mnUsage = kOpenGLTextureMediatorUsePBO;
			
			mpTextureMediator->glTexImage2DUpdate = &glUpdatePBO;
			
			break;
			
		case kOpenGLTextureUsePBOStaticDraw:
			
			mpTextureMediator->mnType  = GL_STATIC_DRAW;
			mpTextureMediator->mnUsage = kOpenGLTextureMediatorUsePBO;
			
			mpTextureMediator->glTexImage2DUpdate = &glUpdatePBO;
			
			break;
			
		case kOpenGLTextureUsePBODynamicDraw:
			
			mpTextureMediator->mnType  = GL_DYNAMIC_DRAW;
			mpTextureMediator->mnUsage = kOpenGLTextureMediatorUsePBO;
			
			mpTextureMediator->glTexImage2DUpdate = &glUpdatePBO;
			
			break;
			
		case kOpenGLTextureUseAppleSharedStorage:
			
			mpTextureMediator->mnType  = GL_STORAGE_SHARED_APPLE;
			mpTextureMediator->mnUsage = kOpenGLTextureMediatorUseTexture;
			
			mpTextureMediator->glTexImage2DUpdate = &glUpdateTextureRange;
			
			break;
			
		case kOpenGLTextureUseAppleCachedStorage:
		default:
			
			mpTextureMediator->mnType  = GL_STORAGE_CACHED_APPLE;
			mpTextureMediator->mnUsage = kOpenGLTextureMediatorUseTexture;
			
			mpTextureMediator->glTexImage2DUpdate = &glUpdateTextureRange;
			
			break;
	} // switch
} // setUsage

//---------------------------------------------------------------------------
//
// Initialize
//
//---------------------------------------------------------------------------

- (id) initTextureMediator:(const OpenGLTextureUsage)theTextureUsage
{
	self = [super init];
	
	if( self )
	{
		mpTextureMediator = (OpenGLTextureMediatorDataRef)calloc(1, sizeof(OpenGLTextureMediatorData));
		
		if( mpTextureMediator != NULL  )
		{
			[self initTextureUsage:theTextureUsage];
			
			mpTextureMediator->mpVBOQuad = [OpenGLVBOQuad new];
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL Texture Controller - Failure Allocating Memory For Attributes!" );
		}  // else
	} // if
	
	return  self;
} // initTextureMediator

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Delete Resources

//---------------------------------------------------------------------------

- (void) dealloc
{
	if( mpTextureMediator != NULL )
	{
		if( mpTextureMediator->mpTextureRange )
		{
			[mpTextureMediator->mpTextureRange release];
			
			mpTextureMediator->mpTextureRange = nil;
		} // if
		
		if( mpTextureMediator->mpPBOUnpack )
		{
			[mpTextureMediator->mpPBOUnpack release];
			
			mpTextureMediator->mpPBOUnpack = nil;
		} // if
		
		if( mpTextureMediator->mpVBOQuad )
		{
			[mpTextureMediator->mpVBOQuad release];
			
			mpTextureMediator->mpVBOQuad = nil;
		} // if
		
		free( mpTextureMediator );
		
		mpTextureMediator = NULL;
	} // if
	
    [super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Controller OpenGLTexImage2DUpdateFuncPtr

//---------------------------------------------------------------------------

- (void) update:(const GLvoid *)theImage
		  frame:(const NSRect *)theFrame
{
	BOOL textureSizeChanged =
		( theFrame->size.width  != mpTextureMediator->m_Frame.size.width  )
	||	( theFrame->size.height != mpTextureMediator->m_Frame.size.height );
	
	BOOL textureOriginChanged =
		( theFrame->origin.x != mpTextureMediator->m_Frame.origin.x )
	||	( theFrame->origin.y != mpTextureMediator->m_Frame.origin.y );
	
	if( textureSizeChanged )
	{
		if( mpTextureMediator->mnUsage == kOpenGLTextureMediatorUseTexture )
		{
			NSRect bounds = NSMakeRect(0.0f,
									   0.0f,
									   theFrame->size.width,
									   theFrame->size.height);
			
			OpenGLTextureRange *pTextureRange = [[OpenGLTextureRange alloc] initTextureRangeWithBounds:&bounds
																								  hint:mpTextureMediator->mnType];
			if( pTextureRange )
			{
				[mpTextureMediator->mpTextureRange release];
				
				mpTextureMediator->mpTextureRange = pTextureRange;
				
				mpTextureMediator->m_Object = mpTextureMediator->mpTextureRange;
				mpTextureMediator->mnTarget = [mpTextureMediator->mpTextureRange target];
				mpTextureMediator->mnName   = [mpTextureMediator->mpTextureRange name];
			} // if
		} // if
		else
		{
			OpenGLPBOUnpack *pPBOUnpack = [[OpenGLPBOUnpack alloc] initPBOUnpackWithSize:&theFrame->size
                                                                                   usage:mpTextureMediator->mnType];
			
			if( pPBOUnpack )
			{
				[mpTextureMediator->mpPBOUnpack release];
				
				mpTextureMediator->mpPBOUnpack = pPBOUnpack;
				
				mpTextureMediator->m_Object = mpTextureMediator->mpPBOUnpack;
				mpTextureMediator->mnTarget = [mpTextureMediator->mpPBOUnpack target];
				mpTextureMediator->mnName   = [mpTextureMediator->mpPBOUnpack name];
			} // if
		} // else
	} // if
	
	mpTextureMediator->glTexImage2DUpdate(theImage, mpTextureMediator->m_Object);
	
	if( textureSizeChanged || textureOriginChanged )
	{
		[mpTextureMediator->mpVBOQuad setFrame:theFrame];
	} // if
	
	mpTextureMediator->m_Frame = *theFrame;
} // updateTexture

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Controller Draw

//---------------------------------------------------------------------------
//
// Activate the VBO and draw a quad with a texture
//
//---------------------------------------------------------------------------

- (void) draw
{
	glEnable(mpTextureMediator->mnTarget);
	{
		glBindTexture(mpTextureMediator->mnTarget,
					  mpTextureMediator->mnName);
		
		[mpTextureMediator->mpVBOQuad bind];
	}
	glDisable(mpTextureMediator->mnTarget);
} // draw

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
