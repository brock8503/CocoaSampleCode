//---------------------------------------------------------------------------
//
//	File: OpenGLPlasmaExhibitsMediator.h
//
//  Abstract: Controller class for all the exhibits
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
//  Copyright (c) 2008-2009, 2012 Apple Inc., All rights reserved.
//
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#import "OpenGLPlasmaKleinExhibit.h"
#import "OpenGLPlasmaSlipperExhibit.h"
#import "OpenGLPlasmaStilettoExhibit.h"
#import "OpenGLPlasmaTranguloidTrefoilExhibit.h"
#import "OpenGLPlasmaTriaxialTritorusExhibit.h"

#import "OpenGLPlasmaExhibitsMediator.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------

@implementation OpenGLPlasmaExhibitsMediator

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Initializer

//---------------------------------------------------------------------------

- (id) init
{
	self = [super init];
	
	if( self )
	{
		OpenGLPlasmaKleinExhibit              *plasmaKlein             = [OpenGLPlasmaKleinExhibit exhibit];
		OpenGLPlasmaSlipperExhibit            *plasmaSlipper           = [OpenGLPlasmaSlipperExhibit exhibit];
		OpenGLPlasmaStilettoExhibit           *plasmaStiletto          = [OpenGLPlasmaStilettoExhibit exhibit];
		OpenGLPlasmaTranguloidTrefoilExhibit  *plasmaTranguloidTrefoil = [OpenGLPlasmaTranguloidTrefoilExhibit exhibit];
		OpenGLPlasmaTriaxialTritorusExhibit   *plasmaTriaxialTritorus  = [OpenGLPlasmaTriaxialTritorusExhibit exhibit];
		
		mpExhibits = [[NSArray alloc] initWithObjects:plasmaKlein,
					  plasmaSlipper,
					  plasmaStiletto,
					  plasmaTranguloidTrefoil,
					  plasmaTriaxialTritorus,
					  nil];
		
		mnType = kPlasmaExhibitIsNone;
	} // if
	
	return self;
} // init

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Designated Initializers

//---------------------------------------------------------------------------

- (void) initExhibitsWithTextures:(NSDictionary *)theTextures
						 uniforms:(NSDictionary *)theUniforms
{
	OpenGLPlasmaKleinExhibit *plasmaKlein = [OpenGLPlasmaKleinExhibit exhibitWithTextures:theTextures
																				 uniforms:theUniforms];
	
	OpenGLPlasmaSlipperExhibit *plasmaSlipper = [OpenGLPlasmaSlipperExhibit exhibitWithTextures:theTextures
																					   uniforms:theUniforms];
	
	OpenGLPlasmaStilettoExhibit *plasmaStiletto = [OpenGLPlasmaStilettoExhibit exhibitWithTextures:theTextures
																						  uniforms:theUniforms];
	
	OpenGLPlasmaTranguloidTrefoilExhibit *plasmaTranguloidTrefoil = [OpenGLPlasmaTranguloidTrefoilExhibit exhibitWithTextures:theTextures
																													 uniforms:theUniforms];
	
	OpenGLPlasmaTriaxialTritorusExhibit *plasmaTriaxialTritorus = [OpenGLPlasmaTriaxialTritorusExhibit exhibitWithTextures:theTextures
																												  uniforms:theUniforms];
	
	mpExhibits = [[NSArray alloc] initWithObjects:plasmaKlein,
				  plasmaSlipper,
				  plasmaStiletto,
				  plasmaTranguloidTrefoil,
				  plasmaTriaxialTritorus,
				  nil];
} // initExhibitsWithTextures

//---------------------------------------------------------------------------

- (id) initWithTextures:(NSDictionary *)theTextures
			   uniforms:(NSDictionary *)theUniforms
{
	self = [super init];
	
	if( self )
	{
		mnType = kPlasmaExhibitIsNone;
		
		[self initExhibitsWithTextures:theTextures
							  uniforms:theUniforms];
		
		[self setExhibitWithType:kPlasmaExhibitIsTranguloidTrefoilSurface];
	} // if
	
	return self;
} // initWithTextures

//---------------------------------------------------------------------------

- (id) initWithDefaultType:(const OpenGLPlasmaExhibitType)theDefaultType
				  samplers:(NSDictionary *)theTextures
				  uniforms:(NSDictionary *)theUniforms
{
	self = [super init];
	
	if( self )
	{
		mnType = kPlasmaExhibitIsNone;
		
		[self initExhibitsWithTextures:theTextures
							  uniforms:theUniforms];
		
		[self setExhibitWithType:theDefaultType];
	} // if
	
	return self;
} // initWithDefaultType

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Deallocating Resources

//---------------------------------------------------------------------------

- (void) dealloc
{
	// Delete all exhibits
	
	if( mpExhibits )
	{
		[mpExhibits release];
		
		mpExhibits = nil;
	} // if
	
	// Dealloc the superclass
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Accessors

//---------------------------------------------------------------------------

- (void) setExhibitWithType:(const OpenGLPlasmaExhibitType)thePlasmaExhibitType
{
	NSUInteger plasmaExhibitIndex = 0;
	
	if( thePlasmaExhibitType != mnType )
	{
		mnType  = thePlasmaExhibitType;
        
		plasmaExhibitIndex = mnType - 1;
        
		mpShader = [mpExhibits objectAtIndex:plasmaExhibitIndex];
	} // if
} // setExhibitWithType

//------------------------------------------------------------------------

- (NSMutableDictionary *) exhibitUniforms
{
	return( [mpShader uniforms] );
} // uniforms

//------------------------------------------------------------------------

- (void) setExhibitUniforms:(NSMutableDictionary *)theUniforms
{
	[mpShader setUniformsDictionary:theUniforms];
} // uniforms

//------------------------------------------------------------------------

- (NSMutableDictionary *) exhibitTextures
{
	return( [mpShader textures] );
} // exhibitTextures

//------------------------------------------------------------------------

- (void) setExhibitTextures:(NSMutableDictionary *)theTextures
{
	[mpShader setTexturesDictionary:theTextures];
} // setExhibitTextures

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Drawing the content

//---------------------------------------------------------------------------

- (void) executeExhibit:(const GLfloat *)theLightPos
{
	[mpShader shaderExecuteWithFloatVector:theLightPos];
} // exhibit

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

