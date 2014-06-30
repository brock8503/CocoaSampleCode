/*
     File: ViewAnimation.m
 Abstract: 
 Utility class to animate views.
 
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

#import "ViewAnimation.h"

#pragma mark -
#pragma mark Private - Data Structures

struct ViewAnimationData
{
    float                     mnFPS;
    NSTimeInterval            mnDuration;
    NSAnimationCurve          mnCurve;
    NSAnimationBlockingMode   mnMode;
    NSViewAnimation          *mpSequence;
};

typedef struct ViewAnimationData  ViewAnimationData;

#pragma mark -
#pragma mark Private - Utilities - Destructors

static void ViewAnimationReleaseSequence(ViewAnimationDataRef pVAnimations)
{
    if(pVAnimations->mpSequence)
    {
        [pVAnimations->mpSequence release];
        
        pVAnimations->mpSequence = nil;
    } // if
} // ViewAnimationReleaseSequence

static void ViewAnimationDelete(ViewAnimationDataRef pVAnimations)
{
    if(pVAnimations != NULL)
    {
        ViewAnimationReleaseSequence(pVAnimations);
        
        free(pVAnimations);
        
        pVAnimations = NULL;
    } // if
} // ViewAnimationDelete

#pragma mark -
#pragma mark Private - Utilities - Accessors

static inline void ViewAnimationSetProperties(ViewAnimationDataRef pVAnimations)
{
    [pVAnimations->mpSequence setDuration:pVAnimations->mnDuration];
    [pVAnimations->mpSequence setAnimationCurve:pVAnimations->mnCurve];
    [pVAnimations->mpSequence setAnimationBlockingMode:pVAnimations->mnMode];
    [pVAnimations->mpSequence setFrameRate:pVAnimations->mnFPS];
} // ViewAnimationSetProperties

static BOOL ViewAnimationSetEffects(ViewEffects *pEffects,
                                    ViewAnimationDataRef pVAnimations)
{
    BOOL bSuccess = pEffects != nil;
    
    if(bSuccess)
    {
        NSArray *pArray = [pEffects array];
        
        bSuccess = pArray != nil;
        
        if(bSuccess)
        {
            NSViewAnimation *pSequence = [[NSViewAnimation alloc] initWithViewAnimations:pArray];
            
            bSuccess = pSequence != nil;
            
            if(bSuccess)
            {
                ViewAnimationReleaseSequence(pVAnimations);
                
                pVAnimations->mpSequence = pSequence;
                
                ViewAnimationSetProperties(pVAnimations);
            } // if
        } // if
    } // if
    
    return bSuccess;
} // ViewAnimationSetEffects

static inline BOOL ViewAnimationSetBlockingMode(const NSAnimationBlockingMode nMode,
                                                ViewAnimationDataRef pVAnimations)
{
    BOOL bSuccess = nMode != pVAnimations->mnMode;
    
    if(bSuccess)
    {
        pVAnimations->mnMode = nMode;
        
        [pVAnimations->mpSequence setAnimationBlockingMode:pVAnimations->mnMode];
    } // if
    
    return bSuccess;
} // ViewAnimationSetBlockingMode

static inline BOOL ViewAnimationSetCurve(const NSAnimationCurve nCurve,
                                         ViewAnimationDataRef pVAnimations)
{
    BOOL bSuccess = nCurve != pVAnimations->mnCurve;
    
    if(bSuccess)
    {
        pVAnimations->mnCurve = nCurve;
        
        [pVAnimations->mpSequence setAnimationCurve:pVAnimations->mnCurve];
    } // if
    
    return bSuccess;
} // ViewAnimationSetCurve

static inline BOOL ViewAnimationSetDuration(const NSTimeInterval nDuration,
                                            ViewAnimationDataRef pVAnimations)
{
    BOOL bSuccess = nDuration != pVAnimations->mnDuration;
    
    if(bSuccess)
    {
        pVAnimations->mnDuration = nDuration;
        
        [pVAnimations->mpSequence setDuration:pVAnimations->mnDuration];
    } // if
    
    return bSuccess;
} // ViewAnimationSetDuration

static inline BOOL ViewAnimationSetFrameRate(const float nFPS,
                                             ViewAnimationDataRef pVAnimations)
{
    BOOL bSuccess = nFPS != pVAnimations->mnFPS;
    
    if(bSuccess)
    {
        pVAnimations->mnFPS = nFPS;
        
        [pVAnimations->mpSequence setFrameRate:pVAnimations->mnFPS];
    } // if
    
    return bSuccess;
} // ViewAnimationSetFrameRate

#pragma mark -
#pragma mark Private - Utilities - Constructor

static ViewAnimationDataRef ViewAnimationCreate(const NSTimeInterval nDuration,
                                                const NSAnimationCurve nCurve,
                                                ViewEffects *pEffects)
{
    ViewAnimationDataRef pVAnimations = (ViewAnimationDataRef)calloc(1, sizeof(ViewAnimationData));
    
    if(pVAnimations != NULL)
    {
        pVAnimations->mnDuration = nDuration;
        pVAnimations->mnCurve    = nCurve;
        pVAnimations->mnMode     = NSAnimationNonblockingThreaded;
        pVAnimations->mnFPS      = 30.0f;
        
        ViewAnimationSetEffects(pEffects, pVAnimations);
    } // if
    
    return pVAnimations;
} // ViewAnimationCreate

#pragma mark -

@implementation ViewAnimation

#pragma mark -
#pragma mark Public - Designated Initializers

- (id) init
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
} // init

- (id) initWithEffects:(ViewEffects *)theEffects
{
	self = [super init];
	
	if(self)
	{
		mpVAnimations = ViewAnimationCreate(1.5, NSAnimationEaseIn, theEffects);
	} // if
	
	return(self);
} // initWithEffects

- (id) initWithEffects:(ViewEffects *)theEffects
              duration:(const NSTimeInterval)theDuration
                 curve:(const NSAnimationCurve)theCurve
{
	self = [super init];
	
	if(self)
	{
		mpVAnimations = ViewAnimationCreate(theDuration, theCurve, theEffects);
	} // if
	
	return(self);
} // initWithEffects

+ (id) animateWithEffects:(ViewEffects *)theEffects
{
	return [[[ViewAnimation allocWithZone:[self zone]] initWithEffects:theEffects] autorelease];
} // animateWithEffects

+ (id) animateWithEffects:(ViewEffects *)theEffects
                 duration:(const NSTimeInterval)theDuration
                    curve:(const NSAnimationCurve)theCurve
{
	return [[[ViewAnimation allocWithZone:[self zone]] initWithEffects:theEffects
                                                              duration:theDuration
                                                                 curve:theCurve] autorelease];
} // animateWithEffects

#pragma mark -
#pragma mark Public - Destructor

- (void) dealloc
{
	ViewAnimationDelete(mpVAnimations);
    
    [super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Accessors

- (NSAnimationBlockingMode) blockingMode
{
    return mpVAnimations->mnMode;
} // blockingMode

- (NSAnimationCurve) curve
{
    return mpVAnimations->mnCurve;
} // curve

- (NSTimeInterval) duration
{
    return mpVAnimations->mnDuration;
} // duration

- (float) frameRate
{
    return mpVAnimations->mnFPS;
} // frameRate

- (BOOL) setBlockingMode:(NSAnimationBlockingMode)theBlockingMode
{
    return ViewAnimationSetBlockingMode(theBlockingMode, mpVAnimations);
} // setBlockingMode

- (BOOL) setCurve:(NSAnimationCurve)theCurve
{
    return ViewAnimationSetCurve(theCurve, mpVAnimations);
} // setCurve

- (BOOL) setDuration:(NSTimeInterval)theDuration
{
    return ViewAnimationSetDuration(theDuration, mpVAnimations);
} // setDuration

- (BOOL) setFrameRate:(float)theFPS
{
    return ViewAnimationSetFrameRate(theFPS, mpVAnimations);
} // setFrameRate

- (BOOL) setEffects:(ViewEffects *)theEffects
{
    return ViewAnimationSetEffects(theEffects, mpVAnimations);
} // setEffects

#pragma mark -
#pragma mark Public - Utilities

- (void) start
{
    [mpVAnimations->mpSequence startAnimation];
} // startAnimation

- (void) stop
{
    [mpVAnimations->mpSequence stopAnimation];
} // stopAnimation

- (BOOL) isAnimating
{
    return [mpVAnimations->mpSequence isAnimating];
} // isAnimating

@end
