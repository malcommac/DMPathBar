//
//  DMPathBar.m
//  XCode style PathBar for Yosemite
//
//  Created by Daniele Margutti (me@danielemargutti.com) on 14/01/15.
//  Copyright (c) 2015 http://www.danielemargutti.com All rights reserved.
//	Distribuited under MIT License http://opensource.org/licenses/MIT
//

#import "DMPathBar.h"

#define kDMPathBarArrowExtraWidth		8.0f

@interface DMPathBar () {
	NSMutableArray		*itemsArray;
	NSMutableArray		*pathArrows;
	NSTrackingArea		*expandTrackingArea;
	NSInteger			 currentExpandedItemIdx;
	BOOL				 isMouseDown;
}

@property (nonatomic,readonly)	NSSize		arrowSize;

@end

@implementation DMPathBar

#pragma mark - Init -

- (instancetype)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void) commonInit {
	self.wantsLayer = YES;
	self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;

	_enabled = YES;
	itemsArray = [NSMutableArray array];
	pathArrows = [NSMutableArray array];
	_accessoryView = nil;
	_accessoryPosition = DMPathBarAccessoryPosRight;
	
	currentExpandedItemIdx = NSNotFound;
	_isWindowActive = YES;
	_backActiveColor = [NSColor whiteColor];
	_backInactiveColor = [NSColor colorWithCalibratedWhite:0.965 alpha:1.000];
	_backShadowColor = [NSColor colorWithCalibratedWhite:0.590 alpha:0.2];
	_backSelectedColor = [NSColor colorWithCalibratedWhite:0.920 alpha:1.000];
	_cornerRadius = 4.0f;
	_contentInsets = NSEdgeInsetsMake(5, _cornerRadius, 5, _cornerRadius);
	_arrowIcon = [NSImage imageNamed:@"arrow"];
}

#pragma mark - Overrides

- (void)updateTrackingAreas {
	[super updateTrackingAreas];
	[self removeTrackingArea:expandTrackingArea];
	
	NSTrackingAreaOptions trackOptions = NSTrackingMouseMoved | NSTrackingInVisibleRect | NSTrackingActiveInKeyWindow | NSTrackingMouseEnteredAndExited;
	expandTrackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:trackOptions owner:self userInfo:nil];
	[self addTrackingArea:expandTrackingArea];
}

- (BOOL)isFlipped {
	return YES;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeMainNotification object:self.window];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignMainNotification object:self.window];
}

