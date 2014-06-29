
/*
     File: APLOrderController.m
 Abstract: Controller object that manages a collection of entrees and toppings.
  Version: 1.1
 
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

#import "APLOrderController.h"

// Keys used by the Entree and Topping dictionaries
static NSString *const kItemNameKey = @"name";
static NSString *const kItemPriceKey = @"price";


@interface APLOrderController ()

// In OS x v10.8, NSTextView does not support weak references.
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@property NSArray *toppings;
@property NSArray *entrees;

@end


@implementation APLOrderController


- (id)init {
    self = [super init];
    
    if (self) {

        // Set up entrees.
        _entrees = @[ @{ kItemNameKey : NSLocalizedString(@"Pizza", @"Pizza"), kItemPriceKey : @5.50f }, @{ kItemNameKey : NSLocalizedString(@"Calzone", @"Calzone"), kItemPriceKey : @6.75f } ];
        
        // Set up toppings.
        _toppings = @ [ @{ kItemNameKey: NSLocalizedString(@"Tomato", @"Tomato"), kItemPriceKey: @1.50f }, @{ kItemNameKey: NSLocalizedString(@"Cheese", @"Cheese"), kItemPriceKey: @1.75f }, @{ kItemNameKey: NSLocalizedString(@"Pepperoni", @"Pepperoni"), kItemPriceKey: @2.75f }, @{ kItemNameKey: NSLocalizedString(@"Sausage", @"Sausage"), kItemPriceKey: @2.25f } ];
    }
    
    return self;
}


#pragma mark - Bound methods

/*
 The following method is bound using Cocoa's binding capabilities. To see how the methods are bound, look in MainMenu.xib.
 
 orderEntree:withToppings: is the method invoked by the "Place your order" button -- it is set up using bindings.
 
 The task is to "print out" to the text view the components and total price of the current order.
 
 The button's bindings are as follows:
 
 1) 'target' is bound to [APLOrderController].self -- this uses 'self' as a key simply to return the APLOrderController instance.
 
 The selector (specified in the 'target' binding) is orderEntree:withToppings:, identifying this method.
 
 2) 'argument' is a multi-value binding:
 
 'argument' is [Entrees].selection -- a proxy object representing the array controller's selection. This object is passed as the first argument to orderEntree:withToppings:. The method only sends the selected object (an entree dictionary) in the entrees table view.
 
 'argument2' is [Toppings].selectedObjects -- the objects currently selected in the toppings table view. This array is passed as the second argument to orderEntree:withToppings:.
 */

- (void)orderEntree:(id)selectedEntree withToppings:(NSArray *)selectedToppings {
	/*
     Check that there was an entree selection (the table view should disallow empty selections, but this is a useful example).
	 */
	if (NSNoSelectionMarker == [selectedEntree valueForKey:@"self"]) {
		[self appendToTextView:NSLocalizedString(@"No Entree Selected", @"No entree selected.\n\n")];
        
		return;
	}
    
    // The total price starts with the price of the entree.
	float __block totalCost = [[selectedEntree valueForKey:kItemPriceKey] floatValue];
    
    
    // If there are no toppings, end here by adding just the plain entree to the order.
	if ([selectedToppings count] == 0) {
        
        NSString *localizedTotalCostWithoutToppings = [NSNumberFormatter localizedStringFromNumber:@(totalCost) numberStyle:NSNumberFormatterCurrencyStyle];
        
		NSString *orderSummaryString = [NSString localizedStringWithFormat:NSLocalizedString(@"Plain Order Summary Format", @"Plain %@\nCost: %@\n\n"),[selectedEntree valueForKey:kItemNameKey], localizedTotalCostWithoutToppings];
        
		[self appendToTextView:orderSummaryString];
        
		return;
	}
	
	/*
     Build an array comprising the names of each of the selected toppings (this is used later to generate the string of components) and update the total.
	 */
	NSMutableArray *toppingNames = [NSMutableArray array];
    [selectedToppings enumerateObjectsUsingBlock:^(NSDictionary *topping, NSUInteger idx, BOOL *stop) {
        
        [toppingNames addObject:[topping valueForKey:kItemNameKey]];
        NSNumber *toppingCostNumber = [topping valueForKey:kItemPriceKey];
        totalCost += toppingCostNumber.floatValue;
    }];
    
    NSString *localizedTotalCostWithToppings = [NSNumberFormatter localizedStringFromNumber:@(totalCost) numberStyle:NSNumberFormatterCurrencyStyle];
    
    // Create a string for the order summary and append that to the text view.
	NSString *toppingsString = [toppingNames componentsJoinedByString:NSLocalizedString(@"Toppings Separator", @", ")];
    
	NSString *orderSummaryString = [NSString localizedStringWithFormat:NSLocalizedString(@"Order Summary Format", @"%@ with %@\nCost: %@\n\n"), [selectedEntree valueForKey:kItemNameKey], toppingsString, localizedTotalCostWithToppings];
    
	[self appendToTextView:orderSummaryString];
}


#pragma mark - Private helper method

// Simple method to append a string to the text view and scroll the text view to make the latest order visible.
- (void)appendToTextView:(NSString *)stringToAppend {
    
	NSInteger textLength = [[self.textView textStorage] length];
	NSRange range = NSMakeRange(textLength, 0);
	[self.textView replaceCharactersInRange:range withString:stringToAppend];
	textLength = [[self.textView textStorage] length];
	range = NSMakeRange(textLength, 0);
	[self.textView scrollRangeToVisible:range];
}

@end

