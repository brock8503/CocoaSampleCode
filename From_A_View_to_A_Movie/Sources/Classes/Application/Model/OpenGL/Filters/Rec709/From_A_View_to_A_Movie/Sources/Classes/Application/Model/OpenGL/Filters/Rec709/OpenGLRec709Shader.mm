/*
     File: OpenGLRec709Shader.mm
 Abstract: 
 Utility toolkit for Rec 709 HD color correction shader.
 
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

#import "CWorkingSpace.h"
#import "CChromaticAdaptation.h"
#import "CSpace.h"

//---------------------------------------------------------------------------

#import "OpenGLRec709Shader.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

static const GLint kUniform1i        = 1;
static const GLint kUniform1f        = 2;
static const GLint kUniformMatrix3fv = 4;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@implementation OpenGLRec709Shader

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Initializer

//---------------------------------------------------------------------------
//
// Get the display profile name, current screen gamma, and get the matrix
// for mappping into CIE XYZ space using the current ICC display profile.
//
//---------------------------------------------------------------------------

- (void) setUniformForDisplay
{
	// Get the Color space attributes for the display
	
	Color::Space<GLfloat> a_MainDisplayCS;
	
	// Get the ICC profile description for the display
	
	CFStringRef profileDescription = a_MainDisplayCS.GetProfileDescription();
	
	CFRetain( profileDescription );
	
	mpDescription = profileDescription;
	
	// Get the gamma for the display
	
	mnGamma = a_MainDisplayCS.GetDisplayGamma();
	
	// Set the gamma uniformxx
	
	[self setUniformWithFloats:@"gamma"
						scalar:mnGamma];
	
	// Get the CIE XYZ matrix transforms
	
	const Math::Matrix3<float> displayMatrix = a_MainDisplayCS.GetCIEMatrix();
	
	// Set the uniform for mapping into CIE XYZ space
	
	[self setUniformWithFloatMatrices3x3:@"displayMat"
								tanspose:GL_FALSE
								matrices:displayMatrix.matrix
								   count:1];
} // setUniformForDisplay

//---------------------------------------------------------------------------
//
// For mapping from CIE XYZ space into Rec 709 space.
//
//---------------------------------------------------------------------------

- (void) setUniformForRec709
{
    // Get default Rec 709 working space
    
    Color::WorkingSpace<float> ws;
    
    // Get the linear transformation matrices for the Rec 709 space
    
	Color::Space<GLfloat> a_Rec709CS(ws.GetWorkingSpace());
	
	// Get the inverse matrix for mapping from CIE XYZ into
	// Rec 709 space
	
	const Math::Matrix3<float> a_Rec709CSMatrixInv = a_Rec709CS.GetCIEMatrixInv();
    
	// Set the uniform for the Rec 709 matrix transform
	
	[self setUniformWithFloatMatrices3x3:@"rec709MatInv"
								tanspose:GL_FALSE
								matrices:a_Rec709CSMatrixInv.matrix
								   count:1];
} // setUniformForRec709

//---------------------------------------------------------------------------
//
// Chromatic adptation for adopting to D65 White point of Rec 709 Space.
//
//---------------------------------------------------------------------------

- (void) setUniformForChromaticAdaptation
{
    Color::ChromaticAdaptation<GLfloat> a_D65CA;
	
	// Get the matrix transform for D65 chromatic adaptation
	
	const Math::Matrix3<float> a_D65CAMatrix = a_D65CA.GetChromaticAdaptation();
    
	// Set the uniform for D65 transform
	
	[self setUniformWithFloatMatrices3x3:@"d65CAMat"
								tanspose:GL_FALSE
								matrices:a_D65CAMatrix.matrix
								   count:1];
} // setUniformForChromaticAdaptation

//---------------------------------------------------------------------------

- (void) setUniforms
{
	[self setUniformWithIntegers:@"tex"
						  scalar:0];
	
	[self setUniformForDisplay];
	[self setUniformForRec709];
	[self setUniformForChromaticAdaptation];
	
	[self bindUniforms];
} // setUniforms

//---------------------------------------------------------------------------

- (void) appDidChangeScreenParamsNotification:(NSNotification *)notification
{
    Color::Sync  csync;
	
	CFStringRef  profileDescription = csync.GetProfileDescription();
	
	if( profileDescription != NULL )
	{
		CFComparisonResult result = CFStringCompare(profileDescription,
													mpDescription,
													kCFCompareLocalized);
		
		if( result != kCFCompareEqualTo )
		{
			CFRelease(mpDescription);
			
			mpDescription = CFStringRef(CFRetain(profileDescription));
			
			[self setUniformForDisplay];
			[self setUniformForChromaticAdaptation];
			
			[self bindUniforms];
		} // if
	} // else
} // appDidChangeScreenParamsNotification

//---------------------------------------------------------------------------
//
// NOTE: In future releases we will post the notification
//
//		NSScreenColorSpaceDidChangeNotification
//
//---------------------------------------------------------------------------

- (void) postAppDidChangeScreenParamsNotification
{
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
	
	if( center )
	{
		[center addObserver:self
				   selector:@selector(appDidChangeScreenParamsNotification:)
					   name:NSApplicationDidChangeScreenParametersNotification
					 object:nil];
	} // if
} // postAppDidChangeScreenParamsNotification

//---------------------------------------------------------------------------

- (id) initRec709ShaderWithBounds:(const NSRect *)theViewBounds
{
	// Describe the Rec 709 uniforms
	
	NSArray *uniformObjects = [NSArray arrayWithObjects:
							   [NSNumber numberWithInt:kUniform1i],
							   [NSNumber numberWithInt:kUniform1f],
							   [NSNumber numberWithInt:kUniformMatrix3fv],
							   [NSNumber numberWithInt:kUniformMatrix3fv],
							   [NSNumber numberWithInt:kUniformMatrix3fv],
							   nil];
	
	NSArray *uniformKeys = [NSArray arrayWithObjects:
							@"tex",
							@"gamma",
							@"displayMat",
							@"rec709MatInv",
							@"d65CAMat",
							nil];
	
	NSDictionary *rec709Uniforms = [NSDictionary dictionaryWithObjects:uniformObjects
															   forKeys:uniformKeys];
	
	// Initialize rec 709 unit with the uniforms
	
	self = [super initShaderWithSourcesInAppBundle:@"Rec709"
										  validate:NO
										  uniforms:rec709Uniforms];
	
	if( self )
	{
		[self setUniforms];
		
		[self postAppDidChangeScreenParamsNotification];
	} // if
	
	return( self );
} // initRec709ShaderWithBounds

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Deallocating Resources

//---------------------------------------------------------------------------

- (void) dealloc
{
	if( mpDescription != NULL )
	{
		CFRelease(mpDescription);
		
		mpDescription = NULL;
	} // if
	
	// Dealloc the superclass
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Accessors

//---------------------------------------------------------------------------

- (GLfloat) displayGamma
{
	return( mnGamma );
} // displayGamma

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