- (void)viewDidMoveToWindow {
	[[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidBecomeMainNotification
													  object:self.window queue:nil usingBlock:^(NSNotification *note) {
		_isWindowActive = YES;
		[self setNeedsDisplay:YES];
	}];
	
	[[NSNotificationCenter defaultCenter] addObserverForName:NSWindowDidResignMainNotification
													  object:self.window queue:nil usingBlock:^(NSNotification *note) {
		_isWindowActive = NO;
		[self setNeedsDisplay:YES];
	}];
}

- (void) setNeedsDisplay:(BOOL)needsDisplay {
	[super setNeedsDisplay:needsDisplay];
	for (DMPathBarItem *item in itemsArray)
		[item setNeedsDisplay:needsDisplay];
	for (NSImageView *pathArrow in pathArrows)
		pathArrow.alphaValue = (_isWindowActive && _enabled ? 1.0f : 0.5f);
}

#pragma mark - Properties -

- (NSArray *)items {
	return [itemsArray copy];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
	_cornerRadius = cornerRadius;
	[self setNeedsDisplay:YES];
}

- (void)setBackShadowColor:(NSColor *)backShadowColor {
	_backShadowColor = backShadowColor;
	[self setNeedsDisplay:YES];
}

- (void)setBackActiveColor:(NSColor *)backActiveColor {
	_backActiveColor = backActiveColor;
	[self setNeedsDisplay:YES];
}

- (void)setBackInactiveColor:(NSColor *)backInactiveColor {
	_backInactiveColor = backInactiveColor;
	[self setNeedsDisplay:YES];
}

#pragma mark - Public Methods -

- (void)setEnabled:(BOOL)enabled {
	_enabled = enabled;
	[self setNeedsDisplay:YES];
}

- (DMPathBarItem *) itemAtPoint:(NSPoint) aPoint {
	for (DMPathBarItem *item in itemsArray)
		if (CGRectContainsPoint(item.frame, aPoint))
			return item;
	
	NSUInteger idx = 0;
	for (NSImageView *arrowImage in pathArrows) {
		if (CGRectContainsPoint(arrowImage.frame, aPoint))
			return itemsArray[idx+1];
		++idx;
	}
	return nil;
}

- (void) setItems:(NSArray *)items animated:(BOOL) aAnimated completion:(void (^)(void)) aCompletion {
	[self setItems:items animated:aAnimated inSequence:NO completion:aCompletion];
}

- (void) setItems:(NSArray *)items animated:(BOOL) aAnimated inSequence:(BOOL) aSerialAddAnimation completion:(void (^)(void)) aCompletion {
	[self removeAllItemsAnimated:aAnimated completion:^{
		if (aSerialAddAnimation) {
			[self recursiveAddItemFromBucket:items idx:0 withCompletion:aCompletion];
		} else {
			[itemsArray addObjectsFromArray:items];
			
			[self layoutItems:NO completion:NULL];
			for (NSUInteger idx = 0; idx < itemsArray.count; ++idx) {
				DMPathBarItem *currentItem = itemsArray[idx];
				currentItem.pathBar = self;
				currentItem.frame = CGRectOffset(currentItem.frame, -10, 0);
				NSImageView *arrowIcon = nil;
				if (idx > 0) {
					arrowIcon = pathArrows[idx-1];
					arrowIcon.frame = CGRectOffset(arrowIcon.frame, -10, 0);
				}
			}
			[self layoutItems:YES completion:aCompletion];
		}
	}];
}

- (void) recursiveAddItemFromBucket:(NSArray *) aBucketList idx:(NSInteger) aIdx withCompletion:(void (^)(void)) aCompletion {
	if (aIdx == aBucketList.count-1) {
		if (aCompletion)
			aCompletion();
		return;
	}
	
	__weak __typeof__(self) weakSelf = self;
	[self addItem: aBucketList[aIdx] animated:YES completion:^{
		[weakSelf recursiveAddItemFromBucket:aBucketList idx: (aIdx+1) withCompletion:aCompletion];
	}];
}

- (void) removeAllItemsAnimated:(BOOL) aAnimated completion:(void (^)(void)) aCompletion {
	[self removeAllItemsAnimated:aAnimated inSequence:NO completion:aCompletion];
}

- (void) removeAllItemsAnimated:(BOOL) aAnimated inSequence:(BOOL) aSerialRemoveAnimation completion:(void (^)(void)) aCompletion {
	if (itemsArray.count < 2) {
		if (aCompletion) aCompletion();
		return;
	}
	NSRange itemsRange = NSMakeRange(1, itemsArray.count-1);
	if (!aAnimated) {
		NSArray *itemsToRemove = [itemsArray subarrayWithRange:itemsRange];
		[itemsToRemove makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[itemsArray removeObjectsInRange:itemsRange];
		[pathArrows makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[pathArrows removeAllObjects];
		if (aCompletion) aCompletion();
	} else {
		if (aSerialRemoveAnimation)
			[self recursiveRemoveLastItemFromBucketWithCompletion:aCompletion];
		else {
			NSInteger itemsCount = itemsArray.count;
			for (NSUInteger idx = 0; idx < itemsCount; ++idx) {
				[self removeItemAnimated:YES completion:NULL];
			}
			if (aCompletion) aCompletion();
		}
	}
}

- (void) setTitleItem:(DMPathBarItem *) aItem animated:(BOOL) aAnimated completion:(void (^)(void)) aCompletion {
	if (itemsArray.count == 0)
		[self addItem:aItem animated:aAnimated completion:aCompletion];
	else
		[self replaceItemAtIndex:0 with:aItem animated:aAnimated completion:aCompletion];
}

- (void) setAccessoryView:(NSView *)accessoryView animated:(BOOL) aAnimated completion:(void (^)(void)) aCompletion {
	if (!aAnimated) {
		if (_accessoryView) [_accessoryView removeFromSuperview];
		_accessoryView = accessoryView;
		_accessoryView.wantsLayer = YES;
		_accessoryView.layer.backgroundColor = _backActiveColor.CGColor;
		_accessoryView.frame = self.accessoryViewRect;
		[self addSubview:_accessoryView];
	}
}

- (void) replaceItemAtIndex:(NSInteger) aIdx with:(DMPathBarItem *) aItem animated:(BOOL) aAnimated completion:(void(^)(void)) aCompletion {
	if (aIdx < 0 || aIdx >= itemsArray.count) return;
	
	DMPathBarItem *itemToReplace = itemsArray[aIdx];
	NSRect itemRect = itemToReplace.frame;
	
	aItem.pathBar = self;
	NSSize bestItemSize = [aItem bestContentSizeWithMax:self.contentRect.size];
	itemRect.size.width = bestItemSize.width;
	itemRect.size.height = self.contentRect.size.height;
	aItem.frame = itemRect;
	
	[itemsArray replaceObjectAtIndex:aIdx withObject:aItem];

	if (!aAnimated) {
		[itemToReplace removeFromSuperview];
		itemToReplace.pathBar = nil;
		[self addSubview:aItem];
		[self layoutItems];
		if (aCompletion)
			aCompletion();
	} else {
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			context.duration = 0.25f;
			[[itemToReplace animator] setAlphaValue:0.0f];
			[[aItem animator] setAlphaValue:1.0f];
		} completionHandler:^{
			[self layoutItems:YES completion:^{
				if (aCompletion)
					aCompletion();
			}];
		}];
	}
}

- (void) recursiveRemoveLastItemFromBucketWithCompletion:(void (^)(void)) aCompletion {
	[self removeItemAnimated:YES completion:^{
		if (itemsArray.count == 0) {
			if (aCompletion) aCompletion();
		} else
			[self recursiveRemoveLastItemFromBucketWithCompletion:aCompletion];
	}];
}

- (void) removeItemAnimated:(BOOL) aAnimated completion:(void (^)(void)) aCompletion {
	if (itemsArray.count == 1) return;
	
	DMPathBarItem *item = itemsArray.lastObject;
	NSImageView *arrow = pathArrows.lastObject;
	
	NSRect finalRectItem = CGRectOffset(item.frame, -10, 0);
	NSRect finalRectArrow = CGRectOffset(arrow.frame, -10, 0);
	
	[itemsArray removeLastObject];
	[pathArrows removeLastObject];
	
	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
		context.duration = 0.25f;
		[[item animator] setFrameOrigin: finalRectItem.origin];
		[[arrow animator] setFrameOrigin: finalRectArrow.origin];
		[arrow animator].alphaValue = 0.0f;
		[item animator].alphaValue = 0.0f;
	} completionHandler:^{
		item.pathBar = nil;
		if (aCompletion)
			aCompletion();
	}];
}

