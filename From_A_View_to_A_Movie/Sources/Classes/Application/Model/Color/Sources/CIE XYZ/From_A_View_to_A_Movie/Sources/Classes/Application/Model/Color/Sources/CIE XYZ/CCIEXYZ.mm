/*
     File: CCIEXYZ.mm
 Abstract: 
 Base utility for getting the CIE XYZ values from ColorSync profile.
 
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

#import <iostream>
#import <string>

//---------------------------------------------------------------------------

#import "CEnums.h"
#import "CCIEXYZ.h"

//---------------------------------------------------------------------------

#import <ICC.h>

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Definitions

//---------------------------------------------------------------------------

#define kTagRedColorant      CFSTR("rXYZ")
#define kTagGreenColorant    CFSTR("gXYZ")
#define kTagBlueColorant     CFSTR("bXYZ")
#define kTagMediaWhitePoint  CFSTR("wtpt")

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Constants

//---------------------------------------------------------------------------

static const int32_t kFixed = int32_t(0x00010000L);

static const CFIndex kCapacityCIEDictionary = Color::Index::kMax;
static const CFIndex kCapacityCIEArray      = 3;

static const CFStringRef kSignatures[Color::Index::kMax] =
{
    kTagRedColorant,
    kTagGreenColorant,
    kTagBlueColorant,
    kTagMediaWhitePoint
};

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Data Structure

//---------------------------------------------------------------------------

template <typename Type>
struct Color::CIE::XYZStruct
{
    Color::Matrix<Type> m_Colorants;
    
    CFMutableDictionaryRef mpDictionary;
};

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Numerics

//---------------------------------------------------------------------------

template <typename Type>
static inline Type CCIEXYZFixed2Float( const uint32_t nFixedNum )
{
	return( Type(nFixedNum) / Type(kFixed) );
} // CCIEXYZFixed2Float

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Numbers

//---------------------------------------------------------------------------

template <typename Type>
static CFNumberType CCIEXYZGetNumberType()
{
	std::string aTypeId = typeid( Type ).name();
	
	CFNumberType aNumberType;
	
	if( aTypeId == "f" )
	{
		aNumberType = kCFNumberFloatType;
	} // if
	else
	{
		aNumberType = kCFNumberDoubleType;
	} // else
	
	return( aNumberType );
} // CCIEXYZGetNumberType

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Accessors

//---------------------------------------------------------------------------

template <typename Type>
static void CCIEXYZSetDictionary(const CFStringRef *pSignatures,
								 Color::CIE::XYZStruct<Type> *pSXYZ)
{
	pSXYZ->mpDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                    kCapacityCIEDictionary,
                                                    &kCFCopyStringDictionaryKeyCallBacks,
                                                    &kCFTypeDictionaryValueCallBacks);
	
	if( pSXYZ->mpDictionary != NULL )
	{
		CFIndex i;
		CFIndex j;
		
		CFMutableArrayRef pSXYZ_Array = NULL;
        
		CFNumberRef  pNumber = NULL;
		CFNumberType nType   = CCIEXYZGetNumberType<Type>();
        
		Type nColor = Type(0);
        
		for( i = 0; i < 4; ++i )
		{
			pSXYZ_Array = CFArrayCreateMutable(kCFAllocatorDefault,
                                               kCapacityCIEArray,
                                               &kCFTypeArrayCallBacks);
			
			if( pSXYZ_Array != NULL )
			{
				for( j = 0; j < 3; ++j )
				{
                    nColor = pSXYZ->m_Colorants(i,j);
                    
					pNumber = CFNumberCreate(kCFAllocatorDefault,
											 nType,
											 &nColor);
					
					if( pNumber != NULL )
					{
						CFArraySetValueAtIndex(pSXYZ_Array, j, pNumber);
                        
						CFRelease(pNumber);
                        
                        pNumber = NULL;
					} // if
				} // for
				
				CFDictionarySetValue(pSXYZ->mpDictionary,
									 pSignatures[i],
									 pSXYZ_Array);
				
				CFRelease(pSXYZ_Array);
                
                pSXYZ_Array = NULL;
			} // if
		} // for
	} // if
} // CCIEXYZSetDictionary

//---------------------------------------------------------------------------

template <typename Type>
static bool CCIEXYZSetReferenceColor(const uint32_t nColorIndex,
									 const ColorSyncProfileRef pProfile,
									 CFStringRef pSignature,
									 Color::CIE::XYZStruct<Type> *pSXYZ)
{
	bool success = false;
	
	CFDataRef pTagData = ColorSyncProfileCopyTag(pProfile, pSignature);
	
	if( pTagData != NULL )
	{
		const uint8_t *ptr = CFDataGetBytePtr( pTagData );
		
		if( ptr != NULL )
		{
			icXYZType xyzTag = *(icXYZType*)ptr;
			
			FourCharCode tagType = CFSwapInt32BigToHost( xyzTag.base.sig );
			
			if( tagType == icSigXYZType )
			{
				pSXYZ->m_Colorants(nColorIndex,Color::Coordinate::kX)
                = CCIEXYZFixed2Float<Type>(CFSwapInt32BigToHost(xyzTag.data.data[0].X));
                
				pSXYZ->m_Colorants(nColorIndex,Color::Coordinate::kY)
                = CCIEXYZFixed2Float<Type>(CFSwapInt32BigToHost(xyzTag.data.data[0].Y));
                
				pSXYZ->m_Colorants(nColorIndex,Color::Coordinate::kZ)
                = CCIEXYZFixed2Float<Type>(CFSwapInt32BigToHost(xyzTag.data.data[0].Z));
				
				success = true;
			} // if
		} // if
		
		CFRelease( pTagData );
	} // if
	
	return( success );
} // CCIEXYZSetReferenceColor

//---------------------------------------------------------------------------

template <typename Type>
static bool CCIEXYZSetDisplay(const ColorSyncProfileRef pProfile,
							  Color::CIE::XYZStruct<Type> *pSXYZ)
{
	bool bSuccess = false;
    
	if( pProfile != NULL )
	{
		uint32_t nColorIndex = 0;
		
		bSuccess = true;
		
		while( ( bSuccess ) && ( nColorIndex < 4 ) )
		{
			bSuccess = CCIEXYZSetReferenceColor<Type>(nColorIndex,
													  pProfile,
													  kSignatures[nColorIndex],
													  pSXYZ);
			
			nColorIndex++;
		} // if
		
		if( bSuccess )
		{
			CCIEXYZSetDictionary<Type>(kSignatures, pSXYZ);
		} // if
	} // if
    
	return( bSuccess );
} // CCIEXYZSetDisplay

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Constructors

//---------------------------------------------------------------------------

template <typename Type>
static Color::CIE::XYZStruct<Type> *CCIEXYZCreate(ColorSyncProfileRef pProfile)
{
    Color::CIE::XYZStruct<Type> *pSXYZ = new Color::CIE::XYZStruct<Type>;
    
    if( pSXYZ != NULL )
    {
        CCIEXYZSetDisplay<Type>(pProfile, pSXYZ);
    } // if
    
    return pSXYZ;
} // CCIEXYZCreate

//---------------------------------------------------------------------------

template <typename Type>
static Color::CIE::XYZStruct<Type> *CCIEXYZCreate(const CGDirectDisplayID nDisplayID)
{
    Color::CIE::XYZStruct<Type> *pSXYZ = new Color::CIE::XYZStruct<Type>;
    
    if( pSXYZ != NULL )
    {
        ColorSyncProfileRef pProfile = ColorSyncProfileCreateWithDisplayID(nDisplayID);
        
        if( pProfile != NULL )
        {
            CCIEXYZSetDisplay<Type>(pProfile, pSXYZ);
            
            CFRelease(pProfile);
            
            pProfile = NULL;
        } // if
    } // if
    
    return pSXYZ;
} // CCIEXYZCreate

//---------------------------------------------------------------------------

template <typename Type>
static Color::CIE::XYZStruct<Type> *CCIEXYZCreate()
{
    return CCIEXYZCreate<Type>(CGMainDisplayID());
} // CCIEXYZCreate

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Copy Constructor

//---------------------------------------------------------------------------

template <typename Type>
static Color::CIE::XYZStruct<Type> *CCIEXYZCreateCopy( const Color::CIE::XYZStruct<Type> * const pSXYZ_Src )
{
    Color::CIE::XYZStruct<Type> *pSXYZ_Dst = NULL;
    
    if( pSXYZ_Src != NULL )
    {
        pSXYZ_Dst = new Color::CIE::XYZStruct<Type>;
        
        if( pSXYZ_Dst != NULL )
        {
            pSXYZ_Dst->m_Colorants = pSXYZ_Src->m_Colorants;
            
            CCIEXYZSetDictionary<Type>(kSignatures, pSXYZ_Dst);
        } // if
    } // if
    
    return pSXYZ_Dst;
} // CCIEXYZCreateCopy

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Destructor

//---------------------------------------------------------------------------

template <typename Type>
static void CCIEXYZDelete(Color::CIE::XYZStruct<Type> *pSXYZ)
{
	if( pSXYZ != NULL )
	{
		if( pSXYZ->mpDictionary != NULL )
		{
			CFRelease(pSXYZ->mpDictionary);
            
            pSXYZ->mpDictionary = NULL;
		} // if
		
		delete pSXYZ;
        
        pSXYZ = NULL;
	} // if
} // CCIEXYZDelete

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Constructors

//---------------------------------------------------------------------------

template <typename Type>
Color::CIE::XYZ<Type>::XYZ()
{
	mpSXYZ = CCIEXYZCreate<Type>();
} // Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::CIE::XYZ<Type>::XYZ( const CGDirectDisplayID nDisplayID )
{
	mpSXYZ = CCIEXYZCreate<Type>(nDisplayID);
} // Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::CIE::XYZ<Type>::XYZ( ColorSyncProfileRef pDisplayProfile )
{
	mpSXYZ = CCIEXYZCreate<Type>(pDisplayProfile);
} // Constructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Destructor

//---------------------------------------------------------------------------

template <typename Type>
Color::CIE::XYZ<Type>::~XYZ()
{
	CCIEXYZDelete<Type>(mpSXYZ);
} // Destructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Copy Constructors

//---------------------------------------------------------------------------

template <typename Type>
Color::CIE::XYZ<Type>::XYZ( const Color::CIE::XYZ<Type> &rXYZ )
{
	mpSXYZ = CCIEXYZCreateCopy<Type>(rXYZ.mpSXYZ);
} // Copy Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::CIE::XYZ<Type>::XYZ( const Color::CIE::XYZ<Type>  * const pXYZ )
{
    if( pXYZ != NULL )
    {
        mpSXYZ = CCIEXYZCreateCopy<Type>(pXYZ->mpSXYZ);
    } // if
} // Copy Constructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Assignment Operator

//---------------------------------------------------------------------------

template <typename Type>
Color::CIE::XYZ<Type> &Color::CIE::XYZ<Type>::operator=(const Color::CIE::XYZ<Type> &rXYZ)
{
	if( ( this != &rXYZ ) && ( rXYZ.mpSXYZ != NULL ) )
	{
        CCIEXYZDelete<Type>(mpSXYZ);
        
        mpSXYZ = CCIEXYZCreateCopy<Type>(rXYZ.mpSXYZ);
	} // if
    
	return *this;
} // XYZ::operator=

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Accessors

//---------------------------------------------------------------------------

template <typename Type>
CFDictionaryRef Color::CIE::XYZ<Type>::GetColorantDictionary() const
{
	return( mpSXYZ->mpDictionary );
} // GetColorantDictionary

//---------------------------------------------------------------------------

template <typename Type>
const Color::Matrix<Type> &Color::CIE::XYZ<Type>::GetColorants() const
{
	return( mpSXYZ->m_Colorants );
} // GetColorants

//---------------------------------------------------------------------------

template <typename Type>
const Math::Vector3<Type> Color::CIE::XYZ<Type>::GetColorantRed() const
{
    return  Math::Vector3<Type>(mpSXYZ->m_Colorants(Color::Index::kRed,Color::Coordinate::kX),
								mpSXYZ->m_Colorants(Color::Index::kRed,Color::Coordinate::kY),
								mpSXYZ->m_Colorants(Color::Index::kRed,Color::Coordinate::kZ));
} // GetColorantRed

//---------------------------------------------------------------------------

template <typename Type>
const  Math::Vector3<Type> Color::CIE::XYZ<Type>::GetColorantGreen() const
{
    return  Math::Vector3<Type>(mpSXYZ->m_Colorants(Color::Index::kGreen,Color::Coordinate::kX),
								mpSXYZ->m_Colorants(Color::Index::kGreen,Color::Coordinate::kY),
								mpSXYZ->m_Colorants(Color::Index::kGreen,Color::Coordinate::kZ));
} // GetColorantGreen

//---------------------------------------------------------------------------

template <typename Type>
const  Math::Vector3<Type> Color::CIE::XYZ<Type>::GetColorantBlue() const
{
    return  Math::Vector3<Type>(mpSXYZ->m_Colorants(Color::Index::kBlue,Color::Coordinate::kX),
								mpSXYZ->m_Colorants(Color::Index::kBlue,Color::Coordinate::kY),
								mpSXYZ->m_Colorants(Color::Index::kBlue,Color::Coordinate::kZ));
} // GetColorantBlue

//---------------------------------------------------------------------------

template <typename Type>
const  Math::Vector3<Type> Color::CIE::XYZ<Type>::GetColorantWhitePoint() const
{
    return  Math::Vector3<Type>(mpSXYZ->m_Colorants(Color::Index::kWhitePt,Color::Coordinate::kX),
								mpSXYZ->m_Colorants(Color::Index::kWhitePt,Color::Coordinate::kY),
								mpSXYZ->m_Colorants(Color::Index::kWhitePt,Color::Coordinate::kZ));
} // GetColorantWhitePoint

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Implementations - Template

//---------------------------------------------------------------------------

template class Color::CIE::XYZ<float>;
template class Color::CIE::XYZ<double>;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
