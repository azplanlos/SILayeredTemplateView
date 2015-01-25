//
//  SILayerView.m
//  Photoroute
//
//  Created by Andreas Zöllner on 25.01.15.
//  Copyright (c) 2015 Studio Istanbul Medya Hiz. Tic. Ltd. Sti. All rights reserved.
//

#import "SILayerView.h"

@implementation SILayerView
@synthesize viewNum;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        viewNum = 0;
    }
    
    return self;
}

-(BOOL)wantsDefaultClipping {
    return NO;
}


@end
