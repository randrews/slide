//
//  LuaManager.m
//  RossLove
//
//  Created by Ross Andrews on 3/16/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "LuaManager.h"
#include "lua_graphics.h"

LuaManager *_instance;
int lm_load_resource(lua_State*);

static const luaL_Reg LM_FNS[] = {
    {"load_resource", lm_load_resource},
    {NULL, NULL}
};

@implementation LuaManager

-(id) init
{
    self = [super init];
    if (self) {
        lua = luaL_newstate();
        luaL_openlibs(lua);
        luaL_openlib(lua, "host", LM_FNS, 0);
                
        lua_pushstring(lua, "manager");
        lua_pushlightuserdata(lua, (void*)self);
        lua_settable(lua, LUA_REGISTRYINDEX);

        [self runLuaCode:"table.insert(package.loaders, host.load_resource)"];
        openGraphicsLibrary(lua);
    }

    return self;
}

+(LuaManager*) sharedManager
{
    @synchronized([LuaManager class])
    {
        if (!_instance)
            _instance = [[LuaManager alloc] init];
        return _instance;
    }
    return nil;
}

-(lua_State*) getState {
    return lua;
}

-(void) runFile: (NSString*) file {
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"lua"];
	NSString *code = [NSString stringWithFormat: @"dofile(\"%@\")", path];
	[self runLuaCode: [code UTF8String]];	
}

-(BOOL) loadFile: (NSString*) file {
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"lua"];
	NSString *code = [NSString stringWithFormat: @"dofile(\"%@\")", path];
	const char* c_code = [code UTF8String];
    int lua_error = luaL_loadbuffer(lua, c_code, strlen(c_code), "line");
	if(lua_error){ [self logLuaError]; }
	return !lua_error;
}

-(BOOL) runLuaCode: (const char*) code {
	int lua_error = luaL_loadbuffer(lua, code, strlen(code), "line") || lua_pcall(lua, 0, 0, 0);
	
	if(lua_error){ [self logLuaError]; }
	return !lua_error;
}

-(void) logLuaError {
	NSString *msg = [NSString stringWithFormat: @"%s\n", lua_tostring(lua, -1)];
	NSLog(@"%@", msg);
	lua_pop(lua, 1);
}

-(void) pushDictionary: (NSDictionary*) dict {
    lua_newtable(lua);
    
    if(!dict) {return;}
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop){
        const char *key_str = [key UTF8String];
        lua_pushstring(lua, key_str);
        
        if([value isKindOfClass:[NSNumber class]]){
            lua_pushnumber(lua, [value doubleValue]);
        } else {
            lua_pushstring(lua, [value UTF8String]);
        }
        
        lua_settable(lua, -3);
    }];
}

-(NSDictionary*) dictFromIndex: (int) index {
    if(!lua_istable(lua, index)){
        luaL_error(lua, "Expected a table");
    }
    
    NSDictionary *dict = [NSMutableDictionary dictionary];
    
    lua_pushnil(lua);
    while(lua_next(lua, index)){
        if(!lua_isstring(lua, -2)){
            luaL_error(lua, "Sorry, only string keys are supported yet");
        }
        
        NSString *key = [NSString stringWithUTF8String:luaL_checkstring(lua, -2)];
        
        if(lua_isstring(lua, -1)) {
            [dict setValue:[NSString stringWithUTF8String:luaL_checkstring(lua, -1)]
                    forKey:key];
        } else if(lua_isnumber(lua, -1)) {
            [dict setValue:[NSNumber numberWithDouble:luaL_checknumber(lua, -1)]
                    forKey:key];
        }
        
        lua_pop(lua, 1);
    }
    
    return dict;
}
@end

int lm_load_resource(lua_State *lua){
    lua_pushstring(lua, "manager");
    lua_gettable(lua, LUA_REGISTRYINDEX);
    LuaManager *manager = (LuaManager*)lua_touserdata(lua, -1);
    const char *name = luaL_checkstring(lua, 1);
    if([manager loadFile:[NSString stringWithCString:name encoding:NSASCIIStringEncoding]])
        ;
    else {
        lua_pushnil(lua);
    }
    return 1;
}

