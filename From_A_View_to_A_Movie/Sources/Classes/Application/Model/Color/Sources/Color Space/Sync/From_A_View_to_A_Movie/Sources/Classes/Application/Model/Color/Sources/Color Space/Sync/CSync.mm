/*
     File: CSync.mm
 Abstract: 
 Base utility for acquring the ICC profile description.
 
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
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#include <iostream>
#include <string>

//---------------------------------------------------------------------------

#include "CFLogError.h"

//---------------------------------------------------------------------------

#include "CEnums.h"
#include "CSync.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Data Structures

//---------------------------------------------------------------------------

struct Color::SyncStruct
{
    CFStringEncoding     mnEncoding;
    CFStringRef          mpProfileDesc;
    CGDirectDisplayID    mnDisplayID;
    ColorSyncProfileRef  mpProfileRef;
}; // ProfileStruct

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Destructor

//---------------------------------------------------------------------------

static void CSyncDelete(Color::SyncStruct *pSProfile)
{
	if( pSProfile != NULL )
	{
		if( pSProfile->mpProfileRef != NULL )
		{
			CFRelease(pSProfile->mpProfileRef);
            
            pSProfile->mpProfileRef = NULL;
		} // if
		
		if( pSProfile->mpProfileDesc != NULL )
		{
			CFRelease(pSProfile->mpProfileDesc);
            
            pSProfile->mpProfileDesc = NULL;
		} // if
		
		delete pSProfile;
        
        pSProfile = NULL;
	} // if
} // CSyncDelete

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Constructors

//---------------------------------------------------------------------------

static bool CSyncCopy(ColorSyncProfileRef pDisplayProfile,
					  Color::SyncStruct *pSProfile)
{
    CFErrorRef warnings = NULL;
    CFErrorRef errors   = NULL;
    
    pSProfile->mpProfileRef  = ColorSyncProfileCreateMutableCopy( pDisplayProfile );
    
    bool bSuccess = ColorSyncProfileVerify(pSProfile->mpProfileRef,
                                           &errors,
                                           &warnings);
    
    if( !bSuccess )
    {
        CFLogErrorDescription( CFSTR(">> ERROR: Color Sync:\n{\n%@\n}\n"), errors );
        CFLogErrorDescription( CFSTR(">> ERROR: Color Sync:\n{\n%@\n}\n"), warnings );
    } // if
    else
    {
        pSProfile->mpProfileDesc = ColorSyncProfileCopyDescriptionString( pDisplayProfile );
    } // else
    
    return bSuccess;
} // CSyncCopy

//---------------------------------------------------------------------------

static bool CSyncCopy(const Color::SyncStruct * const pSProfileSrc,
					  Color::SyncStruct *pSProfileDst)
{
    return CSyncCopy(pSProfileSrc->mpProfileRef, pSProfileDst);
} // CSyncCopy

//---------------------------------------------------------------------------

static Color::SyncStruct *CSyncCreate(ColorSyncProfileRef pDisplayProfile)
{
	Color::SyncStruct *pSProfile = new Color::SyncStruct;
    
	if( pDisplayProfile != NULL )
	{
		pSProfile = new Color::SyncStruct;
		
		if( pSProfile != NULL )
		{
			pSProfile->mnEncoding  = kCFStringEncodingUTF8;
			pSProfile->mnDisplayID = 0;
            
            if( !CSyncCopy(pDisplayProfile, pSProfile) )
            {
                std::cerr << ">> ERROR: ICC Profile Desc - Copying Color Sync profile failed!" << std::endl;
            } // if
		} // if
	} // if
    
    return pSProfile;
} // CSyncCreate

//---------------------------------------------------------------------------

static Color::SyncStruct *CSyncCreate( const CGDirectDisplayID nDirectDisplayID )
{
	Color::SyncStruct *pSProfile = new Color::SyncStruct;
	
	if( pSProfile != NULL )
	{
		pSProfile->mnDisplayID = nDirectDisplayID;
        pSProfile->mnEncoding  = kCFStringEncodingUTF8;
		
        pSProfile->mpProfileRef = ColorSyncProfileCreateWithDisplayID( pSProfile->mnDisplayID );
        
        if( pSProfile->mpProfileRef != NULL )
        {
            pSProfile->mpProfileDesc = ColorSyncProfileCopyDescriptionString( pSProfile->mpProfileRef );
        } // if
	} // if
    
    return pSProfile;
} // CSyncCreate

//---------------------------------------------------------------------------

static Color::SyncStruct *CSyncCreate()
{
    return CSyncCreate(CGMainDisplayID());
} // CSyncCreate

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Copy Constructor

//---------------------------------------------------------------------------

static Color::SyncStruct *CSyncCreateCopy(const Color::SyncStruct * const pSProfileSrc)
{
	Color::SyncStruct *pSProfileDst = new Color::SyncStruct;
	
	if( pSProfileDst != NULL )
	{
		pSProfileDst->mnEncoding  = pSProfileSrc->mnEncoding;
		pSProfileDst->mnDisplayID = pSProfileSrc->mnDisplayID;
		
		if( !CSyncCopy(pSProfileSrc, pSProfileDst) )
		{
			std::cerr << ">> ERROR: ICC Profile Desc - Cloning an ICC profile failed!" << std::endl;
		} // if
	} // if
	
	return( pSProfileDst );
} // CSyncCreateCopy

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Constructors

//---------------------------------------------------------------------------

Color::Sync::Sync()
{
	mpSSync = CSyncCreate();
} // Constructor

//---------------------------------------------------------------------------

Color::Sync::Sync(const CGDirectDisplayID nDisplayID)
{
	mpSSync = CSyncCreate(nDisplayID);
} // Constructor

//---------------------------------------------------------------------------

Color::Sync::Sync(ColorSyncProfileRef pDisplayProfile)
{
	mpSSync = CSyncCreate(pDisplayProfile);
} // Constructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Destructor

//---------------------------------------------------------------------------

Color::Sync::~Sync()
{
	CSyncDelete(mpSSync);
} // Destructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Copy Constructor

//---------------------------------------------------------------------------

Color::Sync::Sync( const Sync &rSync )
{
    mpSSync = CSyncCreateCopy(rSync.mpSSync);
} // Copy Constructor

//---------------------------------------------------------------------------

Color::Sync::Sync( const Sync * const pSync )
{
	if( pSync->mpSSync != NULL )
	{
		mpSSync = CSyncCreateCopy(pSync->mpSSync);
	} // if
} // Copy Constructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Assignment Operator

//---------------------------------------------------------------------------

Color::Sync &Color::Sync::operator=(const Sync &rSync)
{
	if( ( this != &rSync ) && ( rSync.mpSSync != NULL ) )
	{
        CSyncDelete(mpSSync);
		
        mpSSync = CSyncCreateCopy(rSync.mpSSync);
	} // if
    
	return *this;
} //Assignment Operator

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Accessors

//---------------------------------------------------------------------------

const CGDirectDisplayID  Color::Sync::GetDirectDisplayID() const
{
	if( mpSSync != NULL )
	{
		return( mpSSync->mnDisplayID );
	} // if
	
	return( 0 );
} // GetDirectDisplayID

//---------------------------------------------------------------------------

const ColorSyncProfileRef Color::Sync::GetProfileRef() const
{
	if( mpSSync != NULL )
	{
		return( mpSSync->mpProfileRef );
	} // if
	
	return( NULL );
} // GetProfileRef

//---------------------------------------------------------------------------

const CFStringEncoding Color::Sync::GetProfileDescriptionEncoding() const
{
	if( mpSSync != NULL )
	{
		return( mpSSync->mnEncoding );
	} // if
	
	return( kCFStringEncodingUTF8 );
} // GetProfileDescriptionEncoding

//---------------------------------------------------------------------------

const CFStringRef Color::Sync::GetProfileDescription() const
{
	if( mpSSync != NULL )
	{
		return( mpSSync->mpProfileDesc );
	} // if
	
	return( NULL );
} // GetProfileDescription

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
