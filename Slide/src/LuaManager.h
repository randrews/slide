//
//  LuaManager.h
//  RossLove
//
//  Created by Ross Andrews on 3/16/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

@interface LuaManager : NSObject
{
    @private
    lua_State *lua;
}

+(LuaManager*) sharedManager;
-(BOOL) runLuaCode: (const char*) code;
-(void) runFile: (NSString*) file;
-(void) logLuaError;
-(lua_State*) getState;
@end
