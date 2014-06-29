/*
     File: NSStringMap.h
 Abstract: 
 Associative arrays for keys (strings) and values.
 
  Version: 2.0
 
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

#ifndef _NS_STRING_MAP_H_
#define _NS_STRING_MAP_H_

#import <Cocoa/Cocoa.h>

#import <iostream>
#import <string>
#import <unordered_map>

#ifdef __cplusplus

namespace NS
{
    namespace String
    {
        template <typename TName>
        class TMap
        {
        private:
            std::unordered_map<std::string,TName> m_Map;
            
        public:
            TMap()
            {
            }; // Constructor
            
            virtual ~TMap()
            {
                m_Map.clear();
            } // Destructor
            
            inline bool replace(const std::string &rKey, const TName nValue)
            {
                BOOL bSuccess = !rKey.empty();
                
                if(bSuccess)
                {
                    m_Map[rKey] = nValue;
                } // if
                else
                {
                    std::cerr << ">> ERROR: Can't replace with an empty key!" << std::endl;
                } // else
                
                return bSuccess;
            } // replace
            
            inline bool replace(const NSString * const pKey, const TName nValue)
            {
                bool bSuccess = pKey != nil;
                
                if(bSuccess)
                {
                    std::string key = [pKey cStringUsingEncoding:NSASCIIStringEncoding];
                    
                    this->replace(key, nValue);
                } // if
                else
                {
                    std::cerr << ">> ERROR: Can't replace with an invalid key!" << std::endl;
                } // else
                
                return bSuccess;
            } // replace
            
            inline bool emplace(const std::string &rKey, const TName nValue)
            {
                bool bSuccess = !rKey.empty();
                
                if(bSuccess)
                {
                    m_Map.emplace(rKey,nValue);
                } // if
                else
                {
                    std::cerr << ">> ERROR: Can't emplace with an empty key!" << std::endl;
                } // else
                
                return bSuccess;
            } // emplace
            
            inline bool emplace(const NSString * const pKey, const TName nValue)
            {
                bool bSuccess = pKey != nil;
                
                if(bSuccess)
                {
                    std::string key = [pKey cStringUsingEncoding:NSASCIIStringEncoding];
                    
                    this->emplace(key, nValue);
                } // if
                else
                {
                    std::cerr << ">> ERROR: Can't emplace an invalid key!" << std::endl;
                } // else
                
                return bSuccess;
            } // emplace
            
            inline TName value(const std::string &rKey)
            {
                TName nValue = TName(0);
                
                if(!rKey.empty())
                {
                    auto pIter = m_Map.find(rKey);
                    
                    if(pIter != m_Map.cend())
                    {
                        nValue = pIter->second;
                    } // if
                } // if
                else
                {
                    std::cerr << ">> ERROR: Can't acquire value with an empty key!" << std::endl;
                } // else
                
                return nValue;
            } // value
            
            inline TName value(const NSString * const pKey)
            {
                TName nValue = TName(0);
                
                if(pKey)
                {
                    std::string key = [pKey cStringUsingEncoding:NSASCIIStringEncoding];
                    
                    nValue = this->value(key);
                } // if
                else
                {
                    std::cerr << ">> ERROR: Can't acquire value with a NULL key!" << std::endl;
                } // else
                
                return nValue;
            } // value
            
            inline size_t size()
            {
                return m_Map.size();
            } // size
            
            inline void clear()
            {
                m_Map.clear();
            } // clear
        }; // TMap
    } // String
} // NS

#endif

#endif
