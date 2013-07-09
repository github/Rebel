//
//  RBLShadowedTextFieldCell.m
//  Rebel
//
//  Created by Danny Greg on 18/02/2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "RBLShadowedTextFieldCell.h"

#import "NSColor+RBLCGColorAdditions.h"

NSBackgroundStyle const RBLShadowedTextFieldAllBackgroundStyles = 0xFFFFFFFF;

@interface RBLShadowedTextFieldCell ()

// Maps keys of backgroundStyles to values of shadows.
@property (nonatomic, strong) NSMutableDictionary *backgroundStylesToShadows;

@property (nonatomic, readonly, strong) NSTextView *fieldEditor;

@end

@implementation RBLShadowedTextFieldCell

#pragma mark Lifecycle

static void CommonInit(RBLShadowedTextFieldCell *self) {
	self.backgroundStylesToShadows = [NSMutableDictionary dictionary];

	NSTextView *textView = [[NSTextView alloc] initWithFrame:CGRectZero];
	[textView setString:@"blah"];
	[textView setFieldEditor:YES];
	[textView setBackgroundColor:NSColor.redColor];
	[textView setTextColor:NSColor.greenColor];
	self->_fieldEditor = textView;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self == nil) return nil;
	
	CommonInit(self);
	
	return self;
}

- (instancetype)initTextCell:(NSString *)aString {
	self = [super initTextCell:aString];
	if (self == nil) return nil;
	
	CommonInit(self);
	
	return self;
}

#pragma mark Drawing

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	[NSGraphicsContext saveGraphicsState];
	NSShadow *shadow = self.backgroundStylesToShadows[@(self.backgroundStyle)];
	if (shadow == nil) {
		shadow = self.backgroundStylesToShadows[@(RBLShadowedTextFieldAllBackgroundStyles)];
	}
	
	if (shadow != nil) {
		CGContextSetShadowWithColor(NSGraphicsContext.currentContext.graphicsPort, shadow.shadowOffset, shadow.shadowBlurRadius, shadow.shadowColor.rbl_CGColor);
	}
	
	[super drawWithFrame:cellFrame inView:controlView];
	
	[NSGraphicsContext restoreGraphicsState];
}

- (NSText *)setUpFieldEditorAttributes:(NSText *)textObj {
	NSTextView *fieldEditor = (NSTextView*)[super setUpFieldEditorAttributes:textObj];
    NSColor *textColor = NSColor.redColor;
    [fieldEditor setInsertionPointColor:textColor];
    [fieldEditor setTextColor:textColor];
    [fieldEditor setDrawsBackground:NO];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[fieldEditor selectedTextAttributes]];
    [attributes setObject:NSColor.greenColor forKey:NSBackgroundColorAttributeName];
	attributes[NSFontAttributeName] = [NSFont systemFontOfSize:10];
	attributes[NSForegroundColorAttributeName] = NSColor.redColor;
	NSShadow *shadow = self.backgroundStylesToShadows[@(self.backgroundStyle)];
	if (shadow == nil) {
		shadow = self.backgroundStylesToShadows[@(RBLShadowedTextFieldAllBackgroundStyles)];
	}
	attributes[NSShadowAttributeName] = shadow;
    [fieldEditor setSelectedTextAttributes:attributes];
    return fieldEditor;
}

#pragma mark API

- (void)setShadow:(NSShadow *)shadow forBackgroundStyle:(NSBackgroundStyle)backgroundStyle {
	if (shadow == nil) {
		[self.backgroundStylesToShadows removeObjectForKey:@(backgroundStyle)];
		return;
	}
	
	self.backgroundStylesToShadows[@(backgroundStyle)] = shadow;
}

@end
