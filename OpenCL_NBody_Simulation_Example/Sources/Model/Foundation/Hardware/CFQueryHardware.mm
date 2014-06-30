/*
     File: CFQueryHardware.mm
 Abstract: n/a
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
#pragma mark Private - Headers

#import <cstdio>
#import <cstdlib>

#import <sys/types.h>
#import <sys/sysctl.h>

#import "CFQueryHardware.h"

#pragma mark -
#pragma mark Public - Constants

double_t CF::Query::Frequency::kGigaHetrz = 1.0e-9;
double_t CF::Query::Frequency::kMegaHertz = 1.0e-6;
double_t CF::Query::Frequency::kKiloHertz = 1.0e-3;
double_t CF::Query::Frequency::kHertz     = 1.0f;

#pragma mark -
#pragma mark Private - Constants

static const size_t kGigaBytes = 1073741824;

#pragma mark -
#pragma mark Private - Utilities

static int CFQueryHardwareGetMemSize(size_t& gigabytes)
{
    size_t size  = sizeof(size_t);
    size_t bytes = sizeof(size_t);
    
    int result = sysctlbyname("hw.memsize", &bytes, &size, NULL, 0);
    
    if(result < 0)
    {
        std::perror("sysctlbyname() failed for memory size!");
    } // if
    else
    {
        gigabytes = bytes / kGigaBytes;
    } // else
    
    return result;
} // CFQueryHardwareGetMemSize

static int CFQueryHardwareGetCPUCount(size_t& count)
{
    size_t size = sizeof(size_t);
    
    int result = sysctlbyname("hw.physicalcpu_max", &count, &size, NULL, 0);
    
    if(result < 0)
    {
        std::perror("sysctlbyname() failed for max physical cpu count!");
    } // if
    
    return result;
} // CFQueryHardwareGetCPUCount

static int CFQueryHardwareGetCPUClock(double_t& clock)
{
    size_t freq = 0;
    size_t size = sizeof(size_t);
    
    int result = sysctlbyname("hw.cpufrequency_max", &freq, &size, NULL, 0);
    
    if(result < 0)
    {
        std::perror("sysctlbyname() failed for max cpu frequency!");
    } // if
    else
    {
        clock = double_t(freq);
    } // else
    
    return result;
} // CFQueryHardwareGetCPUClock

static int CFQueryHardwareGetModel(std::string& model)
{
    size_t nLength = 0;
    
    int result = sysctlbyname("hw.model", NULL, &nLength, NULL, 0);
    
    if(result < 0)
    {
        std::perror("sysctlbyname() failed in acquring string length for the hardware model!");
        
        return result;
    } // if
    
    if(nLength)
    {
        char *pModel = NULL;
        
        try
        {
            pModel  = new char[nLength];
        } // try
        catch(std::bad_alloc& ba)
        {
            std::perror("sysctlbyname() failed in acquring a string buffer for the hardware model!");
            
            return -1;
        } // catch
        
        int result = sysctlbyname("hw.model", pModel, &nLength, NULL, 0);
        
        if(result < 0)
        {
            std::perror("sysctlbyname() failed in acquring a hardware model name!");
        } // if
        else
        {
            model = pModel;
            
            delete [] pModel;
            
            pModel = NULL;
        } // else
    } // if
    
    return result;
} // CFQueryHardwareGetModel

#pragma mark -
#pragma mark Public - Hardware

CF::Query::Hardware::Hardware(const double_t& frequency)
{
    mnCores = 0;
    mnCPU = 0.0f;
    mnFreq  = (frequency > 0.0f) ? frequency : CF::Query::Frequency::kGigaHetrz;
    mnScale = mnFreq;
    
    int result = CFQueryHardwareGetCPUCount(mnCores);
    
    if(result > -1)
    {
        result = CFQueryHardwareGetCPUClock(mnCPU);
        
        if(result > -1)
        {
            mnScale *= mnFreq * mnCPU * double_t(mnCores);
        } // if
    } // if
    
    CFQueryHardwareGetMemSize(mnSize);
    CFQueryHardwareGetModel(m_Model);
} // Constructor

CF::Query::Hardware::~Hardware()
{
    mnCores = 0;
    mnSize  = 0;
    mnFreq  = 0.0f;
    mnCPU   = 0.0f;
    mnScale = 0.0f;
    
    m_Model.clear();
} // Destructor

CF::Query::Hardware::Hardware(const CF::Query::Hardware& hw)
{
    mnCores = hw.mnCores;
    mnSize  = hw.mnSize;
    mnCPU   = hw.mnCPU;
    mnFreq  = hw.mnFreq;
    mnScale = hw.mnScale;
    m_Model = hw.m_Model;
} // Copy Constructor

CF::Query::Hardware& CF::Query::Hardware::operator=(const CF::Query::Hardware& hw)
{
 	if(this != &hw)
    {
        mnCores = hw.mnCores;
        mnSize  = hw.mnSize;
        mnCPU   = hw.mnCPU;
        mnFreq  = hw.mnFreq;
        mnScale = hw.mnScale;
        m_Model = hw.m_Model;
    } // if
    
    return *this;
} // operator=

void CF::Query::Hardware::setFrequency(const double_t& frequency)
{
    mnFreq   = (frequency > 0.0f) ? frequency : CF::Query::Frequency::kGigaHetrz;
    mnScale  = mnFreq;
    mnScale *= mnFreq * mnCPU * double_t(mnCores);
} // setFrequency

const size_t& CF::Query::Hardware::cores() const
{
    return mnCores;
} // cores

const double_t& CF::Query::Hardware::cpu() const
{
    return mnCPU;
} // cpu

const size_t& CF::Query::Hardware::memory() const
{
    return mnSize;
} // memory

const double_t& CF::Query::Hardware::scale() const
{
    return mnScale;
} // scale

const std::string& CF::Query::Hardware::model() const
{
    return m_Model;
} // model

