/*
     File: CIBevelView.m
 Abstract: View for drawing and event handling.
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

#import "CIBevelView.h"


#define NUM_POINTS  (4)


@implementation CIBevelView
{
    size_t          currentPoint;
    CGPoint         points[NUM_POINTS];
    NSTimeInterval	angleTime;
    CIImage        *lineImage;
    CIFilter       *twirlFilter;
    CIFilter       *heightFieldFilter;
    CIFilter       *shadedFilter;
}


- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if(self)
    {
        points[0] = CGPointMake(0.5 * frameRect.size.width, frameRect.size.height - 100.0);
        points[1] = CGPointMake(150.0, 100.0);
        points[2] = CGPointMake(frameRect.size.width - 150.0, 100.0);
        points[3] = CGPointMake(0.7*points[0].x + 0.3*points[2].x, 0.7*points[0].y + 0.3*points[2].y);
                
        NSURL   *url = [[NSBundle mainBundle] URLForResource:@"lightball" withExtension:@"tiff"];
        CIImage *lightball = [CIImage imageWithContentsOfURL:url];
                
        heightFieldFilter = [CIFilter filterWithName:@"CIHeightFieldFromMask" keysAndValues:@"inputRadius", @15.0, nil];
        
        twirlFilter = [CIFilter filterWithName:@"CITwirlDistortion" keysAndValues:
            @"inputCenter",[CIVector vectorWithX:0.5*frameRect.size.width Y:0.5*frameRect.size.height],
            @"inputRadius", @300.0,
            @"inputAngle", @0, nil];
        
        shadedFilter = [CIFilter filterWithName:@"CIShadedMaterial" keysAndValues:@"inputShadingImage", lightball, @"inputScale", @20.0, nil];
        
        // 1/30 second should give good enough animation.
        [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(changeTwirlAngle:) userInfo:nil repeats:YES];
    }

    return self;
}


- (void) changeTwirlAngle:(NSTimer *)timer
{
    angleTime += [timer timeInterval];
    [twirlFilter setValue:@(-0.2 * sin(angleTime*5.0)) forKey:@"inputAngle"];
    [self updateImage];
}


- (void)mouseDragged:(NSEvent *)event
{
    NSPoint  loc;

    loc = [self convertPoint:[event locationInWindow] fromView:nil];
    points[currentPoint].x = loc.x;
    points[currentPoint].y = loc.y;
    lineImage = nil;

    // Normally we'd want this, but the timer will cause us to redisplay anyway.
    // [self setNeedsDisplay:YES];
}


- (void)mouseDown:(NSEvent *)event
{
    size_t   i;
    CGFloat  x,y, d,t;
    NSPoint  loc;

    d   = 1e4;
    loc = [self convertPoint:[event locationInWindow] fromView:nil];
    for (i=0 ; i<NUM_POINTS ; i++) {
        x = points[i].x - loc.x;
        y = points[i].y - loc.y;
        t = x*x + y*y;

        if(t < d)  currentPoint = i,  d = t;
    }

    [self mouseDragged:event];
}


- (void)updateImage
{
    if (!lineImage)
    {
        CIContext *context = [[NSGraphicsContext currentContext] CIContext];
        NSRect bounds = [self bounds];

        CGLayerRef layer = [context createCGLayerWithSize:CGSizeMake(NSWidth(bounds), NSHeight(bounds)) info:nil];
        CGContextRef cg = CGLayerGetContext(layer);

        CGContextSetRGBStrokeColor(cg, 1,1,1,1);
        CGContextSetLineCap(cg, kCGLineCapRound);

        CGContextSetLineWidth(cg, 60.0);
        CGContextMoveToPoint(cg, points[0].x, points[0].y);
        for (NSInteger i = 1; i < NUM_POINTS; ++i) {
            CGContextAddLineToPoint(cg, points[i].x, points[i].y);
        }
        CGContextStrokePath(cg);

        lineImage = [[CIImage alloc] initWithCGLayer:layer];
        CGLayerRelease(layer);
    }

    [heightFieldFilter setValue:lineImage forKey:@"inputImage"];
    [twirlFilter setValue:[heightFieldFilter valueForKey:@"outputImage"] forKey:@"inputImage"];
    [shadedFilter setValue:[twirlFilter valueForKey:@"outputImage"] forKey:@"inputImage"];

    self.image = [shadedFilter valueForKey:@"outputImage"];
}

@end
