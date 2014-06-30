/*
     File: AppController.mm 
 Abstract: 
    Demonstrates how to enumerate audio devices attached to the system and how to handle device notification.
    This implementation uses the Core Audio Utility Classes and a listener block.
  
  Version: 2.1.1 
  
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
  
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
  
*/

#import <CoreAudio/CoreAudio.h>
#import "AppController.h"

#import "CAHALAudioDevice.h"
#import "CAHALAudioSystemObject.h"
#import "CAPropertyAddress.h"

static void GetAudioDevices(Ptr *devices, UInt32 *devicesAvailable)
{
    CAHALAudioSystemObject audioSystemObject;
    
    *devicesAvailable = audioSystemObject.GetNumberAudioDevices();
    
    // make space for the devices we are about to get
    UInt32 theDataSize = *devicesAvailable * sizeof(AudioObjectID);
    
    if (*devices != NULL) free(*devices);
    *devices = (Ptr)malloc(theDataSize);
    memset(*devices, 0, theDataSize);
    
    UInt32 ioNumberAudioDevices = *devicesAvailable;
    audioSystemObject.GetAudioDevices(ioNumberAudioDevices, (AudioObjectID *)*devices);
}

@implementation AppController

-(void) awakeFromNib
{
	// create empty array to hold device info
	deviceArray = [[NSMutableArray alloc] init];
	if(!deviceArray) return;

	// generate initial device list
	[self updateDeviceList];
    
    // creating the block here allows us access to self so we can call performSelectorOnMainThread when required
    AudioObjectPropertyListenerBlock listenerBlock = ^(UInt32 inNumberAddresses, const AudioObjectPropertyAddress inAddresses[]) {
        
        for (UInt32 x=0; x<inNumberAddresses; x++) {
            
                switch (inAddresses[x].mSelector)
                {
            /*
             * These are the other types of notifications we might receive, however, they are beyond
             * the scope of this sample and we ignore them.
             *
                    case kAudioHardwarePropertyDefaultInputDevice:
                        fprintf(stderr, "AOPropertyListenerBlock: default input device changed\n");
                    break;
                        
                    case kAudioHardwarePropertyDefaultOutputDevice:
                        fprintf(stderr, "AOPropertyListenerBlock: default output device changed\n");
                    break;
                        
                    case kAudioHardwarePropertyDefaultSystemOutputDevice:
                        fprintf(stderr, "AOPropertyListenerBlock: default system output device changed\n");
                    break;
            */
                    case kAudioHardwarePropertyDevices:
                    {
                        fprintf(stderr, "AOPropertyListenerBlock: kAudioHardwarePropertyDevices\n");
                        [self performSelectorOnMainThread:@selector(updateDeviceList) withObject:nil waitUntilDone:NO];
                    }
                    break;
                        
                    default:
                        fprintf(stderr, "AOPropertyListenerBlock: unknown message\n");
                    break;
                }
            }
        };
    
    // need to retain the listener block so that we can remove it later
    AOPropertyListenerBlock = Block_copy(listenerBlock);
	
    // install kAudioHardwarePropertyDevices listener block on the system object
    CAHALAudioSystemObject audioSystemObject;
    audioSystemObject.AddPropertyListenerBlock(CAPropertyAddress(kAudioHardwarePropertyDevices), dispatch_get_main_queue(), AOPropertyListenerBlock);
}

- (void)windowWillClose:(NSNotification *)notification
{
	// remove kAudioHardwarePropertyDevices listener block
    CAHALAudioSystemObject audioSystemObject;
    audioSystemObject.RemovePropertyListenerBlock(CAPropertyAddress(kAudioHardwarePropertyDevices), dispatch_get_main_queue(), AOPropertyListenerBlock);
    
    // release the copied block
    Block_release(AOPropertyListenerBlock);
    AOPropertyListenerBlock = NULL;
}

- (void)updateDeviceList
{
    UInt32		  devicesAvailable = 0;

	UInt32      theNumberInputChannels  = 0;
	UInt32      theNumberOutputChannels = 0;
	CFNumberRef tempNumberRef = NULL;
	CFStringRef tempStringRef = NULL;
	
	// clear out any current entries in device array
	[deviceArray removeAllObjects];
	
	// fetch a pointer to the list of available devices
	GetAudioDevices((Ptr *)&devices, &devicesAvailable);
    
	// iterate over each device gathering information
	for (UInt32 loopCount = 0; loopCount < devicesAvailable; loopCount++) {
		
        // get the object id
        AudioObjectID deviceID = devices[loopCount];
		
		// create dictionary to hold device info
        CFMutableDictionaryRef theDict = NULL;
		theDict = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		if ( theDict == NULL ) {
			fprintf(stderr, "Dictionary Creation Failed\n" );
			return;
		}

		// save id
		tempNumberRef = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt32Type,&deviceID);
		if (tempNumberRef) {
			CFDictionarySetValue(theDict, CFSTR("id"), tempNumberRef);
			CFRelease(tempNumberRef);
		}
        
        // get current device
        CAHALAudioDevice currentDevice = CAHALAudioDevice::CAHALAudioDevice(deviceID);
		
        // get device name
        tempStringRef = currentDevice.CopyName();
		if(tempStringRef) {
			CFDictionarySetValue(theDict, CFSTR("name"), tempStringRef);
			CFRelease(tempStringRef);
		}
        
        // get number of input channels
        theNumberInputChannels = currentDevice.GetTotalNumberChannels(true); // isInput = true
        tempNumberRef = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt32Type,&theNumberInputChannels);
        if  (tempNumberRef) {
            CFDictionarySetValue(theDict, CFSTR("ich"), tempNumberRef);
            CFRelease(tempNumberRef);
        }
        
        // get number of output channels
        theNumberOutputChannels = currentDevice.GetTotalNumberChannels(false); // isInput = false
        tempNumberRef = CFNumberCreate(kCFAllocatorDefault,kCFNumberSInt32Type,&theNumberOutputChannels);
        if (tempNumberRef) {
            CFDictionarySetValue(theDict, CFSTR("och"), tempNumberRef);
            CFRelease(tempNumberRef);
        }
        
		[deviceArray addObject:(NSDictionary*)theDict];
		CFRelease(theDict);
	}
    
	[myTable reloadData];
}

- (NSUInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [deviceArray count];
}

- (id)tableView:(NSTableView *)aTableView
      objectValueForTableColumn:(NSTableColumn *)aTableColumn
      row:(int)rowIndex
{
	NSDictionary *deviceDict = NULL;
	
	deviceDict = [deviceArray objectAtIndex:rowIndex];
	return [deviceDict objectForKey:[aTableColumn identifier]];
}

@end
