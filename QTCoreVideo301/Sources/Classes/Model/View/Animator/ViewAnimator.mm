/*
     File: ViewAnimator.mm
 Abstract: 
 Mediator class for animating grouped views.
 
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

#import <string>

#import "NSStringMap.h"
#import "ViewAnimation.h"
#import "ViewAnimator.h"

#pragma mark -
#pragma mark Private - Data Structures

struct ViewAnimatorData
{
    ViewAnimator           *mpSelf;
    NSDictionary           *mpSequence;
    NS::String::TMap<BOOL>  m_IsVisible;
};

typedef struct ViewAnimatorData  ViewAnimatorData;

#pragma mark -
#pragma mark Private - Utilities - Destructors

static inline void ViewAnimatorDelete(ViewAnimatorDataRef pAnimator)
{
    if(pAnimator != NULL)
    {
        delete pAnimator;
        
        pAnimator = NULL;
    } // if
} // ViewAnimatorDelete

#pragma mark -
#pragma mark Private - Utilities - States

static BOOL ViewAnimatorEmplaceStates(NSDictionary *pDictionary,
                                      ViewAnimatorDataRef pAnimator)
{
    BOOL bSuccess = pDictionary != nil;
    
    if(pDictionary)
    {
        NSString *pKey    = nil;
        NSString *pObject = nil;
        
        NSComparisonResult nResult;
        
        for(pKey in pDictionary)
        {
            pObject = [pDictionary objectForKey:pKey];
            
            if(pObject)
            {
                nResult = [pObject compare:NSViewAnimationFadeInEffect];
                
                pAnimator->m_IsVisible.emplace(pKey, nResult == NSOrderedSame);
            } // if
        } // if
        
        bSuccess = [pDictionary count] == pAnimator->m_IsVisible.size();
    } // if
    
    return bSuccess;
} // ViewAnimatorEmplaceStates

static BOOL ViewAnimatorReplaceStates(NSDictionary *pDictionary,
                                      ViewAnimatorDataRef pAnimator)
{
    BOOL bSuccess = pDictionary != nil;
    
    if(pDictionary)
    {
        NSString *pKey    = nil;
        NSString *pObject = nil;
        
        NSComparisonResult nResult;
        
        for(pKey in pDictionary)
        {
            pObject = [pDictionary objectForKey:pKey];
            
            if(pObject)
            {
                nResult = [pObject compare:NSViewAnimationFadeInEffect];
                
                pAnimator->m_IsVisible.replace(pKey, nResult == NSOrderedSame);
            } // if
        } // if
        
        bSuccess = [pDictionary count] == pAnimator->m_IsVisible.size();
    } // if
    
    return bSuccess;
} // ViewAnimatorReplaceStates

#pragma mark -
#pragma mark Private - Utilities - Constructors

static ViewAnimatorDataRef ViewAnimatorCreate(ViewAnimator *pSelf,
                                              NSDictionary *pDictionary)
{
    ViewAnimatorDataRef pAnimator = new ViewAnimatorData;
    
    if(pAnimator != NULL)
    {
        ViewAnimatorEmplaceStates(pDictionary, pAnimator);
        
        pAnimator->mpSelf = pSelf;
    } // if
    
    return pAnimator;
} // ViewAnimatorCreate

#pragma mark -
#pragma mark Private - Utilities - Accessors

static BOOL ViewAnimatorSetStates(NSDictionary *pDictionary,
                                  ViewAnimatorDataRef pAnimator)
{
    BOOL bSuccess = pDictionary != nil;
    
    if(bSuccess)
    {
        pAnimator->m_IsVisible.clear();
        
        bSuccess = ViewAnimatorReplaceStates(pDictionary, pAnimator);
    } // if
    
    return  bSuccess;
} // ViewAnimatorSetStates

#pragma mark -
#pragma mark Private - Utilities - Effects

static inline void ViewAnimatorAcquireFadeIn(NSString            *pKey,
                                             NSView              *pView,
                                             ViewEffects         *pEffects,
                                             ViewAnimatorDataRef  pAnimator)
{
    std::string key = [pKey cStringUsingEncoding:NSASCIIStringEncoding];
    
    if(!pAnimator->m_IsVisible.value(key))
    {
        // Make the control visible
        [pEffects addFadeIn:pView];
        
        // Next time the control needs to fade out
        pAnimator->m_IsVisible.replace(key, YES);
    } // if
} // ViewAnimatorAcquireFadeIn

static inline void ViewAnimatorAcquireFadeOut(NSString            *pKey,
                                              NSView              *pView,
                                              ViewEffects         *pEffects,
                                              ViewAnimatorDataRef  pAnimator)
{
    std::string key = [pKey cStringUsingEncoding:NSASCIIStringEncoding];
    
    if(pAnimator->m_IsVisible.value(key))
    {
        // Make the control invisible
        [pEffects addFadeOut:pView];
        
        // Next time the control needs to fade in
        pAnimator->m_IsVisible.replace(key, NO);
    } // if
} // ViewAnimatorAcquireFadeOut

// Acquire and array of animation effects array of dictionaries for a group
// of controls
static ViewEffects *ViewAnimatorCreateEffects(ViewAnimatorDataRef pAnimator)
{
    ViewEffects *pEffects = [ViewEffects effects];
    
    if(pEffects)
    {
        NSString *pKey    = nil;
        NSString *pObject = nil;
        
        NSView *pView = nil;
        
        NSComparisonResult nResult;
        
        for(pKey in pAnimator->mpSequence)
        {
            pObject = [pAnimator->mpSequence objectForKey:pKey];
            
            if(pObject)
            {
                pView = [pAnimator->mpSelf view:pKey];
                
                if(pView)
                {
                    nResult = [pObject compare:NSViewAnimationFadeInEffect];
                    
                    if(nResult == NSOrderedSame)
                    {
                        ViewAnimatorAcquireFadeIn(pKey, pView, pEffects, pAnimator);
                    } // if
                    else
                    {
                        ViewAnimatorAcquireFadeOut(pKey, pView, pEffects, pAnimator);
                    } // else
                } // if
            } // if
        } // for
    } // if
    
    return pEffects;
} // ViewAnimatorCreateEffects

#pragma mark -
#pragma mark Private - Utilities - Animations

// Animate a sequence
static BOOL ViewAnimatorStart(NSDictionary *pSequence,
                              ViewAnimatorDataRef pAnimator)
{
    BOOL bSuccess = pSequence != nil;
    
    if(bSuccess)
    {
        pAnimator->mpSequence = [pSequence retain];
        {
            ViewEffects *pEffects = ViewAnimatorCreateEffects(pAnimator);
            
            bSuccess = pEffects != nil;
            
            if(bSuccess)
            {
                ViewAnimation *pAnimation = [ViewAnimation animateWithEffects:pEffects];
                
                bSuccess = pAnimation != nil;
                
                if(bSuccess)
                {
                    [pAnimation start];
                } // if
            } // if
        }
        [pAnimator->mpSequence release];
    } // if
    
    return bSuccess;
} // ViewAnimatorStart

#pragma mark -
#pragma mark Private - Methods

// Private Methods
@interface ViewAnimator(Private)

// Acquire and array of animation effects array of dictionaries for a group
// of controls
- (BOOL) effects:(ViewEffects *)theEffects;

@end

#pragma mark -

@implementation ViewAnimator

#pragma mark -
#pragma mark Public - Designated initializer

- (id) init
{
    self = [super init];
    
    if(self)
    {
        mpAnimator = ViewAnimatorCreate(self,nil);
    } // if
    
    return self;
} // init

// Designated initializer using a dictionary to setup the initial states
- (id) initWithStates:(NSDictionary *)theStates
{
    self = [super init];
    
    if(self)
    {
        mpAnimator = ViewAnimatorCreate(self,theStates);
    } // if
    
    return self;
} // initWithStates

// Instance animator method
+ (id) animator
{
	return [[[ViewAnimator allocWithZone:[self zone]] init] autorelease];
} // animator

// Instance animator method using a dictionary to setup the initial states
+ (id) animatorWithStates:(NSDictionary *)theStates
{
	return [[[ViewAnimator allocWithZone:[self zone]] initWithStates:theStates] autorelease];
} // animatorWithStates

#pragma mark -
#pragma mark Public - Destructor

// Delete/Release resources on application exit
- (void) cleanUp
{
    ViewAnimatorDelete(mpAnimator);
} // cleanUp

// Delete/Release object's resources
- (void) dealloc
{
    ViewAnimatorDelete(mpAnimator);
    
    [super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Accessors

// Set a dictionary with the initial states
- (BOOL) setStates:(NSDictionary *)theDictionary
{
    return  ViewAnimatorSetStates(theDictionary, mpAnimator);
} // setStates

#pragma mark -
#pragma mark Public - Utilities - Views

// Since all controls are derived from a view, for animation, return a view.
// This method must be implemented in the derived class
- (NSView *) view:(NSString *)theControl
{
	return nil;
} // view

#pragma mark -
#pragma mark Public - Utilities - Animate

// Animate a sequence
- (BOOL) start:(NSDictionary *)theSequence
{
    return ViewAnimatorStart(theSequence, mpAnimator);
} // start

@end
