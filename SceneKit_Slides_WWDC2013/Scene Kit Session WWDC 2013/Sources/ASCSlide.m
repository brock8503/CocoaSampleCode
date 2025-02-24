/*
     File: ASCSlide.m
 Abstract: The ASCSlide class represents a slide. A slide owns a node tree, some properties and a text manager.
  Version: 1.1
 
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
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "ASCSlide.h"
#import "ASCSlideTextManager.h"

@implementation ASCSlide

- (id)init {
    if ((self = [super init])) {
        // Node hierarchy :
        // _contentNode
        // |__ _groundNode           : holds the rest of the scene
        // |__ _textManager.textNode : holds the text
        
        _contentNode = [SCNNode node];
        
        _groundNode = [SCNNode node];
        [_contentNode addChildNode:_groundNode];
        
        _textManager = [[ASCSlideTextManager alloc] init];
        [_contentNode addChildNode:_textManager.textNode];
        
        // Default parameters
        _lightIntensities = @[@1.0];
        _mainLightPosition = SCNVector3Make(0, 3, -13);
        _enableShadows = NO;
        _floorImageName = nil;
        _floorReflectivity = 0.25;
        _floorFalloff = 3.0;
        _transitionDuration = 1.0;
        _transitionOffsetX = 0.0;
        _transitionOffsetZ = 0.0;
        _transitionRotation = 0.0;
        _altitude = 5.0;
        _pitch = 0.0;
        _isNewIn10_9 = NO;
    }
    return self;
}

#pragma mark - Navigating within the slide

- (NSUInteger)numberOfSteps {
    return 0;
}

- (void)presentStepIndex:(NSUInteger)index withPresentionViewController:(ASCPresentationViewController *)presentationViewController {
}

- (void)setupSlideWithPresentationViewController:(ASCPresentationViewController *)presentationViewController {
}

- (void)willOrderOutWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
}

- (void)didOrderInWithPresentionViewController:(ASCPresentationViewController *)presentationViewController {
}


@end
