//---------------------------------------------------------------------------
//
// File: OpenGLTextBase.m
//
// Abstract: Utility toolkit to render anti-aliased system fonts as
//           textures.
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
// Copyright ( C ) 2003-2009, 2012 Apple Inc. All Rights Reserved.
//
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#import "CGBitmap.h"

#import "OpenGLTextBase.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structure

//---------------------------------------------------------------------------

struct OpenGLTextBox
{
	NSPoint   origin;
	NSPoint   coordinate;
	NSPoint   topLeft;
	NSPoint   topRight;
	NSPoint   bottomRight;
	NSColor  *color;			// default transparent or none
};

typedef struct OpenGLTextBox  OpenGLTextBox;

//---------------------------------------------------------------------------

struct OpenGLTextBorder
{
	BOOL      isStatic;			// default is NO
	BOOL      hasBorder;		// flag is set depending on the designated initializer
	CGFloat   cornerRadius;		// if 0 just a rectangle. Defaults to 4.0f
	CGFloat   lineWidth;		// Border line width
	CGFloat   clampedRadius;	// Border rounded radius
	NSSize	  margins;			// offset or frame size, default is 4 width 2 height
	NSRect	  frame;			// offset or frame size, default is 4 width 2 height
	NSColor  *color;			// default transparent or none
};

typedef struct OpenGLTextBorder  OpenGLTextBorder;

//---------------------------------------------------------------------------

struct OpenGLTextImage
{
	GLvoid  *data;	// the texture image
	NSSize   size;	// the texture width & height
};

typedef struct OpenGLTextImage  OpenGLTextImage;

//---------------------------------------------------------------------------

struct OpenGLTextRep
{
	BOOL                  antialias;	// Default is YES
	CGBitmapRef           bitmap;		// Bitmap image of a font
	CGContextRef          context;		// Bitmap drawing context of a font
	CFRange               range;		// Text frame setter
	NSAttributedString   *string;		// string representing texture
	NSColor              *color;		// default is opaque white
};

typedef struct OpenGLTextRep  OpenGLTextRep;

//---------------------------------------------------------------------------

struct OpenGLTextBounds
{
	NSRect   rect;			// OpenGL view bounds
	GLfloat  scale[3];		// Scaling factor
	GLfloat  translate[3];	// translation factor
};

typedef struct OpenGLTextBounds  OpenGLTextBounds;

//---------------------------------------------------------------------------

struct OpenGLTextBridge
{
	BOOL                    update;		// View or texture needs an update?
	OpenGLTextureUsage		usage;		// Using PBOs or texture range
	OpenGLTextureMediator  *mediator;	// Texture controller
};

typedef struct OpenGLTextBridge  OpenGLTextBridge;

//---------------------------------------------------------------------------

struct OpenGLTextBaseData
{
	OpenGLTextBounds  bounds;	// Text view bounds
	OpenGLTextBorder  border;	// Tex border
	OpenGLTextBox     box;		// Text box
	OpenGLTextImage   image;	// Text Bitmap
	OpenGLTextRep     rep;		// Text representation
	OpenGLTextBridge  bridge;	// Texture representration
};

typedef struct OpenGLTextBaseData  OpenGLTextBaseData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark OpenGLTextBase

//---------------------------------------------------------------------------
//
// OpenGLTextBase
//
//---------------------------------------------------------------------------

@implementation OpenGLTextBase

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Initializers

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

- (void) initTextBridge
{
	mpTextBase->bridge.usage  = GL_STORAGE_CACHED_APPLE;
	mpTextBase->bridge.update = YES;
} // initTextBridge

//---------------------------------------------------------------------------

- (void) initTextBounds:(const NSRect *)theBounds
{
	if( theBounds != NULL )
	{
		mpTextBase->bounds.rect = *theBounds;
	} // if
	else
	{
		mpTextBase->bounds.rect = NSMakeRect(0.0, 0.0, 512.0, 512.0);
	} // else
} // initTextBounds

//---------------------------------------------------------------------------

- (void) initTextRep:(NSAttributedString *)theAttrString
			   color:(NSColor *)theTextColor
{
	mpTextBase->rep.antialias = YES;
	
	if( theAttrString )
	{
		mpTextBase->rep.string = [theAttrString retain];
	} // if
	
	if( theTextColor )
	{
		mpTextBase->rep.color = [theTextColor retain];
	} // if
	else
	{
		mpTextBase->rep.color = [[NSColor whiteColor] retain];
	} // else
} // initTextRep

