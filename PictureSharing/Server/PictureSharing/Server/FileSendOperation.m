/*
     File: FileSendOperation.m
 Abstract: An NSOperation that sends a file over a TCP connection.
  Version: 2.2
 
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

#import "FileSendOperation.h"

#include <zlib.h>

enum {
    kFileSendOperationStateStart,
    kFileSendOperationStateHeader, 
    kFileSendOperationStateBody, 
    kFileSendOperationStateTrailer
};

enum {
    kFileSendOperationBufferSize = 32768
};

@interface FileSendOperation () <NSStreamDelegate>

// internal properties

@property (atomic, assign, readwrite) NSInteger         sendState;
@property (atomic, strong, readwrite) NSInputStream *   fileStream;
@property (atomic, strong, readwrite) NSMutableData *   buffer;
@property (atomic, assign, readwrite) NSUInteger        bufferOffset;
@property (atomic, assign, readwrite) off_t             fileLength;
@property (atomic, assign, readwrite) off_t             fileOffset;
@property (atomic, assign, readwrite) uLong             crc;

@end

@implementation FileSendOperation

- (id)initWithFilePath:(NSString *)filePath outputStream:(NSOutputStream *)outputStream
{
    assert(filePath != nil);
    assert(outputStream != nil);

    self = [super init];
    if (self != nil) {
        self->_filePath     = [filePath copy];
        self->_outputStream = outputStream;
    }
    return self;
}

- (void)dealloc
{
    assert(self->_buffer == nil);
    assert(self->_fileStream == nil);
}

#pragma mark * Start and stop

- (void)operationDidStart
    // Our superclass calls this on the actual run loop thread to give us an opportunity 
    // to install our run loop sources (and do various other bits of initialisation).
{
    NSDictionary *  fileAttributes;
    NSError *       error;

    assert(self.isActualRunLoopThread);
    assert(self.state == kQRunLoopOperationStateExecuting);
    
    assert(self.fileStream == nil);
        
    // First get the file attributes, to allows us to send the header which contains the file size.
    // This has the added benefit of flush out errors early.
    
    fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:&error];
    if (fileAttributes == nil) {
        [self finishWithError:error];
    } else {
    
        // Now open the file stream.
        
        self.fileStream = [NSInputStream inputStreamWithFileAtPath:self.filePath];
        if (self.fileStream == nil) {
            [self finishWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil]];
        } else {
            // Determine the file length.
            
            assert( [fileAttributes[NSFileSize] isKindOfClass:[NSNumber class]] );
            self.fileLength = [fileAttributes[NSFileSize] longLongValue];
            assert(self.fileLength >= 0);
            
            // Allocate a transfer buffer.
            
            self.buffer = [NSMutableData dataWithCapacity:kFileSendOperationBufferSize];
            assert(self.buffer != nil);
            
            assert(self.sendState == kFileSendOperationStateStart);
            assert(self.bufferOffset == 0);
            assert(self.fileOffset == 0);
            assert(self.crc == 0);
            
            // Open up our streams.
            
            [self.fileStream open];

            [self.outputStream setDelegate:self];
            for (NSString * mode in self.actualRunLoopModes) {
                [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
            }
            [self.outputStream open];
        }
    }
}

- (void)operationWillFinish
    // Our superclass calls this on the actual run loop thread to give us an opportunity 
    // to remove our run loop sources (and do various other bits of clean up).
{
    assert(self.isActualRunLoopThread);
    
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    if (self.outputStream != nil) {
        // We want to hold on to our reference to outputStream until -dealloc, but 
        // we don't want to do this teardown twice, so we conditionalise it based on 
        // whether the delegate is still set.
        if ([self.outputStream delegate] != nil) {
            [self.outputStream setDelegate:nil];
            for (NSString * mode in self.actualRunLoopModes) {
                [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:mode];
            }
            [self.outputStream close];
        }
    }
    self.buffer = nil;      // might as well free up the memory now
}

#pragma mark * Stream delegate callbacks

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
    // An NSStream delegate callback that's called when events happen on our TCP stream.
{
    // CFSocketStream does not retain its delegate.  It's possible that actions early 
    // in this method can affect the state of the program (typically by setting isFinished 
    // to YES so that all our clients release their references to the operation) such that 
    // all references to this object are released, resulting in code later in the method 
    // accessing a self that's been deallocated <rdar://problem/12682482>.  To avoid this, 
    // we manually retain self across the lifetime of this callback.
    
    CFRetain( (__bridge CFTypeRef) self );
    
    assert([NSThread isMainThread]);

    assert(aStream == self.outputStream);
    #pragma unused(aStream)

    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            // do nothing
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);
        } break;
        case NSStreamEventHasSpaceAvailable: {
            NSInteger   bytesWritten;

            #if ! defined(NDEBUG)
                if (self.debugStallSend) {
                    return;
                }
            #endif
            
            // If the buffer has no more data to send, refill it.
            
            if (self.bufferOffset == [self.buffer length]) {
                self.bufferOffset = 0;
                
                switch (self.sendState) {
                    case kFileSendOperationStateStart: {
                        uint64_t    header;

                        // Set up the buffer to send the header.

                        header = OSSwapHostToBigInt64(self.fileLength);
                        [self.buffer setLength:0];
                        [self.buffer appendBytes:&header length:sizeof(header)];

                        self.sendState = kFileSendOperationStateHeader;
                    } break;
                    case kFileSendOperationStateHeader:
                        self.sendState = kFileSendOperationStateBody;
                        // fall through
                    case kFileSendOperationStateBody: {
                        if (self.fileOffset < self.fileLength) {
                            NSUInteger  bytesToRead;
                            NSInteger   bytesRead;

                            // Set up the buffer to send the next chunk of body data.
                            
                            if ( (self.fileLength - self.fileOffset) < (off_t) kFileSendOperationBufferSize ) {
                                bytesToRead = (NSUInteger) (self.fileLength - self.fileOffset);
                            } else {
                                bytesToRead = kFileSendOperationBufferSize;
                            }
                            [self.buffer setLength:bytesToRead];
                            bytesRead = [self.fileStream read:[self.buffer mutableBytes] maxLength:bytesToRead];
                            if (bytesRead < 0) {
                                [self finishWithError:[self.fileStream streamError]];
                            } else if (bytesRead == 0) {
                                // The file must have shrunk while we were reading it!
                                [self finishWithError:[NSError errorWithDomain:NSPOSIXErrorDomain code:EPIPE userInfo:nil]];
                            } else {
                                [self.buffer setLength:(NSUInteger) bytesRead];
                                
                                self.crc = crc32(self.crc, [self.buffer bytes], (uInt) [self.buffer length]);
                                
                                self.fileOffset += bytesRead;
                            }
                        } else {
                            uint32_t    trailer;

                            // Set up the buffer to send the trailer.

                            trailer = OSSwapHostToBigInt32( (uint32_t) self.crc );
                            #if ! defined(NDEBUG)
                                if (self.debugSendBadChecksum) {
                                    trailer ^= 1;
                                }
                            #endif
                            [self.buffer setLength:0];
                            [self.buffer appendBytes:&trailer length:sizeof(trailer)];

                            self.sendState = kFileSendOperationStateTrailer;
                        }
                    } break;
                    case kFileSendOperationStateTrailer: {
                        [self finishWithError:nil];
                    } break;
                }
            }

            // Try to send the remaining bytes in the buffer.
            
            if ( ! [self isFinished] ) {
                assert(self.bufferOffset < [self.buffer length]);
                bytesWritten = [self.outputStream write:((const uint8_t *) [self.buffer bytes]) + self.bufferOffset maxLength:[self.buffer length] - self.bufferOffset];
                if (bytesWritten < 0) {
                    [self finishWithError:[self.outputStream streamError]];
                } else {
                    self.bufferOffset += bytesWritten;
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
            assert([self.outputStream streamError] != nil);
            [self finishWithError:[self.outputStream streamError]];
        } break;
        case NSStreamEventEndEncountered: {
            assert(NO);
        } break;
        default: {
            assert(NO);
        } break;
    }
    
    CFRelease( (__bridge CFTypeRef) self );
}

@end
