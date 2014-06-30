//---------------------------------------------------------------------------
//
// File: OpenGLTextBase.h
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

#import "OpenGLTextureMediator.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

typedef struct OpenGLTextBaseData *OpenGLTextBaseDataRef;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//
// This class requires a current rendering context and all operations will
// be performed in regards to a context the same context should be current
// for all method calls for a particular object instance.
//
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@interface OpenGLTextBase : NSObject
{
@private
	OpenGLTextBaseDataRef mpTextBase;	// text attributes
} // OpenGLTextBase

//---------------------------------------------------------------------------
//
// Designated initializers for strings without borders
//
//---------------------------------------------------------------------------

- (id) initWithAttributedString:(NSAttributedString *)attributedString
						 bounds:(const NSRect *)theBounds;

- (id) initWithString:(NSString *)theString
		   attributes:(NSDictionary *)theData
			   bounds:(const NSRect *)theBounds;

//---------------------------------------------------------------------------
//
// Designated initializer for strings with borders
//
//---------------------------------------------------------------------------

- (id) initWithAttributedString:(NSAttributedString *)attributedString
					stringColor:(NSColor *)theTextColor
					   boxColor:(NSColor *)theBoxColor
					borderColor:(NSColor *)theBorderColor
						 bounds:(const NSRect *)theBounds;

- (id) initWithString:(NSString *)theString
		   attributes:(NSDictionary *)theData
		  stringColor:(NSColor *)theTextColor
			 boxColor:(NSColor *)theBoxColor
		  borderColor:(NSColor *)theBorderColor
			   bounds:(const NSRect *)theBounds;

//---------------------------------------------------------------------------
//
// Draw the string at the (x,y) coordinate points
//
//---------------------------------------------------------------------------

- (void) drawString:(const NSPoint *)theOrigin;

//---------------------------------------------------------------------------
//
// Use PBOs or texture range.  The default is always cached texture.
//
//---------------------------------------------------------------------------

- (void) setUsage:(const OpenGLTextureUsage)theUsage;

//---------------------------------------------------------------------------
//
// Get the pre-multiplied default text color (includes alpha) string
// attributes could override this
//
//---------------------------------------------------------------------------

- (NSColor *) textColor;

//---------------------------------------------------------------------------
//
// Set default text color
//
//---------------------------------------------------------------------------

- (void) setTextColor:(NSColor *)color;

//---------------------------------------------------------------------------
//
// Get the pre-multiplied box color (includes alpha) alpha of 0.0 means
// no background box color
//
//---------------------------------------------------------------------------

- (NSColor *) boxColor;

//---------------------------------------------------------------------------
//
// Set default box color
//
//---------------------------------------------------------------------------

- (void) setBoxColor:(NSColor *)color;

//---------------------------------------------------------------------------
//
// Get the pre-multiplied border color (includes alpha) alpha of 0.0 means
// no border color
//
//---------------------------------------------------------------------------

- (NSColor *) borderColor;

//---------------------------------------------------------------------------
//
// Set default border color
//
//---------------------------------------------------------------------------

- (void) setBorderColor:(NSColor *)color;

//---------------------------------------------------------------------------
//
// Returns whether or not a static frame will be used
//
//---------------------------------------------------------------------------

- (BOOL) borderIsStatic;

//---------------------------------------------------------------------------
//
// Returns either dynamic frame (text color size + margins) or static frame
// size (switch with static frame)
//
//---------------------------------------------------------------------------

- (NSSize) borderFrame;

//---------------------------------------------------------------------------
//
// These methods will force the texture to be regenerated at the next draw
//
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//
// Current margins for text color offset and pads for dynamic frame
//
//---------------------------------------------------------------------------

- (NSSize) borderMargins;

//---------------------------------------------------------------------------
//
// Set offset size and size to fit with offset
//
//---------------------------------------------------------------------------

- (void) setBorderMargins:(const NSSize *)theMargin;

//---------------------------------------------------------------------------
//
// Set static border size and size
//
//---------------------------------------------------------------------------

- (void) useStaticBorder:(const NSSize *)theBorder;

//---------------------------------------------------------------------------
//
// Use dynamic instead of static border
//
//---------------------------------------------------------------------------

- (void) useDynamicBorder;

//---------------------------------------------------------------------------
//
// The current anitaliasing state of the selected font
//
//---------------------------------------------------------------------------

- (BOOL) antialias;

//---------------------------------------------------------------------------
//
// Set the anitaliasing state of a font
//
//---------------------------------------------------------------------------

- (void) setAntialias:(const BOOL)theAntialiasState;

//---------------------------------------------------------------------------
//
// Set string after initial creation
//
//---------------------------------------------------------------------------

- (void) setString:(NSAttributedString *)attributedString;

- (void) setString:(NSString *)theString
		attributes:(NSDictionary *)theData;

//---------------------------------------------------------------------------
//
// Get the current OpenGL view bounds
//
//---------------------------------------------------------------------------

- (NSRect) viewBounds;

//---------------------------------------------------------------------------
//
// Set the current OpenGL view bounds
//
//---------------------------------------------------------------------------

- (void) viewSetBounds:(const NSRect *)theBounds;

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
