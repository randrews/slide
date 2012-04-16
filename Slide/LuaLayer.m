//
//  LuaLayer.m
//  Slide
//
//  Created by Ross Andrews on 4/8/12.
//  Copyright 2012 None. All rights reserved.
//

#import "LuaLayer.h"
#import "LuaManager.h"
#import "lua_graphics.h"

@implementation LuaLayer

@synthesize module;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	LuaLayer *layer = [LuaLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
        [[LuaManager sharedManager] runFile:@"stub"];
        CCNode *old_active = LuaSetActiveLayer(self);
        [[LuaManager sharedManager] runLuaCode:"_init()"];
        LuaSetActiveLayer(old_active);
        
        CCTMXTiledMap *map = [CCTMXTiledMap tiledMapWithTMXFile:@"level.tmx"];
        [self addChild:map];
        CCTMXLayer *walls = [map layerNamed:@"Walls"];
        for(int x = 0; x< 10; x++)
            NSLog(@"%d", [walls tileGIDAt:ccp(x, 15-4)]);

        [self createSwipeRecognizers];
        [self schedule:@selector(callUpdate:)];
	}
	return self;
}

///////////////////////////////////////////////////
// Swipe stuff
///////////////////////////////////////////////////

-(void) createSwipeRecognizers
{
    swipe_left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [swipe_left setDirection:UISwipeGestureRecognizerDirectionLeft];

    swipe_right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [swipe_right setDirection:UISwipeGestureRecognizerDirectionRight];

    swipe_up = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [swipe_up setDirection:UISwipeGestureRecognizerDirectionUp];

    swipe_down = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [swipe_down setDirection:UISwipeGestureRecognizerDirectionDown];
}

-(void) onEnter
{
    [super onEnter];
    id glview = [[CCDirector sharedDirector] openGLView];
    [glview addGestureRecognizer:swipe_left];
    [glview addGestureRecognizer:swipe_right];
    [glview addGestureRecognizer:swipe_up];
    [glview addGestureRecognizer:swipe_down];
    LuaSetActiveLayer(self);
}

-(void) onExit
{
    [super onExit];
    id glview = [[CCDirector sharedDirector] openGLView];
    [glview removeGestureRecognizer:swipe_left];
    [glview removeGestureRecognizer:swipe_right];
    [glview removeGestureRecognizer:swipe_up];
    [glview removeGestureRecognizer:swipe_down];
}

-(IBAction)handleSwipe:(id)sender
{
    UISwipeGestureRecognizerDirection dir = [sender direction];

    switch (dir) {
        case UISwipeGestureRecognizerDirectionRight:
            [self sendSwipeToLua:"right"];
            break;
        case UISwipeGestureRecognizerDirectionLeft:
            [self sendSwipeToLua:"left"];
            break;
        case UISwipeGestureRecognizerDirectionDown:
            [self sendSwipeToLua:"down"];
            break;
        case UISwipeGestureRecognizerDirectionUp:
            [self sendSwipeToLua:"up"];
            break;
    }
}

-(void) sendSwipeToLua: (char*) direction
{
    lua_State *lua = [[LuaManager sharedManager] getState];
    lua_getglobal(lua, "_swipe");
    lua_pushstring(lua, direction);
    lua_call(lua, 1, 0);
}

///////////////////////////////////////////////////
// Drawing stuff
///////////////////////////////////////////////////

-(void) draw
{
    glPushMatrix();
    lua_State *lua = [[LuaManager sharedManager] getState];
    lua_getglobal(lua, "_draw");
    lua_call(lua, 0, 0);
    glPopMatrix();
}

///////////////////////////////////////////////////
// Update stuff
///////////////////////////////////////////////////

-(void) callUpdate: (ccTime) delta
{
    lua_State *lua = [[LuaManager sharedManager] getState];
    lua_getglobal(lua, "_update");
    lua_pushnumber(lua, delta);
    lua_call(lua, 1, 0);
}

@end
