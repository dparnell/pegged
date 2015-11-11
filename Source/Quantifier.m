//
//  Quantifier.m
//  pegged
//
//  Created by Matt Diephouse on 1/1/10.
//  This code is in the public domain.
//

#import "Quantifier.h"

#import "Compiler.h"

@implementation Quantifier

#pragma mark - Node Methods

- (NSString *)compile:(NSString *)parserClassName language:(NSString *)language
{
    NSMutableString *code = [NSMutableString string];
    
    NSString *selector = self.repeats ? @"matchMany" : @"matchOne";
    
    if([language isEqualToString: @"swift"]) {
        if (!self.optional)
            [code appendString:@"if (!"];
        
        [code appendFormat:@"parser.%@WithCaptures(startIndex, block: {(parser: %@, startIndex: Int) -> Bool in\n", selector, parserClassName];
        [code appendString:[[[self.node compile:parserClassName language: language] stringByAddingIndentationWithCount: 1] stringByRemovingTrailingWhitespace]];
        [code appendString:@"\n\treturn true\n"];
        [code appendString:@"})\n"];
        
        if (self.optional)
        {
            [code appendFormat:@"\n"];
        }
        else
        {
            [code appendFormat:@") {\n\treturn false\n}\n"];
        }
    } else {
        if (!self.optional)
            [code appendString:@"if (!"];
        
        [code appendFormat:@"[parser %@WithCaptures:localCaptures startIndex:startIndex block:^(%@ *parser, NSInteger startIndex, NSInteger *localCaptures) {\n", selector, parserClassName];
        [code appendString:[[[self.node compile:parserClassName language: language] stringByAddingIndentationWithCount: 1] stringByRemovingTrailingWhitespace]];
        [code appendString:@"\n\treturn YES;\n"];
        [code appendString:@"}]"];
        
        if (self.optional)
        {
            [code appendFormat:@";\n"];
        }
        else
        {
            [code appendFormat:@")\n\treturn NO;\n"];
        }
    }
    
    return code;
}


#pragma mark - Public Methods

+ (id)quantifierWithNode:(Node *)node
{
    return [[[self class] alloc] initWithNode:node];
}


- (id)initWithNode:(Node *)node
{
    self = [super init];
    
    if (self)
    {
        _node = node;
    }
    
    return self;
}

@end
