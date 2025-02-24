/*
     File: SpeakingTextWindow.m
 Abstract: The main window hosting all the apps speech features.
  Version: 1.5
 
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

#import "SpeakingTextWindow.h"

// Constants
//
NSString *	kPlainTextDataTypeString	= @"Plain Text";
NSString *	kDefaultWindowTextString	= @"Welcome to Cocoa Speech Synthesis Example.	This application provides an example of using Apple's speech synthesis technology in a Cocoa-based application.";

NSString *	kWordCallbackParamPosition	= @"ParamPosition";
NSString *	kWordCallbackParamLength	= @"ParamLength";
NSString *	kErrorCallbackParamPosition = @"ParamPosition";
NSString *	kErrorCallbackParamError	= @"ParamError";

// Prototypes
//
static pascal void	OurErrorCallBackProc(SpeechChannel inSpeechChannel, SRefCon inRefCon, OSErr inError, long inBytePos);
static pascal void	OurTextDoneCallBackProc(SpeechChannel inSpeechChannel, SRefCon inRefCon, const void ** nextBuf, unsigned long * byteLen, long * controlFlags);
static pascal void	OurSpeechDoneCallBackProc(SpeechChannel inSpeechChannel, SRefCon inRefCon);
static pascal void	OurSyncCallBackProc(SpeechChannel inSpeechChannel, SRefCon inRefCon, OSType inSyncMessage);
static pascal void	OurPhonemeCallBackProc(SpeechChannel inSpeechChannel, SRefCon inRefCon, short inPhonemeOpcode);
static pascal void	OurWordCallBackProc(SpeechChannel inSpeechChannel, SRefCon inRefCon, long inWordPos, short inWordLen);


#pragma mark -

@implementation SpeakingTextWindow

/*----------------------------------------------------------------------------------------
init

Set the default text of the window.
----------------------------------------------------------------------------------------*/
- (id)init
{
	self = [super init];
    if (self)
    {
		// set our default window text
        const char * p = [kDefaultWindowTextString UTF8String];
		[self setTextData:[NSData dataWithBytes:p length:strlen(p)]];
		[self setTextDataType:kPlainTextDataTypeString];
	}

	return self;
}

/*----------------------------------------------------------------------------------------
 close
 
 Make sure to stop speech when closing.
 ----------------------------------------------------------------------------------------*/
- (void)close
{
    [self startStopButtonPressed:fStartStopButton];
}

/*----------------------------------------------------------------------------------------
setTextData:

Set our text data variable and update text in window if showing.
----------------------------------------------------------------------------------------*/
- (void)setTextData:(NSData *)theData
{
	fTextData = theData;

	// If the window is showing, update the text view.
	if (fSpokenTextView)
    {
		if ([[self textDataType] isEqualToString:@"RTF Document"])
			[fSpokenTextView replaceCharactersInRange:NSMakeRange(0,[[fSpokenTextView string] length]) withRTF:[self textData]];
		else
        {
			[fSpokenTextView replaceCharactersInRange:NSMakeRange(0,[[fSpokenTextView string] length])
                                           withString:[NSString stringWithUTF8String:[[self textData] bytes]]];
        }
	}
}

/*----------------------------------------------------------------------------------------
textData

Returns autoreleased copy of text data.
----------------------------------------------------------------------------------------*/
- (NSData *)textData
{
	return [fTextData copy];
}

/*----------------------------------------------------------------------------------------
setTextDataType:

Set our text data type variable.
----------------------------------------------------------------------------------------*/
- (void)setTextDataType:(NSString *)theType
{
	fTextDataType = theType;
}

/*----------------------------------------------------------------------------------------
textDataType

Returns autoreleased copy of text data.
----------------------------------------------------------------------------------------*/
- (NSString *)textDataType
{
	return [fTextDataType copy];
}

/*----------------------------------------------------------------------------------------
textDataType

Returns reference to character view for callbacks.
----------------------------------------------------------------------------------------*/
- (SpeakingCharacterView *)characterView
{
	return fCharacterView;
}

/*----------------------------------------------------------------------------------------
shouldDisplayWordCallbacks

Returns true if user has chosen to have words hightlight during synthesis.
----------------------------------------------------------------------------------------*/
- (BOOL)shouldDisplayWordCallbacks
{
	return [fHandleWordCallbacksCheckboxButton intValue];
}

/*----------------------------------------------------------------------------------------
shouldDisplayPhonemeCallbacks

Returns true if user has chosen to the character animate phonemes during synthesis.
----------------------------------------------------------------------------------------*/
- (BOOL)shouldDisplayPhonemeCallbacks
{
	return [fHandlePhonemeCallbacksCheckboxButton intValue];
}

/*----------------------------------------------------------------------------------------
shouldDisplayErrorCallbacks

Returns true if user has chosen to have an alert appear in response to an error callback.
----------------------------------------------------------------------------------------*/
- (BOOL)shouldDisplayErrorCallbacks
{
	return [fHandleErrorCallbacksCheckboxButton intValue];
}

/*----------------------------------------------------------------------------------------
shouldDisplaySyncCallbacks

Returns true if user has chosen to have an alert appear in response to an sync callback.
----------------------------------------------------------------------------------------*/
- (BOOL)shouldDisplaySyncCallbacks
{
	return [fHandleSyncCallbacksCheckboxButton intValue];
}

/*----------------------------------------------------------------------------------------
shouldDisplaySpeechDoneCallbacks

Returns true if user has chosen to have an alert appear when synthesis is finished.
----------------------------------------------------------------------------------------*/
- (BOOL)shouldDisplaySpeechDoneCallbacks
{
	return [fHandleSpeechDoneCallbacksCheckboxButton intValue];
}

/*----------------------------------------------------------------------------------------
shouldDisplayTextDoneCallbacks

Returns true if user has chosen to have an alert appear when text processing is finished.
----------------------------------------------------------------------------------------*/
- (BOOL)shouldDisplayTextDoneCallbacks
{
	return [fHandleTextDoneCallbacksCheckboxButton intValue];
}

