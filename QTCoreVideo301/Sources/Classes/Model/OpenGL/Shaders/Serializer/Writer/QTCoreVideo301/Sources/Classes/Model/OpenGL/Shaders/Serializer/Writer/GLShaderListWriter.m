/*
     File: GLShaderListWriter.m
 Abstract: 
 Utility toolkit for serializing shaders to a XML file.
 
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

#import "NSLogError.h"

#import "GLShaderListWriter.h"

#pragma mark -
#pragma mark Private - Keys

NSString *kGLShaderKeyVert = @"GL_Shader_Vertex";
NSString *kGLShaderKeyFrag = @"GL_Shader_Fragment";

NSString *kGLShaderSuffixVert = @"vs";
NSString *kGLShaderSuffixFrag = @"fs";

#pragma mark -
#pragma mark Private - Constants

static NSString *kGLShaderDocDir = @"~/Documents/shaders.plist";

#pragma mark -
#pragma mark Private - Data Structures

struct GLShaderListWriterData
{
    NSUInteger             mnSLength;
    NSString              *mpBaseDir;
    NSString              *mpPathname;
    NSString              *mpSuffix[2];
    NSData                *mpData[2];
    NSMutableDictionary   *mpShaders;
    NSDirectoryEnumerator *mpEnumerator;
};

typedef struct GLShaderListWriterData  GLShaderListWriterData;

#pragma mark -
#pragma mark Private - Utilities - Destructor

static inline void GLShaderListWriterReleaseSuffixAtIndex(const NSUInteger nIndex,
                                                          GLShaderListWriterDataRef pSLWriter)
{
    if(pSLWriter->mpSuffix[nIndex])
    {
        [pSLWriter->mpSuffix[nIndex] release];
        
        pSLWriter->mpSuffix[nIndex] = nil;
    } // if
} // GLShaderListWriterReleaseSuffixFrag

static inline void GLShaderListWriterReleaseSuffixes(GLShaderListWriterDataRef pSLWriter)
{
    GLShaderListWriterReleaseSuffixAtIndex(0, pSLWriter);
    GLShaderListWriterReleaseSuffixAtIndex(1, pSLWriter);
} // GLShaderListWriterReleaseSuffixes

static inline void GLShaderListWriterReleaseBaseDirectory(GLShaderListWriterDataRef pSLWriter)
{
    if(pSLWriter->mpBaseDir)
    {
        [pSLWriter->mpBaseDir release];
        
        pSLWriter->mpBaseDir = nil;
    } // if
} // GLShaderListWriterReleaseBaseDirectory

static inline void GLShaderListWriterReleaseWritePath(GLShaderListWriterDataRef pSLWriter)
{
    if(pSLWriter->mpPathname)
    {
        [pSLWriter->mpPathname release];
        
        pSLWriter->mpPathname = nil;
    } // if
} // GLShaderListWriterReleaseWritePath

static inline void GLShaderListWriterReleasePaths(GLShaderListWriterDataRef pSLWriter)
{
    GLShaderListWriterReleaseBaseDirectory(pSLWriter);
    GLShaderListWriterReleaseWritePath(pSLWriter);
} // GLShaderListWriterReleasePaths

static inline void GLShaderListWriterReleaseShaders(GLShaderListWriterDataRef pSLWriter)
{
    if(pSLWriter->mpShaders)
    {
        [pSLWriter->mpShaders release];
        
        pSLWriter->mpShaders = nil;
    } // if
} // GLShaderListWriterReleaseShader

static inline void GLShaderListWriterReleaseEnumerator(GLShaderListWriterDataRef pSLWriter)
{
    if(pSLWriter->mpEnumerator)
    {
        [pSLWriter->mpEnumerator release];
        
        pSLWriter->mpEnumerator = nil;
    } // if
} // GLShaderListWriterReleaseEnumerator

static inline void GLShaderListWriterReleaseDataAtIndex(const NSUInteger nIndex,
                                                        GLShaderListWriterDataRef pSLWriter)
{
    if(pSLWriter->mpData[nIndex])
    {
        [pSLWriter->mpData[nIndex] release];
        
        pSLWriter->mpData[nIndex] = nil;
    } // if
} // GLShaderListWriterReleaseDataAtIndex

static inline void GLShaderListWriterReleaseData(GLShaderListWriterDataRef pSLWriter)
{
    GLShaderListWriterReleaseDataAtIndex(0, pSLWriter);
    GLShaderListWriterReleaseDataAtIndex(1, pSLWriter);
} // GLShaderListWriterReleaseData

static void GLShaderListWriterDelete(GLShaderListWriterDataRef pSLWriter)
{
    if(pSLWriter != NULL)
    {
        GLShaderListWriterReleaseSuffixes(pSLWriter);
        GLShaderListWriterReleasePaths(pSLWriter);
        GLShaderListWriterReleaseData(pSLWriter);
        GLShaderListWriterReleaseShaders(pSLWriter);
        GLShaderListWriterReleaseEnumerator(pSLWriter);
        
        free(pSLWriter);
        
        pSLWriter = NULL;
    } // if
} // GLShaderListWriterDelete

#pragma mark -
#pragma mark Private - Utilities - Constructor

static GLShaderListWriterDataRef GLShaderListWriterCreate(const size_t nCapacity)
{
    GLShaderListWriterDataRef pSLWriter = (GLShaderListWriterDataRef)calloc(1, sizeof(GLShaderListWriterData));
    
    if(pSLWriter != NULL)
    {
        pSLWriter->mpShaders   = [[NSMutableDictionary alloc] initWithCapacity:nCapacity];
        pSLWriter->mpSuffix[0] = [[NSString alloc] initWithString:kGLShaderSuffixFrag];
        pSLWriter->mpSuffix[1] = [[NSString alloc] initWithString:kGLShaderSuffixVert];
        pSLWriter->mnSLength   = 3;
    } // if
    
    return pSLWriter;
} // GLShaderListWriterCreate

#pragma mark -
#pragma mark Private - Utilities - Enumerator

static NSDirectoryEnumerator *GLShaderListWriterCreateEnumerator(GLShaderListWriterDataRef pSLWriter)
{
    NSDirectoryEnumerator *pEnumerator = nil;
    
    if(pSLWriter->mpBaseDir)
    {
        NSURL *pDirURL = [NSURL fileURLWithPath:pSLWriter->mpBaseDir
                                    isDirectory:YES];
        if(pDirURL)
        {
            NSArray *pIsDirKey = [NSArray arrayWithObject:NSURLIsDirectoryKey];
            
            if(pIsDirKey)
            {
                NSFileManager *pFileManager = [NSFileManager defaultManager];
                
                if(pFileManager)
                {
                    BOOL (^fileErrorHandler)(NSURL *, NSError *) = ^(NSURL *pURL, NSError *pError)
                    {
                        if(pURL)
                        {
                            NSLog(@">> ERROR: File manager encountered a problem for the URL %@", pURL);
                        } // if
                        
                        NSLogLocalizedError(pError);
                        
                        return YES;
                    };
                    
                    pEnumerator = [[pFileManager enumeratorAtURL:pDirURL
                                      includingPropertiesForKeys:pIsDirKey
                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                    errorHandler:fileErrorHandler] retain];
                } // if
            } // if
        } // if
    } // if
    
    return  pEnumerator;
} // GLShaderListWriterCreateEnumerator

#pragma mark -
#pragma mark Private - Utilities - Dictionary

static void GLShaderListWriterAddDictionary(NSURL *pURL,
                                            GLShaderListWriterDataRef pSLWriter)
{
    if(pSLWriter->mpData[0] && pSLWriter->mpData[1])
    {
        NSString *pFile   = nil;
        NSError  *pError  = nil;
        
        if([pURL getResourceValue:&pFile
                           forKey:NSURLNameKey
                            error:&pError])
        {
            NSUInteger nFLen   = [pFile length];
            NSUInteger nLen    = nFLen - pSLWriter->mnSLength;
            NSRange   range    = NSMakeRange(0, nLen);
            NSString *pDirName = [pFile substringWithRange:range];
            
            if(pDirName)
            {
                NSMutableDictionary *pShader = [NSMutableDictionary new];
                
                if(pShader)
                {
                    [pShader setObject:pSLWriter->mpData[0]
                                forKey:kGLShaderKeyFrag];
                    
                    [pShader setObject:pSLWriter->mpData[1]
                                forKey:kGLShaderKeyVert];
                    
                    [pSLWriter->mpShaders setObject:pShader
                                             forKey:pDirName];
                    
                    [pShader release];
                } // if
            } // if
        } // if
        else
        {
            NSLogError(pError);
        } // else
    } // if
} // GLShaderListWriterAddDictionary

#pragma mark -
#pragma mark Private - Utilities - Data

static void GLShaderListWriterAddFromURLAtIndex(const NSUInteger nIndex,
                                                NSURL *pURL,
                                                GLShaderListWriterDataRef pSLWriter)
{
    NSError *pError = nil;
    NSData  *pData  = [[NSData alloc] initWithContentsOfURL:pURL
                                                    options:NSDataReadingMappedIfSafe
                                                      error:&pError];
    
    if(pData)
    {
        GLShaderListWriterReleaseDataAtIndex(nIndex, pSLWriter);
        
        pSLWriter->mpData[nIndex] = pData;
    } // if
    else
    {
        NSLogError(pError);
    } // else
} // GLShaderListWriterAddFromURLAtIndex

static inline void GLShaderListWriterAddFragData(NSURL *pURL,
                                                 GLShaderListWriterDataRef pSLWriter)
{
    GLShaderListWriterAddFromURLAtIndex(0, pURL, pSLWriter);
} // GLShaderListWriterAddFragData

static inline void GLShaderListWriterAddVertData(NSURL *pURL,
                                                 GLShaderListWriterDataRef pSLWriter)
{
    GLShaderListWriterAddFromURLAtIndex(1, pURL, pSLWriter);
} // GLShaderListWriterAddVertData

#pragma mark -
#pragma mark Private - Utilities - Authoring

static BOOL GLShaderListWriterSerialize(GLShaderListWriterDataRef pSLWriter)
{
    BOOL bSuccess = pSLWriter->mpPathname != nil;
    
    if(bSuccess)
    {
        bSuccess = [pSLWriter->mpShaders writeToFile:pSLWriter->mpPathname
                                          atomically:YES];
    } // if
    else
    {
        NSString *pDestination = [kGLShaderDocDir stringByExpandingTildeInPath];
        
        bSuccess = pDestination != nil;
        
        if(bSuccess)
        {
            bSuccess = [pSLWriter->mpShaders writeToFile:pDestination
                                              atomically:YES];
        } // if
    } // else
    
    return bSuccess;
} // GLShaderListWriterSerialize

static void GLShaderListWriterAddFromURL(const BOOL bLogResults,
                                         NSURL *pURL,
                                         GLShaderListWriterDataRef pSLWriter)
{
    NSError  *pError  = nil;
    NSNumber *pIsDir  = nil;
    
    if(![pURL getResourceValue:&pIsDir
                        forKey:NSURLIsDirectoryKey
                         error:&pError])
    {
        NSLogError(pError);
    } // if
    else if(![pIsDir boolValue])
    {
        NSString *pPath = [pURL absoluteString];
        
        if(pPath)
        {
            if([pPath hasSuffix:pSLWriter->mpSuffix[0]])
            {
                GLShaderListWriterAddFragData(pURL, pSLWriter);
            } // if
            else if([pPath hasSuffix:pSLWriter->mpSuffix[1]])
            {
                GLShaderListWriterAddVertData(pURL, pSLWriter);
            } // if
            
            GLShaderListWriterAddDictionary(pURL, pSLWriter);
            
            if(bLogResults)
            {
                NSLog(@">> Processing %@",pPath);
            } // if
        } // if
    } // else if
} // GLShaderListWriterAddFromURL

static BOOL GLShaderListWriterAuthor(const BOOL bLogResults,
                                     GLShaderListWriterDataRef pSLWriter)
{
    BOOL bSuccess = (pSLWriter->mpEnumerator && pSLWriter->mpShaders);
    
    if(bSuccess)
    {
        NSURL *pURL = nil;
        
        for(pURL in pSLWriter->mpEnumerator)
        {
            GLShaderListWriterAddFromURL(bLogResults, pURL, pSLWriter);
        } // for
        
        bSuccess = GLShaderListWriterSerialize(pSLWriter);
    } // if
    
    return bSuccess;
} // GLShaderListWriterAuthor

#pragma mark -
#pragma mark Private - Utilities - Accessors

static BOOL GLShaderListWriterSetBaseDirectory(NSString *pInBaseDir,
                                               GLShaderListWriterDataRef pSLWriter)
{
    BOOL bSuccess = pInBaseDir != nil;
    
    if(bSuccess)
    {
        NSString *pOutBaseDir = [[NSString alloc] initWithString:pInBaseDir];
        
        if(pOutBaseDir)
        {
            GLShaderListWriterReleaseBaseDirectory(pSLWriter);
            
            pSLWriter->mpBaseDir = pOutBaseDir;
            
            NSDirectoryEnumerator *pEnumerator = GLShaderListWriterCreateEnumerator(pSLWriter);
            
            bSuccess = pEnumerator != nil;
            
            if(bSuccess)
            {
                GLShaderListWriterReleaseEnumerator(pSLWriter);
                
                pSLWriter->mpEnumerator = pEnumerator;
            } // if
        } // if
    } // if
    
    return bSuccess;
} // GLShaderListWriterSetBaseDirectory

static inline BOOL GLShaderListWriterSetPathname(NSString *pInWritePath,
                                                 GLShaderListWriterDataRef pSLWriter)
{
    BOOL bSuccess = pInWritePath != nil;
    
    if(bSuccess)
    {
        NSString *pOutWritePath = [[NSString alloc] initWithString:pInWritePath];
        
        if(pOutWritePath)
        {
            GLShaderListWriterReleaseWritePath(pSLWriter);
            
            pSLWriter->mpPathname = pOutWritePath;
        } // if
    } // if
    
    return bSuccess;
} // GLShaderListWriterSetPathname

static inline BOOL GLShaderListWriterSetSuffixFrag(NSString *pInSuffixFrag,
                                                   GLShaderListWriterDataRef pSLWriter)
{
    BOOL bSuccess = pInSuffixFrag != nil;
    
    if(bSuccess)
    {
        NSString *pOutSuffixFrag = [[NSString alloc] initWithString:pInSuffixFrag];
        
        if(pOutSuffixFrag)
        {
            GLShaderListWriterReleaseSuffixAtIndex(0, pSLWriter);
            
            pSLWriter->mpSuffix[0] = pOutSuffixFrag;
            pSLWriter->mnSLength   = [pSLWriter->mpSuffix[0] length] + 1;
        } // if
    } // if
    
    return bSuccess;
} // GLShaderListWriterSetSuffixFrag

static inline BOOL GLShaderListWriterSetSuffixVert(NSString *pInSuffixVert,
                                                   GLShaderListWriterDataRef pSLWriter)
{
    BOOL bSuccess = pInSuffixVert != nil;
    
    if(bSuccess)
    {
        NSString *pOutSuffixVert = [[NSString alloc] initWithString:pInSuffixVert];
        
        if(pOutSuffixVert)
        {
            GLShaderListWriterReleaseSuffixAtIndex(1, pSLWriter);
            
            pSLWriter->mpSuffix[0] = pOutSuffixVert;
        } // if
    } // if
    
    return bSuccess;
} // GLShaderListWriterSetSuffixVert

#pragma mark -

@implementation GLShaderListWriter

#pragma mark -
#pragma mark Public - Initializers

- (id) init
{
	self = [super init];
	
	if(self)
	{
		mpSLWriter = GLShaderListWriterCreate(0);
	} // if
	
	return(self);
} // init

+ (id) writer
{
	return [[[GLShaderListWriter allocWithZone:[self zone]] init] autorelease];
} // writer

#pragma mark -
#pragma mark Public - Destructor

- (void) dealloc
{
	GLShaderListWriterDelete(mpSLWriter);
    
    [super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Accessors

- (BOOL) setBaseDirectory:(NSString *)theBaseDir
{
    return GLShaderListWriterSetBaseDirectory(theBaseDir, mpSLWriter);
} // setBaseDirectory

- (BOOL) setPathname:(NSString *)thePath
{
    return GLShaderListWriterSetPathname(thePath, mpSLWriter);
} // setPathname

- (BOOL) setSuffixVertex:(NSString *)theVertSuffix
{
    return GLShaderListWriterSetSuffixVert(theVertSuffix, mpSLWriter);
} // setSuffixVertex

- (BOOL) setSuffixFragment:(NSString *)theFragSuffix
{
    return GLShaderListWriterSetSuffixFrag(theFragSuffix, mpSLWriter);
} // setSuffixFragment

- (NSDictionary *) dictionary
{
    return mpSLWriter->mpShaders;
} // dictionary

#pragma mark -
#pragma mark Public - Utilities

- (BOOL) write:(const BOOL)doLog
{
    return GLShaderListWriterAuthor(doLog, mpSLWriter);
} // write

@end
