/*
     File: ViewEffects.m
 Abstract: 
 Utility class for creating an effects array.
 
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

#import "ViewEffects.h"

#pragma mark -
#pragma mark Private - Data Structures

struct ViewEffectsData
{
    NSArray        *mpKeys;
    NSMutableArray *mpArray;
};

typedef struct ViewEffectsData  ViewEffectsData;

#pragma mark -
#pragma mark Private - Utilities - Constructor

static ViewEffectsDataRef ViewEffectsCreate(const NSUInteger nCapacity)
{
    ViewEffectsDataRef pVFXArray = (ViewEffectsDataRef)calloc(1, sizeof(ViewEffectsData));
    
    if(pVFXArray != NULL)
    {
        pVFXArray->mpArray = [[NSMutableArray alloc] initWithCapacity:nCapacity];
        
        pVFXArray->mpKeys = [[NSArray alloc] initWithObjects:NSViewAnimationTargetKey,
                             NSViewAnimationEndFrameKey,
                             NSViewAnimationEffectKey,
                             nil];
    } // if
    
    return pVFXArray;
} // ViewEffectsCreate

#pragma mark -
#pragma mark Private - Utilities - Destructor

static void ViewEffectsDelete(ViewEffectsDataRef pVFXArray)
{
    if(pVFXArray != NULL)
    {
        if(pVFXArray->mpArray)
        {
            [pVFXArray->mpArray release];
            
            pVFXArray->mpArray = nil;
        } // if
        
        if(pVFXArray->mpKeys)
        {
            [pVFXArray->mpKeys release];
            
            pVFXArray->mpKeys = nil;
        } // if
        
        free(pVFXArray);
        
        pVFXArray = NULL;
    } // if
} // ViewEffectsDelete

#pragma mark -
#pragma mark Private - Utilities - Dictionary

static NSDictionary *ViewEffectsCreateDictionary(NSView *pView,
                                                 NSString *pType,
                                                 ViewEffectsDataRef pVFXArray)
{
    NSDictionary *pDictionary = nil;
    
    if(pView && pType)
    {
        NSArray *pObjects = [NSArray arrayWithObjects:pView,
                             [NSValue valueWithRect:[pView frame]],
                             pType,
                             nil ];
        
        if(pObjects)
        {
            pDictionary = [NSDictionary dictionaryWithObjects:pObjects
                                                      forKeys:pVFXArray->mpKeys];
        } // if
    } // if
    
    return pDictionary;
} // ViewEffectsCreateDictionary

#pragma mark -
#pragma mark Private - Utilities - Array

static void ViewEffectsAddObject(NSString *pType,
                                 NSView *pView,
                                 ViewEffectsDataRef pVFXArray)
{
    if(pVFXArray->mpArray)
    {
        NSDictionary  *pDictionary = ViewEffectsCreateDictionary(pView, pType, pVFXArray);
        
        if(pDictionary)
        {
            [pVFXArray->mpArray addObject:pDictionary];
        } // if
    } // if
} // ViewEffectsAddObject

#pragma mark -
#pragma mark Private - Utilities - Effects

// If the requested control is still invisible then make it visible by
// adding a fade-in effect to the animation chain.
static inline void ViewEffectsAddFadeIn(NSView *pView,
                                        ViewEffectsDataRef pVFXArray)
{
    ViewEffectsAddObject(NSViewAnimationFadeInEffect, pView, pVFXArray);
} // ViewEffectsAddFadeIn

// If the requested control is still visible then make it invisible by
// adding a fade-out effect to the animation chain.
static inline void ViewEffectsAddFadeOut(NSView *pView,
                                         ViewEffectsDataRef pVFXArray)
{
    ViewEffectsAddObject(NSViewAnimationFadeOutEffect, pView, pVFXArray);
} // ViewEffectsAddFadeOut

#pragma mark -

@implementation ViewEffects

#pragma mark -
#pragma mark Public - Initializers

- (id) init
{
	self = [super init];
	
	if(self)
	{
		mpVFXArray = ViewEffectsCreate(0);
	} // if
	
	return(self);
} // init

- (id) initWithCapacity:(const NSUInteger)theCapacity
{
	self = [super init];
	
	if(self)
	{
		mpVFXArray = ViewEffectsCreate(theCapacity);
	} // if
	
	return(self);
} // initWithCapacity

+ (id) effects
{
	return [[[ViewEffects allocWithZone:[self zone]] init] autorelease];
} // effects

+ (id) effectsWithCapacity:(const NSUInteger)theCapacity
{
	return [[[ViewEffects allocWithZone:[self zone]] initWithCapacity:theCapacity] autorelease];
} // effectsWithCapacity

#pragma mark -
#pragma mark Public - Destructor

- (void) dealloc
{
	ViewEffectsDelete(mpVFXArray);
    
    [super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Utilities

- (void) addEffect:(NSString *)theType
              view:(NSView *)theView
{
    ViewEffectsAddObject(theType, theView, mpVFXArray);
} // addEffect

- (void) addFadeIn:(NSView *)theView
{
    ViewEffectsAddFadeIn(theView, mpVFXArray);
} // addFadeIn

- (void) addFadeOut:(NSView *)theView
{
    ViewEffectsAddFadeOut(theView, mpVFXArray);
} // addFadeOut

#pragma mark -
#pragma mark Public - Accessors

- (NSArray *) array
{
    return mpVFXArray->mpArray;
} // array

@end
