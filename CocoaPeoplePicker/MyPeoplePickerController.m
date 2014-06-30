/*
     File: MyPeoplePickerController.m
 Abstract: MyPeoplePickerController.h
  Version: 1.3
 
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

#import "MyPeoplePickerController.h"
#import <AddressBook/ABPeoplePickerView.h>
#import <AddressBook/AddressBook.h>

@interface MyPeoplePickerController ()
@property (weak) IBOutlet ABPeoplePickerView *peoplePickerView;
@end


@implementation MyPeoplePickerController

// Show all the groups selected in the people picker view in the console
- (IBAction)printGroups:(id)sender
{
    NSArray *groups = [self.peoplePickerView selectedGroups];
    NSLog(@"Groups: %lu groups selected", [groups count]);
    for (ABGroup *group in groups)
    {
        NSLog(@"Name:%@ Identifier:%@", [group valueForProperty:kABGroupNameProperty],[group uniqueId]);
    }
}


// Show all the contacts currently selected in the people picker view in the console
- (IBAction)printContacts:(id)sender
{
    NSArray *records = [self.peoplePickerView selectedRecords];
    NSLog(@"Records: %lu records selected", [records count]);
    
    for (ABPerson *record in records)
    {
        NSLog(@"Name:%@  Identifier:%@",[NSString stringWithFormat:@"%@ %@",[record valueForProperty:kABFirstNameProperty], [record valueForProperty:kABLastNameProperty]],[record uniqueId]);
    }
}


// Activate specific values for display
- (IBAction)viewProperty:(NSButton *)sender
{
    NSString *property;
    // See MainMenu.nib for the corresponding checkbox tags.
    switch ([sender tag])
    {
        case 0: // Phone
            property = kABPhoneProperty;
            break;
        case 1: // Address
            property = kABAddressProperty;
            break;
        case 2: // Email
            property = kABEmailProperty;
            break;
        case 3: // AIM
            property = kABInstantMessageProperty;
            break;
        case 4: // Homepage
            property = kABURLsProperty;
            break;
        default:
            property = kABHomePageProperty;
            break;
    }
    if ([sender state] == NSOnState)
    {
        [self.peoplePickerView addProperty:property];
    } else
    {
        [self.peoplePickerView removeProperty:property];
    }
}


//[Dis]allow entire group selection in the people picker
- (IBAction)toggleGroupSelection:(NSButton *)sender
{
    [self.peoplePickerView setAllowsGroupSelection:([sender state] == NSOnState)];
}


//[Dis]allow the selection of multiple groups,contacts, or values of multivalue properties in the people picker
- (IBAction)toggleMultipleItemsSelection:(NSButton *)sender
{
    [self.peoplePickerView setAllowsMultipleSelection:([sender state] == NSOnState)];
}


//Launch Address Book to edit the selected contact
- (IBAction)editSelectedContactInAB:(id)sender
{
    [self.peoplePickerView editInAddressBook:sender];
}


//Launch Address Book to show the selected contact
- (IBAction)showSelectedContactInAB:(id)sender
{
    [self.peoplePickerView selectInAddressBook:sender];
}


@end