//---------------------------------------------------------------------------

- (void) initTextBorder:(NSColor *)theBorderColor
{
	mpTextBase->border.margins.width  = 5.0f;
	mpTextBase->border.margins.height = 2.0f;
	mpTextBase->border.cornerRadius   = 4.0f;
	mpTextBase->border.lineWidth      = 2.0f;
	
	if( theBorderColor )
	{
		mpTextBase->border.color     = [theBorderColor retain];
		mpTextBase->border.hasBorder = YES;
	} // if
	else
	{
		mpTextBase->border.color = [[NSColor blackColor] retain];
	} // else
} // initTextBorder

//---------------------------------------------------------------------------

- (void) initTextBox:(NSColor *)theBoxColor
{
	if( theBoxColor )
	{
		mpTextBase->box.color = [theBoxColor retain];
	} // if
	else
	{
		mpTextBase->box.color = [[NSColor blackColor] retain];
	} // else
} // initTextBox

//---------------------------------------------------------------------------
//
// Designated initializers
//
//---------------------------------------------------------------------------

- (id) initWithAttributedString:(NSAttributedString *)theAttrString
					stringColor:(NSColor *)theTextColor
					   boxColor:(NSColor *)theBoxColor
					borderColor:(NSColor *)theBorderColor
						 bounds:(const NSRect *)theBounds
{
	self = [super init];
	
	if( self )
	{
		mpTextBase = (OpenGLTextBaseDataRef)calloc(1, sizeof(OpenGLTextBaseData));
		
		if( mpTextBase != NULL )
		{
			[self initTextBridge];
			[self initTextBounds:theBounds];
			[self initTextBorder:theBorderColor];
			[self initTextBox:theBoxColor];
			[self initTextRep:theAttrString
						color:theTextColor];
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL Text Base - Failure Allocating Memory For Data!" );
		} // else
	} // if
	
	return( self );
} // initWithAttributedString

//---------------------------------------------------------------------------

- (id) initWithString:(NSString *)theString
		   attributes:(NSDictionary *)theAttribs
		  stringColor:(NSColor *)theTextColor
			 boxColor:(NSColor *)theBoxColor
		  borderColor:(NSColor *)theBorderColor
			   bounds:(const NSRect *)theBounds
{
	return( [self initWithAttributedString:[[[NSAttributedString alloc] initWithString:theString
																			attributes:theAttribs] autorelease]
							   stringColor:theTextColor
								  boxColor:theBoxColor
							   borderColor:theBorderColor
									bounds:theBounds] );
} // initWithString

//---------------------------------------------------------------------------
//
// Designated initializer for an attributed string without borders
//
//---------------------------------------------------------------------------

- (id) initWithAttributedString:(NSAttributedString *)theAttrSting
						 bounds:(const NSRect *)theBounds
{
	return( [self initWithAttributedString:theAttrSting
							   stringColor:nil
								  boxColor:nil
							   borderColor:nil
									bounds:theBounds] );
} // initWithAttributedString

//---------------------------------------------------------------------------
//
// Designated initializer for a string without borders
//
//---------------------------------------------------------------------------

- (id) initWithString:(NSString *)theString
		   attributes:(NSDictionary *)theAttribs
			   bounds:(const NSRect *)theBounds
{
	return( [self initWithAttributedString:[[[NSAttributedString alloc] initWithString:theString
																			attributes:theAttribs] autorelease]
							   stringColor:nil
								  boxColor:nil
							   borderColor:nil
									bounds:theBounds] );
} // initWithString

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Dealloc

//---------------------------------------------------------------------------

- (void) cleanUpTextBase
{
	if( mpTextBase != NULL )
	{
		if( mpTextBase->bridge.mediator )
		{
			[mpTextBase->bridge.mediator release];
		} // if
		
		if( mpTextBase->rep.color )
		{
			[mpTextBase->rep.color release];
		} // if
		
		if( mpTextBase->box.color )
		{
			[mpTextBase->box.color release];
		} // if
		
		if( mpTextBase->border.color )
		{
			[mpTextBase->border.color release];
		} // if
		
		if( mpTextBase->rep.string )
		{
			[mpTextBase->rep.string release];
		} // if
		
		if( mpTextBase->rep.bitmap )
		{
			CGBitmapRelease(mpTextBase->rep.bitmap);
		} // if
		
		free( mpTextBase );
		
		mpTextBase = NULL;
	} // if
} // cleanUpTextBase

