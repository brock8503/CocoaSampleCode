/*
     File: CVGLSLToonUnit.m
 Abstract: 
 Utility toolkit for GLSL toon shader.
 
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

#import "CVGLSLToonUnit.h"

#pragma mark -
#pragma mark Private - Constants

static const GLfloat kAlphaMax  = 10.0f;
static const GLfloat kOffsetMax = 10.0f;

#pragma mark -

@implementation CVGLSLToonUnit

#pragma mark -
#pragma mark Public - Initializers

- (id) init
{
    self = [super initWithShadersInAppBundle:@"toon"];
    
    if(self)
    {
        [self sampler:@"tex"
                value:0];
        
        mpUniforms = [[GLUniformDictionary alloc] initWithProgram:[self program]];
        
        m_Values[0] = 0.0f;
        m_Values[1] = 0.0f;
    } // if
    
	return  self;
} // init

- (id) initWithShadersInAppBundle:(NSString *)theName
{
    self = [super initWithShadersInAppBundle:theName];
    
    if(self)
    {
        [self sampler:@"tex"
                value:0];
        
        mpUniforms = [[GLUniformDictionary alloc] initWithProgram:[self program]];
        
        m_Values[0] = 0.0f;
        m_Values[1] = 0.0f;
    } // if
    
	return  self;
} // initWithShadersInAppBundle

- (id) initWithDictionary:(NSDictionary *)theDicitionary
{
    self = [super initWithDictionary:theDicitionary];
    
    if(self)
    {
        [self sampler:@"tex"
                value:0];
        
        mpUniforms = [[GLUniformDictionary alloc] initWithProgram:[self program]];
        
        m_Values[0] = 0.0f;
        m_Values[1] = 0.0f;
    } // if
    
	return  self;
} // initWithDictionary

+ (id) unit
{
	return [[[CVGLSLToonUnit allocWithZone:[self zone]] init] autorelease];
} // unit

+ (id) unitInAppBundle:(NSString *)theName
{
	return [[[CVGLSLToonUnit allocWithZone:[self zone]] initWithShadersInAppBundle:theName] autorelease];
} // unitInAppBundle

+ (id) unitWithDictionary:(NSDictionary *)theDictionary
{
	return [[[CVGLSLToonUnit allocWithZone:[self zone]] initWithDictionary:theDictionary] autorelease];
} // unitWithDictionary

#pragma mark -
#pragma mark Public - Destructor

- (void) dealloc
{
    // Release the uniforms' dictionary
    if(mpUniforms)
    {
        [mpUniforms release];
    } // if
    
	// Dealloc the superclass
	[super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Utilities

- (void) execute:(CVOpenGLTextureRef)theVideo
            flag:(const BOOL)theFlag
          values:(const GLfloat *)theValues
{
    [self enable];
    {
        m_Values[0] = kAlphaMax  * theValues[0];
        m_Values[1] = kOffsetMax * theValues[1];
        
        [mpUniforms addIntegerScalar:@"style"
                               value:theFlag];
        
        [mpUniforms addFloatScalar:@"alpha"
                             value:m_Values[0]];
        
        [mpUniforms addFloatScalar:@"offset"
                             value:m_Values[1]];

         [self display:theVideo
              uniforms:[mpUniforms dictionary]];
    }
    [self disable];
} // execute

@end

