/*
     File: CChromaticAdaptation.mm
 Abstract: 
 Utility class for chromatic adaptation computation.
 
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

#import "Matrix3.h"

//---------------------------------------------------------------------------

#import "CEnums.h"

//---------------------------------------------------------------------------

#import "CBradfordAdaptation.h"
#import "CChromaticAdaptation.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities

//---------------------------------------------------------------------------

template <typename Type>
static Math::Matrix3<Type> CChromaticAdaptationGetMatrix(const Color::ConeResponseDomain<Type> &rCRD)
{
    Math::Matrix3<Type> T;
    
	Math::Vector3<Type> v = rCRD.GetScaleVector();
	
	if( ( v.x == Type(1) ) && ( v.y == Type(1) ) && ( v.z == Type(1) ) )
	{
        T = diag(Math::Vector3<Type>(Type(1),Type(1),Type(1)));
	} // if
	else
	{
        Color::BradfordAdaptation<Type> BAM(1);
        Color::BradfordAdaptation<Type> BAMI(-1);
		
		Math::Matrix3<Type> A = BAM.GetBradfordAdaptation();
		Math::Matrix3<Type> B = BAMI.GetBradfordAdaptation();
        Math::Matrix3<Type> S = rCRD.GetScaleMatrix();
		
		T = B * S * A;
	} // else
    
    return T;
} // CChromaticAdaptationGetMatrix

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Constructors

//---------------------------------------------------------------------------

template <typename Type>
Color::ChromaticAdaptation<Type>::ChromaticAdaptation()
: Color::ConeResponseDomain<Type>::ConeResponseDomain()
{
	m_Matrix = CChromaticAdaptationGetMatrix<Type>(*this);
} // Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::ChromaticAdaptation<Type>::ChromaticAdaptation( const CGDirectDisplayID nDisplayID )
: Color::ConeResponseDomain<Type>::ConeResponseDomain(nDisplayID)
{
	m_Matrix = CChromaticAdaptationGetMatrix<Type>(*this);
} // Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::ChromaticAdaptation<Type>::ChromaticAdaptation( ColorSyncProfileRef pDisplayProfile )
: Color::ConeResponseDomain<Type>::ConeResponseDomain(pDisplayProfile)
{
	m_Matrix = CChromaticAdaptationGetMatrix<Type>(*this);
} // Constructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Destructor

//---------------------------------------------------------------------------

template <typename Type>
Color::ChromaticAdaptation<Type>::~ChromaticAdaptation()
{
} // Destructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Copy Constructors

//---------------------------------------------------------------------------

template <typename Type>
Color::ChromaticAdaptation<Type>::ChromaticAdaptation( const Color::ChromaticAdaptation<Type> &rCA )
: Color::ConeResponseDomain<Type>::ConeResponseDomain(rCA)
{
    m_Matrix = rCA.m_Matrix;
} // Copy Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::ChromaticAdaptation<Type>::ChromaticAdaptation( const Color::ChromaticAdaptation<Type> * const pCA )
: Color::ConeResponseDomain<Type>::ConeResponseDomain(pCA)
{
    if( pCA != NULL )
    {
        m_Matrix = pCA->m_Matrix;
    } // if
} // Copy Constructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Assignment Operator

//---------------------------------------------------------------------------

template <typename Type>
Color::ChromaticAdaptation<Type> &Color::ChromaticAdaptation<Type>::operator=(const Color::ChromaticAdaptation<Type> &rCA)
{
	if( this != &rCA )
	{
		this->Color::ConeResponseDomain<Type>::operator=(rCA);
        
        m_Matrix = rCA.m_Matrix;
	} // if
	
	return *this;
} // ChromaticAdaptation::operator=

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Accessors

//---------------------------------------------------------------------------

template <typename Type>
const Math::Matrix3<Type> &Color::ChromaticAdaptation<Type>::GetChromaticAdaptation() const
{
	return m_Matrix;
} // ChromaticAdaptation::GetChromaticAdaptation

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Template Implementations - Chromatic Adaptation

//---------------------------------------------------------------------------

template class Color::ChromaticAdaptation<float>;
template class Color::ChromaticAdaptation<double>;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
