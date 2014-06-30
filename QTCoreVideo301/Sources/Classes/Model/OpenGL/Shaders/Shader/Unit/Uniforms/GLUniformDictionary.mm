/*
     File: GLUniformDictionary.mm
 Abstract: 
 A utility toolkit for managing dictionary of shader uniforms
 
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
#pragma mark Private - Headers - STL

#import <string>
#import <unordered_map>

#pragma mark -
#pragma mark Private - Headers - Project

#import "GLUseProgram.h"

#import "GLSizes.h"

#import "GLSLUnitDictKeys.h"
#import "GLSLUnitDictTypes.h"

#import "GLUniformDictionary.h"

#pragma mark -
#pragma mark Private - Data Structure

typedef std::unordered_map<std::string,GLuint> GLLocations;

struct GLUniformDictionaryData
{
    NSMutableDictionary        *mpDictionary;
    NSMutableDictionary        *mpAttributes;
    GL::Program::Use::Facade   *mpProgram;
    GLLocations                 m_Locations;
};

typedef struct GLUniformDictionaryData   GLUniformDictionaryData;

#pragma mark -
#pragma mark Private - Utilities - Constructor

static GLUniformDictionaryDataRef GLUniformDictionaryCreate(const GLuint nProgram)
{
    GLUniformDictionaryDataRef pUniforms = new GLUniformDictionaryData;
    
    if(pUniforms != NULL)
    {
        pUniforms->mpDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
        pUniforms->mpAttributes = nil;
        pUniforms->mpProgram    = new GL::Program::Use::Facade(nProgram);
    } // if
    
    return pUniforms;
} // GLUniformDictionaryCreate

#pragma mark -
#pragma mark Private - Utilities - Destructors

static inline void GLUniformDictionaryDeleteProgram(GLUniformDictionaryDataRef pUniforms)
{
    if(pUniforms->mpProgram != NULL)
    {
        delete pUniforms->mpProgram;
        
        pUniforms->mpProgram = NULL;
    } // if
} // GLUniformDictionaryDeleteProgram

static inline void GLUniformDictionaryClearLocations(GLUniformDictionaryDataRef pUniforms)
{
    if(!pUniforms->m_Locations.empty())
    {
        pUniforms->m_Locations.clear();
    } // if
} // GLUniformDictionaryClearLocations

static inline void GLUniformDictionaryReleaseDictionary(GLUniformDictionaryDataRef pUniforms)
{
    if(pUniforms->mpDictionary)
    {
        [pUniforms->mpDictionary release];
    } // if
} // GLUniformDictionaryReleaseDictionary

static inline void GLUniformDictionaryReleaseAttributes(GLUniformDictionaryDataRef pUniforms)
{
    if(pUniforms->mpAttributes)
    {
        [pUniforms->mpAttributes release];
    } // if
} // GLUniformDictionaryReleaseAttributes

static void GLUniformDictionaryDelete(GLUniformDictionaryDataRef pUniforms)
{
    if(pUniforms != NULL)
    {
        GLUniformDictionaryClearLocations(pUniforms);
        GLUniformDictionaryReleaseDictionary(pUniforms);
        GLUniformDictionaryReleaseAttributes(pUniforms);
        GLUniformDictionaryDeleteProgram(pUniforms);
        
        delete pUniforms;
        
        pUniforms = NULL;
    } // if
} // GLUniformDictionaryDeleteLocations

#pragma mark -
#pragma mark Private - Utilities - Accessors

static inline BOOL GLUniformDictionarySetIsProgram(const GLuint nProgram,
                                                   GLUniformDictionaryDataRef pUniforms)
{
    GL::Program::Use::Facade *pProgram = new GL::Program::Use::Facade(nProgram);
    
    if(pProgram != NULL)
    {
        GLUniformDictionaryDeleteProgram(pUniforms);
        
        pUniforms->mpProgram = pProgram;
    } // if
    
    pUniforms->mpProgram = new GL::Program::Use::Facade(nProgram);
    
    return pUniforms->mpProgram->isProgram();
} // GLUniformDictionarySetIsProgram

static BOOL GLUniformDictionarySetLocation(NSString *pName,
                                           GLUniformDictionaryDataRef pUniforms)
{
    GLint nLocation = -1;
    
    if(pName && pUniforms->mpProgram->isProgram())
    {
        std::string name = [pName cStringUsingEncoding:NSASCIIStringEncoding];
        
        if(!name.empty())
        {
            if(pUniforms->mpAttributes)
            {
                [pUniforms->mpAttributes release];
            } // if
            
            pUniforms->mpAttributes = [[NSMutableDictionary alloc] initWithCapacity:0];
            
            if(pUniforms->mpAttributes)
            {
                auto pIter = pUniforms->m_Locations.find(name);
                
                if(pIter != pUniforms->m_Locations.cend())
                {
                    nLocation = pIter->second;
                    
                    [pUniforms->mpAttributes setObject:[NSNumber numberWithInt:nLocation]
                                                forKey:kGLSLUniformLocKey];
                } // if
                else
                {
                    nLocation = glGetUniformLocation(pUniforms->mpProgram->program(),
                                                     name.c_str());
                    
                    if(nLocation == -1)
                    {
                        NSLog(@">> [OpenGL Uniform Dictionary] WARNING: No such uniform named \"%s\"!", name.c_str());
                    } // if
                    else
                    {
                        [pUniforms->mpAttributes setObject:[NSNumber numberWithInt:nLocation]
                                                    forKey:kGLSLUniformLocKey];
                        
                        pUniforms->m_Locations[name] = nLocation;
                    } // else
                } // else
            } // if
        } // if
    } // if
    
    return nLocation > -1;
} // GLUniformDictionaryGetLocation

#pragma mark -
#pragma mark Private - Utilities - Add Values

static void GLUniformDictionaryAddValue(NSString *pName,
                                        const GLint nValue,
                                        GLUniformDictionaryDataRef pUniforms)
{
    if(GLUniformDictionarySetLocation(pName, pUniforms))
    {
        [pUniforms->mpAttributes setObject:[NSNumber numberWithInt:kGLSLUniform1i]
                                    forKey:kGLSLUniformTypeKey];
        
        [pUniforms->mpAttributes setObject:[NSNumber numberWithInt:nValue]
                                    forKey:kGLSLUniformValueKey];
        
        [pUniforms->mpDictionary setObject:pUniforms->mpAttributes
                                    forKey:pName];
    } // if
} // GLUniformDictionaryAddValue

static void GLUniformDictionaryAddValue(NSString *pName,
                                        const GLfloat nValue,
                                        GLUniformDictionaryDataRef pUniforms)
{
    if(GLUniformDictionarySetLocation(pName, pUniforms))
    {
        [pUniforms->mpAttributes setObject:[NSNumber numberWithInt:kGLSLUniform1f]
                                    forKey:kGLSLUniformTypeKey];
        
        [pUniforms->mpAttributes setObject:[NSNumber numberWithFloat:nValue]
                                    forKey:kGLSLUniformValueKey];
        
        [pUniforms->mpDictionary setObject:pUniforms->mpAttributes
                                    forKey:pName];
    } // if
} // GLUniformDictionaryAddValue

static void GLUniformDictionaryAddValues(NSString *pName,
                                         const GLSLUniformScalarTypes nType,
                                         const GLint * const pValue,
                                         GLUniformDictionaryDataRef pUniforms)
{
    if(GLUniformDictionarySetLocation(pName, pUniforms))
    {
        NSUInteger nLength = nType * kGLSizeSignedInt;
        
        if(nLength)
        {
            NSNumber *pType = nil;
            
            switch(nType)
            {
                case kGLSL2Scalars:
                    pType = [NSNumber numberWithInt:kGLSLUniform2i];
                    break;
                case kGLSL3Scalars:
                    pType = [NSNumber numberWithInt:kGLSLUniform3i];
                    break;
                case kGLSL4Scalars:
                    pType = [NSNumber numberWithInt:kGLSLUniform4i];
                    break;
                    
                case kGLSLScalar:
                default:
                    break;
            } // switch
            
            if(pType)
            {
                [pUniforms->mpAttributes setObject:pType
                                            forKey:kGLSLUniformTypeKey];
                
                [pUniforms->mpAttributes setObject:[NSData dataWithBytes:pValue length:nLength]
                                            forKey:kGLSLUniformValueKey];
                
                [pUniforms->mpDictionary setObject:pUniforms->mpAttributes
                                            forKey:pName];
            } // if
        } // if
    } // if
} // GLUniformDictionaryAddValues

static void GLUniformDictionaryAddValues(NSString *pName,
                                         const GLSLUniformScalarTypes nType,
                                         const GLfloat * const pValue,
                                         GLUniformDictionaryDataRef pUniforms)
{
    if(GLUniformDictionarySetLocation(pName, pUniforms))
    {
        NSUInteger nLength = nType * kGLSizeFloat;
        
        if(nLength)
        {
            NSNumber *pType = nil;
            
            switch(nType)
            {
                case kGLSL2Scalars:
                    pType = [NSNumber numberWithInt:kGLSLUniform2f];
                    break;
                case kGLSL3Scalars:
                    pType = [NSNumber numberWithInt:kGLSLUniform3f];
                    break;
                case kGLSL4Scalars:
                    pType = [NSNumber numberWithInt:kGLSLUniform4f];
                    break;
                    
                case kGLSLScalar:
                default:
                    break;
            } // switch
            
            if(pType)
            {
                [pUniforms->mpAttributes setObject:pType
                                            forKey:kGLSLUniformTypeKey];
                
                [pUniforms->mpAttributes setObject:[NSData dataWithBytes:pValue length:nLength]
                                            forKey:kGLSLUniformValueKey];
                
                [pUniforms->mpDictionary setObject:pUniforms->mpAttributes
                                            forKey:pName];
            } // if
        } // if
    } // if
} // GLUniformDictionaryAddValues

static void GLUniformDictionaryAddValues(NSString *pName,
                                         const GLSLUniformVectorTypes nType,
                                         const GLuint nCount,
                                         const GLint * const pVectors,
                                         GLUniformDictionaryDataRef pUniforms)
{
    if(GLUniformDictionarySetLocation(pName, pUniforms))
    {
        NSUInteger nLength = nType * nCount * kGLSizeSignedInt;
        
        if(nLength)
        {
            NSNumber *pType = nil;
            
            switch(nType)
            {
                case kGLSLVector:
                    pType = [NSNumber numberWithInt:kGLSLUniform1iv];
                    break;
                case kGLSL2Vector:
                    pType = [NSNumber numberWithInt:kGLSLUniform2iv];
                    break;
                case kGLSL3Vector:
                    pType = [NSNumber numberWithInt:kGLSLUniform3iv];
                    break;
                case kGLSL4Vector:
                    pType = [NSNumber numberWithInt:kGLSLUniform4iv];
                    break;
            } // switch
            
            if(pType)
            {
                [pUniforms->mpAttributes setObject:pType
                                            forKey:kGLSLUniformTypeKey];
                
                [pUniforms->mpAttributes setObject:[NSData dataWithBytes:pVectors length:nLength]
                                            forKey:kGLSLUniformValueKey];
                
                [pUniforms->mpAttributes setObject:[NSNumber numberWithInt:nCount]
                                            forKey:kGLSLUniformCountKey];
                
                [pUniforms->mpDictionary setObject:pUniforms->mpAttributes
                                            forKey:pName];
            } // if
        } // if
    } // if
} // GLUniformDictionaryAddValues

static void GLUniformDictionaryAddValues(NSString *pName,
                                         const GLSLUniformVectorTypes nType,
                                         const GLuint nCount,
                                         const GLfloat * const pVectors,
                                         GLUniformDictionaryDataRef pUniforms)
{
    if(GLUniformDictionarySetLocation(pName, pUniforms))
    {
        const NSUInteger nLength = nType * nCount * kGLSizeFloat;
        
        if(nLength)
        {
            NSNumber *pType = nil;
            
            switch(nType)
            {
                case kGLSLVector:
                    pType = [NSNumber numberWithInt:kGLSLUniform1fv];
                    break;
                case kGLSL2Vector:
                    pType = [NSNumber numberWithInt:kGLSLUniform2fv];
                    break;
                case kGLSL3Vector:
                    pType = [NSNumber numberWithInt:kGLSLUniform3fv];
                    break;
                case kGLSL4Vector:
                    pType = [NSNumber numberWithInt:kGLSLUniform4fv];
                    break;
            } // switch
            
            if(pType)
            {
                [pUniforms->mpAttributes setObject:pType
                                            forKey:kGLSLUniformTypeKey];
                
                [pUniforms->mpAttributes setObject:[NSData dataWithBytes:pVectors length:nLength]
                                            forKey:kGLSLUniformValueKey];
                
                [pUniforms->mpAttributes setObject:[NSNumber numberWithInt:nCount]
                                            forKey:kGLSLUniformCountKey];
                
                [pUniforms->mpDictionary setObject:pUniforms->mpAttributes
                                            forKey:pName];
            } // if
        } // if
    } // if
} // GLUniformDictionaryAddValues

static void GLUniformDictionaryAddValues(NSString *pName,
                                         const GLSLUniformMatrixTypes nType,
                                         const GLuint nCount,
                                         const BOOL bTransposed,
                                         const GLfloat * const pMatrices,
                                         GLUniformDictionaryDataRef pUniforms)
{
    if(GLUniformDictionarySetLocation(pName, pUniforms))
    {
        const NSUInteger nLength = nType * nType * nCount * kGLSizeFloat;
        
        if(nLength)
        {
            NSNumber *pType = nil;
            
            switch(nType)
            {
                case kGLSL2Matrix:
                    pType = [NSNumber numberWithInt:kGLSLUniform2x2fv];
                    break;
                case kGLSL3Matrix:
                    pType = [NSNumber numberWithInt:kGLSLUniform3x3fv];
                    break;
                case kGLSL4Matrix:
                    pType = [NSNumber numberWithInt:kGLSLUniform4x4fv];
                    break;
            } // switch
            
            if(pType)
            {
                [pUniforms->mpAttributes setObject:pType
                                            forKey:kGLSLUniformTypeKey];
                
                [pUniforms->mpAttributes setObject:[NSData dataWithBytes:pMatrices length:nLength]
                                            forKey:kGLSLUniformValueKey];
                
                [pUniforms->mpAttributes setObject:[NSNumber numberWithInt:nCount]
                                            forKey:kGLSLUniformCountKey];
                
                [pUniforms->mpAttributes setObject:[NSNumber numberWithInt:bTransposed]
                                            forKey:kGLSLUniformTransposeKey];
                
                [pUniforms->mpDictionary setObject:pUniforms->mpAttributes
                                            forKey:pName];
            } // if
        } // if
    } // if
} // GLUniformDictionaryAddValues

#pragma mark -
#pragma mark Private - Utilities - To be Deprecated

static GLint GLUniformDictionaryGetLocation(const GLuint nProgram,
                                            NSString *pName)
{
    GLint nLocation = -1;
    
    if(pName)
    {
        const GLchar *pUniform = (GLchar *)[pName cStringUsingEncoding:NSASCIIStringEncoding];
        
        if(pUniform != NULL)
        {
            nLocation = glGetUniformLocation(nProgram, pUniform);
            
            if(nLocation == -1)
            {
                NSLog(@">> [OpenGL Shader Kit] WARNING: No such uniform named \"%s\"!", pUniform);
            } // if
        } // if
    } // if
    
	return nLocation;
} // GLUniformDictionaryGetLocation

@implementation GLUniformDictionary

#pragma mark -
#pragma mark Public - Initializers

- (id) init
{
    self = [super init];
    
    if(self)
    {
        mpUniforms = GLUniformDictionaryCreate(0);
    } // if
    
    return self;
} // init

- (id) initWithProgram:(const GLuint)theProgram
{
    self = [super init];
    
    if(self)
    {
        mpUniforms = GLUniformDictionaryCreate(theProgram);
    } // if
    
    return self;
} // initWithProgram

+ (id) uniforms
{
	return [[[GLUniformDictionary allocWithZone:[self zone]] init] autorelease];
} // uniforms

+ (id) uniformsWithProgram:(const GLuint)theProgram
{
	return [[[GLUniformDictionary allocWithZone:[self zone]] initWithProgram:theProgram] autorelease];
} // uniformsWithProgram

#pragma mark -
#pragma mark Public - Utilities

- (void) addIntegerScalar:(NSString *)theName
                    value:(const GLint)theValue
{
    GLUniformDictionaryAddValue(theName, theValue, mpUniforms);
} // addIntegerScalar

- (void) addIntegerScalars:(NSString *)theName
                      type:(const GLSLUniformScalarTypes)theType
                     value:(const GLint *)theValue
{
    GLUniformDictionaryAddValues(theName, theType, theValue, mpUniforms);
} // addIntegerScalars

- (void) addIntegerVectors:(NSString *)theName
                      type:(const GLSLUniformVectorTypes)theType
                     count:(const GLuint)theCount
                   vectors:(const GLint *)theVectors
{
    GLUniformDictionaryAddValues(theName, theType, theCount, theVectors, mpUniforms);
} // addIntegerVectors

- (void) addFloatScalar:(NSString *)theName
                  value:(const GLfloat)theValue
{
    GLUniformDictionaryAddValue(theName, theValue, mpUniforms);
} // addFloatScalar

- (void) addFloatScalars:(NSString *)theName
                    type:(const GLSLUniformScalarTypes)theType
                   value:(const GLfloat *)theValue
{
    GLUniformDictionaryAddValues(theName, theType, theValue, mpUniforms);
} // addFloatScalars

- (void) addFloatVectors:(NSString *)theName
                    type:(const GLSLUniformVectorTypes)theType
                   count:(const GLuint)theCount
                 vectors:(const GLfloat *)theVectors
{
    GLUniformDictionaryAddValues(theName, theType, theCount, theVectors, mpUniforms);
} // addFloatVectors

- (void) addFloatMatrices:(NSString *)theName
                     type:(const GLSLUniformMatrixTypes)theType
                    count:(const GLuint)theCount
                transpose:(const BOOL)theFlag
                 matrices:(const GLfloat *)theMatrices
{
    GLUniformDictionaryAddValues(theName, theType, theCount, theFlag, theMatrices, mpUniforms);
} // addFloatMatrices

#pragma mark -
#pragma mark Public - Destructor

- (void) dealloc
{
    GLUniformDictionaryDelete(mpUniforms);
    
	[super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Utilities

- (void) enable
{
    mpUniforms->mpProgram->enable();
} // enable

- (void) disable
{
    mpUniforms->mpProgram->disable();
} // disable

#pragma mark -
#pragma mark Public - Accessor

- (BOOL) setProgram:(const GLuint)theProgram;
{
    return GLUniformDictionarySetIsProgram(theProgram, mpUniforms);
} // setProgram

- (NSDictionary *) dictionary
{
    return mpUniforms->mpDictionary;
} // dictionary

@end