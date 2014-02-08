//
//  GameOverScene.m
//  Stroids
//
//  Created by Brian Wagner on 2/6/14.
//  Copyright (c) 2014 brianwagner. All rights reserved.
//

#import "GameOverScene.h"
#import "MyScene.h"

@implementation GameOverScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        NSString *gameOverMessage;
        gameOverMessage = @"Game Over!";
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = gameOverMessage;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
        
        NSString *retryMessage;
        retryMessage = @"Play Again";
        SKLabelNode *retryButton = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        retryButton.text = retryMessage;
        retryButton.fontColor = [SKColor blackColor];
        retryButton.position = CGPointMake(self.size.width/2, 50);
        retryButton.name = @"retry";
        [self addChild:retryButton];
        
    }
    
    return self;
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        
        if ([node.name isEqualToString:@"retry"]) {
            
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            MyScene *gameScene = [MyScene sceneWithSize:self.view.bounds.size];
            gameScene.scaleMode = SKSceneScaleModeAspectFill;
            [self.view presentScene:gameScene transition:reveal];
            
        }
        
    }
    
}

@end
