/*
     File: AddressBookCocoa.m
 Abstract: Shows how to create, access, add, search, and retrieve Address Book records.
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

#import <AddressBook/AddressBook.h>
#import "AddressBookCocoa.h"

@interface AddressBookCocoa ()
@property (weak) IBOutlet NSTextField *firstName;
@property (weak) IBOutlet NSTextField *streetAddress;
@property (weak) IBOutlet NSTextField *workFaxPhone;
@property (weak) IBOutlet NSTextField *matchingRecordsFound;
@property (weak) IBOutlet NSButton *addContactButton;
@property (weak) IBOutlet NSButton *findContactButton;
@property (nonatomic, strong) ABAddressBook *addressBook;

@end

@implementation AddressBookCocoa
Boolean findFirstMatchWithLabel(ABMutableMultiValue *multiValue, NSString *label, int* index);

-(void)awakeFromNib
{
    // Fetch the address book for the logged-in user. This API will return an instance of address book
    // if the user has granted access to the Address Book database and nil, otherwise.
    self.addressBook= [ABAddressBook sharedAddressBook];
    
    // Enable the addContact and findContact buttons if the user has granted us acccess to the Address Book
    if (self.addressBook != nil)
    {
        [self.addContactButton setEnabled:YES];
        [self.findContactButton setEnabled:YES];
    }
    else
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"\"AddressBookCocoa\" does not have access to Contacts."
                                         defaultButton:@"OK"
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"Grant it access in Apple menu > System Preferences > Security & Privacy > Privacy to enable its features."];
        [alert runModal];

    }
}


#pragma mark Add a contact

// Create and add a contact to the Address Book
- (IBAction)addContact:(id)sender
{
    // Create a contact
    ABPerson *person = [[ABPerson alloc] init];
    
    // Set the first name
    [person setValue:@"Able" forProperty:kABFirstNameProperty];

    // Set the last name
    [person setValue:@"Elba" forProperty:kABLastNameProperty];
    
    // Both homeAddress and workAddress are multivalue properties that respectively store
    // the home and work addresses. Create and populate an NSMutableDictionary object with
    // the home street, city, state, zip code, and country addresses.
    NSMutableDictionary *homeAddress = [[NSMutableDictionary alloc] initWithCapacity:0];
    [homeAddress setObject:@"123 Home Dr."  forKey:kABAddressStreetKey];
    [homeAddress setObject:@"Home City"     forKey:kABAddressCityKey];
    [homeAddress setObject:@"CA"            forKey:kABAddressStateKey];
    [homeAddress setObject:@"94110"         forKey:kABAddressZIPKey];
    [homeAddress setObject:@"United States" forKey:kABAddressCountryKey];
    

    // Create and populate an NSMutableDictionary object with the work city,
    // state, zip code, and country addresses.
    NSMutableDictionary *workAddress = [[NSMutableDictionary alloc] initWithCapacity:0];
    [workAddress setObject:@"123 Work Dr."  forKey:kABAddressStreetKey];
    [workAddress setObject:@"Work City"     forKey:kABAddressCityKey];
    [workAddress setObject:@"CA"            forKey:kABAddressStateKey];
    [workAddress setObject:@"94110"         forKey:kABAddressZIPKey];
    [workAddress setObject:@"United States" forKey:kABAddressCountryKey];

    
    // Create an ABMultivalue object and add homeAddress and workAddress to it
    ABMutableMultiValue *multiValue = [[ABMutableMultiValue alloc] init];
    [multiValue addValue:homeAddress withLabel:kABAddressHomeLabel];
    [multiValue addValue:workAddress withLabel:kABAddressWorkLabel];

    
    // Set up the contact for the address property
    [person setValue:multiValue forProperty:kABAddressProperty];


    // kABPhoneProperty is a multivalue. Create and populate a multiValue object with
    // home, work, mobile, main, home fax, work fax, and pager phone numbers.
    multiValue = [[ABMutableMultiValue alloc] init];
    [multiValue addValue:@"408-974-0000" withLabel:kABPhoneWorkLabel];
    [multiValue addValue:@"408-974-1111" withLabel:kABPhoneHomeLabel];
    [multiValue addValue:@"408-974-2222" withLabel:kABPhoneMobileLabel];
    [multiValue addValue:@"408-974-3333" withLabel:kABPhoneMainLabel];
    [multiValue addValue:@"408-974-4444" withLabel:kABPhoneHomeFAXLabel];
    [multiValue addValue:@"408-974-5555" withLabel:kABPhoneWorkFAXLabel];
    [multiValue addValue:@"408-974-6666" withLabel:kABPhonePagerLabel];

    
    // Set up the contact for the phone property
    [person setValue:multiValue forProperty:kABPhoneProperty];
    
    // Add the contact to the Address Book
    if ([self.addressBook  addRecord:person])
    {
		// Save the Address Book
        if ([self.addressBook save])
        {
			NSLog(@"Contact was successfully saved to Address Book");
		}
	}
}


#pragma mark Search for contact

// Find and display a record from Address Book
- (IBAction)findContact:(id)sender
{
    int	index = 0;
    // Create a search element
    ABSearchElement *find = [ABPerson searchElementForProperty:kABLastNameProperty
                                                         label:nil
                                                           key:nil
                                                         value:@"Elba"
                                                    comparison:kABEqual];
                                            
    // Run a search
    NSArray *results = [self.addressBook recordsMatchingSearchElement:find];
    
    // How many records found?
    if ([results count] > 0)
    {
        // Update the UI with the number of matching records
        [self.matchingRecordsFound setIntegerValue:[results count]];
        
        // Get the first contact
        ABRecord *firstRecord = [results objectAtIndex:0];
        
        // Fetch its first name and add it to the UI
        [self.firstName setStringValue:[firstRecord valueForProperty:kABFirstNameProperty]];

        // Fetch this contact's address
        ABMutableMultiValue *multiValue = [firstRecord valueForProperty:kABAddressProperty];
        
        // Look for the index of the home address label in the address
        if (findFirstMatchWithLabel(multiValue, kABAddressHomeLabel, &index))
        {
             NSMutableDictionary *dictionary = [[multiValue valueAtIndex:index] mutableCopy];
             [self.streetAddress setStringValue:[dictionary valueForKey:kABAddressStreetKey]];
        }
        
        // Fetch all the phone numbers of this contact
        multiValue = [firstRecord valueForProperty:kABPhoneProperty];
        
        // Look for the index of the work fax label among the phone numbers
        if (findFirstMatchWithLabel(multiValue, kABPhoneWorkFAXLabel, &index))
        {
			 [self.workFaxPhone setStringValue:[multiValue valueAtIndex:index]];
		}
    }
}


// Fetch the index of a given label in a specified multivalue object
Boolean findFirstMatchWithLabel(ABMutableMultiValue *multiValue, NSString *label, int* index)
{
    if ([multiValue count] > 0)
    {
        for (unsigned int i=0; i<[multiValue count]; i++)
        {
            // Fetch the label for the specified index
            NSString *myLabel = [multiValue labelAtIndex:i];
            
            // Return the above index and true if both labels match
            if ([myLabel isEqualToString:label])
            {
                *index = i;
                return true;
            }
        }
    }
    return false;
}
@end
