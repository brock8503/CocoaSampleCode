//---------------------------------------------------------------------------
//
//	File: OpenGLViewPixelFormat.m
//
//  Abstract: Utility class for setting pixel formats
// 			 
//  Disclaimer: IMPORTANT:  This Apple software is supplied to you by
//  Inc. ("Apple") in consideration of your agreement to the following terms, 
//  and your use, installation, modification or redistribution of this Apple 
//  software constitutes acceptance of these terms.  If you do not agree with 
//  these terms, please do not use, install, modify or redistribute this 
//  Apple software.
//  
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Apple grants you a personal, non-exclusive
//  license, under Apple's copyrights in this original Apple software (the
//  "Apple Software"), to use, reproduce, modify and redistribute the Apple
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Apple Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software. 
//  Neither the name, trademarks, service marks or logos of Apple Inc. may 
//  be used to endorse or promote products derived from the Apple Software 
//  without specific prior written permission from Apple.  Except as 
//  expressly stated in this notice, no other rights or licenses, express
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
//  Copyright (c) 2008 Apple Inc., All rights reserved.
//
//---------------------------------------------------------------------------

//------------------------------------------------------------------------

#import "OpenGLViewPixelFormat.h"

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Check for extensions

//------------------------------------------------------------------------

static inline BOOL CheckForExtension(const char *extensionName, 
									 const GLubyte *extensions)
{
	BOOL  extensionIsAvailable = (BOOL)gluCheckExtension((GLubyte *)extensionName, 
														 extensions);
	
	return extensionIsAvailable;
} // CheckForExtension

//------------------------------------------------------------------------

static inline void LogExtensionAvailable(const BOOL extensionAvailable, 
										 const char *extensionName)
{
	if( !extensionAvailable )
	{
		NSLog(@">> WARNING: OpenGL View Pixel Format - \"%s\" extension is not available!\n", extensionName);
	} // if
} // CheckForExtensions

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark For Software fallback

//------------------------------------------------------------------------
//
// We need to return NSOpenGLPixelFormatAttribute array with proper 
// attributes set for forced software rendering. For this reason we'll 
// try a simple memory allocation routine for resizing, and preserving
// ther old values.
//
//------------------------------------------------------------------------

static void PixelFormatAttributesForForcedSoftwareRendering(const NSInteger theSourcePixelFormatAttributesCount,
															NSOpenGLPixelFormatAttribute **theSourcePixelFormatAttributes )
{
	
	NSInteger pixelFormatAttributesCount     = theSourcePixelFormatAttributesCount + 2;
	NSInteger pixelFormatAttributesSize      = pixelFormatAttributesCount * sizeof(NSOpenGLPixelFormatAttribute);
	NSInteger pixelFormatAttributesLastIndex = theSourcePixelFormatAttributesCount - 1; // Start with the old
	
	NSOpenGLPixelFormatAttribute *pixelFormatAttributes = (NSOpenGLPixelFormatAttribute *)malloc( pixelFormatAttributesSize );
	
	if ( pixelFormatAttributes != NULL )
	{
		// The last index of NSOpenGLPixelFormatAttribute array
		
		NSInteger pixelFormatAttributesIndex;
		
		// Copy the old values (minus the last entry, becuase we know that one is zero)
		
		for(pixelFormatAttributesIndex = 0;
			pixelFormatAttributesIndex < pixelFormatAttributesLastIndex;
			pixelFormatAttributesIndex++ )
		{
			pixelFormatAttributes[pixelFormatAttributesIndex] 
			= *theSourcePixelFormatAttributes[pixelFormatAttributesIndex];
		} // for
		
		// Update the last index value
		
		pixelFormatAttributesLastIndex = pixelFormatAttributesCount - 1;
		
		// This will designate the end of NSOpenGLPixelFormatAttribute array, 
		// akin to a null terminated array
		
		pixelFormatAttributes[pixelFormatAttributesLastIndex] = 0;
		
		// We don't need the old pixel attributes
		
		free( *theSourcePixelFormatAttributes );
		
		// Now we point to the new pixel attributes
		
		*theSourcePixelFormatAttributes = pixelFormatAttributes;
		
		// For software rendering we want these to be the last two elements in
		// our NSOpenGLPixelFormatAttribute array
		
		pixelFormatAttributes[pixelFormatAttributesLastIndex - 2] = NSOpenGLPFARendererID;
		pixelFormatAttributes[pixelFormatAttributesLastIndex - 1] = kCGLRendererGenericFloatID;
	} // if
} // UpdateHardwareAttributesForForcedSoftwareRendering

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -

//------------------------------------------------------------------------

@implementation OpenGLViewPixelFormat

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Supported Features

//------------------------------------------------------------------------

