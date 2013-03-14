//
//  RBLHTMLView.h
//  Rebel
//
//  Created by Josh Abernathy on 3/13/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <WebKit/WebKit.h>

// A view for displaying HTML-styled text.
@interface RBLHTMLView : WebView

// The CSS to use to style the HTML.
//
// Reasonable defaults are used when this is not set.
@property (nonatomic, copy) NSString *CSS;

// The HTML to display.
@property (nonatomic, copy) NSString *HTML;

@end