//---------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpTextBase];
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Text Color

//---------------------------------------------------------------------------
//
// Set the default to use PBOs or texture range
//
//---------------------------------------------------------------------------

- (void) setUsage:(const OpenGLTextureUsage)theUsage
{
	mpTextBase->bridge.usage = theUsage;
} // setUsage

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Text Color

//---------------------------------------------------------------------------
//
// Set default the text color
//
//---------------------------------------------------------------------------

- (void) setTextColor:(NSColor *)color
{
	if( color )
	{
		[mpTextBase->rep.color release];
		
		mpTextBase->rep.color     = [color retain];
		mpTextBase->bridge.update = YES;
	} // if
} // setTextColor

//---------------------------------------------------------------------------
//
// Get the pre-multiplied default text color (includes alpha) string
// attributes could override this
//
//---------------------------------------------------------------------------

- (NSColor *) textColor
{
	return( mpTextBase->rep.color );
} // textColor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Box Color

//---------------------------------------------------------------------------
//
// Set default text color
//
//---------------------------------------------------------------------------

- (void) setBoxColor:(NSColor *)color
{
	if( color )
	{
		[mpTextBase->box.color release];
		
		mpTextBase->box.color     = [color retain];
		mpTextBase->bridge.update = YES;
	} // if
} // setBoxColor

//---------------------------------------------------------------------------
//
// Get the pre-multiplied box color (includes alpha) alpha of 0.0 means no
// background box color
//
//---------------------------------------------------------------------------

- (NSColor *) boxColor
{
	return( mpTextBase->box.color );
} // boxColor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Border Color

//---------------------------------------------------------------------------
//
// Set default text color
//
//---------------------------------------------------------------------------

- (void) setBorderColor:(NSColor *)color
{
	if( color )
	{
		[mpTextBase->border.color release];
		
		mpTextBase->border.color  = [color retain];
		mpTextBase->bridge.update = YES;
	} // if
} // setBorderColor

//---------------------------------------------------------------------------
//
// Get the pre-multiplied border color (includes alpha) alpha of 0.0 means
// no boeder color
//
//---------------------------------------------------------------------------

- (NSColor *) borderColor
{
	return( mpTextBase->border.color );
} // borderColor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Border Margins

//---------------------------------------------------------------------------
//
// Ensure dynamic frame sizes will be recalculated
//
//---------------------------------------------------------------------------

- (void) recalcDynamicFrame
{
	if( mpTextBase->border.isStatic == NO )
	{
		mpTextBase->border.frame.size.width  = 0.0f;
		mpTextBase->border.frame.size.height = 0.0f;
	} // if
} // recalcDynamicFrame

//---------------------------------------------------------------------------
//
// Set offset size and size to fit with offset
//
// This method will force the texture to be regenerated at the next draw
//
//---------------------------------------------------------------------------

- (void) setBorderMargins:(const NSSize *)theMargin
{
	[self recalcDynamicFrame];
	
	mpTextBase->border.margins = *theMargin;
	mpTextBase->bridge.update  = YES;
} // setBorderMargins

//---------------------------------------------------------------------------
//
// Current margins for text color offset and pads for dynamic frame
//
//---------------------------------------------------------------------------

- (NSSize) borderMargins
{
	return( mpTextBase->border.margins );
} // borderMargins

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Border Properties

//---------------------------------------------------------------------------

- (void) updateBorderSize
{
	if( (mpTextBase->border.isStatic == NO)
	   && (mpTextBase->border.frame.size.width  == 0.0f)
	   && (mpTextBase->border.frame.size.height == 0.0f) )
	{
		// find frame size if we have not already found it
		
		// current string size
		
		mpTextBase->border.frame.size = [mpTextBase->rep.string size];
		
		// add padding
		
		mpTextBase->border.frame.size.width  += (mpTextBase->border.margins.width  * 2.0f);
		mpTextBase->border.frame.size.height += (mpTextBase->border.margins.height * 2.0f);
	} // if
} // updateBorderSize

