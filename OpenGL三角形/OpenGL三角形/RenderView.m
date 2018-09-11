//
//  RenderView.m
//  OpenGL三角形
//
//  Created by zkzk on 2018/9/11.
//  Copyright © 2018年 1707002. All rights reserved.
//



#import "RenderView.h"

// 引入版本
#import <OpenGLES/ES2/gl.h>

@interface RenderView()
{
    GLuint _renderBuffer;
    GLuint _frameBuffer;
}

@property (nonatomic, strong) CAEAGLLayer *eaglLayer;

@property (nonatomic, strong) EAGLContext *eaglContext;

@end

@implementation RenderView
+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initEveryThing];
    }
    return self;
}

- (void)initEveryThing{
    [self initEaglLayer];
    [self initEaglContext];
    [self deleteBuffer];
    [self initRenderBuffer];
    [self initFrameBuffer];
}

- (void)initEaglLayer{
    self.eaglLayer = (CAEAGLLayer*)self.layer;
    [self setContentScaleFactor:[UIScreen mainScreen].scale];
    self.eaglLayer.opaque = YES;
    self.eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,nil];
}

- (void)initEaglContext{
    EAGLContext* context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!context) {
        NSLog(@"create context is failed ");
        return;
    }
    self.eaglContext = context;
    if (![EAGLContext setCurrentContext:self.eaglContext]) {
        NSLog(@"set context is failed ");
    }
}

- (void)initRenderBuffer{
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    /* Attaches an EAGLDrawable as storage for the OpenGL ES renderbuffer object bound to <target> */
    // 给opengles rendebuffer 对象关联的目标对象设置一个EAGLDrawable 作为存储对象
    // 参数1 绑定的renderbuffer 关联对象 用来管理所有render的数据
    //id<EAGLDrawable> 遵守该协议的任意对象 CAEAGLLayer 就遵守了该协议
    [self.eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eaglLayer];
}

- (void)initFrameBuffer{
    // 创建
    glGenFramebuffers(1, &_frameBuffer);
    //绑定
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    //关联renderbuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
}

- (void)deleteBuffer{
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
}


@end
