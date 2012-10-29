//
//  NSObject+NSObjectSizzlingAdditions.h
//  Rebel
//
//  Created by Colin Wheeler on 10/29/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NSObjectSizzlingAdditions)

+ (void)swapMethod:(SEL)originalSelector with:(SEL)newSelector;

@end
