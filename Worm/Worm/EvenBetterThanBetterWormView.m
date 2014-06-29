/*
     File: EvenBetterThanBetterWormView.m
 Abstract:  This subclass of WormView, GoodWormView, BetterWormView, and EvenBetterWormView queries for the actual dirtied regions and thus redraws a much smaller portion of the view.
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
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "EvenBetterThanBetterWormView.h"


@implementation EvenBetterThanBetterWormView

- (BOOL)performAnimation {
    BOOL done;
    GamePosition oldTargetPosition = targetPosition;
    NSUInteger i;
    
    // Compute a rect covering the worm's original position
    for (i = 0; i < wormLength; i++) {
        [self setNeedsDisplayInRect:[self rectForPosition:wormPositions[i]]];
    }
    
    // Update game state
    done = [self updateState];
    
    // Union in the new head (since the worm has moved)
    [self setNeedsDisplayInRect:[self rectForPosition:wormPositions[0]]];
    
    // If the target has changed locations, also include that in
    if (oldTargetPosition.x != targetPosition.x || oldTargetPosition.y != targetPosition.y) {
        [self setNeedsDisplayInRect:[self rectForPosition:targetPosition]];
    }
    
    return done;
}

- (void)drawRect:(NSRect)rect {
    const NSRect *rects;
    NSInteger rectsCount;

    [self getRectsBeingDrawn:&rects count:&rectsCount];

    [backgroundColor set];

    NSUInteger i;
    for (i = 0; i < rectsCount; i++) NSRectFill(rects[i]);

    NSRect tRect;
    for (i = 0; i < wormLength; i++) {
        NSRect wRect = [self rectForPosition:wormPositions[i]];
	if ([self needsToDrawRect:wRect]) {	// Draw this portion of the body only if in the update region
            NSUInteger characterIndex = i % [wormString length];
            NSString *string = [wormString substringWithRange:NSMakeRange(characterIndex, 1)];
	    
            [string drawInRect:wRect withAttributes: wormTextAttributes];
        }
    }
    
    tRect = [self rectForPosition:targetPosition];
    if ([self needsToDrawRect:tRect]) {	// Draw target only if in the update rect
        [[NSColor blackColor] set];
        [[NSBezierPath bezierPathWithOvalInRect:NSInsetRect(tRect, 2, 2)] fill];
    }
}

@end
