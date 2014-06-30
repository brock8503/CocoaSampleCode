/*
     File: CVGLSLUnitMediator.m
 Abstract: 
 A mediator class for managing all shader units.
 
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

#import "CVGLSLBlurUnit.h"
#import "CVGLSLBrightenUnit.h"
#import "CVGLSLColorInvertUnit.h"
#import "CVGLSLDilationUnit.h"
#import "CVGLSLEdgeDetectionUnit.h"
#import "CVGLSLErosionUnit.h"
#import "CVGLSLExtractColorUnit.h"
#import "CVGLSLFogUnit.h"
#import "CVGLSLGrayInvertUnit.h"
#import "CVGLSLGrayscaleUnit.h"
#import "CVGLSLHeatSignatureUnit.h"
#import "CVGLSLSaturationUnit.h"
#import "CVGLSLSepiaUnit.h"
#import "CVGLSLSharpenUnit.h"
#import "CVGLSLSkyUnit.h"
#import "CVGLSLToonUnit.h"

#import "CVGLSLUnitTypes.h"
#import "CVGLSLUnit.h"
#import "CVGLSLUnitMediator.h"

#import "GLShaderListReader.h"

#pragma mark -

@implementation CVGLSLUnitMediator

#pragma mark -
#pragma mark Public - Initializer

- (id) init
{
	self = [super init];
	
	if(self)
	{
        GLShaderListReader *pReader = [GLShaderListReader reader];
        
        if(pReader)
        {
            [pReader setResource:@"units"];
            [pReader read];
            
            NSArray *pKeys = [pReader keys];
            
            if(pKeys)
            {
                mpFilters = [[NSMutableArray alloc] initWithCapacity:kCVGLSLUnitMax];
                
                if(mpFilters)
                {
                    [mpFilters addObject:[CVGLSLGrayscaleUnit     unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitBase]]]];
                    [mpFilters addObject:[CVGLSLBlurUnit          unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitBlur]]]];
                    [mpFilters addObject:[CVGLSLBrightenUnit      unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitBrighten]]]];
                    [mpFilters addObject:[CVGLSLColorInvertUnit   unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitColorInvert]]]];
                    [mpFilters addObject:[CVGLSLDilationUnit      unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitDilation]]]];
                    [mpFilters addObject:[CVGLSLEdgeDetectionUnit unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitEdgeDection]]]];
                    [mpFilters addObject:[CVGLSLErosionUnit       unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitErosion]]]];
                    [mpFilters addObject:[CVGLSLExtractColorUnit  unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitExtractColor]]]];
                    [mpFilters addObject:[CVGLSLFogUnit           unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitFog]]]];
                    [mpFilters addObject:[CVGLSLGrayInvertUnit    unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitGrayInvert]]]];
                    [mpFilters addObject:[CVGLSLGrayscaleUnit     unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitGrayscale]]]];
                    [mpFilters addObject:[CVGLSLHeatSignatureUnit unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitHeatSig]]]];
                    [mpFilters addObject:[CVGLSLSaturationUnit    unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitSaturation]]]];
                    [mpFilters addObject:[CVGLSLSepiaUnit         unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitSepia]]]];
                    [mpFilters addObject:[CVGLSLSharpenUnit       unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitSharpen]]]];
                    [mpFilters addObject:[CVGLSLSkyUnit           unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitSky]]]];
                    [mpFilters addObject:[CVGLSLToonUnit          unitWithDictionary:[pReader shader:[pKeys objectAtIndex:kCVGLSLUnitToon]]]];
                } // if
            } // if
        } // if
	} // if
    
	return self;
} // init

#pragma mark -
#pragma mark Public - Destructor

- (void) dealloc
{
    if(mpFilters)
    {
        [mpFilters release];
        
        mpFilters = nil;
    } // if
    
    [super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Utilities

- (void) execute:(CVImageBufferRef)theVideo
            type:(const GLuint)theType
            flag:(const BOOL)theFlag
           value:(const GLfloat *)theValues
{
    if(mpFilters)
    {
        [[mpFilters objectAtIndex:theType] execute:theVideo
                                              flag:theFlag
                                            values:theValues];
    } // if
} // execute

- (void) setSize:(const NSSize *)theSize
{
    CVGLSLUnit *pFilter = nil;
    
    for(pFilter in mpFilters)
    {
        [pFilter setSize:theSize];
    } // for
} // setSize

@end
