/*
     File: CConeResponseDomain.mm
 Abstract: 
 Utility class for mapping CIE XYZ white point coordinates into cone response domain space.
 
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

#import <cmath>
#import <iostream>

//---------------------------------------------------------------------------

#import "CEnums.h"
#import "CCIEXYZ.h"

//---------------------------------------------------------------------------

#import "CBradfordAdaptation.h"
#import "CConeResponseDomain.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Data Structures - Cone Response Domain

//---------------------------------------------------------------------------

template <typename Type>
struct Color::ConeResponseDomainStruct
{
    bool mbD65WhitePoints;
    
    Math::Vector3<Type> m_WhitePoint[2];
    Math::Vector3<Type> m_SVector;
    Math::Matrix3<Type> m_SMatrix;
}; // ConeResponseDomainStruct

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - White Point Transformation

//---------------------------------------------------------------------------

template <typename Type>
static void CConeResponseDomainGetSrcWhitePoint(ColorSyncProfileRef pProfile,
												Color::ConeResponseDomainStruct<Type> *pSCRD)
{
    Color::CIE::XYZ<Type> colorants(pProfile);
    
    pSCRD->m_WhitePoint[0] = colorants.GetColorantWhitePoint();
	
	Math::Vector3<Type> delta = diff(pSCRD->m_WhitePoint[0], pSCRD->m_WhitePoint[1]);
    
	pSCRD->mbD65WhitePoints = ( delta.x <= Type(1E-4) )
    && ( delta.y <= Type(1E-4) )
    && ( delta.z <= Type(1E-4) );
} // CConeResponseDomainGetSrcWhitePoint

//---------------------------------------------------------------------------

template <typename Type>
static void CConeResponseDomainGetSrcWhitePoint(const CGDirectDisplayID nDisplayID,
												Color::ConeResponseDomainStruct<Type> *pSCRD)
{
	ColorSyncProfileRef  pProfile = ColorSyncProfileCreateWithDisplayID( nDisplayID );
	
	if( pProfile != NULL )
	{
		CConeResponseDomainGetSrcWhitePoint<Type>(pProfile, pSCRD);
		
		CFRelease(pProfile);
        
        pProfile = NULL;
	} // if
} // CConeResponseDomainGetSrcWhitePoint

//---------------------------------------------------------------------------

template <typename Type>
static void CConeResponseDomainSetScale(Color::ConeResponseDomainStruct<Type> *pSCRD)
{
	if( !pSCRD->mbD65WhitePoints )
	{
        Color::BradfordAdaptation<Type> BAM(1);
        
        Math::Matrix3<Type> M = BAM.GetBradfordAdaptation();
        Math::Vector3<Type> s = M * pSCRD->m_WhitePoint[0];
        Math::Vector3<Type> d = M * pSCRD->m_WhitePoint[1];
        
		pSCRD->m_SVector.x = d.x / s.x;
		pSCRD->m_SVector.y = d.y / s.y;
		pSCRD->m_SVector.z = d.z / s.z;
    } // if
	else
	{
		pSCRD->m_SVector.x = Type(1);
		pSCRD->m_SVector.y = Type(1);
		pSCRD->m_SVector.z = Type(1);
	} // else
    
    pSCRD->m_SMatrix = Math::diag(pSCRD->m_SVector);
} // CConeResponseDomainSetScale

//---------------------------------------------------------------------------
//
// For D65 standard observer and starting with CIE xy: { 0.312727, 0.329023 }
//
//---------------------------------------------------------------------------

template <typename Type>
static void CConeResponseDomainGetDstWhitePoint(Color::ConeResponseDomainStruct<Type> *pSCRD)
{
	static Math::Vector2<Type> D65(Type(0.312727), Type(0.329023));
	
	pSCRD->m_WhitePoint[1].x = D65.x / D65.y;
	pSCRD->m_WhitePoint[1].y = Type(1);
	pSCRD->m_WhitePoint[1].z = (Type(1) - D65.x - D65.y) / D65.y;
} // CConeResponseDomainGetDstWhitePoint

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Constructors

//---------------------------------------------------------------------------

template <typename Type>
static Color::ConeResponseDomainStruct<Type> *CConeResponseDomainCreate(ColorSyncProfileRef pProfile)
{
    Color::ConeResponseDomainStruct<Type> *pSCRD = NULL;
    
    if( pProfile != NULL )
    {
        pSCRD = new Color::ConeResponseDomainStruct<Type>;
        
        if( pSCRD != NULL )
        {
            CConeResponseDomainGetDstWhitePoint<Type>(pSCRD);
            CConeResponseDomainGetSrcWhitePoint<Type>(pProfile,pSCRD);
            CConeResponseDomainSetScale<Type>(pSCRD);
        } // if
    } // if
    
    return pSCRD;
} // CConeResponseDomainCreate

//---------------------------------------------------------------------------

template <typename Type>
static Color::ConeResponseDomainStruct<Type> *CConeResponseDomainCreate(const CGDirectDisplayID nDisplayID)
{
	Color::ConeResponseDomainStruct<Type> *pSCRD = new Color::ConeResponseDomainStruct<Type>;
	
	if( pSCRD != NULL )
	{
		CConeResponseDomainGetDstWhitePoint<Type>(pSCRD);
		CConeResponseDomainGetSrcWhitePoint<Type>(nDisplayID,pSCRD);
		CConeResponseDomainSetScale<Type>(pSCRD);
	} // if
    
    return pSCRD;
} // CConeResponseDomainCreate

//---------------------------------------------------------------------------

template <typename Type>
static Color::ConeResponseDomainStruct<Type> *CConeResponseDomainCreate()
{
    return CConeResponseDomainCreate<Type>(CGMainDisplayID());
} // CConeResponseDomainCreate

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Destructor

//---------------------------------------------------------------------------

template <typename Type>
static void CConeResponseDomainDelete(Color::ConeResponseDomainStruct<Type> *pSCRD)
{
	if( pSCRD != NULL )
	{
		delete pSCRD;
        
        pSCRD = NULL;
	} // if
} // Destructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Copy Constructor

//---------------------------------------------------------------------------

template <typename Type>
static Color::ConeResponseDomainStruct<Type> *CConeResponseDomainCreateCopy(const Color::ConeResponseDomainStruct<Type> * const pSCRDSrc)
{
	Color::ConeResponseDomainStruct<Type> *pSCRDDst = NULL;
    
	if( pSCRDSrc != NULL )
	{
		pSCRDDst = new Color::ConeResponseDomainStruct<Type>;
		
		if( pSCRDDst != NULL )
		{
            pSCRDDst->m_WhitePoint[0] = pSCRDSrc->m_WhitePoint[0];
            pSCRDDst->m_WhitePoint[1] = pSCRDSrc->m_WhitePoint[1];
            
            pSCRDDst->m_SVector = pSCRDSrc->m_SVector;
            pSCRDDst->m_SMatrix = pSCRDSrc->m_SMatrix;
		} // if
	} // if
    
    return pSCRDDst;
} // CConeResponseDomainCreateCopy

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Constructors

//---------------------------------------------------------------------------

template <typename Type>
Color::ConeResponseDomain<Type>::ConeResponseDomain()
{
	mpSCRD = CConeResponseDomainCreate<Type>();
} // Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::ConeResponseDomain<Type>::ConeResponseDomain( const CGDirectDisplayID nDisplayID )
{
	mpSCRD = CConeResponseDomainCreate<Type>(nDisplayID);
} // Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::ConeResponseDomain<Type>::ConeResponseDomain( ColorSyncProfileRef pDisplayProfile )
{
	mpSCRD = CConeResponseDomainCreate<Type>(pDisplayProfile);
} // Constructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Destructor

//---------------------------------------------------------------------------

template <typename Type>
Color::ConeResponseDomain<Type>::~ConeResponseDomain()
{
	CConeResponseDomainDelete<Type>(mpSCRD);
} // Destructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Copy Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::ConeResponseDomain<Type>::ConeResponseDomain( const Color::ConeResponseDomain<Type> &rCRD )
{
    mpSCRD = CConeResponseDomainCreateCopy<Type>(rCRD.mpSCRD);
} // Copy Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::ConeResponseDomain<Type>::ConeResponseDomain( const Color::ConeResponseDomain<Type> * const pCRD )
{
    if( pCRD != NULL )
    {
        mpSCRD = CConeResponseDomainCreateCopy<Type>(pCRD->mpSCRD);
    } // if
} // Copy Constructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Assignment Operator

//---------------------------------------------------------------------------

template <typename Type>
Color::ConeResponseDomain<Type> &Color::ConeResponseDomain<Type>::operator=(const Color::ConeResponseDomain<Type> &rCRD)
{
	if( ( this != &rCRD ) && ( rCRD.mpSCRD != NULL ) )
	{
        CConeResponseDomainDelete<Type>(mpSCRD);
		
        mpSCRD = CConeResponseDomainCreateCopy<Type>(rCRD.mpSCRD);
	} // if
	
	return *this;
} // ConeResponseDomain::operator=

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Accessors

//---------------------------------------------------------------------------

template <typename Type>
const Math::Vector3<Type> &Color::ConeResponseDomain<Type>::GetScaleVector() const
{
    return mpSCRD->m_SVector;
} // GetScaleVector

//---------------------------------------------------------------------------

template <typename Type>
const Math::Matrix3<Type> &Color::ConeResponseDomain<Type>::GetScaleMatrix() const
{
    return mpSCRD->m_SMatrix;
} // GetScaleMatrix

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Template Implementations - Cone Response Domain

//---------------------------------------------------------------------------

template class Color::ConeResponseDomain<float>;
template class Color::ConeResponseDomain<double>;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
