/*
     File: OpenGLIFStream.mm
 Abstract: 
 A toolkit for managing input file streams (such as vertex, fragment, or geometry shader ascii text files).
 
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

// STL containers
#import <iostream>
#import <fstream>

// String copy utilities
#import "CFStringCopy.h"

// OpenGL string utilities
#import "OpenGLString.h"

// OpenGL input file stream
#import "OpenGLIFStream.h"

#pragma mark -
#pragma mark Private - Data Structures

// Input file stream structure
struct GLIFStream
{
	GLbuffer mpBuffer;
	size_t   mnLength;
    
    std::string    m_Pathname;
    std::ifstream  m_Stream;
};

typedef struct GLIFStream GLfile;

#pragma mark -
#pragma mark Private - Utilities - Constructors

static void GLIFStreamRead(GLIFStreamRef pIFStream)
{
	pIFStream->mnLength = pIFStream->m_Stream.tellg();
	
	if( pIFStream->mnLength > 0 )
	{
		pIFStream->mpBuffer = new GLchar[pIFStream->mnLength];
		
		if( pIFStream->mpBuffer != NULL )
		{
			pIFStream->m_Stream.seekg(0, std::ios::beg);
			
			pIFStream->m_Stream.read(pIFStream->mpBuffer, pIFStream->mnLength);
			pIFStream->m_Stream.close();
		} // if
		else
		{
			std::cerr
			<< ">> ERROR: Core Foundation File - Failed allocating buffer memory!"
			<< std::endl;
		} // else
	} // if
	else
	{
		std::cerr
		<< ">> ERROR: Core Foundation File - File has size 0!"
		<< std::endl;
	} // else
} // GLIFStreamRead

static void GLIFStreamAcquire(const GLpathname &rPathname,
							  GLIFStreamRef pIFStream)
{
    if( rPathname.length() > 0 )
    {
        pIFStream->m_Pathname = rPathname;
		
        pIFStream->m_Stream.open(pIFStream->m_Pathname.c_str(),
								 std::ios::in|std::ios::binary|std::ios::ate);
        
        if( pIFStream->m_Stream.is_open() )
        {
            GLIFStreamRead(pIFStream);
        } // if
        else
        {
            std::cerr
			<< ">> ERROR: Core Foundation File - Failed opening the file \""
			<< rPathname
			<< "\"!"
			<< std::endl;
        } // else
    } // if
    else
    {
		std::cerr
		<< ">> ERROR: Core Foundation File - Invalid pathname!"
		<< std::endl;
    } // else
} // GLIFStreamAcquire

static GLIFStreamRef GLIFStreamCreate()
{
	GLIFStreamRef pIFStream = new GLIFStream;
	
    if( pIFStream != NULL )
    {
        pIFStream->mpBuffer = NULL;
        pIFStream->mnLength = 0;
    } // if
	else
	{
		std::cerr << ">> ERROR: Core Foundation File - Failed creating a backing store!" << std::endl;
	} // else
	
	return( pIFStream );
} // GLIFStreamCreate

#pragma mark -
#pragma mark Private - Utilities - Destructors

static inline void GLIFStreamDeleteBuffer( GLIFStreamRef pIFStream )
{
	if( pIFStream->mpBuffer != NULL )
	{
		delete [] pIFStream->mpBuffer;
		
		pIFStream->mpBuffer = NULL;
	} // if
} // GLIFStreamDeleteBuffer

static inline void GLIFStreamCloseStream( GLIFStreamRef pIFStream )
{
	if( pIFStream->m_Stream.is_open() )
	{
		pIFStream->m_Stream.close();
	} // if
} // GLIFStreamCloseStream

static inline void GLIFStreamClearPathname( GLIFStreamRef pIFStream )
{
	pIFStream->m_Pathname.clear();
} // GLIFStreamClearPathname

#pragma mark -
#pragma mark Public - Constructors

// Create a file object from a stl string pathname
GLIFStreamRef GLIFStreamCreate(const GLchar * const pPathname)
{
	GLIFStreamRef pIFStream = GLIFStreamCreate();
	
	if( (pIFStream != NULL) && (pPathname != NULL) )
	{
        GLIFStreamAcquire(pPathname, pIFStream);
	} // if
	
	return( pIFStream );
} // GLIFStreamCreate

GLIFStreamRef GLIFStreamCreate( const std::string &rPathname )
{
	GLIFStreamRef pIFStream = GLIFStreamCreate();
	
	if( pIFStream != NULL )
	{
        GLIFStreamAcquire(rPathname, pIFStream);
	} // if
	
	return( pIFStream );
} // GLIFStreamCreate

static GLIFStreamRef GLIFStreamCreate( const std::string *pPathname )
{
	GLIFStreamRef pIFStream = GLIFStreamCreate();
	
	if( (pIFStream != NULL ) && (pPathname != NULL) )
	{
        GLIFStreamAcquire(*pPathname, pIFStream);
	} // if
    
	return( pIFStream );
} // GLIFStreamCreate

GLIFStreamRef GLIFStreamCreate( CFStringRef pPathname )
{
	GLIFStreamRef pIFStream = GLIFStreamCreate();
	
    if( pIFStream != NULL )
    {
        const std::string pathname = CFStringCreateStringCopy(pPathname);
		
		GLIFStreamAcquire(pathname, pIFStream);
    } // if
	
	return( pIFStream );
} // GLIFStreamCreate

#pragma mark -
#pragma mark Public - Destructor

void GLIFStreamDelete( GLIFStreamRef pIFStream )
{
	if( pIFStream != NULL )
	{
		GLIFStreamDeleteBuffer( pIFStream );
		GLIFStreamCloseStream( pIFStream );
		GLIFStreamClearPathname( pIFStream );
        
		delete pIFStream;
		
		pIFStream = NULL;
	} // if
} // GLIFStreamDelete

#pragma mark -
#pragma mark Public - Accessors

const GLpathname GLIFStreamGetPathname(const GLIFStreamRef pIFStream)
{
	return pIFStream->m_Pathname.c_str();
} // GLIFStreamGetPathname

const GLbuffer GLIFStreamGetBuffer(const GLIFStreamRef pIFStream)
{
	return pIFStream->mpBuffer;
} // GLIFStreamGetBuffer

const size_t GLIFStreamGetLength(const GLIFStreamRef pIFStream)
{
	return pIFStream->mnLength;
} // GLIFStreamGetBuffer