- (void) addItem:(DMPathBarItem *) aItem animated:(BOOL) aAnimated completion:(void (^)(void)) aCompletion {
	// Add item to the list
	aItem.pathBar = self;
	[itemsArray addObject:aItem];
	
	// Evaluate start offset of the block
	NSRect rect = self.contentRect;
	DMPathBarItem *lastItem = (itemsArray.count == 1 ? nil : itemsArray[itemsArray.count-2]);
	CGFloat offsetX = (lastItem ? CGRectGetMaxX(lastItem.frame) : CGRectGetMinX(rect));
	
	NSImageView *arrowIcon = nil;
	if (itemsArray.count > 1) {
		// Create new arrow
		// Evaluate offset of the arrow
		arrowIcon = [self newArrowIcon];
		[pathArrows addObject:arrowIcon];
		NSRect arrowIconFrame = NSMakeRect(offsetX, rect.origin.y, arrowIcon.frame.size.width, rect.size.height);
		arrowIconFrame = CGRectOffset(arrowIconFrame, -10, 0);
		arrowIcon.frame = arrowIconFrame;
		arrowIcon.alphaValue = 0.0f;

		offsetX += CGRectGetWidth(arrowIconFrame);
	}
	
	// Evaluate offset of the item
	NSSize itemBestSize = [aItem bestContentSizeWithMax:rect.size];
	NSRect itemRect = NSIntegralRect(NSMakeRect(offsetX, rect.origin.y, itemBestSize.width, rect.size.height));
	itemRect = CGRectOffset(itemRect, -10, 0);
	aItem.frame = itemRect;
	aItem.alphaValue = 0.0f;
	
	if (!aAnimated) {
		aItem.alphaValue = 1.0f;
		arrowIcon.alphaValue = 1.0f;
		[self layoutItems];
		if (aCompletion)
			aCompletion();
	} else {
		[self layoutItems:YES completion:^{
			if (aCompletion)
				aCompletion();
		}];
	}
}