- (NSOpenGLPixelFormatAttribute *) pixelFormatAttributes:(NSArray *)thePixelAttributes
												   count:(NSInteger *)thePixelFormatAttributesCount;
{
	NSNumber  *pixelAttribute;
	GLuint     pixelAttributeCount = [thePixelAttributes count] + 1;
	GLuint     pixelAttributeSize  = pixelAttributeCount * sizeof( NSOpenGLPixelFormatAttribute );

	GLuint i = 0;
	
	NSOpenGLPixelFormatAttribute *pixelFormatAttributes = (NSOpenGLPixelFormatAttribute *)malloc( pixelAttributeSize );
	
	if( pixelFormatAttributes != NULL )
	{
		for (pixelAttribute in thePixelAttributes) 
		{
			pixelFormatAttributes[i] = [pixelAttribute integerValue];
			
			i++;
		} // for
		
		// Last element set to zero, designating null termination
		
		pixelFormatAttributes[i] = 0;
		
		*thePixelFormatAttributesCount = pixelAttributeCount;
	} // if
	
	return pixelFormatAttributes;
} // pixelFormatAttributes

//------------------------------------------------------------------------

- (void) checkForShaders:(NSOpenGLPixelFormatAttribute **)thePixelFormatAttributes
				   count:(const NSInteger)thePixelFormatAttributesCount
{
	const GLubyte *extensions = glGetString(GL_EXTENSIONS);
	
	BOOL shaderObjectAvailable      = CheckForExtension("GL_ARB_shader_objects", extensions);
	BOOL shaderLanguage100Available = CheckForExtension("GL_ARB_shading_language_100", extensions);
	BOOL vertexShaderAvailable      = CheckForExtension("GL_ARB_vertex_shader", extensions);
	BOOL fragmentShaderAvailable    = CheckForExtension("GL_ARB_fragment_shader", extensions);
	
	BOOL hardwareRendering =		shaderObjectAvailable 
								||	shaderLanguage100Available 
								||	vertexShaderAvailable 
								||	fragmentShaderAvailable;
	
	// Force software rendering, so fragment shaders will execute
	
	if( !hardwareRendering )
	{
		LogExtensionAvailable(shaderObjectAvailable, "GL_ARB_shader_objects");
		LogExtensionAvailable(shaderLanguage100Available, "GL_ARB_shading_language_100");
		LogExtensionAvailable(vertexShaderAvailable, "GL_ARB_vertex_shader");
		LogExtensionAvailable(fragmentShaderAvailable, "GL_ARB_fragment_shader");
		
		PixelFormatAttributesForForcedSoftwareRendering(thePixelFormatAttributesCount,
														thePixelFormatAttributes );
	} // if
} // checkForShaders

//------------------------------------------------------------------------
//
// Inform OpenGL that the geometry is entirely within the view volume 
// and that view-volume clipping is unnecessary. Normal clipping can be 
// resumed by setting this hint to GL_DONT_CARE. When clipping is 
// disabled with this hint, results are undefined if geometry actually 
// falls outside the view volume.
//
//------------------------------------------------------------------------

- (void) checkForClipVolumeHint:(NSOpenGLPixelFormatAttribute *)thePixelAttributes
{
	const GLubyte *extensions = glGetString(GL_EXTENSIONS);
	
	BOOL  clipVolumeHintExtAvailable = CheckForExtension("GL_EXT_clip_volume_hint", 
														 extensions);
	
	if(  clipVolumeHintExtAvailable )
	{
		glHint(GL_CLIP_VOLUME_CLIPPING_HINT_EXT,GL_FASTEST);
	} // if
} // checkForClipVolumeHint

//------------------------------------------------------------------------
//
// Create a pre-flight context to check for GLSL hardware support
//
//------------------------------------------------------------------------

- (NSOpenGLPixelFormatAttribute *) checkForGLSLHardwareSupport:(NSArray *)thePixelAttributes
{
	NSInteger  pixelFormatAttributesCount = 0;
	
	NSOpenGLPixelFormatAttribute *pixelFormatAttributes = [self pixelFormatAttributes:thePixelAttributes 
																				count:&pixelFormatAttributesCount];
	
	if( pixelFormatAttributes )
	{
		NSOpenGLPixelFormat  *preflightPixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes];
		
		if( preflightPixelFormat )
		{
			NSOpenGLContext *preflightContext = [[NSOpenGLContext alloc] initWithFormat:preflightPixelFormat 
																		   shareContext:nil];
			
			if( preflightContext )
			{
				[preflightContext makeCurrentContext];
				
				[self checkForShaders:&pixelFormatAttributes 
								count:pixelFormatAttributesCount];
				
				[self checkForClipVolumeHint:pixelFormatAttributes];
				
				[preflightContext release];
			} // if
			
			[preflightPixelFormat release];
		} // if
	} // if
	
	return pixelFormatAttributes;
} // checkForGLSLHardwareSupport

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Designated Initializers

