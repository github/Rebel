//
//  RBLHTMLView.m
//  Rebel
//
//  Created by Josh Abernathy on 3/13/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "RBLHTMLView.h"

@interface RBLHTMLView () <WebPolicyDelegate, WebUIDelegate>
@end

@implementation RBLHTMLView

#pragma mark Lifecycle

static void CommonInit(RBLHTMLView *self) {
	self.drawsBackground = NO;
	self.maintainsBackForwardList = NO;
	self.mainFrame.frameView.allowsScrolling = NO;
	self.policyDelegate = self;
	self.UIDelegate = self;
}

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self == nil) return nil;

	CommonInit(self);

	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (self == nil) return nil;

	CommonInit(self);

	return self;
}

#pragma mark WebPolicyDelegate

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
	// WebNavigationTypeOther is when we do our HTML string load. Otherwise, we
	// shunt it off to a Real Browser®.
	if ([actionInformation[WebActionNavigationTypeKey] integerValue] == WebNavigationTypeOther) {
		[listener use];
	} else {
		[listener ignore];
		[NSWorkspace.sharedWorkspace openURL:request.URL];
	}
}

#pragma mark WebUIDelegate

- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems {
	NSMutableArray *strippedMenuItems = [[NSMutableArray alloc] initWithArray:defaultMenuItems];
	for (NSMenuItem *item in defaultMenuItems) {
		NSUInteger tag = item.tag;
		if (tag == WebMenuItemTagReload || tag == WebMenuItemTagGoBack || tag == WebMenuItemTagGoForward || tag == WebMenuItemTagStop || tag == WebMenuItemTagDownloadLinkToDisk) [strippedMenuItems removeObject:item];
	}
	
	return strippedMenuItems;
}

- (NSUInteger)webView:(WebView *)webView dragDestinationActionMaskForDraggingInfo:(id<NSDraggingInfo>)draggingInfo {
	return WebDragDestinationActionNone;
}

#pragma mark HTML

- (void)setHTML:(NSString *)HTML {
	if ([_HTML isEqual:HTML]) return;

	_HTML = [HTML copy];

	[self reloadConstructedContent];
}

- (void)setCSS:(NSString *)CSS {
	if ([_CSS isEqual:CSS]) return;

	_CSS = [CSS copy];

	[self reloadConstructedContent];
}

- (void)reloadConstructedContent {
	if (self.HTML == nil) return;

	static NSString * const template = @""
	"<!DOCTYPE html>"
	"<style> "
	"    body { "
	"        font: 11px Lucida Grande, sans-serif; "
	"        color: #262626; "
	"        line-height: 16px; "
	"        vertical-align: baseline; "
	"        margin: 0px 0px 0px 0px; "
	"    } "
	"    a { "
	"        text-decoration: none; "
	"        color: #06C; "
	"    } "
	"    a:visited { "
	"        text-decoration: none; "
	"        color: #06C; "
	"    } "
	"    .error { "
	"        color: #911; "
	"    } "
	"%@"
	"</style> "
	"<body>%@</body> ";

	NSString *constructedHTML = [NSString stringWithFormat:template, self.CSS, self.HTML];
	[self.mainFrame loadHTMLString:constructedHTML baseURL:nil];
	while (self.isLoading) {
		[NSRunLoop.currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
	}
}

@end
