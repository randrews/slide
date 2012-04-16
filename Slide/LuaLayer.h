//
//  LuaLayer.h
//  Slide
//
//  Created by Ross Andrews on 4/8/12.
//  Copyright 2012 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LuaLayer : CCLayer
{
    UISwipeGestureRecognizer *swipe_left, *swipe_right, *swipe_up, *swipe_down;
}

@property (retain) NSString *module;

+(CCScene *) scene;

-(void) createSwipeRecognizers;
-(void) sendSwipeToLua: (char*) direction;

@end
