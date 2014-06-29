/*
     File: ComplexNumber.h
 Abstract: ComplexNumber.h
  Version: 1.0.1
 
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

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	ComplexNumber.h
//
//		a useful complex number class
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#ifndef __CoreAudio_ComplexNumber
#define __CoreAudio_ComplexNumber

#include <math.h>
#include <stdio.h>

class Complex
{
public:
	Complex()
		: mReal(0.0), mImag(0.0) {};
	
	Complex(double inReal, double inImag )
		: mReal(inReal), mImag(inImag) {};

	Complex(float inReal)				// construct complex from real
		: mReal(inReal), mImag(0) {};
		


	double			GetReal() const {return mReal;};
	double			GetImag() const {return mImag;};
	void			SetReal(double inReal) {mReal = inReal;};
	void			SetImag(double inImag) {mImag = inImag;};
	
	double			Phase() const {return atan2(mImag, mReal);};
	double			GetPhase() const {return atan2(mImag, mReal);};
	double			Magnitude() const {return sqrt(mImag*mImag + mReal*mReal);};
	double			GetMagnitude() const {return sqrt(mImag*mImag + mReal*mReal);};
	
	
	void			SetMagnitudePhase(double inMagnitude, double inPhase)
	{
		mReal = inMagnitude * cos(inPhase);
		mImag = inMagnitude * sin(inPhase);
	};

	
	Complex			Pow(double inPower)
	{
		double mag = GetMagnitude();
		double phase = GetPhase();
		
		Complex result;
		result.SetMagnitudePhase(pow(mag, inPower), phase*inPower );
		
		return result;
	};
	
	Complex			GetConjugate() const {return Complex(mReal, -mImag);};
	
	
	Complex			inline operator += (const Complex &a);
	Complex			inline operator -= (const Complex &a);


	void			Print() {printf("(%f,%f)", mReal, mImag ); };
	void			PrintMagnitudePhase() {printf("(%f,%f)\n", GetMagnitude(), GetPhase() ); };
	
	
	double			mReal;
	double			mImag;
};

Complex			inline operator+ (const Complex &a, const Complex &b )
	{return Complex(a.GetReal() + b.GetReal(), a.GetImag() + b.GetImag() ); };

Complex			inline operator - (const Complex &a, const Complex &b )
	{return Complex(a.GetReal() - b.GetReal(), a.GetImag() - b.GetImag() ); };
	
Complex			inline operator * (const Complex &a, const Complex &b )
	{return Complex(	a.GetReal()*b.GetReal() - a.GetImag()*b.GetImag(),
						a.GetReal()*b.GetImag() + a.GetImag()*b.GetReal() ); };
	
Complex			inline operator * (const Complex &a, double b)
	{return Complex(a.GetReal()*b, a.GetImag()*b );};
	
Complex			inline operator * (double b, const Complex &a )
	{return Complex(a.GetReal()*b, a.GetImag()*b );};
	
Complex			inline operator/(const Complex& a, const Complex& b)
{
	double mag1 = a.GetMagnitude();
	double mag2 = b.GetMagnitude();
	
	double phase1 = a.GetPhase();
	double phase2 = b.GetPhase();
	
	Complex c;
	c.SetMagnitudePhase(mag1/mag2, phase1 - phase2 );
	
	return c;
}

Complex			inline Complex::operator += (const Complex &a)
{
	*this = *this + a;
	return *this;
};

Complex			inline Complex::operator -= (const Complex &a)
{
	*this = *this - a;
	return *this;
};

bool			inline	operator == (const Complex &a, const Complex &b )
{
	return a.GetReal() == b.GetReal() && a.GetImag() == b.GetImag();
}

inline Complex		UnitCircle(double mag, double phase)
{
	return Complex(mag * cos(phase), mag * sin(phase) );
}

#endif // __ComplexNumber