/*----------------------------------------------------------------------------------------
awakeFromNib

This routine is call once right after our nib file is loaded.  We build our voices
pop-up menu, create a new speech channel and update our window using parameters from
the new speech channel.
----------------------------------------------------------------------------------------*/
- (void)awakeFromNib
{
	OSErr theErr = noErr;

	// Build the Voices pop-up menu
	{
		short		numOfVoices;
		long		voiceIndex;
		BOOL		voiceFoundAndSelected = NO;
		VoiceSpec	theVoiceSpec;

		// Delete the existing voices from the bottom of the menu.
		while([fVoicesPopUpButton numberOfItems] > 2)
			[fVoicesPopUpButton removeItemAtIndex:2];

		// Ask TTS API for each available voicez
		theErr = CountVoices(&numOfVoices);
		if (theErr != noErr)
			NSRunAlertPanel(@"CountVoices", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);

		if (theErr == noErr)
        {
			for (voiceIndex = 1; voiceIndex <= numOfVoices; voiceIndex++)
            {
				VoiceDescription theVoiceDesc;
				theErr = GetIndVoice(voiceIndex, &theVoiceSpec);
				if (theErr != noErr)
					NSRunAlertPanel(@"GetIndVoice", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
				if (theErr == noErr)
					theErr = GetVoiceDescription(&theVoiceSpec, &theVoiceDesc, sizeof(theVoiceDesc));
				if (theErr != noErr)
					NSRunAlertPanel(@"GetVoiceDescription", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);

				if (theErr == noErr)
                {
					// Get voice name and add it to the menu list
					NSString *theNameString = [[NSString alloc] initWithUTF8String:(char *) &(theVoiceDesc.name[1])];
					[fVoicesPopUpButton addItemWithTitle:theNameString];

					// Selected this item if it matches our default voice spec.
					if (theVoiceSpec.creator == fSelectedVoiceCreator && theVoiceSpec.id == fSelectedVoiceID)
                    {
						[fVoicesPopUpButton selectItemAtIndex:voiceIndex-1];
						voiceFoundAndSelected = YES;
					}

				}
			}

			// User preference default if problems.
			if (! voiceFoundAndSelected && numOfVoices >= 1)
            {
				// Update our object fields with the first voice
				fSelectedVoiceCreator	= 0;
				fSelectedVoiceID		= 0;

				[fVoicesPopUpButton selectItemAtIndex:0];
			}
		}
		else
        {
			[fVoicesPopUpButton selectItemAtIndex:0];
		}

	}

	// Create Speech Channel configured with our desired options and callbacks
	[self createNewSpeechChannel:NULL];

	// Set editable default fields
	[self fillInEditableParameterFields];

	// Enable buttons appropriatelly
	[fStartStopButton setEnabled:YES];
	[fPauseContinueButton setEnabled:NO];
	[fSaveAsFileButton setEnabled:YES];

	// Set starting expresison on animated character
	[self phonemeCallbacksButtonPressed:fHandlePhonemeCallbacksCheckboxButton];

}

/*----------------------------------------------------------------------------------------
updateSpeakingControlState

This routine is called when appropriate to update the Start/Stop Speaking,
Pause/Continue Speaking buttons.
----------------------------------------------------------------------------------------*/
- (void)updateSpeakingControlState
{
	// Update controls based on speaking state
	//
	[fSaveAsFileButton setEnabled:!fCurrentlySpeaking];
	[fPauseContinueButton setEnabled:fCurrentlySpeaking];
	[fStartStopButton setEnabled:!fCurrentlyPaused];

	if (fCurrentlySpeaking)
    {
		[fStartStopButton setTitle:NSLocalizedString(@"Stop Speaking", @"Stop Speaking")];
		[fPauseContinueButton setTitle:NSLocalizedString(@"Pause Speaking", @"Pause Speaking")];
	}
	else
    {
		[fStartStopButton setTitle:NSLocalizedString(@"Start Speaking", @"Start Speaking")];
		[fSpokenTextView setSelectedRange:fOrgSelectionRange];	// Set selection length to zero.
	}

	if (fCurrentlyPaused)
		[fPauseContinueButton setTitle:NSLocalizedString(@"Continue Speaking", @"Continue Speaking")];
	else
		[fPauseContinueButton setTitle:NSLocalizedString(@"Pause Speaking", @"Pause Speaking")];

	[self enableOptionsForSpeakingState:fCurrentlySpeaking];

	// update parameter fields
	Fixed tempFixedValue = 0;

	GetSpeechInfo(fCurSpeechChannel, soRate, &tempFixedValue);
	[fRateCurrentStaticField setDoubleValue:(tempFixedValue / 65536.0)];

	GetSpeechPitch(fCurSpeechChannel, &tempFixedValue);
	[fPitchBaseCurrentStaticField setDoubleValue:(tempFixedValue / 65536.0)];

	GetSpeechInfo(fCurSpeechChannel, soPitchMod, &tempFixedValue);
	[fPitchModCurrentStaticField setDoubleValue:(tempFixedValue / 65536.0)];

	GetSpeechInfo(fCurSpeechChannel, soVolume, &tempFixedValue);
	[fVolumeCurrentStaticField setDoubleValue:(tempFixedValue / 65536.0)];
}

/*----------------------------------------------------------------------------------------
highlightWordWithParams:

Highlights the word currently being spoken based on text position and text length
provided in the word callback routine.
----------------------------------------------------------------------------------------*/
- (void)highlightWordWithParams:(NSDictionary *)params
{
	UInt32	selectionPosition = [params[kWordCallbackParamPosition] longValue] + fOffsetToSpokenText;
	UInt32	wordLength = [params[kWordCallbackParamLength] longValue];

	[fSpokenTextView scrollRangeToVisible:NSMakeRange(selectionPosition, wordLength)];
	[fSpokenTextView setSelectedRange:NSMakeRange(selectionPosition, wordLength)];
	[fSpokenTextView display];
}

/*----------------------------------------------------------------------------------------
displayErrorAlertWithParams:

Displays an alert describing a text processing error provided in the error callback.
----------------------------------------------------------------------------------------*/
- (void)displayErrorAlertWithParams:(NSDictionary *)params
{
	UInt32	errorPosition = [params[kErrorCallbackParamPosition] longValue] + fOffsetToSpokenText;
	UInt32	errorCode = [params[kErrorCallbackParamError] longValue];

	if (errorCode != fLastErrorCode)
    {
		OSErr theErr = noErr;
		unsigned long alertButtonClicked;
		NSString *theMessageStr = NULL;

		// Tell engine to pause while we display this dialog.
		theErr = PauseSpeechAt(fCurSpeechChannel, kImmediate);
		if (theErr != noErr)
			NSRunAlertPanel(@"PauseSpeechAt", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);

		// Select offending character
		[fSpokenTextView setSelectedRange:NSMakeRange(errorPosition, 1)];
		[fSpokenTextView display];

		// Display error alert, and stop or continue based on user's desires
		theMessageStr = [NSString stringWithFormat:@"Error #%ld occurred at position %ld in the text.", (long) errorCode, (long) errorPosition];
		alertButtonClicked = NSRunAlertPanel(@"Text Processing Error", theMessageStr, @"Stop", NULL, @"Continue");
		if (alertButtonClicked == 1)
			[self startStopButtonPressed:fStartStopButton];
		else
        {
			theErr = ContinueSpeech(fCurSpeechChannel);
			if (theErr != noErr)
				NSRunAlertPanel(@"ContinueSpeech", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
		}

		fLastErrorCode = errorCode;
	}
}

/*----------------------------------------------------------------------------------------
displaySyncAlertWithMessage:

Displays an alert with information about a sync command in response to a sync callback.
----------------------------------------------------------------------------------------*/
- (void)displaySyncAlertWithMessage:(NSNumber *)messageNumber
{
	OSErr theErr = noErr;
	unsigned long alertButtonClicked;
	NSString *theMessageStr = NULL;

	// Tell engine to pause while we display this dialog.
	theErr = PauseSpeechAt(fCurSpeechChannel, kImmediate);
	if (theErr != noErr)
		NSRunAlertPanel(@"PauseSpeechAt", [NSString stringWithFormat:@"Error #%i returned.", theErr], @"Oh?", NULL, NULL);

	// Display error alert, and stop or continue based on user's desires
	UInt32	theMessageValue = [messageNumber longValue];
	theMessageStr = [NSString stringWithFormat:@"Sync embedded command was discovered containing message %ld ('%4s').", (long) theMessageValue, (char*) &theMessageValue];
	alertButtonClicked = NSRunAlertPanel(@"Sync Callback", theMessageStr, @"Stop", NULL, @"Continue");
	if (alertButtonClicked == 1)
		[self startStopButtonPressed:fStartStopButton];
	else
	{
		theErr = ContinueSpeech(fCurSpeechChannel);
		if (theErr != noErr)
			NSRunAlertPanel(@"ContinueSpeech", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
	}

}

/*----------------------------------------------------------------------------------------
speechIsDone

Updates user interface and optionally displays an alert when generation of speech is
finish.
----------------------------------------------------------------------------------------*/
- (void)speechIsDone
{
	fCurrentlySpeaking = NO;
	[self updateSpeakingControlState];
	[self enableCallbackControlsBasedOnSavingToFileFlag:NO];

	if ([self shouldDisplaySpeechDoneCallbacks])
		NSRunAlertPanel(@"Speech Done", @"Generation of synthesized speech is finished.", @"OK", NULL, NULL);
}

/*----------------------------------------------------------------------------------------
displayTextDoneAlert

Displays an alert in response to a text done callback.
----------------------------------------------------------------------------------------*/
- (void)displayTextDoneAlert
{
	OSErr theErr = noErr;
	unsigned long alertButtonClicked;

	// Tell engine to pause while we display this dialog.
	theErr = PauseSpeechAt(fCurSpeechChannel, kImmediate);
	if (theErr != noErr)
		NSRunAlertPanel(@"PauseSpeechAt", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);

	// Display error alert, and stop or continue based on user's desires
	alertButtonClicked = NSRunAlertPanel(@"Text Done Callback", @"Processing of the text has completed.", @"Stop", NULL, @"Continue");
	if (alertButtonClicked == 1)
		[self startStopButtonPressed:fStartStopButton];
	else
	{
		theErr = ContinueSpeech(fCurSpeechChannel);
		if (theErr != noErr)
			NSRunAlertPanel(@"ContinueSpeech", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
	}
}


/*----------------------------------------------------------------------------------------
startStopButtonPressed:

An action method called when the user clicks the "Start Speaking"/"Stop Speaking"
button.	 We either start or stop speaking based on the current speaking state.
----------------------------------------------------------------------------------------*/
- (IBAction)startStopButtonPressed:(id)sender
{
	OSErr theErr = noErr;

	if (fCurrentlySpeaking)
    {
		long whereToStop;

		// Grab where to stop at value from radio buttons
		if ([fAfterWordRadioButton intValue])
			whereToStop = kEndOfWord;
		else if ([fAfterSentenceRadioButton intValue])
			whereToStop = kEndOfSentence;
		else
			whereToStop = kImmediate;

		if (whereToStop == kImmediate)
        {
			// NOTE:	We could just call StopSpeechAt with kImmediate, but for test purposes
			//			we exercise the StopSpeech routine.
			theErr = StopSpeech(fCurSpeechChannel);
			if (theErr != noErr)
				NSRunAlertPanel(@"StopSpeech", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
		}
		else
        {
			theErr = StopSpeechAt(fCurSpeechChannel, whereToStop);
			if (theErr != noErr)
				NSRunAlertPanel(@"StopSpeechAt", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
		}

		fCurrentlySpeaking = NO;
		[self updateSpeakingControlState];
	}
	else
    {
		[self startSpeakingTextViewToURL:NULL];
	}
}

/*----------------------------------------------------------------------------------------
saveAsButtonPressed:

An action method called when the user clicks the "Save As File" button.	 We ask user
to specify where to save the file, then start speaking to this file.
----------------------------------------------------------------------------------------*/
- (IBAction)saveAsButtonPressed:(id)sender
{
	NSURL *selectedFileURL = NULL;

	NSSavePanel *theSavePanel = [NSSavePanel savePanel];
	[theSavePanel setPrompt:NSLocalizedString(@"Save", @"Save")];
    [theSavePanel setNameFieldStringValue:@"Synthesized Speech.aiff"];

	if (NSFileHandlingPanelOKButton == [theSavePanel runModal])
    {
		selectedFileURL = [theSavePanel URL];
		[self startSpeakingTextViewToURL:selectedFileURL];
	}
}

/*----------------------------------------------------------------------------------------
startSpeakingTextViewToURL:

This method sets up the speech channel and begins the speech synthesis
process, optionally speaking to a file instead playing through the speakers.
----------------------------------------------------------------------------------------*/
- (void)startSpeakingTextViewToURL:(NSURL *)url
{
	OSErr theErr = noErr;
	NSString *theViewText;

	// Grab the selection substring, or if no selection then grab entire text.
	fOrgSelectionRange = [fSpokenTextView selectedRange];

	if (fOrgSelectionRange.length == 0)
    {
		theViewText = [fSpokenTextView string];
		fOffsetToSpokenText = 0;
	}
	else
    {
		theViewText = [[fSpokenTextView string] substringWithRange:fOrgSelectionRange];
		fOffsetToSpokenText = fOrgSelectionRange.location;
	}

	// Setup our callbacks
	fSavingToFile =	(url != NULL);
	if (theErr == noErr)
    {
		theErr = SetSpeechInfo(fCurSpeechChannel, soErrorCallBack, fSavingToFile?NULL:OurErrorCallBackProc);
		if (theErr != noErr)
			NSRunAlertPanel(@"SetSpeechInfo(soErrorCallBack)", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
	}
	if (theErr == noErr)
    {
		theErr = SetSpeechInfo(fCurSpeechChannel, soPhonemeCallBack, fSavingToFile?NULL:OurPhonemeCallBackProc);
		if (theErr != noErr)
			NSRunAlertPanel(@"SetSpeechInfo(soPhonemeCallBack)", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
	}
	if (theErr == noErr)
    {
		theErr = SetSpeechInfo(fCurSpeechChannel, soSpeechDoneCallBack, OurSpeechDoneCallBackProc);
		if (theErr != noErr)
			NSRunAlertPanel(@"SetSpeechInfo(soSpeechDoneCallBack)", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
	}
	if (theErr == noErr)
    {
		theErr = SetSpeechInfo(fCurSpeechChannel, soSyncCallBack, fSavingToFile?NULL:OurSyncCallBackProc);
		if (theErr != noErr)
			NSRunAlertPanel(@"SetSpeechInfo(soSyncCallBack)", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
	}

	if (theErr == noErr)
    {
		theErr = SetSpeechInfo(fCurSpeechChannel, soTextDoneCallBack, fSavingToFile?NULL:OurTextDoneCallBackProc);
		if (theErr != noErr)
			NSRunAlertPanel(@"SetSpeechInfo(soTextDoneCallBack)", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
	}
	if (theErr == noErr)
    {
		theErr = SetSpeechInfo(fCurSpeechChannel, soWordCallBack, fSavingToFile?NULL:OurWordCallBackProc);
		if (theErr != noErr)
			NSRunAlertPanel(@"SetSpeechInfo(soWordCallBack)", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
	}

	// Set URL to save file to disk
	SetSpeechInfo(fCurSpeechChannel, soOutputToFileWithCFURL, (__bridge const void *)(url));

	// Convert NSString to cString.
	char *theTextToSpeak = (char *)[theViewText UTF8String];
	if (theTextToSpeak)
    {
		// We want the text view the active view.  Also saves any parameters currently being edited.
		[fWindow makeFirstResponder:fSpokenTextView];

		theErr = SpeakText(fCurSpeechChannel, theTextToSpeak, strlen(theTextToSpeak));
		if (theErr == noErr)
        {
			// Update our vars
			fLastErrorCode = 0;
			fLastSpeakingValue = NO;
			fLastPausedValue = NO;
			fCurrentlySpeaking = YES;
			fCurrentlyPaused = NO;
			[self updateSpeakingControlState];
		}
		else
        {
			NSRunAlertPanel(@"SpeakText", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
		}
	}

	[self enableCallbackControlsBasedOnSavingToFileFlag:fSavingToFile];
}

/*----------------------------------------------------------------------------------------
pauseContinueButtonPressed:

An action method called when the user clicks the "Pause Speaking"/"Continue Speaking"
button.	 We either pause or continue speaking based on the current speaking state.
----------------------------------------------------------------------------------------*/
- (IBAction)pauseContinueButtonPressed:(id)sender
{
	OSErr theErr = noErr;

	if (fCurrentlyPaused)
    {
		// We want the text view the active view.  Also saves any parameters currently being edited.
		[fWindow makeFirstResponder:fSpokenTextView];

		theErr = ContinueSpeech(fCurSpeechChannel);
		if (theErr != noErr)
			NSRunAlertPanel(@"ContinueSpeech", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);

		fCurrentlyPaused = NO;
		[self updateSpeakingControlState];
	}
	else
    {
		long whereToPause;

		// Figure out where to stop from radio buttons
		if ([fAfterWordRadioButton intValue])
			whereToPause = kEndOfWord;
		else if ([fAfterSentenceRadioButton intValue])
			whereToPause = kEndOfSentence;
		else
			whereToPause = kImmediate;

		theErr = PauseSpeechAt(fCurSpeechChannel, whereToPause);
		if (theErr != noErr)
			NSRunAlertPanel(@"PauseSpeechAt", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);

		fCurrentlyPaused = YES;
		[self updateSpeakingControlState];
	}
}

/*----------------------------------------------------------------------------------------
voicePopupSelected:

An action method called when the user selects a new voice from the Voices pop-up
menu.  We ask the speech channel to use the selected voice.	 If the current
speech channel cannot use the selected voice, we close and open new speech
channel with the selecte voice.
----------------------------------------------------------------------------------------*/
- (IBAction) voicePopupSelected:(id)sender
{
	OSErr theErr = noErr;
	VoiceSpec theVoiceSpec;
	long theSelectedMenuIndex = [sender indexOfSelectedItem];

	if (theSelectedMenuIndex == 0)
    {
		// Use the default voice from preferences.
		//
		// Our only choice is to close and reopen the speech channel to get the default voice.
		fSelectedVoiceCreator = 0;
		theErr = [self createNewSpeechChannel:NULL];
		if (theErr != noErr)
			NSRunAlertPanel(@"createNewSpeechChannel", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
	}
	else
    {
		// Use the voice the user selected.
		//
		theErr = GetIndVoice([sender indexOfSelectedItem] - 1, &theVoiceSpec);
		if (theErr != noErr)
			NSRunAlertPanel(@"GetIndVoice", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);

		if (theErr == noErr)
        {
			// Update our object fields with the selection
			fSelectedVoiceCreator	= theVoiceSpec.creator;
			fSelectedVoiceID		= theVoiceSpec.id;

			// Change the current voice.  If it needs another engine, then dispose the current channel and open another
			if (SetSpeechInfo(fCurSpeechChannel, soCurrentVoice, &theVoiceSpec) == incompatibleVoice)
            {
				theErr = [self createNewSpeechChannel:&theVoiceSpec];
                if (theErr != noErr)
                    NSRunAlertPanel(@"createNewSpeechChannel", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
            }
		}
	}

	// Set editable default fields
	if (fCurSpeechChannel)
		[self fillInEditableParameterFields];
}

/*----------------------------------------------------------------------------------------
charByCharCheckboxSelected:

An action method called when the user checks/unchecks the Character-By-Character
mode checkbox.	We tell the speech channel to use this setting.
----------------------------------------------------------------------------------------*/
- (IBAction)charByCharCheckboxSelected:(id)sender
{
	OSErr theErr = noErr;

	OSType theMode;
	if ([fCharByCharCheckboxButton intValue])
		theMode = modeLiteral;
	else
		theMode = modeNormal;

	theErr = SetSpeechInfo(fCurSpeechChannel, soCharacterMode, &theMode);
	if (theErr != noErr)
		NSRunAlertPanel(@"SetSpeechInfo(soCharacterMode)", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
}

/*----------------------------------------------------------------------------------------
digitByDigitCheckboxSelected:

An action method called when the user checks/unchecks the Digit-By-Digit
mode checkbox.	We tell the speech channel to use this setting.
----------------------------------------------------------------------------------------*/
- (IBAction)digitByDigitCheckboxSelected:(id)sender
{
	OSErr theErr = noErr;

	OSType theMode;
	if ([fDigitByDigitCheckboxButton intValue])
		theMode = modeLiteral;
	else
		theMode = modeNormal;

	theErr = SetSpeechInfo(fCurSpeechChannel, soNumberMode, &theMode);
	if (theErr != noErr)
		NSRunAlertPanel(@"SetSpeechInfo(soNumberMode)", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
}

/*----------------------------------------------------------------------------------------
digitByDigitCheckboxSelected:

An action method called when the user checks/unchecks the Phoneme input
mode checkbox.	We tell the speech channel to use this setting.
----------------------------------------------------------------------------------------*/
- (IBAction)phonemeModeCheckboxSelected:(id)sender
{
	OSErr theErr = noErr;

	OSType theMode;
	if ([fPhonemeModeCheckboxButton intValue])
		theMode = modePhonemes;
	else
		theMode = modeText;

	theErr = SetSpeechInfo(fCurSpeechChannel, soInputMode, &theMode);
	if (theErr != noErr)
		NSRunAlertPanel(@"SetSpeechInfo(soInputMode)", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
}

/*----------------------------------------------------------------------------------------
dumpPhonemesSelected:

An action method called when the user clicks the Dump Phonemes button.	We ask
the speech channel for a phoneme representation of the window text then save the
result to a text file at a location determined by the user.
----------------------------------------------------------------------------------------*/
- (IBAction)dumpPhonemesSelected:(id)sender
{
	NSSavePanel *panel = [NSSavePanel savePanel];

	if ([panel runModal])
    {
		long theNumOfPhonBytes	= 0;

		// Get and speech text
		char *	theTextToSpeak = (char *)[[fSpokenTextView string] UTF8String];
		if (theTextToSpeak)
        {
			Handle thePhonemeHandle = NewHandle(0);
			if (thePhonemeHandle)
            {
				OSErr theErr = TextToPhonemes(fCurSpeechChannel, (Ptr)theTextToSpeak, (long)strlen(theTextToSpeak), thePhonemeHandle, (long *)&theNumOfPhonBytes);
				if (theErr != noErr)
					NSRunAlertPanel(@"TextToPhonemes", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
				else
                {
					// Create NSData object with resulting handle and then write to disk.
					NSData *	thePhonemeText = [NSData dataWithBytesNoCopy:*thePhonemeHandle length:theNumOfPhonBytes freeWhenDone:NO];
					if(! [thePhonemeText writeToURL:[panel URL] atomically:NO])
						NSRunAlertPanel(@"TextToPhonemes", @"Phoneme file could not be written to disk", @"Oh?", NULL, NULL);
				}

				DisposeHandle(thePhonemeHandle);
			}
			else
				NSRunAlertPanel(@"TextToPhonemes", @"Could not allocate handle for phonemes", @"Oh?", NULL, NULL);
		}
	}

}

/*----------------------------------------------------------------------------------------
useDictionarySelected:

An action method called when the user clicks the Use Dictionary button.
----------------------------------------------------------------------------------------*/
- (IBAction)useDictionarySelected:(id)sender
{
	// Open file.
	NSOpenPanel *panel = [NSOpenPanel openPanel];

	[panel setAllowsMultipleSelection:YES];
	if ([panel runModal])
    {
		NSEnumerator *fileURLsEnumerator = [[panel URLs]objectEnumerator];
		NSURL *fileURL = NULL;
		while (fileURL = [fileURLsEnumerator nextObject])
        {
			// Read dictionary file into NSData object.
			NSData *speechSynthesisDictionaryData = [NSData dataWithContentsOfURL:fileURL];
			if (speechSynthesisDictionaryData)
            {
				// Allocate handle, then copy the data into the handle and pass it to UseDictionary.
				Handle	theFileDataHandle = NewHandle([speechSynthesisDictionaryData length]);
				if (theFileDataHandle)
                {
					memcpy(*theFileDataHandle, [speechSynthesisDictionaryData bytes], [speechSynthesisDictionaryData length]);

					OSErr theErr = UseDictionary(fCurSpeechChannel, theFileDataHandle);
					DisposeHandle(theFileDataHandle);

					if (theErr != noErr)
						NSRunAlertPanel(@"UseDictionary", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
				}
				else
					NSRunAlertPanel(@"TextToPhonemes", @"Could not allocate handle for dictionary", @"Oh?", NULL, NULL);
			}
			else
				NSRunAlertPanel(@"TextToPhonemes", [NSString stringWithFormat:@"Error occurred reading %@.", [fileURL path]], @"Oh?", NULL, NULL);
		}
	}
}

/*----------------------------------------------------------------------------------------
rateChanged:

An action method called when the user changes the rate field.  We tell the speech
channel to use this setting.
----------------------------------------------------------------------------------------*/
- (IBAction)rateChanged:(id)sender
{
	OSErr theErr = noErr;

	Fixed theNewValue = [fRateDefaultEditableField doubleValue] * 65536.0;
	theErr = SetSpeechInfo(fCurSpeechChannel, soRate, &theNewValue);

	if (theErr != noErr)
		NSRunAlertPanel(@"SetSpeechInfo(soRate)", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
	else
		[fRateCurrentStaticField setDoubleValue:[fRateDefaultEditableField doubleValue]];
}

/*----------------------------------------------------------------------------------------
pitchBaseChanged:

An action method called when the user changes the pitch base field.	 We tell the speech
channel to use this setting.
----------------------------------------------------------------------------------------*/
- (IBAction)pitchBaseChanged:(id)sender
{
	OSErr theErr = noErr;

	Fixed theNewValue = [fPitchBaseDefaultEditableField doubleValue] * 65536.0;
	theErr = SetSpeechPitch(fCurSpeechChannel, theNewValue);

	if (theErr != noErr)
		NSRunAlertPanel(@"SetSpeechPitch", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
	else
		[fPitchBaseCurrentStaticField setDoubleValue:[fPitchBaseDefaultEditableField doubleValue]];
}

/*----------------------------------------------------------------------------------------
pitchModChanged:

An action method called when the user changes the pitch modulation field.  We tell
the speech channel to use this setting.
----------------------------------------------------------------------------------------*/
- (IBAction)pitchModChanged:(id)sender
{
	OSErr theErr = noErr;

	Fixed theNewValue = [fPitchModDefaultEditableField doubleValue] * 65536.0;
	theErr = SetSpeechInfo(fCurSpeechChannel, soPitchMod, &theNewValue);

	if (theErr != noErr)
		NSRunAlertPanel(@"SetSpeechInfo(soPitchMod)", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
	else
		[fPitchModCurrentStaticField setDoubleValue:[fPitchModDefaultEditableField doubleValue]];
}

/*----------------------------------------------------------------------------------------
volumeChanged:

An action method called when the user changes the volume field.	 We tell
the speech channel to use this setting.
----------------------------------------------------------------------------------------*/
- (IBAction)volumeChanged:(id)sender
{
	OSErr theErr = noErr;

	Fixed theNewValue = [fVolumeDefaultEditableField doubleValue] * 65536.0;
	theErr = SetSpeechInfo(fCurSpeechChannel, soVolume, &theNewValue);

	if (theErr != noErr)
		NSRunAlertPanel(@"SetSpeechInfo(soVolume)", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
	else
		[fVolumeCurrentStaticField setDoubleValue:[fVolumeDefaultEditableField doubleValue]];
}

/*----------------------------------------------------------------------------------------
resetSelected:

An action method called when the user clicks the Use Defaults button.  We tell
the speech channel to use this the default settings.
----------------------------------------------------------------------------------------*/
- (IBAction)resetSelected:(id)sender
{
	OSErr theErr = noErr;

	theErr = SetSpeechInfo(fCurSpeechChannel, soReset, NULL);

	[self fillInEditableParameterFields];

	if (theErr != noErr)
		NSRunAlertPanel(@"SetSpeechInfo(soReset)", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
}

- (IBAction)wordCallbacksButtonPressed:(id)sender
{
	if (![fHandleWordCallbacksCheckboxButton intValue])
		[fSpokenTextView setSelectedRange:fOrgSelectionRange];
}

- (IBAction)phonemeCallbacksButtonPressed:(id)sender
{
	if ([fHandlePhonemeCallbacksCheckboxButton intValue])
		[fCharacterView setExpression:kCharacterExpressionIdentifierIdle];
	else
		[fCharacterView setExpression:kCharacterExpressionIdentifierSleep];
}

/*----------------------------------------------------------------------------------------
enableOptionsForSpeakingState:

Updates controls in the Option tab panel based on the passed speakingNow flag.
----------------------------------------------------------------------------------------*/
- (void)enableOptionsForSpeakingState:(BOOL)speakingNow
{
	[fVoicesPopUpButton setEnabled:!speakingNow];
	[fCharByCharCheckboxButton setEnabled:!speakingNow];
	[fDigitByDigitCheckboxButton setEnabled:!speakingNow];
	[fPhonemeModeCheckboxButton setEnabled:!speakingNow];
	[fDumpPhonemesButton setEnabled:!speakingNow];
	[fUseDictionaryButton setEnabled:!speakingNow];
}

/*----------------------------------------------------------------------------------------
enableCallbackControlsForSavingToFile:

Updates controls in the Callback tab panel based on the passed savingToFile flag.
----------------------------------------------------------------------------------------*/
- (void)enableCallbackControlsBasedOnSavingToFileFlag:(BOOL)savingToFile
{
	[fHandleWordCallbacksCheckboxButton setEnabled:!savingToFile];
	[fHandlePhonemeCallbacksCheckboxButton setEnabled:!savingToFile];
	[fHandleSyncCallbacksCheckboxButton setEnabled:!savingToFile];
	[fHandleErrorCallbacksCheckboxButton setEnabled:!savingToFile];
	[fHandleTextDoneCallbacksCheckboxButton setEnabled:!savingToFile];

	if (savingToFile || [fHandlePhonemeCallbacksCheckboxButton intValue] == 0)
		[fCharacterView setExpression:kCharacterExpressionIdentifierSleep];
	else
		[fCharacterView setExpression:kCharacterExpressionIdentifierIdle];
}

/*----------------------------------------------------------------------------------------
fillInEditableParameterFields

Updates "Current" fields in the Parameters tab panel based on the current state of the
speech channel.
----------------------------------------------------------------------------------------*/
- (void)fillInEditableParameterFields
{
	Fixed tempFixedValue = 0;

	GetSpeechInfo(fCurSpeechChannel, soRate, &tempFixedValue);
	[fRateDefaultEditableField setDoubleValue:(tempFixedValue / 65536.0)];
	[fRateCurrentStaticField setDoubleValue:(tempFixedValue / 65536.0)];

	GetSpeechPitch(fCurSpeechChannel, &tempFixedValue);
	[fPitchBaseDefaultEditableField setDoubleValue:(tempFixedValue / 65536.0)];
	[fPitchBaseCurrentStaticField setDoubleValue:(tempFixedValue / 65536.0)];

	GetSpeechInfo(fCurSpeechChannel, soPitchMod, &tempFixedValue);
	[fPitchModDefaultEditableField setDoubleValue:(tempFixedValue / 65536.0)];
	[fPitchModCurrentStaticField setDoubleValue:(tempFixedValue / 65536.0)];

	GetSpeechInfo(fCurSpeechChannel, soVolume, &tempFixedValue);
	[fVolumeDefaultEditableField setDoubleValue:(tempFixedValue / 65536.0)];
	[fVolumeCurrentStaticField setDoubleValue:(tempFixedValue / 65536.0)];
}

/*----------------------------------------------------------------------------------------
createNewSpeechChannel:

Create a new speech channel for the given voice spec.  A nil voice spec pointer
causes the speech channel to use the default voice.	 Any existing speech channel
for this window is closed first.
----------------------------------------------------------------------------------------*/
- (OSErr)createNewSpeechChannel:(VoiceSpec *)voiceSpec
{
	OSErr theErr = noErr;

	// Dispose of the current one, if present.
	if (fCurSpeechChannel)
    {
		theErr = DisposeSpeechChannel(fCurSpeechChannel);
		if (theErr != noErr)
			NSRunAlertPanel(@"DisposeSpeechChannel", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);

		fCurSpeechChannel = NULL;
	}

	// Create a speech channel
	if (theErr == noErr)
    {
		theErr = NewSpeechChannel(voiceSpec, &fCurSpeechChannel);
		if (theErr != noErr)
			NSRunAlertPanel(@"NewSpeechChannel", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
	}

	// Setup our refcon to the document controller object so we have access within our Speech callbacks
	if (theErr == noErr)
    {
		theErr = SetSpeechInfo(fCurSpeechChannel, soRefCon, (__bridge const void *)(self));
		if (theErr != noErr)
			NSRunAlertPanel(@"SetSpeechInfo(soRefCon)", [NSString stringWithFormat:@"Error #%d returned.", theErr], @"Oh?", NULL, NULL);
	}

	return theErr;
}

/*----------------------------------------------------------------------------------------
windowNibName

Part of the NSDocument support.	 Called by NSDocument to return the nib file name of
the document.
----------------------------------------------------------------------------------------*/
- (NSString *)windowNibName
{
	return @"SpeakingTextWindow";
}

/*----------------------------------------------------------------------------------------
windowControllerDidLoadNib:

Part of the NSDocument support.	 Called by NSDocument after the nib has been loaded
to udpate window as appropriate.
----------------------------------------------------------------------------------------*/
- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];

	// Update the window text from data
	if ([[self textDataType] isEqualToString:@"RTF Document"])
		[fSpokenTextView replaceCharactersInRange:NSMakeRange(0,[[fSpokenTextView string] length]) withRTF:[self textData]];
	else
		[fSpokenTextView replaceCharactersInRange:NSMakeRange(0,[[fSpokenTextView string] length]) withString:[NSString stringWithUTF8String:[[self textData] bytes]]];
}

/*----------------------------------------------------------------------------------------
dataRepresentationOfType:

Part of the NSDocument support.	 Called by NSDocument to read data from file.
----------------------------------------------------------------------------------------*/
- (NSData *)dataRepresentationOfType:(NSString *)aType
{
	// Write text to file.
	if ([aType isEqualToString:@"RTF Document"])
		[self setTextData:[fSpokenTextView RTFFromRange:NSMakeRange(0,[[fSpokenTextView string] length])]];
	else
		[self setTextData:[NSData dataWithBytes:[[fSpokenTextView string] cString] length:[[fSpokenTextView string] cStringLength]]];

	return [self textData];
}

/*----------------------------------------------------------------------------------------
loadDataRepresentation: ofType:

Part of the NSDocument support.	 Called by NSDocument to write data to file.
----------------------------------------------------------------------------------------*/
- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
	// Read the opened file.
	[self setTextData:data];
	[self setTextDataType:aType];

	return YES;
}

@end

#pragma mark - Callback routines

//
// AN IMPORTANT NOTE ABOUT CALLBACKS AND THREADS
//
// All speech synthesis callbacks, except for the Text Done callback, call their specified routine on a
// thread other than the main thread.  Performing certain actions directly from a speech synthesis callback
// routine may cause your program to crash without certain safe gaurds.	 In this example, we use the NSThread
// method performSelectorOnMainThread:withObject:waitUntilDone: to safely update the user interface and
// interact with our objects using only the main thread.
//
// Depending on your needs you may be able to specify your Cocoa application is multiple threaded
// then preform actions directly from the speech synthesis callback routines.  To indicate your Cocoa
// application is mulitthreaded, call the following line before calling speech synthesis routines for
// the first time:
//
//	  [NSThread detachNewThreadSelector:@selector(self) toTarget:self withObject:nil];
//


/*----------------------------------------------------------------------------------------
OurErrorCallBackProc

Called by speech channel when an error occurs during processing of text to speak.
----------------------------------------------------------------------------------------*/
pascal void OurErrorCallBackProc(SpeechChannel inSpeechChannel, SRefCon inRefCon, OSErr inError, long inBytePos)
{
	@autoreleasepool {
        SpeakingTextWindow *stw = (__bridge SpeakingTextWindow *)inRefCon;

	if ([stw shouldDisplayTextDoneCallbacks])
		[stw performSelectorOnMainThread:@selector(displayErrorAlertWithParams:)
                              withObject:@{kErrorCallbackParamPosition: @(inBytePos), kErrorCallbackParamError:[NSNumber numberWithLong:inError]}
                           waitUntilDone:NO];

	}
}

/*----------------------------------------------------------------------------------------
OurTextDoneCallBackProc

Called by speech channel when all text has been processed.	Additional text can be
passed back to continue processing.
----------------------------------------------------------------------------------------*/
pascal void OurTextDoneCallBackProc(SpeechChannel inSpeechChannel, SRefCon inRefCon, const void **nextBuf, unsigned long *byteLen, long *controlFlags)
{
	@autoreleasepool {
        SpeakingTextWindow *stw = (__bridge SpeakingTextWindow *)inRefCon;

	*nextBuf = NULL;

	if ([stw shouldDisplayTextDoneCallbacks])
		[stw performSelectorOnMainThread:@selector(displayTextDoneAlert)
                              withObject:NULL
                           waitUntilDone:NO];

	}
}

/*----------------------------------------------------------------------------------------
OurSpeechDoneCallBackProc

Called by speech channel when all speech has been generated.
----------------------------------------------------------------------------------------*/
pascal void OurSpeechDoneCallBackProc(SpeechChannel inSpeechChannel, SRefCon inRefCon)
{
	@autoreleasepool {
        SpeakingTextWindow *stw = (__bridge SpeakingTextWindow *)inRefCon;

	[stw performSelectorOnMainThread:@selector(speechIsDone)
                          withObject:NULL
                       waitUntilDone:NO];
	}
}

/*----------------------------------------------------------------------------------------
OurSyncCallBackProc

Called by speech channel when it encouters a synchronization command within an
embedded speech comand in text being processed.
----------------------------------------------------------------------------------------*/
pascal void OurSyncCallBackProc(SpeechChannel inSpeechChannel, SRefCon inRefCon, OSType inSyncMessage)
{
	@autoreleasepool {
        SpeakingTextWindow *stw = (__bridge SpeakingTextWindow *)inRefCon;

	if ([stw shouldDisplaySyncCallbacks])
		[stw performSelectorOnMainThread:@selector(displaySyncAlertWithMessage:)
                              withObject:[NSNumber numberWithLong:inSyncMessage]
                           waitUntilDone:NO];

	}
}

/*----------------------------------------------------------------------------------------
OurPhonemeCallBackProc

Called by speech channel every time a phoneme is about to be generated.	 You might use
this to animate a speaking character.
----------------------------------------------------------------------------------------*/
pascal void OurPhonemeCallBackProc(SpeechChannel inSpeechChannel, SRefCon inRefCon, short inPhonemeOpcode)
{
	@autoreleasepool {
        SpeakingTextWindow *stw = (__bridge SpeakingTextWindow *)inRefCon;

	if ([stw shouldDisplayPhonemeCallbacks])
		[[stw characterView] performSelectorOnMainThread:@selector(setExpressionForPhoneme:)
                                              withObject:@(inPhonemeOpcode)
                                           waitUntilDone:NO];

	}
}

/*----------------------------------------------------------------------------------------
OurWordCallBackProc

Called by speech channel every time a word is about to be generated.  This program
uses this callback to highlight the currently spoken word.
----------------------------------------------------------------------------------------*/
pascal void OurWordCallBackProc(SpeechChannel inSpeechChannel, SRefCon inRefCon, long inWordPos, short inWordLen)
{
	@autoreleasepool {
        SpeakingTextWindow *stw = (__bridge SpeakingTextWindow *)inRefCon;

	if ([stw shouldDisplayWordCallbacks])
		[stw performSelectorOnMainThread:@selector(highlightWordWithParams:)
                              withObject:@{kWordCallbackParamPosition: @(inWordPos), kWordCallbackParamLength: [NSNumber numberWithLong:inWordLen]}
                           waitUntilDone:NO];
	}
}

