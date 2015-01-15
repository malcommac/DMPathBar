//
//  DMPathBarItem.m
//  XCode style PathBar for Yosemite
//
//  Created by Daniele Margutti (me@danielemargutti.com) on 14/01/15.
//  Copyright (c) 2015 http://www.danielemargutti.com All rights reserved.
//	Distribuited under MIT License http://opensource.org/licenses/MIT
//

#import "DMPathBarItem.h"
#import "DMPathBar.h"

#define kDMPathBarItemTitleIconSpacing	5.0f
#define kDMPathBarItemTextFieldBorder	4.0f
#define kDMPathBarItemGradientWidth		20.0f

#pragma mark - DMPathBarItem -

@interface DMPathBarGradient : NSView

@property (nonatomic,weak)	DMPathBarItem	*pathBarItem;

@end

@implementation DMPathBarGradient

+ (instancetype) newGradient:(DMPathBarItem *) aItem {
	DMPathBarGradient *gradient = [[DMPathBarGradient alloc] initWithFrame:NSZeroRect];
	gradient.pathBarItem = aItem;
	return gradient;
}

- (BOOL)isFlipped {
	return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
	NSGradient *g = [[NSGradient alloc] initWithColorsAndLocations:
					 [NSColor colorWithCalibratedWhite:1.0f alpha:0.0f], 0.0f,
					 _pathBarItem.pathBar.backActiveColor, 0.7f, nil];
	[g drawInRect:self.bounds angle:0];
}

@end

@interface DMPathBarItem () {
	NSTextField				*fldTitle;
	DMPathBarGradient		*gradient;
}

@property (nonatomic,readonly)	NSRect		titleRect;
@property (nonatomic,readonly)	NSRect		iconRect;

@end

@implementation DMPathBarItem

+ (instancetype) itemWithTitle:(NSString *) aTitle icon:(NSImage *) aIcon {
	return [[DMPathBarItem alloc] initWithTitle:aTitle icon:aIcon];
}

+ (instancetype) itemWithCustomView:(NSView *) aCustomView {
	return [[DMPathBarItem alloc] initWithCustomView:aCustomView];
}

- (instancetype)initWithCustomView:(NSView *) aCustomView {
	if (self = [self init]) {
		_title = nil;
		_icon = nil;
		_customView = aCustomView;
		_activeTitleAttributes = nil;
		_inactiveTitleAttributes = nil;
		_boldActiveTitleAttributes = nil;
		_boldInactiveTitleAttributes = nil;
		[fldTitle removeFromSuperview];
		fldTitle = nil;
	}
	return self;
}

- (instancetype) init {
	self = [super initWithFrame:NSZeroRect];
	if (self) {
		self.wantsLayer = YES;
		self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;

		_enabled = YES;
		fldTitle = [[NSTextField alloc] initWithFrame:NSZeroRect];
		fldTitle.wantsLayer = YES;
		fldTitle.autoresizingMask = NSViewWidthSizable;
		fldTitle.drawsBackground = NO;
		fldTitle.editable = NO;
		fldTitle.bordered = NO;
		[fldTitle setBordered:NO];
		[self addSubview:fldTitle];
	}
	return self;
}

- (instancetype)initWithTitle:(NSString *) aTitle icon:(NSImage *) aIcon {
	if (self = [self init]) {
		_title = aTitle;
		_icon = aIcon;
		_customView = nil;
		
		NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
		paragraph.lineBreakMode = NSLineBreakByWordWrapping;
		
		_activeTitleAttributes = @{NSFontAttributeName					: [NSFont fontWithName:@"HelveticaNeue" size:12.0f],
								   NSForegroundColorAttributeName		: [NSColor blackColor],
								   NSParagraphStyleAttributeName		: paragraph};
		_inactiveTitleAttributes = @{NSFontAttributeName				: [NSFont fontWithName:@"HelveticaNeue" size:12.0f],
									 NSForegroundColorAttributeName		: [NSColor lightGrayColor],
									 NSParagraphStyleAttributeName		: paragraph};
		_boldActiveTitleAttributes = @{NSFontAttributeName				: [NSFont fontWithName:@"HelveticaNeue-Medium" size:12.0f],
									   NSForegroundColorAttributeName	: [NSColor blackColor],
									   NSParagraphStyleAttributeName	: paragraph};
		_boldInactiveTitleAttributes = @{NSFontAttributeName			: [NSFont fontWithName:@"HelveticaNeue-Medium" size:12.0f],
										 NSForegroundColorAttributeName	: [NSColor lightGrayColor],
										 NSParagraphStyleAttributeName	: paragraph};
	}
	return self;
}

- (void)setEnabled:(BOOL)enabled {
	_enabled = enabled;
	[self layoutSubviews];
}

- (void)setInactiveTitleAttributes:(NSDictionary *)inactiveTitleAttributes {
	_inactiveTitleAttributes = inactiveTitleAttributes;
	[self setNeedsDisplay:YES];
}

- (void)setActiveTitleAttributes:(NSDictionary *)activeTitleAttributes {
	_activeTitleAttributes = activeTitleAttributes;
	[self setNeedsDisplay:YES];
}

- (void)setBoldActiveTitleAttributes:(NSDictionary *)boldActiveTitleAttributes {
	_boldActiveTitleAttributes = boldActiveTitleAttributes;
	[self setNeedsDisplay:YES];
}