//------------------------------------------------------------------------

- (id) initWithPixelAttributes:(NSArray *)thePixelAttributes
{
	self = [super init];
	
	if( self )
	{
		NSOpenGLPixelFormatAttribute *pixelFormatAttributes	= NULL;	
		
		if( thePixelAttributes )
		{
			pixelFormatAttributes = [self checkForGLSLHardwareSupport:thePixelAttributes];
		} // else
		else
		{
			NSArray *defaultPixelAttributes = [NSArray arrayWithObjects:
											   [NSNumber numberWithInt:NSOpenGLPFAAccelerated],
											   [NSNumber numberWithInt:NSOpenGLPFADoubleBuffer],
											   [NSNumber numberWithInt:NSOpenGLPFAColorSize],
											   [NSNumber numberWithInt:24],
											   [NSNumber numberWithInt:NSOpenGLPFAAlphaSize],
											   [NSNumber numberWithInt:8],
											   [NSNumber numberWithInt:NSOpenGLPFADepthSize],
											   [NSNumber numberWithInt:24],
											   nil];
			
			pixelFormatAttributes = [self checkForGLSLHardwareSupport:defaultPixelAttributes];
		} // if
		
		if( pixelFormatAttributes != NULL )
		{
			pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes];
			
			free( pixelFormatAttributes );
			
			pixelFormatAttributes = NULL;
		} // if
	} // if
	
	return self;
} // initWithPixelAttributes

//------------------------------------------------------------------------

- (id) initWithFullScreenPixelAttributes:(NSArray *)thePixelAttributes
{
	self = [super init];
	
	if( self )
	{
		NSOpenGLPixelFormatAttribute *pixelFormatAttributes	= NULL;	
		
		if( thePixelAttributes )
		{
			pixelFormatAttributes = [self checkForGLSLHardwareSupport:thePixelAttributes];
		} // else
		else
		{
			CGOpenGLDisplayMask displayMask = CGDisplayIDToOpenGLDisplayMask(kCGDirectMainDisplay);

			NSArray *defaultPixelAttributes = [NSArray arrayWithObjects:
											   [NSNumber numberWithInt:NSOpenGLPFAFullScreen],
											   [NSNumber numberWithInt:NSOpenGLPFAScreenMask],
											   [NSNumber numberWithInt:displayMask],
											   [NSNumber numberWithInt:NSOpenGLPFADoubleBuffer],
											   [NSNumber numberWithInt:NSOpenGLPFANoRecovery],
											   [NSNumber numberWithInt:NSOpenGLPFAColorSize],
											   [NSNumber numberWithInt:24],
											   [NSNumber numberWithInt:NSOpenGLPFAAlphaSize],
											   [NSNumber numberWithInt:8],
											   [NSNumber numberWithInt:NSOpenGLPFADepthSize],
											   [NSNumber numberWithInt:16],
											   nil];
			
			pixelFormatAttributes = [self checkForGLSLHardwareSupport:defaultPixelAttributes];
		} // if
		
		if( pixelFormatAttributes != NULL )
		{
			pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes];
			
			free( pixelFormatAttributes );
			
			pixelFormatAttributes = NULL;
		} // if
	} // if
	
	return self;
} // initWithFullScreenPixelAttributes

//------------------------------------------------------------------------

+ (id) withPixelAttributes:(NSArray *)thePixelAttributes
{
	return( [[[OpenGLViewPixelFormat allocWithZone:[self zone]] 
			  initWithPixelAttributes:thePixelAttributes] autorelease] );
} // withPixelAttributes

//------------------------------------------------------------------------

+ (id) withFullScreenPixelAttributes:(NSArray *)thePixelAttributes
{
	return( [[[OpenGLViewPixelFormat allocWithZone:[self zone]] 
			  initWithFullScreenPixelAttributes:thePixelAttributes] autorelease] );
} // withFullScreenPixelAttributes

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Deallocating Resources

//------------------------------------------------------------------------

- (void) dealloc
{
	if( pixelFormat )
	{
		[pixelFormat release];
		
		pixelFormat = nil;
	} //if
	
	// Dealloc the superclass
	
	[super dealloc];
} // dealloc

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Accessors

//------------------------------------------------------------------------

- (NSOpenGLPixelFormat *) pixelFormat
{
	return  pixelFormat;
} // pixelFormat

//------------------------------------------------------------------------

@end

//------------------------------------------------------------------------

//------------------------------------------------------------------------

