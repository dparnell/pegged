//
//  Node.m
//  pegged
//
//  Created by Matt Diephouse on 12/29/09.
//  This code is in the public domain.
//

#import "Node.h"

@implementation Node

#pragma mark - Public Methods

+ (id)node
{
    return [[self class] new];
}


- (NSString *)compile:(NSString *)parserClassName language:(NSString*)language
{
    return nil;
}


- (void)invert
{
    self.inverted = !self.inverted;
}

@end