- (void)setBoldInactiveTitleAttributes:(NSDictionary *)boldInactiveTitleAttributes {
	_boldInactiveTitleAttributes = boldInactiveTitleAttributes;
	[self setNeedsDisplay:YES];
}

- (void)setFrame:(NSRect)frame {
	[super setFrame:frame];
	[self layoutSubviews];
}

- (BOOL)isFlipped {
	return YES;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%p> %@",
			self,
			(_customView ? [NSString stringWithFormat: @"CUSTOM VIEW %@ <%p>",_customView,_customView] : _title)];
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	if (CGRectEqualToRect(CGRectZero, self.bounds))
		return;
	
	BOOL isKeyWindow = _pathBar.isWindowActive;
	BOOL isEnabled = _pathBar.enabled;
	
	BOOL isTitleItem = ([_pathBar.items indexOfObject:self] == 0);
	NSDictionary *textAttrsDict;
	if (isKeyWindow && isEnabled && _enabled)
		textAttrsDict = (isTitleItem ? _boldActiveTitleAttributes : _activeTitleAttributes);
	else
		textAttrsDict = (isTitleItem ? _boldInactiveTitleAttributes : _inactiveTitleAttributes);
	
	CGFloat imageAlpha = (isKeyWindow ? 1.0f : 0.5f);
	NSStringDrawingOptions opt = (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading);

	CGFloat offsetX = 0.0f;
	
	if (_icon) {
		NSSize iconSize = _icon.size;
		NSRect iconRect = NSMakeRect(offsetX, roundf( (CGRectGetHeight(self.bounds)-_icon.size.height)/2.0f), iconSize.width, iconSize.height);
		[_icon drawInRect: iconRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:imageAlpha respectFlipped:YES hints:nil];
		offsetX+=CGRectGetWidth(iconRect)+kDMPathBarItemTitleIconSpacing;
	}
	
	if (_title) {
		NSSize singleLineSize = [_title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:opt attributes:textAttrsDict].size;
		NSSize titleSize = [_title boundingRectWithSize:self.bounds.size options:opt attributes:textAttrsDict].size;
		titleSize.width += kDMPathBarItemTextFieldBorder;
		NSRect titleRect = NSMakeRect(offsetX, roundf( (CGRectGetHeight(self.bounds)-singleLineSize.height)/2.0f)-2,
									  titleSize.width, singleLineSize.height);
		fldTitle.stringValue = _title;
		fldTitle.font = textAttrsDict[NSFontAttributeName];
		fldTitle.textColor = textAttrsDict[NSForegroundColorAttributeName];
		fldTitle.lineBreakMode = NSLineBreakByCharWrapping;
		fldTitle.frame = titleRect;
//		[_title drawInRect:titleRect withAttributes:textAttrsDict];
	}
	
	[self layoutSubviews];
}

- (void) layoutSubviews {
	[self setNeedsDisplay:YES];
	if (gradient) {
		NSRect gradientRect = NSZeroRect;
		if (_isCompressed)
			gradientRect = NSMakeRect(CGRectGetMaxX(self.bounds)-kDMPathBarItemGradientWidth, 0,
									  kDMPathBarItemGradientWidth, CGRectGetHeight(self.bounds));
		gradient.frame = gradientRect;
	}
}

- (NSSize) bestContentSize {
	return [self bestContentSizeWithMax:NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX)];
}

- (NSSize) bestContentSizeWithMax:(NSSize) maxSize {
	if (_customView)
		return _customView.frame.size;
	
	BOOL isTitleItem = ([_pathBar.items indexOfObject:self] == 0);

	NSStringDrawingOptions opt = (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading);
	NSSize titleSize = [_title boundingRectWithSize:maxSize options:opt
										 attributes:(isTitleItem ? _boldActiveTitleAttributes : _activeTitleAttributes)].size;
	titleSize.width += kDMPathBarItemTextFieldBorder;
	NSSize iconSize = _icon.size;
	
	CGFloat maxHeight = MAX(titleSize.height,iconSize.height);
	CGFloat maxWidth = (titleSize.width + iconSize.width + (_icon && _title ? kDMPathBarItemTitleIconSpacing : 0.0f));
	return NSMakeSize(ceilf(maxWidth), ceilf(maxHeight));
}

- (void) setCompressed:(BOOL) aCompressed animated:(BOOL) aAnimated {
	if (_isCompressed == aCompressed) return;
	_isCompressed = aCompressed;
	
	if (_isCompressed && !gradient) {
		gradient = [DMPathBarGradient newGradient:self];
		[self layoutSubviews];
		gradient.alphaValue = 0.0f;
		[self addSubview:gradient];
		
		if (!aAnimated) {
			gradient.alphaValue = 1.0f;
		} else {
			[gradient animator].alphaValue = 1.0f;
		}
		
	} else if (!_isCompressed && gradient) {
		if (!aAnimated) {
			[gradient removeFromSuperview];
			gradient = nil;
		} else {
			[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
				[gradient animator].alphaValue = 0.0f;
			} completionHandler:^{
				[gradient removeFromSuperview];
				gradient = nil;
			}];
		}
	}
	[self setNeedsDisplay:YES];
}

@end