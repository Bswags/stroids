//
//  MyScene.m
//  Stroids
//
//  Created by Brian Wagner on 2/6/14.
//  Copyright (c) 2014 brianwagner. All rights reserved.
//

#import "MyScene.h"

static const uint32_t shipCategory = 0x1 << 0;
static const uint32_t obstacleCategory = 0x1 << 1;

static const float BG_VELOCITY = 100.0;
static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}
static inline CGPoint CGPointScale(const CGPoint a, const CGFloat b) {
    return CGPointMake(a.x * b, a.y * b);
}

@implementation MyScene

SKSpriteNode *ship;
SKAction *actionMoveLeft;
SKAction *actionMoveRight;
NSTimeInterval _lastUpdateTime;
NSTimeInterval _dt;
NSTimeInterval _lastMissileTime;

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor whiteColor];
        [self initializeBackground];
        [self addShip];
        // Make self delegate of physics world
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        //self.physicsWorld.contactDelegate = self;
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLoc = [touch locationInNode:self.scene];
    
    if (touchLoc.y > ship.position.y) {
        if (ship.position.y < 300)
            [ship runAction:actionMoveLeft];
    } else {
        if (ship.position.y > 50)
            [ship runAction:actionMoveRight];
    }

}

-(void)addShip {
    // Initialize spaceship
    SKSpriteNode *ship = [SKSpriteNode new];
    ship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship.png"];
    [ship setScale:0.25];
    //ship.zRotation = -M_PI / 2;
    
    // Add the fizzicks
    ship.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ship.size];
    ship.physicsBody.categoryBitMask = shipCategory;
    ship.physicsBody.dynamic = YES;
    ship.physicsBody.contactTestBitMask = obstacleCategory;
    ship.physicsBody.collisionBitMask = 0;
    ship.name = @"ship";
    ship.position = CGPointMake(160, 120);
    
    // Add ship to scene
    [self addChild:ship];
    
    // Create actions
    actionMoveLeft = [SKAction moveByX:0 y:30 duration:0.2];
    actionMoveRight = [SKAction moveByX:0 y:-30 duration:0.2];
}

-(void)initializeBackground {
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
        bg.position = CGPointMake(0, i * bg.size.height);
        bg.anchorPoint = CGPointZero;
        bg.name = @"bg";
        [self addChild:bg];
    }
}

-(void)moveBackground {
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop) {
        SKSpriteNode *bg = (SKSpriteNode *)node;
        CGPoint bgVelocity = CGPointMake(0, -BG_VELOCITY);
        CGPoint amountToMove = CGPointScale(bgVelocity, _dt);
        bg.position = CGPointAdd(bg.position, amountToMove);
        
        // If the bg node is off the screen, place it at the top
        if (bg.position.y <= -bg.size.height)
            bg.position = CGPointMake(bg.position.x, bg.position.y + bg.size.height*2);
    }];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (_lastUpdateTime)
        _dt = currentTime - _lastUpdateTime;
    else
        _dt = 0;
    _lastUpdateTime = currentTime;
    
    [self moveBackground];
}

@end