//---------------------------------------------------------------------------
//
// Returns either dynamic frame (text color size + margins) or static frame
// size (switch with static frame)
//
//---------------------------------------------------------------------------

- (NSSize) borderFrame
{
	[self updateBorderSize];
	
	return( mpTextBase->border.frame.size );
} // borderFrame

//---------------------------------------------------------------------------
//
// Returns whether or not a static frame will be used
//
//---------------------------------------------------------------------------

- (BOOL) borderIsStatic
{
	return( mpTextBase->border.isStatic );
} // borderIsStatic

//---------------------------------------------------------------------------
//
// Set static frame size and size to frame
//
// This method will force the texture to be regenerated at the next draw
//
//---------------------------------------------------------------------------

- (void) useStaticBorder:(const NSSize *)theBorder
{
	mpTextBase->border.frame.size = *theBorder;
	mpTextBase->border.isStatic   =  YES;
	mpTextBase->bridge.update     =  YES;
} // useStaticBorder

//---------------------------------------------------------------------------
//
// Use dynamic instead of static frame
//
// This method will force the texture to be regenerated at the next draw
//
//---------------------------------------------------------------------------

- (void) useDynamicBorder
{
	if( mpTextBase->border.isStatic )
	{
		// set to dynamic frame and set to regenerate texture
		
		mpTextBase->bridge.update  = YES;
		mpTextBase->border.isStatic = NO;
		
		[self recalcDynamicFrame];
	} // if
} // useDynamicBorder

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Antialiasing

//---------------------------------------------------------------------------
//
// The current anitaliasing state of the selected font
//
//---------------------------------------------------------------------------

- (BOOL) antialias
{
	return( mpTextBase->rep.antialias );
} // antialias

//---------------------------------------------------------------------------
//
// Set the anitaliasing state of a font
//
//---------------------------------------------------------------------------

- (void) setAntialias:(const BOOL)theAntialiasState
{
	mpTextBase->rep.antialias = theAntialiasState;
	mpTextBase->bridge.update = YES;
} // setAntialias

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark String

//---------------------------------------------------------------------------
//
// Set string after initial creation
//
//---------------------------------------------------------------------------

- (void) setString:(NSAttributedString *)theAttrString
{
	if( theAttrString )
	{
		[mpTextBase->rep.string release];
		
		mpTextBase->rep.string = [theAttrString retain];
		
		[self recalcDynamicFrame];
		
		mpTextBase->rep.range     = CFRangeMake(0, [mpTextBase->rep.string length]);
		mpTextBase->bridge.update = YES;
	} // if
} // setString

//---------------------------------------------------------------------------
//
// Set string after initial creation
//
//---------------------------------------------------------------------------

- (void) setString:(NSString *)theString
		attributes:(NSDictionary *)theAttribs
{
	if( theString && theAttribs )
	{
		NSAttributedString *pAttrString = [[NSAttributedString alloc] initWithString:theString
																		  attributes:theAttribs];
		
		if( pAttrString )
		{
			[mpTextBase->rep.string release];
			
			mpTextBase->rep.string = pAttrString;
			
			[self recalcDynamicFrame];
			
			mpTextBase->rep.range     = CFRangeMake(0, [mpTextBase->rep.string length]);
			mpTextBase->bridge.update = YES;
		} // if
	} // if
} // setString

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark OpenGL View Bounds

//---------------------------------------------------------------------------
//
// Set the current OpenGL view bounds
//
//---------------------------------------------------------------------------

- (void) viewSetBounds:(const NSRect *)theBounds
{
	mpTextBase->bridge.update = !NSEqualRects(*theBounds, mpTextBase->bounds.rect);
	
	if( mpTextBase->bridge.update )
	{
		mpTextBase->bounds.rect = *theBounds;
	} // if
} // viewSetBounds

//---------------------------------------------------------------------------

- (NSRect) viewBounds
{
	return( mpTextBase->bounds.rect );
} // viewBounds

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Texture Updates

//---------------------------------------------------------------------------

