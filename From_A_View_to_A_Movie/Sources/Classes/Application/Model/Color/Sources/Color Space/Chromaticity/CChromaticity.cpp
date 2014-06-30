/*
     File: CChromaticity.cpp
 Abstract: 
 Chromaticity initialization utility class.
 
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
#include <limits>

//---------------------------------------------------------------------------

#include "CEnums.h"
#include "CChromaticity.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Constructors

//---------------------------------------------------------------------------

template <typename Type>
Color::Chromaticity<Type>::Chromaticity()
{
} // Constructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Destructor

//---------------------------------------------------------------------------

template <typename Type>
Color::Chromaticity<Type>::~Chromaticity()
{
} // Destructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Function Operator

//---------------------------------------------------------------------------

template <typename Type>
const Color::Matrix<Type> Color::Chromaticity<Type>::operator()(const Type * const pVector) const
{
    Color::Matrix<Type> M;
    
	if( pVector != NULL )
	{
		M(Color::Index::kRed,Color::Coordinate::kX) = pVector[0];
		M(Color::Index::kRed,Color::Coordinate::kY) = pVector[1];
		M(Color::Index::kRed,Color::Coordinate::kZ) = Type(1) - pVector[0] - pVector[1];
        
		M(Color::Index::kGreen,Color::Coordinate::kX) = pVector[2];
		M(Color::Index::kGreen,Color::Coordinate::kY) = pVector[3];
		M(Color::Index::kGreen,Color::Coordinate::kZ) = Type(1) - pVector[2] - pVector[3];
        
		M(Color::Index::kBlue,Color::Coordinate::kX) = pVector[4];
		M(Color::Index::kBlue,Color::Coordinate::kY) = pVector[5];
		M(Color::Index::kBlue,Color::Coordinate::kZ) = Type(1) - pVector[4] - pVector[5];
        
		M(Color::Index::kWhitePt,Color::Coordinate::kX) = pVector[6];
		M(Color::Index::kWhitePt,Color::Coordinate::kY) = pVector[7];
		M(Color::Index::kWhitePt,Color::Coordinate::kZ) = Type(1) - pVector[6] - pVector[7];
	} // if
    
    return M;
} // Function Operator

//---------------------------------------------------------------------------

template <typename Type>
const Color::Matrix<Type> Color::Chromaticity<Type>::operator()(const Math::Vector2<Type> &rRed,
																const Math::Vector2<Type> &rGreen,
																const Math::Vector2<Type> &rBlue,
																const Math::Vector2<Type> &rWhitePt) const
{
    Color::Matrix<Type> M;
    
    M(Color::Index::kRed,Color::Coordinate::kX) = rRed.x;
    M(Color::Index::kRed,Color::Coordinate::kY) = rRed.y;
    M(Color::Index::kRed,Color::Coordinate::kZ) = Type(1) - rRed.x - rRed.y;
    
    M(Color::Index::kGreen,Color::Coordinate::kX) = rGreen.x;
    M(Color::Index::kGreen,Color::Coordinate::kY) = rGreen.y;
    M(Color::Index::kGreen,Color::Coordinate::kZ) = Type(1) - rGreen.x - rGreen.y;
    
    M(Color::Index::kBlue,Color::Coordinate::kX) = rBlue.x;
    M(Color::Index::kBlue,Color::Coordinate::kY) = rBlue.y;
    M(Color::Index::kBlue,Color::Coordinate::kZ) = Type(1) - rBlue.x - rBlue.y;
    
    M(Color::Index::kWhitePt,Color::Coordinate::kX) = rWhitePt.x;
    M(Color::Index::kWhitePt,Color::Coordinate::kY) = rWhitePt.y;
    M(Color::Index::kWhitePt,Color::Coordinate::kZ) = Type(1) - rWhitePt.x - rWhitePt.y;
    
    return M;
} // Function Operator

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Implementations - Template

//---------------------------------------------------------------------------

template class Color::Chromaticity<float>;
template class Color::Chromaticity<double>;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

