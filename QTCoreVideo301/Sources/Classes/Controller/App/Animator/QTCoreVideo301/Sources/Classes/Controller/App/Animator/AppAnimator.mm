/*
     File: AppAnimator.mm
 Abstract: 
 Mediator class for managing application's view animations.
 
  Version: 2.0
 
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
#pragma mark Private - Headers

#import "CVGLSLUnitTypes.h"

#import "AppAnimatorKeys.h"
#import "AppAnimator.h"

#pragma mark -

@implementation AppAnimator

#pragma mark -
#pragma mark Public - Initializers

- (id) init
{
    self = [super init];
    
    if(self)
    {
        mpSequence[0] = [[NSMutableDictionary alloc] initWithCapacity:8];
        
        if(mpSequence[0])
        {
            [mpSequence[0] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyPushButton];
            [mpSequence[0] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyBottomSlider];
            [mpSequence[0] setObject:NSViewAnimationFadeInEffect  forKey:kAppAnimatorKeyTopSlider];
            [mpSequence[0] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyColorWell];
            [mpSequence[0] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyBottomStaticTextField];
            [mpSequence[0] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyBottomTextField];
            [mpSequence[0] setObject:NSViewAnimationFadeInEffect  forKey:kAppAnimatorKeyTopStaticTextField];
            [mpSequence[0] setObject:NSViewAnimationFadeInEffect  forKey:kAppAnimatorKeyTopTextField];
            
            [self setStates:mpSequence[0]];
        } // if
        
        mpSequence[1] = [[NSMutableDictionary alloc] initWithCapacity:8];
        
        if(mpSequence[1])
        {
            [mpSequence[1] setObject:NSViewAnimationFadeInEffect  forKey:kAppAnimatorKeyPushButton];
            [mpSequence[1] setObject:NSViewAnimationFadeInEffect  forKey:kAppAnimatorKeyBottomSlider];
            [mpSequence[1] setObject:NSViewAnimationFadeInEffect  forKey:kAppAnimatorKeyTopSlider];
            [mpSequence[1] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyColorWell];
            [mpSequence[1] setObject:NSViewAnimationFadeInEffect  forKey:kAppAnimatorKeyBottomStaticTextField];
            [mpSequence[1] setObject:NSViewAnimationFadeInEffect  forKey:kAppAnimatorKeyBottomTextField];
            [mpSequence[1] setObject:NSViewAnimationFadeInEffect  forKey:kAppAnimatorKeyTopStaticTextField];
            [mpSequence[1] setObject:NSViewAnimationFadeInEffect  forKey:kAppAnimatorKeyTopTextField];
        } // if
        
        mpSequence[2] = [[NSMutableDictionary alloc] initWithCapacity:8];
        
        if(mpSequence[2])
        {
            [mpSequence[2] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyPushButton];
            [mpSequence[2] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyBottomSlider];
            [mpSequence[2] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyTopSlider];
            [mpSequence[2] setObject:NSViewAnimationFadeInEffect  forKey:kAppAnimatorKeyColorWell];
            [mpSequence[2] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyBottomStaticTextField];
            [mpSequence[2] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyBottomTextField];
            [mpSequence[2] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyTopStaticTextField];
            [mpSequence[2] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyTopTextField];
        } // if
        
        mpSequence[3] = [[NSMutableDictionary alloc] initWithCapacity:8];
        
        if(mpSequence[3])
        {
            [mpSequence[3] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyPushButton];
            [mpSequence[3] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyBottomSlider];
            [mpSequence[3] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyTopSlider];
            [mpSequence[3] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyColorWell];
            [mpSequence[3] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyBottomStaticTextField];
            [mpSequence[3] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyBottomTextField];
            [mpSequence[3] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyTopStaticTextField];
            [mpSequence[3] setObject:NSViewAnimationFadeOutEffect forKey:kAppAnimatorKeyTopTextField];
        } // if
    } // if
    
    return self;
} // init

#pragma mark -
#pragma mark Public - Destructor

// Delete/Release resources on application exit
- (void) cleanUp
{
    size_t i;
    
    for(i = 0; i < 4; ++i)
    {
        if(mpSequence[i])
        {
            [mpSequence[i] release];
            
            mpSequence[i] = nil;
        } // if
    } // for
    
    [super cleanUp];
} // cleanUp

// Delete/Release object's resources
- (void) dealloc
{
    [self cleanUp];
    
    [super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Utilities

// Based on selected shader, we shall fade in or out the controls associated
// with a particular shader.
- (void) animate:(const NSUInteger)theSelector
{
	switch(CVGLSLUnitTypes(theSelector))
	{
		case kCVGLSLUnitBlur:
		case kCVGLSLUnitBrighten:
		case kCVGLSLUnitDilation:
		case kCVGLSLUnitEdgeDection:
		case kCVGLSLUnitErosion:
		case kCVGLSLUnitFog:
		case kCVGLSLUnitSaturation:
		case kCVGLSLUnitSharpen:
		case kCVGLSLUnitSky:
            [self start:mpSequence[0]];
			break;
            
		case kCVGLSLUnitToon:
            [self start:mpSequence[1]];
			break;
            
		case kCVGLSLUnitExtractColor:
            [self start:mpSequence[2]];
			break;
			
		case kCVGLSLUnitColorInvert:
		case kCVGLSLUnitGrayInvert:
		case kCVGLSLUnitGrayscale:
		case kCVGLSLUnitHeatSig:
		case kCVGLSLUnitSepia:
		default:
            [self start:mpSequence[3]];
			break;
	} // switch
} // animate

@end