- (void) appendPathWithRoundRect:(BOOL)theFillFlag
{
	CGContextMoveToPoint(mpTextBase->rep.context,
						 mpTextBase->box.coordinate.x,
						 mpTextBase->box.coordinate.y);
	
	CGContextAddArcToPoint(mpTextBase->rep.context,
						   mpTextBase->box.topLeft.x,
						   mpTextBase->box.topLeft.y,
						   mpTextBase->box.origin.x,
						   mpTextBase->box.origin.y,
						   mpTextBase->border.clampedRadius);
	
	CGContextAddArcToPoint(mpTextBase->rep.context,
						   mpTextBase->box.origin.x,
						   mpTextBase->box.origin.y,
						   mpTextBase->box.bottomRight.x,
						   mpTextBase->box.bottomRight.y,
						   mpTextBase->border.clampedRadius);
	
	CGContextAddArcToPoint(mpTextBase->rep.context,
						   mpTextBase->box.bottomRight.x,
						   mpTextBase->box.bottomRight.y,
						   mpTextBase->box.topRight.x,
						   mpTextBase->box.topRight.y,
						   mpTextBase->border.clampedRadius);
	
	CGContextAddArcToPoint(mpTextBase->rep.context,
						   mpTextBase->box.topRight.x,
						   mpTextBase->box.topRight.y,
						   mpTextBase->box.topLeft.x,
						   mpTextBase->box.topLeft.y,
						   mpTextBase->border.clampedRadius);
	
	CGContextClosePath(mpTextBase->rep.context);
	
	if( theFillFlag )
	{
		CGContextFillPath(mpTextBase->rep.context);
	} // if
	else
	{
		CGContextStrokePath(mpTextBase->rep.context);
	} // else
} // appendPathWithRoundRect

//---------------------------------------------------------------------------
//
// When radius == 0.0, this degenerates to the simple case of a plain
// rectangle.
//
//---------------------------------------------------------------------------

- (void) appendPathWithPlainRect:(NSRect)theRect
						  doFill:(BOOL)theFillFlag
{
	CGRect aRect = NSRectToCGRect(theRect);
	
	if( theFillFlag )
	{
		CGContextFillRect(mpTextBase->rep.context, aRect);
	} // if
	else
	{
		CGContextStrokeRect(mpTextBase->rep.context, aRect);
	} // else
} // appendPathWithPlainRect

//---------------------------------------------------------------------------

- (void) computeRoundRect:(NSRect)theRect
			 cornerRadius:(CGFloat)theRadius
{
	CGFloat width  = NSWidth(theRect);
	CGFloat height = NSHeight(theRect);
	CGFloat length = 0.5f * MIN(width, height);
	
	// Clamp radius to be no larger than half the
	// rectangles's width or height.
	
	mpTextBase->border.clampedRadius = MIN(theRadius, length);
	
	CGFloat minX = NSMinX(theRect);
	CGFloat midX = NSMidX(theRect);
	CGFloat maxX = NSMaxX(theRect);
	CGFloat minY = NSMinY(theRect);
	CGFloat maxY = NSMaxY(theRect);
	
	mpTextBase->box.origin      = theRect.origin;
	mpTextBase->box.coordinate  = NSMakePoint(midX, maxY);
	mpTextBase->box.topLeft     = NSMakePoint(minX, maxY);
	mpTextBase->box.topRight    = NSMakePoint(maxX, maxY);
	mpTextBase->box.bottomRight = NSMakePoint(maxX, minY);
} // computeRoundRect

//---------------------------------------------------------------------------

- (void) createRoundRect:(NSRect)theRect
			cornerRadius:(CGFloat)theRadius
{
	[self computeRoundRect:theRect
			  cornerRadius:theRadius];
	
	if( [mpTextBase->box.color alphaComponent] )
	{
		[self appendPathWithRoundRect:YES];
	} // if
	
	if( [mpTextBase->border.color alphaComponent] )
	{
		[self appendPathWithRoundRect:NO];
	} // if
} // createRoundRect

//---------------------------------------------------------------------------

- (void) createPlainRect:(NSRect)theRect
{
	if( [mpTextBase->box.color alphaComponent] )
	{
		[self appendPathWithPlainRect:theRect
							   doFill:YES];
	} // if
	
	if( [mpTextBase->border.color alphaComponent] )
	{
		[self appendPathWithPlainRect:theRect
							   doFill:NO];
	} // if
} // createPlainRect

//---------------------------------------------------------------------------

