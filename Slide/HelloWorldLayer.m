#import "HelloWorldLayer.h"

CCSprite *bot;
float vel = 128.0;
UISwipeGestureRecognizer *swipe_right;

@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init])) {
		bot = [CCSprite spriteWithFile:@"slide.png" rect:CGRectMake(0, 0, 31.5, 45.5)];
        bot.position = CGPointMake(100, 50);
        [self addChild:bot];
                
        swipe_right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        [swipe_right setDirection:UISwipeGestureRecognizerDirectionRight];
        
        [self schedule:@selector(moveSprite:)];

        //[self setIsTouchEnabled: YES];
	}
	return self;
}

-(void) onEnter
{
    [super onEnter];
    [[[CCDirector sharedDirector] openGLView] addGestureRecognizer:swipe_right];
}

-(void) onExit
{
    [super onExit];
[[[CCDirector sharedDirector] openGLView] removeGestureRecognizer:swipe_right];
}

-(void) swipe: (id) sender
{
    NSLog(@"Swipe");
}

-(void) draw
{
    // closed purble poly
	glColor4ub(255, 0, 255, 255);
	glLineWidth(2);
    
	CGPoint vertices2[] = { ccp(30,200), ccp(130,200), ccp(130,100), ccp(30, 100) };
	ccDrawPolyWithMode( vertices2, 4, YES, GL_TRIANGLE_FAN);
}

-(void) moveSprite: (ccTime) dt
{
    CGPoint pos = [bot position];
    if ((pos.x <= 50 && vel < 0) ||
        (pos.x >= 150 && vel > 0)) vel *= -1;
    [bot setPosition:CGPointMake(pos.x + dt * vel, pos.y)];
}

- (void) dealloc
{
    [swipe_right release];
    swipe_right = nil;
	[super dealloc];
}
@end
