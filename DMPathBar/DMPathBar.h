//
//  DMPathBar.h
//  XCode style PathBar for Yosemite
//
//  Created by Daniele Margutti (me@danielemargutti.com) on 14/01/15.
//  Copyright (c) 2015 http://www.danielemargutti.com All rights reserved.
//	Distribuited under MIT License http://opensource.org/licenses/MIT
//

#import <Cocoa/Cocoa.h>

#import "DMPathBarItem.h"
#import "DMPathBarProgressIndicator.h"

typedef NS_ENUM(NSInteger, DMPathBarAccessoryPos) {
	DMPathBarAccessoryPosLeft,		// Accessory view located on the left side of the bar
	DMPathBarAccessoryPosRight		// Accessory view located on the right side of the bar
};

typedef NSMenu*(^DMPathBarAction)(NSInteger index,DMPathBarItem *item);

IB_DESIGNABLE
@interface DMPathBar : NSView

// Appaerance of the path bar
@property (nonatomic,retain)	NSColor					*backActiveColor;		// Default is white
@property (nonatomic,retain)	NSColor					*backSelectedColor;		// Default is a light gray
@property (nonatomic,retain)	NSColor					*backInactiveColor;		// Default is a light gray
@property (nonatomic,retain)	NSColor					*backShadowColor;		// Default is a dark gray
@property (nonatomic,assign)	NSEdgeInsets			 contentInsets;			// Default is (1,1,1,1)
@property (nonatomic,assign)	CGFloat					 cornerRadius;			// Default is 4.0f
@property (nonatomic,retain)	NSImage					*arrowIcon;				// Default is 'arrow'

@property (nonatomic,readonly)	NSRect					 contentRect;			// Content rect area (does not include accessoryView rect, if any)
@property (nonatomic,readonly)	NSRect					 accessoryViewRect;		// Accessory view rect (if any)

@property (nonatomic,readonly)	NSArray					*items;					// Items of the bar
@property (nonatomic,readonly)	NSView					*accessoryView;			// Accessory view (if set)
@property (nonatomic,assign)	DMPathBarAccessoryPos	 accessoryPosition;		// Accessory view position (default is right, if any accessoryView)
@property (nonatomic,assign)	BOOL					 isWindowActive;		// ## You should not touch this! ##

@property (nonatomic,copy)		DMPathBarAction			 action;
@property (nonatomic,assign)	BOOL					 enabled;				// YES to make the control interactive, NO to disable all

// Progress Bar Support
@property (nonatomic,retain)	NSColor					*progressColor;
@property (nonatomic,readonly)	DMPathBarProgressIndicator	*progressBar;

// Set the title item of the navigation bar. Title is a normal DMPathBarItem object with a bold style
- (void) setTitleItem:(DMPathBarItem *) aItem animated:(BOOL) aAnimated completion:(void (^)(void)) aCompletion;

// Set an array of items to the path bar (if aSerialAddAnimation = YES animation is serial and each item is added until the last item, then return completion block if specified)
- (void) setItems:(NSArray *)items animated:(BOOL) aAnimated inSequence:(BOOL) aSerialAddAnimation completion:(void (^)(void)) aCompletion;
- (void) setItems:(NSArray *)items animated:(BOOL) aAnimated completion:(void (^)(void)) aCompletion;

// Add a new item path to the path bar
- (void) addItem:(DMPathBarItem *) aItem animated:(BOOL) aAnimated completion:(void (^)(void)) aCompletion;
// Remove last added item of the path bar
- (void) removeItemAnimated:(BOOL) aAnimated completion:(void (^)(void)) aCompletion;

// Remove all items of the path bar
- (void) removeAllItemsAnimated:(BOOL) aAnimated completion:(void (^)(void)) aCompletion;
- (void) removeAllItemsAnimated:(BOOL) aAnimated inSequence:(BOOL) aSerialRemoveAnimation completion:(void (^)(void)) aCompletion;

// Replace an existing item of the path bar with another one
- (void) replaceItemAtIndex:(NSInteger) aIdx with:(DMPathBarItem *) aItem animated:(BOOL) aAnimated completion:(void(^)(void)) aCompletion;

// Set an accessory NSView to the path bar
- (void) setAccessoryView:(NSView *)accessoryView animated:(BOOL) aAnimated completion:(void (^)(void)) aCompletion;


@end

extern NSRect NSRectInsetWithEdgeInsets(NSRect rect, NSEdgeInsets insets);
