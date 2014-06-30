/*
     File: CFIFStream.mm
 Abstract: 
 Utility methods for managing input file streams.
 
  Version: 3.1
 
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

#pragma mark -
#pragma mark Headers

#import <fstream>
#import <iostream>
#import <sstream>

#import "CFIFStream.h"

#pragma mark -
#pragma mark Private - Data Structures

struct CF::IFStream
{
    bool     mbIsValid;
	char    *mpBuffer;
	size_t   mnLength;
    size_t   mnRefCount;
    
    std::string    m_Pathname;
    std::ifstream  m_Stream;
};

#pragma mark -
#pragma mark Private - Utilities - Delete

static void CFIFStreamDelete(CF::IFStreamRef pStream)
{
    if(pStream != NULL)
    {
        if(pStream->mpBuffer != NULL)
        {
            delete [] pStream->mpBuffer;
            
            pStream->mpBuffer = NULL;
        } // if
        
        if(pStream->m_Stream.is_open())
        {
            pStream->m_Stream.close();
        } // if
        
        if(!pStream->m_Pathname.empty())
        {
            pStream->m_Pathname.clear();
        } // if
        
        delete pStream;
        
        pStream = NULL;
    } // if
} // CF::IFStreamDelete

#pragma mark -
#pragma mark Private - Utilities - Reference counting

// Increment the refernce count
static CF::IFStreamRef CFIFStreamRetainCount(CF::IFStreamRef pStream)
{
    CF::IFStreamRef pStreamCopy = NULL;
    
    if(pStream != NULL)
    {
        pStream->mnRefCount++;
        
        pStreamCopy = pStream;
    } // if
    
    return pStreamCopy;
} // CF::IFStreamRetainCount

// Decrement the refernce count
static void CFIFStreamReleaseCount(CF::IFStreamRef pStream)
{
    if(pStream != NULL)
    {
        pStream->mnRefCount--;
        
        if(pStream->mnRefCount == 0)
        {
            CFIFStreamDelete(pStream);
        } // if
    } // if
} // CF::IFStreamReleaseCount

#pragma mark -
#pragma mark Private - Utilities - Files

static bool CFIFStreamOpen(const std::string& pathname,
                           CF::IFStreamRef pStream)
{
    pStream->m_Pathname = pathname;
    
    pStream->m_Stream.open(pStream->m_Pathname.c_str(),
                           std::ios::in|std::ios::binary|std::ios::ate);
    
    return pStream->m_Stream.is_open();
} // CF::IFStreamOpen

static bool CFIFStreamSetLength(CF::IFStreamRef pStream)
{
	pStream->mnLength = pStream->m_Stream.tellg();
    
    return pStream->mnLength > 0;
} // CF::IFStreamSetLength

static bool CFIFStreamRead(CF::IFStreamRef pStream)
try
{
    bool bSuccess = CFIFStreamSetLength(pStream);
    
	if(bSuccess)
	{
        pStream->mpBuffer = new char[pStream->mnLength + 1];
        
        pStream->m_Stream.seekg(0, std::ios::beg);
        pStream->m_Stream.read(pStream->mpBuffer, pStream->mnLength);
        pStream->m_Stream.close();
        
        pStream->mpBuffer[pStream->mnLength] = '\0';
        
        bSuccess = pStream->mpBuffer != NULL;
	} // if
	else
	{
		NSLog(@">> ERROR: File has size 0!");
	} // else
    
    return bSuccess;
} // try
catch(std::bad_alloc& ba)
{
    NSLog(@">> ERROR: Failed allocating memory for i/o file stream buffer: \"%s\"", ba.what());
    
    return false;
} // catch

#pragma mark -
#pragma mark Private - Utilities - Acquire

static void CFIFStreamAcquire(const std::string& pathname,
                              CF::IFStreamRef pStream)
{
    pStream->mbIsValid = CFIFStreamOpen(pathname, pStream);
    
    if(pStream->mbIsValid)
    {
        pStream->mbIsValid = CFIFStreamRead(pStream);
    } // if
    else
    {
        NSLog(@">> ERROR: Failed opening the file \"%s\"!", pathname.c_str());
    } // else
} // CF::IFStreamAcquire

#pragma mark -
#pragma mark Private - Utilities - Constructors

static CF::IFStreamRef CFIFStreamCreateFromPath(const std::string& pathname)
try
{
    CF::IFStreamRef pStream = NULL;
    
    bool bIsValid = !pathname.empty();
    
    if(bIsValid)
    {
        pStream = new CF::IFStream;
        
        pStream->mnRefCount = 1;
        
        CFIFStreamAcquire(pathname, pStream);
    } // if
    else
    {
		NSLog(@">> ERROR: Invalid pathname!");
    } // else
    
    return pStream;
} // try
catch(std::bad_alloc& ba)
{
    NSLog(@">> ERROR: Failed allocating memory for i/o file stream backing-store: \"%s\"", ba.what());
    
    return NULL;
} // catch

#pragma mark -
#pragma mark Public - Utilities

CF::IFStreamRef CF::IFStreamCreate(const std::string& pathname)
{
    return CFIFStreamCreateFromPath(pathname);
} // CF::IFStreamCreate

CF::IFStreamRef CF::IFStreamCreate(CFStringRef pName,
                                   CFStringRef pExt)
{
    CF::IFStreamRef pStream = NULL;
    
    if(pName)
    {
        CFStringRef pFileExt = (pExt) ? (pExt) : CFSTR("txt");
        
        CFBundleRef pBundle = CFBundleGetMainBundle();
        
        if(pBundle != NULL)
        {
            CFURLRef pURL = CFBundleCopyResourceURL(pBundle, pName, pFileExt, NULL);
            
            if(pURL != NULL)
            {
                CFStringRef pPathname = CFURLCopyPath(pURL);
                
                if(pPathname != NULL)
                {
                    CFIndex nLength = CFStringGetLength(pPathname);
                    
                    if(nLength)
                    {
                        char *pBuffer = NULL;
                        
                        try
                        {
                            pBuffer = new char[nLength + 1];
                        } // try
                        catch(std::bad_alloc& ba)
                        {
                            NSLog(@">> ERROR: Failed allocating memory for absolute pathname buffer: \"%s\"", ba.what());
                            
                            CFRelease(pPathname);
                            CFRelease(pURL);
                            
                            return NULL;
                        } // catch
                        
                        if(CFStringGetCString(pPathname, pBuffer, nLength+1, kCFStringEncodingASCII))
                        {
                            pStream = CFIFStreamCreateFromPath(pBuffer);
                        } // if
                        
                        delete [] pBuffer;
                    } // if
                    
                    CFRelease(pPathname);
                } // if
                
                CFRelease(pURL);
            } // if
        } // if
    } // if
    
    return pStream;
} // CF::IFStreamCreate

// Create a deep-copy of OpenGL input file stream opaque data reference
CF::IFStreamRef CF::IFStreamCreateCopy(const CF::IFStreamRef pStreamSrc)
{
    
	CF::IFStreamRef pStreamDst = NULL;
    
    if(pStreamSrc != NULL)
    {
        pStreamDst = CFIFStreamCreateFromPath(pStreamSrc->m_Pathname);
    } // if
    
    return pStreamDst;
} // CF::IFStreamCreateCopy

CF::IFStreamRef CF::IFStreamRetain(CF::IFStreamRef pStream)
{
    return CFIFStreamRetainCount(pStream);
} // CF::IFStreamRelease

void CF::IFStreamRelease(CF::IFStreamRef pStream)
{
    CFIFStreamReleaseCount(pStream);
} // CF::IFStreamRelease

bool CF::IFStreamIsValid(const CF::IFStreamRef pStream)
{
    return (pStream != NULL) ? pStream->mbIsValid : false;
} // CF::IFStreamIsValid

const char* CF::IFStreamGetBuffer(const CF::IFStreamRef pStream)
{
	return (pStream != NULL) ? pStream->mpBuffer : NULL;
} // CF::IFStreamGetBuffer
