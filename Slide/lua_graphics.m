//
//  lua_graphics.c
//  LuaWrapper
//
//  Created by Ross Andrews on 4/1/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#include "lua_graphics.h"

int gfx_push(lua_State *lua);
int gfx_pop(lua_State *lua);
int gfx_translate(lua_State *lua);
int gfx_rotate(lua_State *lua);
int gfx_scale(lua_State *lua);
int gfx_setColor(lua_State *lua);
int gfx_rectangle(lua_State *lua);
int gfx_circle(lua_State *lua);
int gfx_newSprite(lua_State *lua);
int gfx_newParticle(lua_State *lua);
int gfx_size(lua_State *lua);

float screen_w, screen_h;
CCNode *active_node;

luaL_Reg GFX_FNS[] = {
    {"push", gfx_push},
    {"pop", gfx_pop},
    {"translate", gfx_translate},
    {"rotate", gfx_rotate},
    {"scale", gfx_scale},
    {"setColor", gfx_setColor},
    {"rectangle", gfx_rectangle},
    {"circle", gfx_circle},
    {"sprite", gfx_newSprite},
    {"particle", gfx_newParticle},
    {"size", gfx_size},
    {NULL, NULL}
};

/*********************************************/

int nodeToString(lua_State*);
int gcNode(lua_State*);
int node_position(lua_State*);
int addNode(lua_State*);
int removeNode(lua_State*);

luaL_Reg NodeMethods[] = {
    {"__tostring", nodeToString},
    {"__gc", gcNode},
    {"position", node_position},
    {"add", addNode},
    {"remove", removeNode},
    {NULL, NULL}
};

/*********************************************/

void openGraphicsLibrary(lua_State *lua){
    luaL_openlib(lua, "graphics", GFX_FNS, 0);

    luaL_newmetatable(lua, "Graphics.node");
    lua_pushstring(lua, "__index");
    lua_pushvalue(lua, -2);  /* pushes the metatable */
    lua_settable(lua, -3);  /* metatable.__index = metatable */
    luaL_openlib(lua, NULL, NodeMethods, 0);
}

void LuaSetScreenSize(float w, float h){
    screen_w = w; screen_h = h;
}

CCNode* LuaSetActiveLayer(CCNode *new_active_layer){
    CCNode *old_active = active_node;
    active_node = new_active_layer;
    return old_active;
}

/*********************************************/

int gfx_size(lua_State *lua){
    lua_pushnumber(lua, screen_w);
    lua_pushnumber(lua, screen_h);
    return 2;
}

int gfx_push(lua_State *lua){
    glPushMatrix();
    return 0;
}

int gfx_pop(lua_State *lua){
    glPopMatrix();
    return 0;
}

int gfx_translate(lua_State *lua){
    float x = luaL_checknumber(lua, 1);
    float y = luaL_checknumber(lua, 2);
    glTranslatef(x, y, 0.0f);
    return 0;
}

int gfx_rotate(lua_State *lua){
    float deg = luaL_checknumber(lua, 1);
    glRotatef(deg, 0, 0, 1);
    return 0;
}

int gfx_scale(lua_State *lua){
    float x = luaL_checknumber(lua, 1);
    float y = luaL_checknumber(lua, 2);
    glScalef(x, y, 1);
    return 0;
}

int gfx_setColor(lua_State *lua){
    float r = luaL_checknumber(lua, 1);
    float g = luaL_checknumber(lua, 2);
    float b = luaL_checknumber(lua, 3);
    float a = 255;
    if(lua_gettop(lua) > 3)
        a = luaL_checknumber(lua, 4);

    glColor4ub(r, g, b, a);
    return 0;
}

int gfx_rectangle(lua_State *lua){
    const char *drawmode = luaL_checkstring(lua, 1);
    float x = luaL_checknumber(lua, 2);
    float y = luaL_checknumber(lua, 3);
    float w = luaL_checknumber(lua, 4);
    float h = luaL_checknumber(lua, 5);

	glLineWidth(1);
    
	CGPoint vertices[] = { ccp(x,y), ccp(x, y+h), ccp(x+w, y+h), ccp(x+w, y) };

    if(!strcmp(drawmode, "fill"))
        ccDrawPolyWithMode( vertices, 4, YES, GL_TRIANGLE_FAN);
    else if(!strcmp(drawmode, "line"))
        ccDrawPoly( vertices, 4, YES);
    return 0;    
}

