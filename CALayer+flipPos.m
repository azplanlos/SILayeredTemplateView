//
//  CALayer+flipPos.m
//  Photoroute
//
//  Created by Andreas Zöllner on 17.01.15.
//  Copyright (c) 2015 Studio Istanbul Medya Hiz. Tic. Ltd. Sti. All rights reserved.
//

#import "CALayer+flipPos.h"

@implementation CALayer (flipPos)

-(void)flipCoordinatesForRect:(NSRect)frameRect {
    self.frame = NSMakeRect(self.frame.origin.x, frameRect.size.height - (self.frame.origin.y + self.frame.size.height), self.frame.size.width, self.frame.size.height);
}
@end
