/*
     File: APLAppDelegate.m
 Abstract: Application delegate class.
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

#import "APLAppDelegate.h"



@interface APLAppDelegate ()

@property (weak) IBOutlet NSTableView *mountainsTableView;
@property (weak) IBOutlet NSTextField *sentenceText;

@property (nonatomic, readonly) NSArray *mountains;
@property (nonatomic) NSArray *sortedMountains;

@end



#import "APLMountain.h"


@implementation APLAppDelegate

// mountains is a readonly property, so the instance variable isn't synthesized by default.
@synthesize mountains = _mountains;


// Configure the UI after the nib is loaded.
- (void)awakeFromNib
{
	[self resetSentence];
}


#pragma mark - Table view data source 

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [self.mountains count];
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	id returnValue = @"";
    
	APLMountain *mountain = [self.sortedMountains objectAtIndex:rowIndex];
	NSString *columnID = [aTableColumn identifier];
    
	if ([columnID isEqualToString:kMountainNameKey]) {
		returnValue = [[mountain name] capitalizedString];
	}
	else if ([columnID isEqualToString:kMountainHeightKey]) {
		returnValue = [self stringFromHeight:[mountain height]];
	}
	else if ([columnID isEqualToString:kMountainClimbedDateKey]) {
		returnValue = [self stringWithClimbedDate:[mountain climbedDate]];
	}
    
	return returnValue;
}


#pragma mark - Responding to changes in the table view

- (void)tableViewSelectionDidChange:(id)notification
{
	[self resetSentence];
}


- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    self.sortedMountains = nil;
	[aTableView reloadData];
}


/*
 When the table view sorting changes, the selected row doesn't, so reset the sentence display to match the new data on that row.
 */
- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{
	[self resetSentence];
}


/*
 Reset the text field with a sentence for the currently selected mountain. This is localized, and two versions are used because not all mountains have a climbed date available.
 */
- (void)resetSentence
{
    NSTableView *summaryTable = self.mountainsTableView;

	NSString *sentence = @"";
	NSString *format;
	if ([summaryTable selectedRow] != -1) {
		APLMountain *mountain = (APLMountain *) [[self sortedMountains] objectAtIndex:[summaryTable selectedRow]];
		if (mountain.climbedDate != nil) {
			format = NSLocalizedStringFromTable(@"sentenceFormat", @"Mountains", @"A sentence with the mountain's name (first parameter), height (second parameter), and climbed date (third parameter)");
			sentence = [NSString stringWithFormat:format, mountain.name, [self stringFromHeight:mountain.height], [self stringWithClimbedDate:mountain.climbedDate]];
		}
		else {
			format = NSLocalizedStringFromTable(@"undatedSentenceFormat", @"Mountains", @"A sentence with the mountain's name (first parameter), and height (second parameter), but no climbed date");
			sentence = [NSString stringWithFormat:format, mountain.name, [self stringFromHeight:mountain.height]];
		}
	}
    
	[self.sentenceText setStringValue:sentence];
}

// Update all the UI elements.
- (void)resetAll
{
	[self resetSentence];
	[self.mountainsTableView reloadData];
}


#pragma mark - String representations of data

/*
Returns a single string expressing a mountain's height. Allow for the possibility that the user is using non-metric units. If the units are non-metric, convert the value to feet.
*/
- (NSString*)stringFromHeight:(NSNumber*)heightNumber
{
	NSString *returnValue = @"";
	if (heightNumber != nil) {
		NSString *format = @"%d";
		NSInteger height = [heightNumber integerValue];
		NSNumber *usesMetricSystem = [[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem];
        
		if (usesMetricSystem != nil && ![usesMetricSystem boolValue]) {
			// Convert the height to feet
			height = (int) ((float) height * 3.280839895);
			format = NSLocalizedStringFromTable(@"footFormat", @"Mountains", @"Use to express a height in feet");
		}
		else {
			format = NSLocalizedStringFromTable(@"meterFormat", @"Mountains", @"Use to express a height in meters");
		}

		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];

		returnValue = [NSString stringWithFormat:format, [formatter stringFromNumber:[NSNumber numberWithInteger:height]]];

	}
	return returnValue;
}

/*
 Returns a localized string expressing a mountain's climbed date.
 */
- (NSString*)stringWithClimbedDate:(NSDate*)date
{
	NSString *returnValue = @"";
    
	if (date != nil) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterLongStyle];
		[formatter setTimeStyle:NSDateFormatterNoStyle];
		returnValue = [formatter stringFromDate:date];
	}
    
	// Demonstrate that descriptionWithLocale does the right thing.
	NSLog(@"%@ => %@", [date descriptionWithLocale:[NSLocale currentLocale]], returnValue);
	return returnValue;
}


#pragma mark - Responding to locale changes

/*
 It is generally unusual for a user to change their locale settings while an application is running. If they do, there may be limits to what you can do to respond. In this application, you can change the way some of the mountain data is displayed at runtime, but the mountain names and so on remain the same, as do titles on user interface items like the window and menus.
 */

- (void)applicationDidFinishLaunching:(NSNotification *)notification {

    // Register for notifications of locale changes (so we can update everything).
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeChanged:) name:NSCurrentLocaleDidChangeNotification object:nil];
}


- (void)localeChanged:(NSNotification *)notification
{
	[self resetAll];
}


#pragma mark - Mountain data

/*
 Allocate the mountain data only when it's needed.
 */
- (NSArray *)mountains
{
	if (_mountains == nil) {
		// Get the localized version of the data file.
        NSURL *mountainsPlistURL = [[NSBundle mainBundle] URLForResource:@"Mountains" withExtension:@"plist"];
        if (!mountainsPlistURL) {
            NSLog(@"Didn't find the mountains");
            return nil;
        }

        NSArray *mountainDictionaries = [[NSArray alloc] initWithContentsOfURL:mountainsPlistURL];
        NSMutableArray *mountainsArray = [[NSMutableArray alloc] initWithCapacity:[mountainDictionaries count]];

        for (NSDictionary *mountainDictionary in mountainDictionaries) {
            APLMountain *mountain = [APLMountain mountainWithDictionary:mountainDictionary];
            [mountainsArray addObject:mountain];
        }
        _mountains = [mountainsArray copy];
	}

	return _mountains;
}


/*
 Mountains sorted per the table view's descriptors. Note that the sort method for the name column is localizedStandardCompare:.
 */
- (NSArray*)sortedMountains
{
    if (_sortedMountains == nil) {
        _sortedMountains = [[self mountains] sortedArrayUsingDescriptors:[self.mountainsTableView sortDescriptors]];
    }
	return _sortedMountains ;
}


#pragma mark - Tidying up

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSCurrentLocaleDidChangeNotification object:nil];
}


// NSApp delegate method
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}


@end