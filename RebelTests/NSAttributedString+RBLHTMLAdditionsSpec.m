//
//  NSAttributedString+RBLHTMLAdditionsSpec.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-12-11.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <Quick/Quick.h>
#import <Rebel/Rebel.h>

QuickSpecBegin(NSAttributedStringHTMLAdditions)

it(@"should initialize from a simple HTML string", ^{
	NSAttributedString *attributedString = [NSAttributedString rbl_attributedStringWithHTML:@"some <u>formatted</u><br />text"];
	expect(attributedString).notTo.beNil();

	// within "some"
	expect([attributedString attributesAtIndex:1 effectiveRange:NULL][NSUnderlineStyleAttributeName]).to.beNil();

	// within "formatted"
	expect([attributedString attributesAtIndex:7 effectiveRange:NULL][NSUnderlineStyleAttributeName]).to.equal(@(NSUnderlineStyleSingle));

	expect([attributedString.string characterAtIndex:14]).to.equal('\n');
});

it(@"should initialize from an HTML string with CSS styling", ^{
	NSAttributedString *attributedString = [NSAttributedString rbl_attributedStringWithHTML:@"<span style='font-family: Courier;'>formatted text</span>"];
	expect(attributedString).notTo.beNil();

	NSFont *font = [attributedString attributesAtIndex:1 effectiveRange:NULL][NSFontAttributeName];
	expect(font).notTo.beNil();
	expect(font.familyName).to.equal(@"Courier");
});

QuickSpecEnd