#pragma mark - Drawing Routines -

- (NSRect) contentRect {
	NSRect bounds = self.bounds;
	NSRect contentRect = NSRectInsetWithEdgeInsets(bounds, _contentInsets);

	// Take the space of the accessory view
	CGFloat accessoryWidth = CGRectGetWidth(self.accessoryViewRect);
	contentRect.size.width -= accessoryWidth;
	if (_accessoryPosition == DMPathBarAccessoryPosLeft)
	contentRect.origin.x += CGRectGetWidth(self.accessoryViewRect);

	contentRect.size.height -=1;
	return contentRect;
}

- (NSRect) accessoryViewRect {
	if (!_accessoryView) return NSZeroRect;
	
	NSRect contentRect = NSRectInsetWithEdgeInsets(self.bounds, _contentInsets);
	NSRect accessoryRect = NSMakeRect(0.0f, contentRect.origin.y, CGRectGetWidth(_accessoryView.frame), CGRectGetHeight(contentRect));
	if (_accessoryPosition == DMPathBarAccessoryPosRight)
		accessoryRect.origin.x = CGRectGetMaxX(contentRect)-CGRectGetWidth(accessoryRect);
	else
		accessoryRect.origin.x = CGRectGetMinX(contentRect);
	accessoryRect.size.width += _contentInsets.right;
	return accessoryRect;
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	if (CGRectEqualToRect(CGRectZero, self.bounds))
		return;
	
	NSRect backPathRect = CGRectMake(0.0f, 0.0f, CGRectGetWidth(_bounds), CGRectGetHeight(_bounds));
	NSRect contentPathRect = CGRectMake(0.0f, 0.0f, CGRectGetWidth(backPathRect), CGRectGetHeight(backPathRect)-1);
	
	[NSGraphicsContext saveGraphicsState];
	
	if (_isWindowActive) {
		NSBezierPath *backPath = [NSBezierPath bezierPathWithRoundedRect:backPathRect xRadius:_cornerRadius yRadius:_cornerRadius];
		[_backShadowColor set];
		[backPath fill];
	}
	
	NSBezierPath *contentPath = [NSBezierPath bezierPathWithRoundedRect:contentPathRect xRadius:_cornerRadius yRadius:_cornerRadius];
	[(_isWindowActive && _enabled ? (isMouseDown ? _backSelectedColor : _backActiveColor) : _backInactiveColor) set];
	[contentPath fill];
	[NSGraphicsContext restoreGraphicsState];
}

- (NSSize) arrowSize {
	NSSize size = NSMakeSize((_arrowIcon.size.width+kDMPathBarArrowExtraWidth),_arrowIcon.size.height);
	return size;
}

- (void) layoutItems {
	[self layoutItems:NO completion:NULL];
}

- (void) bringSubviewToFront:(NSView *) aView {
	[aView removeFromSuperview];
	[self addSubview:aView positioned:NSWindowAbove relativeTo:nil];
}

