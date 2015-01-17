//
//  CALayer+flipPos.h
//  Photoroute
//
//  Created by Andreas Zöllner on 17.01.15.
//  Copyright (c) 2015 Studio Istanbul Medya Hiz. Tic. Ltd. Sti. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (flipPos)
-(void)flipCoordinatesForRect:(NSRect)frameRect;
@end
