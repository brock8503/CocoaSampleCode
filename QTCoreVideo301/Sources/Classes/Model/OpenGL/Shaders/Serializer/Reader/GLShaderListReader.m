/*
     File: GLShaderListReader.m
 Abstract: 
 Utility toolkit for reading a shaders from a serialized dictionary.
 
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

#import "NSStringConversion.h"

#import "GLShaderListConstants.h"
#import "GLShaderListReader.h"

#pragma mark -
#pragma mark Private - Data Structures

struct GLShaderListReaderData
{
    NSString             *mpPath;
    NSMutableArray       *mpKeys;
    NSMutableDictionary  *mpShaders;
};

typedef struct GLShaderListReaderData  GLShaderListReaderData;

#pragma mark -
#pragma mark Private - Utilities - Destructors

static inline void GLShaderListReaderReleaseKeys(GLShaderListReaderDataRef pSLReader)
{
    if(pSLReader->mpKeys)
    {
        [pSLReader->mpKeys release];
        
        pSLReader->mpKeys = nil;
    } // if
} // GLShaderListReaderReleaseKeys

static inline void GLShaderListReaderReleasePath(GLShaderListReaderDataRef pSLReader)
{
    if(pSLReader->mpPath)
    {
        [pSLReader->mpPath release];
        
        pSLReader->mpPath = nil;
    } // if
} // GLShaderListReaderReleasePath

static inline void GLShaderListReaderReleaseShaders(GLShaderListReaderDataRef pSLReader)
{
    if(pSLReader->mpShaders)
    {
        [pSLReader->mpShaders release];
        
        pSLReader->mpShaders = nil;
    } // if
} // GLShaderListReaderReleaseShaders

static void GLShaderListReaderDelete(GLShaderListReaderDataRef pSLReader)
{
    if(pSLReader != NULL)
    {
        GLShaderListReaderReleaseKeys(pSLReader);
        GLShaderListReaderReleasePath(pSLReader);
        GLShaderListReaderReleaseShaders(pSLReader);
        
        free(pSLReader);
        
        pSLReader = NULL;
    } // if
} // GLShaderListReaderDelete

#pragma mark -
#pragma mark Private - Utilities - Constructor

static GLShaderListReaderDataRef GLShaderListReaderCreate(const size_t nCapacity)
{
    GLShaderListReaderDataRef pSLReader = (GLShaderListReaderDataRef)calloc(1, sizeof(GLShaderListReaderData));
    
    if(pSLReader != NULL)
    {
        pSLReader->mpKeys = [[NSMutableArray alloc] initWithCapacity:nCapacity];
    } // if
    
    return pSLReader;
} // GLShaderListReaderCreate

#pragma mark -
#pragma mark Private - Utilities - Strings

static NSString *NSStringCreateFromDictionaryData(NSString *pKey,
                                                  NSDictionary *pDictionary)
{
    NSString *pString = NULL;
    
    if(pKey)
    {
        NSData *pData = [pDictionary objectForKey:pKey];
        
        if(pData)
        {
            pString = NSStringCreateFromData(NSASCIIStringEncoding, pData);
        } // if
    } // if
    
    return pString;
} // NSStringCreateFromDictionaryData

#pragma mark -
#pragma mark Private - Utilities - Shader Sources

static inline void GLShaderListReaderAddSource(NSString *pKey,
                                               NSDictionary *pValue,
                                               NSMutableDictionary *pDictionary)
{
    NSString *pSource = NSStringCreateFromDictionaryData(pKey,
                                                         pValue);
    
    if(pSource)
    {
        [pDictionary setObject:pSource
                        forKey:pKey];
    } // if
} // GLShaderListReaderAddSource

static NSMutableDictionary *GLShaderListReaderCreateShader(NSDictionary *pValue)
{
    NSMutableDictionary *pDictionary = nil;
    
    if(pValue)
    {
        pDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
        
        if(pDictionary)
        {
            GLShaderListReaderAddSource(kGLShaderKeyVert, pValue, pDictionary);
            GLShaderListReaderAddSource(kGLShaderKeyFrag, pValue, pDictionary);
        } // if
    } // if
    
    return  pDictionary;
} // GLShaderListReaderCreateShader

#pragma mark -
#pragma mark Private - Utilities - Acquire

static inline void GLShaderListReaderRemoveKeys(GLShaderListReaderDataRef pSLReader)
{
    if([pSLReader->mpKeys count])
    {
        [pSLReader->mpKeys removeAllObjects];
    } // if
} // GLShaderListReaderRemoveKeys

static inline void GLShaderListReaderSortKeys(GLShaderListReaderDataRef pSLReader)
{
    NSComparisonResult (^comparator)(id, id) = ^(id pObject1, id pObject2)
    {
        NSString *pKey1 = (NSString *)pObject1;
        NSString *pKey2 = (NSString *)pObject2;
        
        return [pKey1 compare:pKey2];
    };
    
    [pSLReader->mpKeys sortWithOptions:NSSortConcurrent
                       usingComparator:comparator];
} // GLShaderListReaderSortKeys

static inline BOOL GLShaderListReaderCreateWithCapacity(const NSUInteger nCount,
                                                        GLShaderListReaderDataRef pSLReader)
{
    NSMutableDictionary *pShaders = [[NSMutableDictionary alloc] initWithCapacity:nCount];
    
    if(pShaders)
    {
        GLShaderListReaderReleaseShaders(pSLReader);
        
        pSLReader->mpShaders = pShaders;
    } // if
    
    return pSLReader->mpShaders != nil;
} // GLShaderListReaderCreateWithCapacity

static inline void GLShaderListReaderEmplace(NSString *pKey,
                                             NSDictionary *pValue,
                                             GLShaderListReaderDataRef pSLReader)
{
    if(pKey)
    {
        NSMutableDictionary *pShader = GLShaderListReaderCreateShader(pValue);
        
        if(pShader)
        {
            [pSLReader->mpShaders setObject:pShader
                                     forKey:pKey];
            
            [pSLReader->mpKeys addObject:pKey];
        } // if
    } // if
} // GLShaderListReaderEmplace

static inline void GLShaderListReaderConcat(NSDictionary *pDictionary,
                                            GLShaderListReaderDataRef pSLReader)
{
    NSString     *pKey   = nil;
    NSDictionary *pValue = nil;
    
    for(pKey in pDictionary)
    {
        pValue = [pDictionary objectForKey:pKey];
        
        if(pValue)
        {
            GLShaderListReaderEmplace(pKey, pValue, pSLReader);
        } // if
    } // for
} // GLShaderListReaderConcat

static inline NSDictionary *GLShaderListReaderWithFile(GLShaderListReaderDataRef pSLReader)
{
    NSDictionary *pDictionary = nil;
    
    if(pSLReader->mpPath)
    {
        pDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:pSLReader->mpPath];
    } // if
    
    return pDictionary;
} // GLShaderListReaderWithFile

static void GLShaderListReaderAcquire(GLShaderListReaderDataRef pSLReader)
{
    NSDictionary *pDictionary = GLShaderListReaderWithFile(pSLReader);
    
    if(pDictionary)
    {
        NSUInteger nCount = [pDictionary count];
        
        if(GLShaderListReaderCreateWithCapacity(nCount, pSLReader))
        {
            GLShaderListReaderRemoveKeys(pSLReader);
            GLShaderListReaderConcat(pDictionary, pSLReader);
            GLShaderListReaderSortKeys(pSLReader);
        } // if
    } // if
} // GLShaderListReaderAcquire

#pragma mark -
#pragma mark Private - Utilities - Accessors

static inline NSDictionary *GLShaderListReaderGetSources(NSString *pKey,
                                                         GLShaderListReaderDataRef pSLReader)
{
    NSDictionary *pSources = nil;
    
    if(pKey)
    {
        pSources = [pSLReader->mpShaders objectForKey:pKey];
    } // if
    
    return pSources;
} // GLShaderListReaderGetSources

static inline NSString *GLShaderListReaderGetSourceFrag(NSString *pKey,
                                                        GLShaderListReaderDataRef pSLReader)
{
    NSString *pSource = nil;
    
    if(pKey)
    {
        NSDictionary *pDictionary = [pSLReader->mpShaders objectForKey:pKey];
        
        if(pDictionary)
        {
            pSource = [pDictionary objectForKey:kGLShaderKeyFrag];
        } // if
    } // if
    
    return pSource;
} // GLShaderListReaderGetSourceFrag

static inline NSString *GLShaderListReaderGetSourceVert(NSString *pKey,
                                                        GLShaderListReaderDataRef pSLReader)
{
    NSString *pSource = nil;
    
    if(pKey)
    {
        NSDictionary *pDictionary = [pSLReader->mpShaders objectForKey:pKey];
        
        if(pDictionary)
        {
            pSource = [pDictionary objectForKey:kGLShaderKeyVert];
        } // if
    } // if
    
    return pSource;
} // GLShaderListReaderGetSourceVert

static inline BOOL GLShaderListReaderSetPathname(NSString * const pInReaderPath,
                                                 GLShaderListReaderDataRef pSLReader)
{
    BOOL bSuccess = pInReaderPath != nil;
    
    if(bSuccess)
    {
        NSString *pOutReaderPath = [[NSString alloc] initWithString:pInReaderPath];
        
        if(pOutReaderPath)
        {
            GLShaderListReaderReleasePath(pSLReader);
            
            pSLReader->mpPath = pOutReaderPath;
        } // if
    } // if
    
    return bSuccess;
} // GLShaderListReaderSetPathname

static inline BOOL GLShaderListReaderSetResource(NSString * const pResource,
                                                 GLShaderListReaderDataRef pSLReader)
{
    BOOL bSuccess = pResource != nil;
    
    if(bSuccess)
    {
        NSBundle *pAppBundle = [NSBundle mainBundle];
        
        bSuccess = pAppBundle != nil;
        
        if(bSuccess)
        {
            NSString  *pPathname = [pAppBundle pathForResource:pResource
                                                        ofType:@"spkg"];
            
            bSuccess = pPathname != nil;
            
            if(pPathname)
            {
                bSuccess = GLShaderListReaderSetPathname(pPathname, pSLReader);
            } // if
        } // if
    } // if
    
    return bSuccess;
} // GLShaderListReaderSetResource

#pragma mark -

@implementation GLShaderListReader

#pragma mark -
#pragma mark Public - Initializers

- (id) init
{
	self = [super init];
	
	if(self)
	{
		mpSLReader = GLShaderListReaderCreate(0);
	} // if
	
	return(self);
} // init

+ (id) reader
{
	return [[[GLShaderListReader allocWithZone:[self zone]] init] autorelease];
} // reader

#pragma mark -
#pragma mark Public - Destructor

- (void) dealloc
{
	GLShaderListReaderDelete(mpSLReader);
    
    [super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Accessors

- (BOOL) setResource:(NSString *)theResource
{
    return GLShaderListReaderSetResource(theResource, mpSLReader);
} // setResource

- (BOOL) setPathname:(NSString *)thePath
{
    return GLShaderListReaderSetPathname(thePath, mpSLReader);
} // setPathname

- (NSArray *) keys
{
    return mpSLReader->mpKeys;
} // keys

- (NSString *) fragment:(NSString *)theName
{
    return GLShaderListReaderGetSourceFrag(theName, mpSLReader);
} // fragment

- (NSString *) vertex:(NSString *)theName
{
    return GLShaderListReaderGetSourceVert(theName, mpSLReader);
} // vertex

- (NSDictionary *) shader:(NSString *)theName
{
    return GLShaderListReaderGetSources(theName, mpSLReader);
} // shader

#pragma mark -
#pragma mark Public - Utilities

- (void) read
{
    GLShaderListReaderAcquire(mpSLReader);
} // read

@end