- (void) layoutItems:(BOOL) aAnimated completion:(void (^)(void)) aCompletion {
	if (CGRectEqualToRect(CGRectZero, self.bounds) || itemsArray.count == 0)
		return;
	
	NSInteger requiredArrows = (itemsArray.count-1);
	CGFloat arrowIconsSpace = (requiredArrows * self.arrowSize.width);
	CGFloat availableWidth = CGRectGetWidth(self.contentRect)-arrowIconsSpace;
	CGFloat requiredWidth = 0.0f;
	CGSize contentSize = NSMakeSize(availableWidth, CGRectGetHeight(self.contentRect));
	for (DMPathBarItem *item in itemsArray) {
		item.pathBar = self;
		requiredWidth += [item bestContentSizeWithMax: contentSize].width;
	}
	requiredWidth = roundf(requiredWidth);
	
	CGFloat compressionPerItem = 0.0f;
	BOOL compressionIsForAll = NO;
	if (requiredWidth > availableWidth) {
		// We want to compress proportionally only items in the middle between the title and the second-last item
		CGFloat extraNeededSpace = (requiredWidth-availableWidth);
		compressionIsForAll = (itemsArray.count <= 2);
		NSInteger itemsToCompress = (!compressionIsForAll ? itemsArray.count-2 : itemsArray.count);
		if (compressionIsForAll || (!compressionIsForAll && currentExpandedItemIdx > 1 && currentExpandedItemIdx < itemsArray.count-1))
			itemsToCompress-=1; // one of the compressed items is not compressed, shift it's delta to the other items
		compressionPerItem = ceilf((extraNeededSpace/itemsToCompress));
	}
	
	[self regenerateRequiredPathArrowsIfNeeded];
	
	void (^frameUpdateBlock)(void) = ^void(void) {
		NSRect rect = self.contentRect;
		CGFloat offsetX = CGRectGetMinX(rect);
		NSInteger arrowIdx = 0;
		NSInteger lastItemIdx = (itemsArray.count-1);
		for (NSUInteger currentItemIdx = 0; currentItemIdx < itemsArray.count; ++currentItemIdx) {
			if (currentItemIdx > 0 && currentItemIdx <= itemsArray.count-1) {
				NSImageView *arrowIcon = pathArrows[arrowIdx];
				NSRect arrowIconFrame = NSMakeRect(offsetX, rect.origin.y, arrowIcon.frame.size.width, contentSize.height);
				
				if (!aAnimated) {
					arrowIcon.alphaValue = 1.0f;
					arrowIcon.frame = arrowIconFrame;
				} else {
					[arrowIcon animator].alphaValue = 1.0f;
					[arrowIcon animator].frame = arrowIconFrame;
				}
				
				if (arrowIcon.superview != self) [self addSubview:arrowIcon];
				++arrowIdx;
				offsetX += CGRectGetWidth(arrowIconFrame);
			}
			DMPathBarItem *item = itemsArray[currentItemIdx];
			NSSize itemBestSize = [item bestContentSizeWithMax:contentSize];
			NSRect itemRect = NSIntegralRect(NSMakeRect(offsetX, rect.origin.y, itemBestSize.width, contentSize.height));
			
			BOOL isLastItem = (lastItemIdx == currentItemIdx);
			BOOL isItemExpanded = (currentExpandedItemIdx != NSNotFound && currentExpandedItemIdx == currentItemIdx);
			
			BOOL isCompressed = NO;
			if ( compressionPerItem > 0 && (currentItemIdx != 0 && !isLastItem) && !isItemExpanded) {
				isCompressed = YES;
				itemRect.size.width -= compressionPerItem;
			}
			
			[item setCompressed:isCompressed animated:aAnimated];
			
			if (item.superview != self)
				[self addSubview:item];
			
			[self bringSubviewToFront:_accessoryView];

			if (!aAnimated) {
				item.alphaValue = 1.0f;
				item.frame = itemRect;
			} else {
				[item animator].alphaValue = 1.0f;
				[item animator].frame = itemRect;
			}
			[item layoutSubviews];
			offsetX += CGRectGetWidth(itemRect);
		}
	};
	
	if (!aAnimated) {
		frameUpdateBlock();
		if (aCompletion) aCompletion();
	} else {
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			context.duration = 0.25f;
			frameUpdateBlock();
		} completionHandler:^{
			if (aCompletion)
				aCompletion();
		}];
	}
}