- (void) setBorderData
{
	CGContextSetRGBFillColor(mpTextBase->rep.context,
							 [mpTextBase->box.color redComponent],
							 [mpTextBase->box.color greenComponent],
							 [mpTextBase->box.color blueComponent],
							 [mpTextBase->box.color alphaComponent]);
	
	CGContextSetRGBStrokeColor(mpTextBase->rep.context,
							   [mpTextBase->border.color redComponent],
							   [mpTextBase->border.color greenComponent],
							   [mpTextBase->border.color blueComponent],
							   [mpTextBase->border.color alphaComponent]);
	
	CGContextSetLineWidth(mpTextBase->rep.context,
						  mpTextBase->border.lineWidth);
} // setBorderData

//---------------------------------------------------------------------------

- (void) acquireBorder
{
	if( mpTextBase->border.hasBorder )
	{
		NSRect insetRect = NSInsetRect(mpTextBase->border.frame,
									   1.5,
									   1.5);
		
		if( !NSIsEmptyRect(insetRect) )
		{
			[self setBorderData];
			
			if( mpTextBase->border.cornerRadius > 0.0f )
			{
				[self createRoundRect:insetRect
						 cornerRadius:mpTextBase->border.cornerRadius];
			} // if
			else
			{
				[self createPlainRect:insetRect];
			} // else
		} // if
	} // if
} // acquireBorder

//---------------------------------------------------------------------------
//
// Create a frame setter using an attributed string. Next, initialize a
// rectangular path. Lastly, create a frame and draw it into its graphics
// context.
//
//---------------------------------------------------------------------------

- (BOOL) updateFrame
{
	CTFramesetterRef pFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)mpTextBase->rep.string);
	
	BOOL bSuccess = pFramesetter != NULL;

	if( bSuccess )
	{
		CGMutablePathRef pPath = CGPathCreateMutable();
		
		if( pPath != NULL )
		{
			CGRect bounds = CGRectMake(mpTextBase->border.margins.width,
									   -mpTextBase->border.margins.height,
									   mpTextBase->border.frame.size.width,
									   mpTextBase->border.frame.size.height);
			
			CGPathAddRect(pPath, NULL, bounds);
			
			CTFrameRef pFrame = CTFramesetterCreateFrame(pFramesetter,
														 mpTextBase->rep.range,
														 pPath,
														 NULL);
			
			bSuccess = pFrame != NULL;
			
			if( bSuccess )
			{
				CGContextSetRGBFillColor(mpTextBase->rep.context,
										 [mpTextBase->rep.color redComponent],
										 [mpTextBase->rep.color greenComponent],
										 [mpTextBase->rep.color blueComponent],
										 [mpTextBase->rep.color alphaComponent]);
				
				CTFrameDraw(pFrame,
							mpTextBase->rep.context);
				
				CFRelease(pFrame);
			} // if
			
			CGPathRelease(pPath);
		} // if
		
		CFRelease(pFramesetter);
	} // if
	
	return( bSuccess );
} // updateFrame

//---------------------------------------------------------------------------

- (BOOL) acquireImage
{
	BOOL isValidString = mpTextBase->rep.string != nil;
	BOOL isValidFrame  = !NSIsEmptyRect(mpTextBase->border.frame);
	BOOL isValid       = isValidString && isValidFrame;
	
	if( isValid )
	{
		CGBitmapRelease(mpTextBase->rep.bitmap);
		
		mpTextBase->rep.bitmap = CGBitmapCreate(&mpTextBase->border.frame.size,
												kCGImageAlphaPremultipliedFirst);
		
		if( mpTextBase->rep.bitmap != NULL )
		{
			mpTextBase->rep.context = CGBitmapGetContext(mpTextBase->rep.bitmap);
			
			CGBitmapSetShouldAntialias(mpTextBase->rep.antialias,
									   mpTextBase->rep.bitmap);
		} // if
	} // if
	
	return( isValid );
} // acquireImage

//---------------------------------------------------------------------------

- (BOOL) updateImage
{
	BOOL updated = NO;
	
	if( [self updateFrame] )
	{
		mpTextBase->image.size.width  = CGBitmapGetWidth(mpTextBase->rep.bitmap);
		mpTextBase->image.size.height = CGBitmapGetHeight(mpTextBase->rep.bitmap);
		mpTextBase->image.data        = CGBitmapGetPixels(mpTextBase->rep.bitmap);
		
		updated = mpTextBase->image.data != NULL;
	} // if
	
	return( updated );
} // updateImage

