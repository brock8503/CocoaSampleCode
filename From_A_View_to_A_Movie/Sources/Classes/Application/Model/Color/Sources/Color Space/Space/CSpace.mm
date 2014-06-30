/*
     File: CSpace.mm
 Abstract: 
 Class for basic color space operations.
 
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

#import <cmath>
#import <iostream>

//---------------------------------------------------------------------------

#import "CEnums.h"
#import "CMatrix.h"
#import "CChromaticity.h"

#import "CSpace.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Data Structures

//---------------------------------------------------------------------------

template <typename Type>
struct Color::SpaceStruct
{
    //-------------------------------------------------------------------
    //
    // Output device gamma.
    //
    //-------------------------------------------------------------------
    //
    // The recommended transfer function for the output device is used
    // here, not the inverse of the transfer function of the camera.
    //
    // This means we use the model
    //
    //                    γ
    //		L = ( E' + Δ )
    //
    // instead of inverting the equations
    //
    //		E' = α L, for L ≤ δ ;
    //
    //                      β
    //		E' = ( 1 + ε ) L  - ε,  for L > δ .
    //
    // with ε = 0.099, δ = 0.018, α = 4.5, β = 1/γ, and γ = 2.2.
    // Note that γ is usually intentionally not defined as 1/γ, to
    // produce an expansion of contrast on the output device which
    // is generally more pleasing. Also, ∆ is the free parameter and
    // γ held ﬁxed. The conversion function presented here is an
    // idealized version with ∆ = 0.
    //
    // We want to use the γ of the output device, since that is what
    // people will actually see.
    //
    //-------------------------------------------------------------------
    //
    // Rec 709 does not specify a gamma for the output device. Only
    // the gamma of the input device (0.45) is given. Typical CRTs
    // have a gamma value of 2.5, which yields an overall gamma of
    // 1.125 - which is within the 1.1 to 1.2 range, usually used
    // with the dim viewing environment assumed for television.
    //
    //-------------------------------------------------------------------
    
    //-------------------------------------------------------------------
    //
    // Scaling factors for multipication with input linear RGB values
    //
    //-------------------------------------------------------------------
    
    Type m_Scale[3];
    
    //-------------------------------------------------------------------
    //
    // The RGB to CIE XYZ conversion martix and its inverse.
    //
    // This is derived from the a RGB work space 4x2 matrix.
    //
    //-------------------------------------------------------------------
    
    Math::Matrix3<Type> m_RGB_2_XYZ;
    Math::Matrix3<Type> m_RGB_2_XYZ_Inv;
    
    //-------------------------------------------------------------------
    //
    // Chromaticity 4x3 matrix.
    //
    //-------------------------------------------------------------------
    
    Color::Matrix<Type> m_Chromaticity;
    
    // Pointer to the parent objects
    
    Color::Profile<Type> *mpColorProfile;
}; // SpaceStruct

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Accessors

//---------------------------------------------------------------------------

template <typename Type>
static void CSpaceSetChromaticity(const Type * const pWorkingSpace,
								  Color::SpaceStruct<Type> *pSSpace)
{
    Color::Chromaticity<Type> chromaticity;
    
	if( pWorkingSpace != NULL )
    {
        pSSpace->m_Chromaticity = chromaticity(pWorkingSpace);
    } // if
    else
	{
        Math::Vector2<Type> red     = pSSpace->mpColorProfile->GetChromaticityRed();
        Math::Vector2<Type> green   = pSSpace->mpColorProfile->GetChromaticityGreen();
        Math::Vector2<Type> blue    = pSSpace->mpColorProfile->GetChromaticityBlue();
        Math::Vector2<Type> whitePt = pSSpace->mpColorProfile->GetChromaticityWhitePoint();
        
        pSSpace->m_Chromaticity = chromaticity(red, green, blue, whitePt);
	} // else
} // CSpaceSetChromaticity

//---------------------------------------------------------------------------

template <typename Type>
static void CSpaceSetTranforms(Color::SpaceStruct<Type> *pSSpace)
{
	Math::Matrix3<Type> CIE_XYZ;
	
	long i;
    
	for( i = Color::Index::kRed; i < Color::Index::kWhitePt; ++i )
	{
		CIE_XYZ(Color::Coordinate::kX,i)
        = pSSpace->m_Chromaticity(i, Color::Coordinate::kX) / pSSpace->m_Chromaticity(i, Color::Coordinate::kY);
        
		CIE_XYZ(Color::Coordinate::kY,i) = Type(1);
        
		CIE_XYZ(Color::Coordinate::kZ,i)
        = pSSpace->m_Chromaticity(i, Color::Coordinate::kZ) / pSSpace->m_Chromaticity(i, Color::Coordinate::kY);
    } // for
    
	Math::Matrix3<Type> CIE_XYZ_Inv = Math::inv(CIE_XYZ);
	
	Type xWhite
    = pSSpace->m_Chromaticity(Color::Index::kWhitePt, Color::Coordinate::kX)
    / pSSpace->m_Chromaticity(Color::Index::kWhitePt, Color::Coordinate::kY);
	
    Type zWhite
    = pSSpace->m_Chromaticity(Color::Index::kWhitePt, Color::Coordinate::kZ)
    / pSSpace->m_Chromaticity(Color::Index::kWhitePt, Color::Coordinate::kY);
	
	for( i = Color::Index::kRed; i < Color::Index::kWhitePt; ++i )
	{
		pSSpace->m_Scale[i]
        = CIE_XYZ_Inv(i,Color::Index::kRed) * xWhite
        + CIE_XYZ_Inv(i,Color::Index::kGreen)
        + CIE_XYZ_Inv(i,Color::Index::kBlue) * zWhite;
		
		pSSpace->m_RGB_2_XYZ(Color::Coordinate::kX, i)
        = CIE_XYZ(Color::Coordinate::kX, i) * pSSpace->m_Scale[i];
        
		pSSpace->m_RGB_2_XYZ(Color::Coordinate::kY, i)
        = CIE_XYZ(Color::Coordinate::kY, i) * pSSpace->m_Scale[i];
        
		pSSpace->m_RGB_2_XYZ(Color::Coordinate::kZ, i)
        = CIE_XYZ(Color::Coordinate::kZ, i) * pSSpace->m_Scale[i];
	} // for
    
    pSSpace->m_RGB_2_XYZ     = Math::tr(pSSpace->m_RGB_2_XYZ);
	pSSpace->m_RGB_2_XYZ_Inv = Math::inv(pSSpace->m_RGB_2_XYZ);
} // CSpaceSetTranforms

//---------------------------------------------------------------------------

template <typename Type>
static void CSpaceSetMatrices(const Type * const pWorkingSpace,
							  Color::SpaceStruct<Type> *pSSpace)
{
    CSpaceSetChromaticity<Type>(pWorkingSpace, pSSpace);
    CSpaceSetTranforms<Type>(pSSpace);
} // CSpaceSetMatrices

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Destructor

//---------------------------------------------------------------------------

template <typename Type>
static void CSpaceDelete(Color::SpaceStruct<Type> *pSSpace)
{
	if( pSSpace != NULL )
	{
		delete pSSpace;
		
		pSSpace = NULL;
	} // if
} // Space::SpaceReleaseData

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Constructor

//---------------------------------------------------------------------------

template <typename Type>
static Color::SpaceStruct<Type> *CSpaceCreate(const Type * const pDisplayChromaticity,
											  Color::Profile<Type> *pColorProfile)
{
	Color::SpaceStruct<Type> *pSSpace = new Color::SpaceStruct<Type>;
    
    if( pSSpace != NULL )
    {
        pSSpace->mpColorProfile = pColorProfile;
        
        CSpaceSetMatrices<Type>(pDisplayChromaticity, pSSpace);
    } // if
    
	return pSSpace;
} // CSpaceCreate

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Copy Constructor

//---------------------------------------------------------------------------

template <typename Type>
static Color::SpaceStruct<Type> *CSpaceCreateCopy(const Color::SpaceStruct<Type> * const pSSpaceSrc,
												  Color::Profile<Type> *pColorProfile)
{
	Color::SpaceStruct<Type> *pSSpaceDst = NULL;
    
    if( pSSpaceSrc != NULL )
    {
        pSSpaceDst = new Color::SpaceStruct<Type>;
        
        if( pSSpaceDst != NULL )
        {
            pSSpaceDst->mpColorProfile = pColorProfile;
            
            pSSpaceDst->m_Scale[0] = pSSpaceSrc->m_Scale[0];
            pSSpaceDst->m_Scale[1] = pSSpaceSrc->m_Scale[1];
            pSSpaceDst->m_Scale[2] = pSSpaceSrc->m_Scale[2];
            
            pSSpaceDst->m_RGB_2_XYZ     = pSSpaceSrc->m_RGB_2_XYZ;
            pSSpaceDst->m_RGB_2_XYZ_Inv = pSSpaceSrc->m_RGB_2_XYZ_Inv;
        } // if
    } // if
    
	return pSSpaceDst;
} // CSpaceCreateCopy

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Constructors

//---------------------------------------------------------------------------

template <typename Type>
Color::Space<Type>::Space()
: Color::Profile<Type>::Profile()
{
    mpSSpace = CSpaceCreate<Type>(NULL, this);
} // Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::Space<Type>::Space( const Type * const pChromaticity )
: Color::Profile<Type>::Profile()
{
    mpSSpace = CSpaceCreate<Type>(pChromaticity, this);
} // Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::Space<Type>::Space( const CGDirectDisplayID nDisplayID )
: Color::Profile<Type>::Profile(nDisplayID)
{
    mpSSpace = CSpaceCreate<Type>(NULL, this);
} // Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::Space<Type>::Space( ColorSyncProfileRef pDisplayProfile )
: Color::Profile<Type>::Profile(pDisplayProfile)
{
    mpSSpace = CSpaceCreate<Type>(NULL, this);
} // Constructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Destructor

//---------------------------------------------------------------------------

template <typename Type>
Color::Space<Type>::~Space()
{
	CSpaceDelete<Type>(mpSSpace);
} // Destructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Copy Constructors

//---------------------------------------------------------------------------

template <typename Type>
Color::Space<Type>::Space( const Space<Type> &rSpace )
: Color::Profile<Type>::Profile(rSpace)
{
    mpSSpace = CSpaceCreateCopy<Type>(rSpace.mpSSpace, this);
} // Copy Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::Space<Type>::Space( const Space * const pSpace )
: Color::Profile<Type>::Profile(pSpace)
{
    if( pSpace->mpSSpace != NULL )
    {
        mpSSpace = CSpaceCreateCopy<Type>(pSpace->mpSSpace, this);
    } // if
} // Copy Constructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Assignment Operator

//---------------------------------------------------------------------------

template <typename Type>
Color::Space<Type> &Color::Space<Type>::operator=(const Space<Type> &rSpace)
{
	if( ( this != &rSpace ) && ( rSpace.mpSSpace != NULL ) )
	{
        CSpaceDelete<Type>(mpSSpace);
		
        mpSSpace = CSpaceCreateCopy<Type>(rSpace.mpSSpace, this);
	} // if
	
	return *this;
} // ColorProfile::operator=

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Accessors

//---------------------------------------------------------------------------

template <typename Type>
const Math::Matrix3<Type> &Color::Space<Type>::GetCIEMatrix() const
{
    static Math::Matrix3<Type> identity = diag(Math::Vector3<Type>(Type(1),Type(1),Type(1)));
    
	if( mpSSpace != NULL )
	{
		return( mpSSpace->m_RGB_2_XYZ );
	} // if
    
	return identity;
} // GetCIEMatrix

//---------------------------------------------------------------------------

template <typename Type>
const Math::Matrix3<Type> &Color::Space<Type>::GetCIEMatrixInv() const
{
    static Math::Matrix3<Type> identity = diag(Math::Vector3<Type>(Type(1),Type(1),Type(1)));
    
	if( mpSSpace != NULL )
	{
		return( mpSSpace->m_RGB_2_XYZ_Inv );
	} // if
	
	return identity;
} // GetCIEMatrixInv

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Template Implementations - Color Space

//---------------------------------------------------------------------------

template class Color::Space<float>;
template class Color::Space<double>;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

