//
//  AppDelegate.m
//  DMPathBar
//
//  Created by daniele on 14/01/15.
//  Copyright (c) 2015 danielemargutti. All rights reserved.
//

#import "AppDelegate.h"

#import "DMPathBar.h"

@interface AppDelegate () {
	IBOutlet	DMPathBar		*pathBar;
	IBOutlet	NSView			*accessoryView;
	IBOutlet	NSButton		*buttonUseAnimations;
	IBOutlet	NSTextField		*fldNewItemTitle;
	IBOutlet	NSButton		*buttonNewItemUseIcon;
	IBOutlet	NSButton		*buttonAnimationInSequence;
}

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic,readonly)	BOOL useAnimations;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	[pathBar setTitleItem:[DMPathBarItem itemWithTitle:@"Macintosh HD" icon:[NSImage imageNamed:@"icon"]] animated:NO completion:NULL];
	
	pathBar.action = ^NSMenu *(NSInteger idx,DMPathBarItem *item) {
		NSLog(@"Tap on item %ld : %@",idx,item);
		NSMenu *menu = [[NSMenu alloc] initWithTitle:@"ciao"];
		[menu addItemWithTitle:@"Menu Item 1" action:@selector(testMenuItem:) keyEquivalent:@""];
		[menu addItemWithTitle:@"Menu Item 2" action:@selector(testMenuItem:) keyEquivalent:@""];
		[menu addItemWithTitle:@"Menu Item 3" action:@selector(testMenuItem:) keyEquivalent:@""];
		return menu;
	};
}

- (void) testMenuItem:(id) sender {
	NSLog(@"%@",sender);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (IBAction) buttonSetItems:(id)sender {
	NSUInteger itemsCount = 7;
	NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:itemsCount];
	for (NSUInteger idx = 0; idx < itemsCount; ++idx) {
		DMPathBarItem *item = [DMPathBarItem itemWithTitle:[NSString stringWithFormat:@"Item %ld",idx] icon:nil];
		[list addObject:item];
	}
	BOOL inSequence = (buttonAnimationInSequence.state == NSOnState);
	[pathBar setItems:list animated:YES inSequence:inSequence completion:^{
		NSLog(@"Added new items:\n %@",list);
	}];
}

- (BOOL)useAnimations {
	return (buttonUseAnimations.state == NSOnState);
}

- (IBAction) buttonToggleEnabled:(id)sender {
	pathBar.enabled = !pathBar.enabled;
}

- (IBAction) buttonAddItem:(id)sender {
	NSImage *icon = (buttonNewItemUseIcon.state == NSOnState ? [NSImage imageNamed:@"icon"] : nil);
	NSString *title = fldNewItemTitle.stringValue;
	
	if (title.length > 0) {
		DMPathBarItem *item = [DMPathBarItem itemWithTitle: title icon: icon];
		[pathBar addItem:item animated: self.useAnimations completion:^{
			NSLog(@"Added new item %@",item);
		}];
	} else
		NSBeep();
}

- (IBAction)buttonSetItemTitle:(id)sender {
	__weak __typeof__(pathBar) weakPathBar = pathBar;
	[pathBar setTitleItem:[DMPathBarItem itemWithTitle:@"New Title" icon:nil] animated:YES completion:^{
		NSLog(@"Changed path bar item: %@",weakPathBar.items.firstObject);
	}];
}

- (IBAction)buttonRemoveAllItems:(id)sender {
[pathBar removeAllItemsAnimated:YES completion:^{
	
}];
}

- (IBAction)buttonSetAccessoryView:(id)sender {
[pathBar setAccessoryView:accessoryView animated:NO completion:^{
	
}];
}

- (IBAction)buttonRemoveItem:(id)sender {
	[pathBar removeItemAnimated:YES completion:^{
		
	}];
}

@end
