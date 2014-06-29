/*
     File: OpenGLQuery.mm
 Abstract: 
 Utility toolkit for constructing a query of OpenGL Core profile features.
 
  Version: 1.0
 
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
#pragma mark Headers

// STL containers
#import <sstream>

// Mac OS X OpenGL frameworks
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>

// OpenGL string utilities
#import "OpenGLString.h"

// Query Header
#import "OpenGLQuery.h"

#pragma mark -
#pragma mark Private - Data Structures

// More (private) OpenGL container types
typedef std::stringstream                       GLsstream;
typedef std::map<GLstring, GLstring>            GLextdb;
typedef std::map<GLstring, GLstring>::iterator  GLextdbitr;

// Renderer, version, and vendor data structures
struct GLQueryString
{
    GLstring m_Renderer;
    GLstring m_Version;
    GLstring m_Vendor;
};

typedef struct GLQueryString   GLQueryString;

// Apple, ARB, and EXT features and their strings
struct GLQueryFeatures
{
    GLfeatures m_Apple;
    GLfeatures m_ARB;
    GLfeatures m_EXT;

    CFMutableArrayRef mpApple;
    CFMutableArrayRef mpARB;
    CFMutableArrayRef mpEXT;
};

typedef struct GLQueryFeatures   GLQueryFeatures;

// Apple, ARB, and EXT features as an associative array
struct GLQueryDB
{
	GLextdb     m_Exts;
	GLextdbitr  m_ExtsEnd;
};

typedef struct GLQueryDB  GLQueryDB;

// OpenGL query strings, extensions (or features), including
// a dictionary representation
struct GLQuery
{
    GLQueryString    m_String;
    GLQueryFeatures  m_Features;
	GLQueryDB        m_DB;
};

typedef struct GLQuery GLQuery;

#pragma mark -
#pragma mark Private - Utilities - Strings

// OpenGL features as a string, where each feature is separated
// using a seperator string
static GLstring GLQueryCreateStringFeatures(const GLstring &rSeperator,
											const GLfeatures &rFeatures)
{
	GLstring string;
	
	GLuint iMax = rFeatures.size();
	
	if( iMax )
	{
		GLuint i;
		
		GLsstream oss;
		
        GLstring seperator = !rSeperator.empty() ? rSeperator : " ";
        
		iMax--;
		
		for( i = 0; i < iMax; ++i )
		{
			oss << rFeatures[i] << seperator;
		} // for
		
		oss << rFeatures[iMax];
		
		string = oss.str();
	} // if
	
	return string;
} // GLQueryCreateStringFeatures

// OpenGL Apple features as a string, where each feature is separated
// using a seperator string
static inline GLstring GLQueryCreateStringApple(const GLstring &rSeperator,
												const GLQueryRef pQuery)
{
	return GLQueryCreateStringFeatures(rSeperator, pQuery->m_Features.m_Apple);
} // GLQueryCreateStringApple

// OpenGL ARB features as a string, where each feature is separated
// using a seperator string
static inline GLstring GLQueryCreateStringARB(const GLstring &rSeperator,
											  const GLQueryRef pQuery)
{
	return GLQueryCreateStringFeatures(rSeperator, pQuery->m_Features.m_ARB);
} // GLQueryCreateStringARB

// OpenGL EXT features as a string, where each feature is separated
// using a seperator string
static inline GLstring GLQueryCreateStringEXT(const GLstring &rSeperator,
											  const GLQueryRef pQuery)
{
	return GLQueryCreateStringFeatures(rSeperator, pQuery->m_Features.m_EXT);
} // GLQueryCreateStringEXT

#pragma mark -
#pragma mark Private - Utilities - Arrays

// Search string for feature family
static const GLchar *kGLQueryStringApple = "GL_APPLE";
static const GLchar *kGLQueryStringARB   = "GL_ARB";
static const GLchar *kGLQueryStringEXT   = "GL_EXT";

// String feature family length
static const size_t kGLQuerySzStringApple = 8;
static const size_t kGLQuerySzStringARB   = 6;
static const size_t kGLQuerySzStringEXT   = 6;

// Found Apple feature
static inline bool GLQueryStringIsApple(const GLchar * const pExtension)
{
	return( strncmp(pExtension, kGLQueryStringApple, kGLQuerySzStringApple) == 0 );
} // GLQueryStringIsApple

// Found ARB feature
static inline bool GLQueryStringIsARB(const GLchar * const pExtension)
{
	return( strncmp(pExtension, kGLQueryStringARB, kGLQuerySzStringARB) == 0 );
} // GLQueryStringIsARB

// Found EXT feature
static inline bool GLQueryStringIsEXT(const GLchar * const pExtension)
{
	return( strncmp(pExtension, kGLQueryStringEXT, kGLQuerySzStringEXT) == 0 );
} // GLQueryStringIsEXT

// Add Apple feature
static inline void GLQueryAddFeatureApple(const GLchar * const pFeature,
										  GLQueryRef pQuery)
{
	GLstring feature(pFeature);
	
	pQuery->m_Features.m_Apple.push_back(feature);
	
	pQuery->m_DB.m_Exts[feature] = kGLQueryStringApple;
} // GLQueryAddFeatureApple

// Add ARB feature
static inline void GLQueryAddFeatureARB(const GLchar * const pFeature,
										GLQueryRef pQuery)
{
	GLstring feature(pFeature);
	
	pQuery->m_Features.m_ARB.push_back(feature);
	
	pQuery->m_DB.m_Exts[feature] = kGLQueryStringARB;
} // GLQueryAddFeatureARB

// Add EXT feature
static inline void GLQueryAddFeatureEXT(const GLchar * const pFeature,
										GLQueryRef pQuery)
{
	GLstring feature(pFeature);
	
	pQuery->m_Features.m_EXT.push_back(feature);
	
	pQuery->m_DB.m_Exts[feature] = kGLQueryStringEXT;
} // GLQueryAddFeatureEXT

// Query OpenGL and get a string representation of extension (or feature).
static void GLQueryAppendFeature(const GLuint &rExtIdx,
								 GLQueryRef pQuery)
{
    const GLchar *pFeature = (const GLchar *)glGetStringi(GL_EXTENSIONS, rExtIdx);
	
	if( pFeature != NULL )
	{
		if( GLQueryStringIsApple(pFeature) )
		{
			GLQueryAddFeatureApple(pFeature, pQuery);
		} // if
		else if( GLQueryStringIsARB(pFeature) )
		{
			GLQueryAddFeatureARB(pFeature, pQuery);
		} // else if
		else if( GLQueryStringIsEXT(pFeature) )
		{
			GLQueryAddFeatureEXT(pFeature, pQuery);
		} // else if
	} // if
} // GLQueryAppendFeature

#pragma mark -
#pragma mark Private - Utilities - Destructors

// Clear all strings
static inline void GLQueryClearStrings(GLQueryRef pQuery)
{
	pQuery->m_String.m_Renderer.clear();
	pQuery->m_String.m_Vendor.clear();
	pQuery->m_String.m_Version.clear();
} // GLQueryClearStrings

// Clear all features
static inline void GLQueryClearFeatures(GLQueryRef pQuery)
{
	pQuery->m_Features.m_Apple.clear();
	pQuery->m_Features.m_ARB.clear();
	pQuery->m_Features.m_EXT.clear();
} // GLQueryClearFeatures

// Release all arrays
static inline void GLQueryReleaseArrays(GLQueryRef pQuery)
{
	if(pQuery->m_Features.mpApple != NULL)
    {
        CFRelease(pQuery->m_Features.mpApple);
    } // if
    
	if(pQuery->m_Features.mpARB != NULL)
    {
        CFRelease(pQuery->m_Features.mpARB);
    } // if
    
	if(pQuery->m_Features.mpEXT != NULL)
    {
        CFRelease(pQuery->m_Features.mpEXT);
    } // if
} // GLQueryReleaseArrays

// Clear extensions' map
static inline void GLQueryClearDB(GLQueryRef pQuery)
{
	pQuery->m_DB.m_Exts.clear();
} // GLQueryClearDB

#pragma mark -
#pragma mark Private - Utilities - Constructors

// Create a vector of extensions (or features)
static void GLQueryCreateFeatures(GLQueryRef pQuery)
{
    GLuint  nExtIdx = 0;
    GLint   nExtCnt = 0;
    
    glGetIntegerv(GL_NUM_EXTENSIONS, &nExtCnt);
    
    for( nExtIdx = 0; nExtIdx < nExtCnt; ++nExtIdx )
    {
		GLQueryAppendFeature(nExtIdx, pQuery);
    } // for
	
	pQuery->m_DB.m_ExtsEnd = pQuery->m_DB.m_Exts.end();
    
    pQuery->m_Features.mpApple = NULL;
    pQuery->m_Features.mpARB   = NULL;
    pQuery->m_Features.mpEXT   = NULL;
} // GLQueryCreateFeatures

// Create vendor, version, and renderer strings
static void GLQueryCreateStrings(GLQueryRef pQuery)
{
	pQuery->m_String.m_Renderer = GLStringCreateWithParam(GL_VERSION);
	pQuery->m_String.m_Vendor   = GLStringCreateWithParam(GL_VENDOR);
	pQuery->m_String.m_Version  = GLStringCreateWithParam(GL_RENDERER);
} // GLQueryCreateStrings

#pragma mark -
#pragma mark Private - Utilities - Features

// Convert STL vector to CF mutable array
static CFMutableArrayRef GLQueryFeaturesCreateCopy(const GLfeatures &rFeature)
{
    CFMutableArrayRef pFeatures = NULL;
    
    GLuint iMax = rFeature.size();
    
    if( iMax )
    {
        pFeatures = CFArrayCreateMutable(kCFAllocatorDefault,
                                         0,
                                         &kCFTypeArrayCallBacks);
        
        if( pFeatures != NULL )
        {
            CFStringRef pFeature = NULL;
            
            GLuint i;
            
            for( i = 0; i < iMax; ++i)
            {
                pFeature = CFStringCreateWithCString(kCFAllocatorDefault,
                                                     rFeature[i].c_str(),
                                                     kCFStringEncodingASCII);
                
                if( pFeature != NULL )
                {
                    CFArrayAppendValue(pFeatures, pFeature);
                    
                    CFRelease(pFeature);
                } // if
            } // for
        } // if
    } // if
    
    return pFeatures;
} // GLQueryFeaturesCreateCopy

#pragma mark -
#pragma mark Public - Constructor

// Create an OpenGL query opaque data reference
GLQueryRef GLQueryCreate()
{
	GLQueryRef pQuery = new GLQuery;
	
	if( pQuery != NULL )
	{
        GLQueryCreateFeatures(pQuery);
        GLQueryCreateStrings(pQuery);
	} // if
	
	return( pQuery );
} // GLQueryCreate

#pragma mark -
#pragma mark Public - Destructor

// Delete an OpenGL query opaque data reference
void GLQueryDelete(GLQueryRef pQuery)
{
	if( pQuery != NULL )
	{
        GLQueryClearFeatures(pQuery);
        GLQueryClearStrings(pQuery);
        GLQueryClearDB(pQuery);
        
		GLQueryReleaseArrays(pQuery);
        
		delete pQuery;
		
		pQuery = NULL;
	} // if
} // GLQueryDelete

#pragma mark -
#pragma mark Public - Accessors - Features

// OpenGL Apple features
const GLfeatures GLQueryFeaturesGetApple(const GLQueryRef pQuery)
{
	return pQuery->m_Features.m_Apple;
} // GLQueryFeaturesGetApple

// OpenGL ARB features
const GLfeatures GLQueryFeaturesGetARB(const GLQueryRef pQuery)
{
	return pQuery->m_Features.m_ARB;
} // GLQueryFeaturesGetARB

// OpenGL EXT features
const GLfeatures GLQueryFeaturesGetEXT(const GLQueryRef pQuery)
{
	return pQuery->m_Features.m_EXT;
} // GLQueryFeaturesGetEXT

#pragma mark -
#pragma mark Public - Accessors - Strings

// OpnGL vendor
const GLstring GLQueryStringGetVendor(const GLQueryRef pQuery)
{
	return pQuery->m_String.m_Vendor;
} // GLQueryStringGetVendor

// OpenGL version
const GLstring GLQueryStringGetVersion(const GLQueryRef pQuery)
{
	return pQuery->m_String.m_Version;
} // GLQueryStringGetVersion

// OpenGL renderer
const GLstring GLQueryStringGetRenderer(const GLQueryRef pQuery)
{
	return pQuery->m_String.m_Renderer;
} // GLQueryStringGetRenderer

// OpenGL Apple features as a string, where each feature
// is separated using a seperator string
const GLstring GLQueryStringGetApple(const GLstring &rSeperator,
									 const GLQueryRef pQuery)
{
	return GLQueryCreateStringApple(rSeperator, pQuery);
} // GLQueryStringGetApple

// OpenGL Apple features as a string, where each feature
// is separated using a seperator string
const GLstring GLQueryStringGetARB(const GLstring &rSeperator,
								   const GLQueryRef pQuery)
{
	return GLQueryCreateStringARB(rSeperator, pQuery);
} // GLQueryStringGetARB

// OpenGL Apple features as a string, where each feature
// is separated using a seperator string
const GLstring GLQueryStringGetEXT(const GLstring &rSeperator,
								   const GLQueryRef pQuery)
{
	return GLQueryCreateStringEXT(rSeperator, pQuery);
} // GLQueryStringGetEXT

#pragma mark -
#pragma mark Public - Utilities - Arrays

// Apple feature set as an CF array
CFArrayRef GLQueryArrayGetApple(GLQueryRef pQuery)
{
    if( pQuery->m_Features.mpApple == NULL )
    {
        pQuery->m_Features.mpApple = GLQueryFeaturesCreateCopy(pQuery->m_Features.m_Apple);
    } // if
    
    return pQuery->m_Features.mpApple;
} // GLQueryArrayGetApple

// ARB feature set as an CF array
CFArrayRef GLQueryArrayGetARB(GLQueryRef pQuery)
{
    if( pQuery->m_Features.mpARB == NULL )
    {
        pQuery->m_Features.mpARB = GLQueryFeaturesCreateCopy(pQuery->m_Features.m_ARB);
    } // if
    
    return pQuery->m_Features.mpARB;
} // GLQueryArrayGetARB

// EXT feature set as an CF array
CFArrayRef GLQueryArrayGetEXT(GLQueryRef pQuery)
{
    if( pQuery->m_Features.mpEXT == NULL )
    {
        pQuery->m_Features.mpEXT = GLQueryFeaturesCreateCopy(pQuery->m_Features.m_EXT);
    } // if
    
    return pQuery->m_Features.mpEXT;
} // GLQueryArrayGetEXT

#pragma mark -
#pragma mark Public - Utilities - Features

// Is the feature available
const bool GLQueryFeatureIsAvailable(const GLfeature &rFeature,
									 GLQueryRef pQuery)
{
	return pQuery->m_DB.m_Exts.find(rFeature) != pQuery->m_DB.m_ExtsEnd;
} // GLQueryFeatureIsAvailable

// If the feature is found, the returned string will be GL_APPLE,
// GL_ARB, or GL_EXT
const GLstring GLQueryFeatureGetType(const GLfeature &rFeature,
									 GLQueryRef pQuery)
{
	return pQuery->m_DB.m_Exts[rFeature];
} // GLQueryFeatureGetType
