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

@property (nonatomic,readonly)	NSString		*title;
@property (nonatomic,readonly)	NSImage			*icon;
@property (nonatomic,readonly)	NSView			*customView;

@property (nonatomic,retain)	NSDictionary	*activeTitleAttributes;
@property (nonatomic,retain)	NSDictionary	*inactiveTitleAttributes;
@property (nonatomic,retain)	NSDictionary	*boldActiveTitleAttributes;
@property (nonatomic,retain)	NSDictionary	*boldInactiveTitleAttributes;

@property (nonatomic,weak)		DMPathBar		*pathBar;
@property (nonatomic,readonly)	BOOL			 isCompressed;
@property (nonatomic,readonly)	NSSize			 bestContentSize;

// Create a new item with custom title and icon
+ (instancetype) itemWithTitle:(NSString *) aTitle icon:(NSImage *) aIcon;

// Create a new item with a custom view
+ (instancetype) itemWithCustomView:(NSView *) aCustomView;

// Helper Methods
- (NSSize) bestContentSizeWithMax:(NSSize) maxSize;
- (void) setCompressed:(BOOL) aCompressed animated:(BOOL) aAnimated;
- (void) layoutSubviews;

@end