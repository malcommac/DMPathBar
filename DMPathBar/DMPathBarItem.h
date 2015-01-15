//
//  DMPathBarItem.h
//  XCode style PathBar for Yosemite
//
//  Created by Daniele Margutti (me@danielemargutti.com) on 14/01/15.
//  Copyright (c) 2015 http://www.danielemargutti.com All rights reserved.
//	Distribuited under MIT License http://opensource.org/licenses/MIT
//

#import <Cocoa/Cocoa.h>

@class DMPathBar;

IB_DESIGNABLE
@interface DMPathBarItem : NSView

@property (nonatomic,readonly)	NSString		*title;							// The title of the item
@property (nonatomic,readonly)	NSImage			*icon;							// The icon of the item
@property (nonatomic,readonly)	NSView			*customView;					// If initialized a path bar item can contain a custom view too
@property (nonatomic,assign)	BOOL			 enabled;						// NO to disable item (click on this item does not produce any action)

// Valid only for title/icon path bar items
@property (nonatomic,retain)	NSDictionary	*activeTitleAttributes;			// Text attributes for active state
@property (nonatomic,retain)	NSDictionary	*inactiveTitleAttributes;		// Text attributes for inactive state
@property (nonatomic,retain)	NSDictionary	*boldActiveTitleAttributes;		// Text attributes for active state of the path bar title
@property (nonatomic,retain)	NSDictionary	*boldInactiveTitleAttributes;	// Text attributes for inactive state of the path bar title

@property (nonatomic,weak)		DMPathBar		*pathBar;						// Refernece to the parent pathbar (you should not touch it)
@property (nonatomic,readonly)	BOOL			 isCompressed;					// YES if pathbar is compressed (you should not touch it)
@property (nonatomic,readonly)	NSSize			 bestContentSize;				// Best size which can contains the path bar item elements

// Create a new item with custom title and icon
+ (instancetype) itemWithTitle:(NSString *) aTitle icon:(NSImage *) aIcon;

// Create a new item with a custom view
+ (instancetype) itemWithCustomView:(NSView *) aCustomView;

// Helper Methods
- (NSSize) bestContentSizeWithMax:(NSSize) maxSize;
- (void) setCompressed:(BOOL) aCompressed animated:(BOOL) aAnimated;
- (void) layoutSubviews;

@end