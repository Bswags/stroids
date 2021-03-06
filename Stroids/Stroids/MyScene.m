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
static const float OBJECT_VELOCITY = 160.0;

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
NSTimeInterval _lastMissileAdded;

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor whiteColor];
        [self initializeBackground];
        [self addShip];
        // Make self delegate of physics world
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
    }
    return self;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    /* Called when a touch begins */
    for (UITouch *touch in touches) {
        CGPoint touchLoc = [touch locationInNode:self.scene];
        DDLogVerbose(@"Got a touch");
        DDLogVerbose(@"Loc is: %f, %f", touchLoc.x, touchLoc.y);
        
        if (touchLoc.y > ship.position.y) {
            //if (ship.position.y < 300)
            DDLogInfo(@"Triggered moveleft");
                [ship runAction:actionMoveLeft];
            
        } else {
            //if (ship.position.y > 50)
            DDLogInfo(@"Triggered moveright");
                [ship runAction:actionMoveRight];
        }
    }

}

-(void)addShip {
    
    // Initialize spaceship
    SKSpriteNode *ship = [SKSpriteNode new];
    ship = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship.png"];
    [ship setScale:0.25];
    
    // Add the fizzicks
    ship.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ship.size];
    ship.physicsBody.categoryBitMask = shipCategory;
    ship.physicsBody.dynamic = YES;
    ship.physicsBody.contactTestBitMask = obstacleCategory;
    ship.physicsBody.collisionBitMask = 0;
    ship.physicsBody.usesPreciseCollisionDetection = YES;
    ship.name = @"ship";
    ship.position = CGPointMake(100, 100);
    
    // Add ship to scene
    [self addChild:ship];
    
    // Create actions
    actionMoveLeft = [SKAction moveByX:-30 y:0 duration:0.2];
    actionMoveRight = [SKAction moveByX:30 y:0 duration:0.2];
    
}

-(void)addMissile {
    
    // Initialize missile
    SKSpriteNode *missile;
    missile = [SKSpriteNode spriteNodeWithImageNamed:@"missile.png"];
    [missile setScale:0.15];
    missile.zRotation = M_PI / 2;
    
    // Add physics
    missile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:missile.size];
    missile.physicsBody.categoryBitMask = obstacleCategory;
    missile.physicsBody.dynamic = YES;
    missile.physicsBody.contactTestBitMask = shipCategory;
    missile.physicsBody.collisionBitMask = 0;
    missile.physicsBody.usesPreciseCollisionDetection = YES;
    missile.name = @"missile";
    
    // Select random x position for missile
    int r = arc4random() % lrintf(self.frame.size.width);
    missile.position = CGPointMake(r, self.frame.size.height + 20);
    [self addChild:missile];
    
}

-(void)moveObstacle {
    
    NSArray *nodes = self.children;
    
    for (SKNode *node in nodes) {
        if ([node.name isEqual:@"missile"]) {
            SKSpriteNode *obst = (SKSpriteNode *)node;
            CGPoint obstVelocity = CGPointMake(0, -OBJECT_VELOCITY);
            CGPoint amountToMove = CGPointScale(obstVelocity, _dt);
            
            obst.position = CGPointAdd(obst.position, amountToMove);
            if (obst.position.y < -100)
                [obst removeFromParent];
        }
    }
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

-(void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ( (firstBody.categoryBitMask & shipCategory) != 0 &&
            (secondBody.categoryBitMask & obstacleCategory) != 0 )
        [ship removeFromParent];
    
}

-(void)update:(CFTimeInterval)currentTime {
    
    /* Called before each frame is rendered */
    
    if (_lastUpdateTime)
        _dt = currentTime - _lastUpdateTime;
    else
        _dt = 0;
    
    _lastUpdateTime = currentTime;
    
    if (currentTime - _lastMissileAdded > 1) {
        _lastMissileAdded = currentTime;
        [self addMissile];
    }
    
    [self moveBackground];
    [self moveObstacle];
    
}

@end
