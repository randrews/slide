//
//  lua_graphics.h
//  LuaWrapper
//
//  Created by Ross Andrews on 4/1/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#ifndef LuaWrapper_lua_graphics_h
#define LuaWrapper_lua_graphics_h

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "cocos2d.h"

typedef enum NodeType { SPRITE, PARTICLE } NodeType;

typedef struct NodeWrapper {
    CCSprite *sprite;
    CCParticleSystemQuad *particle;
    NodeType type;
} NodeWrapper;

void openGraphicsLibrary(lua_State*);
void LuaSetScreenSize(float w, float h);
CCNode *LuaSetActiveLayer(CCNode*);

#endif