- (void) regenerateRequiredPathArrowsIfNeeded {
	if (pathArrows.count == itemsArray.count-1)
		return;
	BOOL shouldCreateNewPathArrows = (pathArrows.count < (itemsArray.count-1));
	int missingNo = (int)abs( (int)itemsArray.count-1- (int)pathArrows.count);
	for (NSUInteger idx = 0; idx < missingNo; ++idx) {
		if (shouldCreateNewPathArrows)
			[pathArrows addObject:[self newArrowIcon]];
		else {
			[pathArrows.lastObject performSelector:@selector(removeFromSuperview)];
			[pathArrows removeLastObject];
		}
	}
}

- (NSImageView *) newArrowIcon {
	NSRect arrowRect = NSMakeRect(0.0f, 0.0f,self.arrowSize.width,_arrowIcon.size.height);
	NSImageView *pathArrow = [[NSImageView alloc] initWithFrame:arrowRect];
	[pathArrow setImageAlignment:NSImageAlignCenter];
	[pathArrow setImageFrameStyle:NSImageFrameNone];
	[pathArrow setImageScaling:NSImageScaleProportionallyDown];
	[pathArrow setImage:_arrowIcon];
	pathArrow.wantsLayer = YES;
	return pathArrow;
}

#pragma mark - Mouse Events -

- (void) mouseMoved:(NSEvent *)theEvent {
	if (!_enabled) {
		[super mouseMoved:theEvent];
		return;
	}
	DMPathBarItem *itemBehindTheMouse = [self itemAtPoint: [self convertPoint:theEvent.locationInWindow fromView:nil]];
	if (!itemBehindTheMouse)
		currentExpandedItemIdx = NSNotFound;
	else
		currentExpandedItemIdx = [itemsArray indexOfObject:itemBehindTheMouse];
	[self layoutItems:YES completion:NULL];
}

- (void)mouseExited:(NSEvent *)theEvent {
	if (!_enabled) {
		[super mouseExited:theEvent];
		return;
	}
	currentExpandedItemIdx = NSNotFound;
	[self layoutItems:YES completion:NULL];
}

- (void)mouseDown:(NSEvent *)theEvent {
	if (!_enabled) {
		[super mouseDown:theEvent];
		return;
	}
	DMPathBarItem *item = [self itemAtPoint: [self convertPoint:theEvent.locationInWindow fromView:nil]];
	if (!item || !item.enabled) {
		[super mouseDown:theEvent];
		return;
	}
	
	isMouseDown = YES;
	[self setNeedsDisplay:YES];
	if (_action) {
		NSMenu *returnedMenu = _action([itemsArray indexOfObject:item],item);
		if (returnedMenu) {
			NSRect itemRect = item.frame;
			NSPoint fakeLocation = [self convertPoint:NSMakePoint(NSMinX(itemRect), NSMinY(itemRect)+10.0f) toView:nil];
			NSEvent *fakeEvent = [NSEvent mouseEventWithType:NSLeftMouseUp location:fakeLocation
											   modifierFlags: 0
												   timestamp: NSTimeIntervalSince1970
												windowNumber: [_window windowNumber]
													 context: nil
												 eventNumber: 0
												  clickCount: 0
													pressure: 0.1];
			[NSMenu popUpContextMenu:returnedMenu withEvent:fakeEvent forView:nil];
		}
		return;
	} else {
		[super mouseDown:theEvent];
	}
}

- (void)mouseUp:(NSEvent *)theEvent {
	if (!_enabled) {
		[super mouseUp:theEvent];
		return;
	}
	[super mouseUp:theEvent];
	isMouseDown = NO;
	[self setNeedsDisplay:YES];
}

@end


NSRect NSRectInsetWithEdgeInsets(NSRect inRect, NSEdgeInsets insets) {
	inRect.size.height -= (insets.top + insets.bottom);
	inRect.size.width -= (insets.left + insets.right);
	inRect.origin.x += insets.left;
	inRect.origin.y += insets.top;
	return inRect;
}