int gfx_circle(lua_State *lua){
    NSLog(@"Not implemented yet");
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    const char *drawmode = luaL_checkstring(lua, 1);
//    float x = luaL_checknumber(lua, 2);
//    float y = luaL_checknumber(lua, 3);
//    float w = luaL_checknumber(lua, 4);
//    float h = w;
//    
//    if (lua_gettop(lua) > 4) {
//        h = luaL_checknumber(lua, 5);
//    }
//    
//    CGRect rect = CGRectMake(x-w, y-h, w*2, h*2);
//    
//    if(!strcmp(drawmode, "fill"))
//        CGContextFillEllipseInRect(ctx, rect);
//    else if(!strcmp(drawmode, "line"))
//        CGContextStrokeEllipseInRect(ctx, rect);
    return 0;    
}

/*******************************************************/

int gfx_newSprite(lua_State *lua){    
    CCSprite *sprite;

    const char *fname = luaL_checkstring(lua, 1);
    NSString *ns_fname = [NSString stringWithUTF8String:fname];
    
    float pos_x = luaL_checknumber(lua, 2);
    float pos_y = luaL_checknumber(lua, 3);
    
    if (lua_gettop(lua) > 3) {
        float x = luaL_checknumber(lua, 4);
        float y = luaL_checknumber(lua, 5);
        float w = luaL_checknumber(lua, 6);
        float h = luaL_checknumber(lua, 7);
        sprite = [[CCSprite alloc] initWithFile:ns_fname rect:CGRectMake(x, y, w, h)];
    } else {
        sprite = [[CCSprite alloc] initWithFile:ns_fname];
    }

    [sprite setPosition:ccp(pos_x, pos_y)];
    
    NodeWrapper *sw = (NodeWrapper*)lua_newuserdata(lua, sizeof(NodeWrapper));
    luaL_getmetatable(lua, "Graphics.node");
    lua_setmetatable(lua, -2);
    sw->sprite = sprite;
    sw->type = SPRITE;
    return 1;
}

int gfx_newParticle(lua_State *lua){    
    CCParticleSystemQuad *part;
    
    const char *fname = luaL_checkstring(lua, 1);
    NSString *ns_fname = [NSString stringWithUTF8String:fname];
    
    float pos_x = luaL_checknumber(lua, 2);
    float pos_y = luaL_checknumber(lua, 3);
    
    part = [[CCParticleSystemQuad alloc] initWithFile:ns_fname];
    
    [part setPosition:ccp(pos_x, pos_y)];
    
    NodeWrapper *nw = (NodeWrapper*)lua_newuserdata(lua, sizeof(NodeWrapper));
    luaL_getmetatable(lua, "Graphics.node");
    lua_setmetatable(lua, -2);
    nw->particle = part;
    nw->type = PARTICLE;
    return 1;
}

NodeWrapper *checknode (lua_State *lua, int n) {
    void *ud = luaL_checkudata(lua, n, "Graphics.node");
    luaL_argcheck(lua, ud != NULL, n, "`node' expected");
    return (NodeWrapper*)ud;
}

int nodeToString(lua_State *lua){
    NodeWrapper *n = checknode(lua, 1);
    switch (n->type) {
        case SPRITE:
            lua_pushstring(lua, "<sprite>");
            break;
        case PARTICLE:
            lua_pushstring(lua, "<particle>");
            break;            
        default:
            lua_pushstring(lua, "<node>");
            break;
    }
    return 1;
}

CCNode *nodeInWrapper(NodeWrapper *node){
    switch (node->type) {
        case SPRITE:
            return node->sprite;
        case PARTICLE:
            return node->particle;
        default:
            return 0;
    }
}

void removeFromParent(NodeWrapper *nw){
    CCNode *n = nodeInWrapper(nw);

    if ([n parent]) {
        [[n parent] removeChild:n cleanup:YES];
    }    
}

int removeNode(lua_State *lua){
    NodeWrapper *nw = checknode(lua, 1);
    removeFromParent(nw);
    return 0;
}

int addNode(lua_State *lua){
    NodeWrapper *nw = checknode(lua, 1);
    [active_node addChild:nodeInWrapper(nw)];
    return 0;
}

int gcNode(lua_State *lua){
    NodeWrapper *nw = checknode(lua, 1);
    removeFromParent(nw);
    CCNode *n = nodeInWrapper(nw);
    [n release];
    return 0;
}

int node_position(lua_State *lua){
    NodeWrapper *node = checknode(lua, 1);
    CCNode *n = nodeInWrapper(node);
    if (lua_gettop(lua) > 1) {
        float x = luaL_checknumber(lua, 2);
        float y = luaL_checknumber(lua, 3);
        [n setPosition:ccp(x,y)];
        return 0;
    } else {
        CGPoint pt = [n position];
        lua_pushnumber(lua, pt.x);
        lua_pushnumber(lua, pt.y);
        return 2;
    }
}