//---------------------------------------------------------------------------

- (BOOL) updateContext
{
	BOOL updated = NO;
	
	if( mpTextBase->bridge.update )
	{
		NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
		
		if( currentContext )
		{
			[self updateBorderSize];
			
			if( [self acquireImage] )
			{
				[self acquireBorder];
				
				updated = [self updateImage];
				
				mpTextBase->bridge.update = NO;
			} // if
		} // if
	} // if
	
	return( updated );
} // updateContext

//---------------------------------------------------------------------------

- (void) updateTexture:(const NSPoint *)theOrigin
{
	if( mpTextBase->bridge.mediator == nil )
	{
		// Instantiate a new texture controller object
		
		mpTextBase->bridge.mediator = [[OpenGLTextureMediator alloc] initTextureMediator:mpTextBase->bridge.usage];
	} // if
	
	NSRect frame = NSMakeRect(theOrigin->x,
							  theOrigin->y,
							  mpTextBase->image.size.width,
							  mpTextBase->image.size.height);
	
	[mpTextBase->bridge.mediator update:mpTextBase->image.data
								  frame:&frame];
} // updateTexture

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Drawing

//---------------------------------------------------------------------------
//
// Draw the string at the (x,y) coordinate points
//
//---------------------------------------------------------------------------

- (void) stringScale
{
	if( mpTextBase->bridge.update )
	{
		mpTextBase->bounds.scale[0] =  2.0f / mpTextBase->bounds.rect.size.width;
		mpTextBase->bounds.scale[1] = -2.0f / mpTextBase->bounds.rect.size.height;
		mpTextBase->bounds.scale[2] =  1.0f;
	} // if
	
	glScalef(mpTextBase->bounds.scale[0],
			 mpTextBase->bounds.scale[1],
			 mpTextBase->bounds.scale[2]);
} // stringScale

//---------------------------------------------------------------------------

- (void) stringTranslate
{
	if( mpTextBase->bridge.update )
	{
		mpTextBase->bounds.translate[0] = -0.5f * mpTextBase->bounds.rect.size.width;
		mpTextBase->bounds.translate[1] = -0.5f * mpTextBase->bounds.rect.size.height;
		mpTextBase->bounds.translate[2] =  0.0f;
	} // if
	
	glTranslatef(mpTextBase->bounds.translate[0],
				 mpTextBase->bounds.translate[1],
				 mpTextBase->bounds.translate[2]);
} // stringTranslate

//---------------------------------------------------------------------------

- (void) stringDrawBegin
{
	// Set orthograhic 1:1  pixel transform in local view coords
	
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	
	glLoadIdentity();
	
	glMatrixMode (GL_MODELVIEW);
	glPushMatrix();
	
	glLoadIdentity();
	
	// Initialize color
	
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	
	// GL_COLOR_BUFFER_BIT for glBlendFunc, GL_ENABLE_BIT for enable/disable pair
	
	glPushAttrib(GL_ENABLE_BIT | GL_TEXTURE_BIT | GL_COLOR_BUFFER_BIT);
	
	// Ensure text color is not removed by depth buffer test.
	
	glDisable(GL_DEPTH_TEST);
	
	// For the text color fading
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
} // stringDrawBegin

//---------------------------------------------------------------------------

- (void) stringDrawEnd
{
	glPopAttrib();
	
	// Reset orginal martices
	
	glPopMatrix(); // GL_MODELVIEW
	
	glMatrixMode(GL_PROJECTION);
	
	glPopMatrix();
} // stringDrawEnd

//---------------------------------------------------------------------------
//
// Generates a string texture without drawing the texture to current context.
//
//---------------------------------------------------------------------------

- (void) stringDrawUpdate:(const NSPoint *)theOrigin
{
	if( [self updateContext] )
	{
		[self updateTexture:theOrigin];
	} // if
	
	[mpTextBase->bridge.mediator draw];
} // stringDrawUpdate

//---------------------------------------------------------------------------

- (void) drawString:(const NSPoint *)theOrigin
{
	[self stringDrawBegin];
	[self stringScale];
	[self stringTranslate];
	[self stringDrawUpdate:theOrigin];
	[self stringDrawEnd];
} // drawString

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

